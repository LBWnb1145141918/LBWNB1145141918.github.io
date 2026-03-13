const express = require('express');
const session = require('express-session');
const passport = require('passport');
const SteamStrategy = require('passport-steam').Strategy;
const sqlite3 = require('sqlite3').verbose();
const cors = require('cors');
const path = require('path');

// 加载环境变量（Vercel 会自动处理）
try {
  require('dotenv').config();
} catch (e) {
  // Vercel 环境不需要 dotenv
}

const app = express();
const PORT = process.env.PORT || 3000;

// ==================== CORS 配置 ====================
app.use(cors({
  origin: ['http://localhost:3000', 'https://lbwnb1145141918.github.io'],
  credentials: true
}));

// ==================== 数据库初始化 ====================
const db = new sqlite3.Database(process.env.DATABASE_PATH || './database.sqlite');

// 创建用户表
db.serialize(() => {
  db.run(`
    CREATE TABLE IF NOT EXISTS users (
      steamId TEXT PRIMARY KEY,
      username TEXT,
      displayName TEXT,
      avatar TEXT,
      profileUrl TEXT,
      firstLogin DATETIME DEFAULT CURRENT_TIMESTAMP,
      lastLogin DATETIME DEFAULT CURRENT_TIMESTAMP,
      loginCount INTEGER DEFAULT 1,
      isGuest INTEGER DEFAULT 0
    )
  `);

  db.run(`
    CREATE TABLE IF NOT EXISTS guest_users (
      guestId TEXT PRIMARY KEY,
      displayName TEXT,
      createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
      lastActive DATETIME DEFAULT CURRENT_TIMESTAMP
    )
  `);

  console.log('数据库初始化完成');
});

// ==================== Passport 配置 ====================
passport.serializeUser((user, done) => {
  done(null, user);
});

passport.deserializeUser((user, done) => {
  done(null, user);
});

// Steam OpenID 策略
// Vercel 环境使用生产域名，本地环境使用 localhost
const BASE_URL = process.env.VERCEL === '1' 
  ? 'https://scp-terminal-backend.vercel.app' 
  : `http://localhost:${PORT}`;

passport.use(new SteamStrategy({
  returnURL: `${BASE_URL}/auth/steam/return`,
  realm: BASE_URL,
  apiKey: process.env.STEAM_API_KEY,
  profile: true
}, function(identifier, profile, done) {
  const userData = {
    steamId: profile.id,
    username: profile.username,
    displayName: profile.displayName,
    avatar: profile.photos[2]?.value || profile.photos[1]?.value || profile.photos[0]?.value,
    profileUrl: profile.profileUrl
  };

  const sql = `INSERT INTO users (steamId, username, displayName, avatar, profileUrl, lastLogin, loginCount)
    VALUES (?, ?, ?, ?, ?, CURRENT_TIMESTAMP, COALESCE((SELECT loginCount FROM users WHERE steamId = ?), 0) + 1)
    ON CONFLICT(steamId) DO UPDATE SET
      displayName = excluded.displayName,
      avatar = excluded.avatar,
      profileUrl = excluded.profileUrl,
      lastLogin = CURRENT_TIMESTAMP,
      loginCount = loginCount + 1`;
  
  db.run(sql, [
    userData.steamId,
    userData.username,
    userData.displayName,
    userData.avatar,
    userData.profileUrl,
    userData.steamId
  ], function(err) {
    if (err) return done(err);
    return done(null, userData);
  });
}));

// ==================== 中间件 ====================
app.use(session({
  secret: process.env.SESSION_SECRET || 'scp-foundation-secret-key',
  resave: true,
  saveUninitialized: true,
  cookie: { 
    secure: process.env.NODE_ENV === 'production',
    maxAge: 7 * 24 * 60 * 60 * 1000
  }
}));

app.use(passport.initialize());
app.use(passport.session());

// 静态文件服务
app.use(express.static(path.join(__dirname)));

// ==================== 路由 ====================

// 检查登录状态
app.get('/api/auth/status', (req, res) => {
  if (req.isAuthenticated()) {
    res.json({
      loggedIn: true,
      user: req.user,
      isGuest: false
    });
  } else if (req.session.guestId) {
    res.json({
      loggedIn: true,
      user: {
        displayName: req.session.guestName || '访客',
        avatar: null
      },
      isGuest: true,
      guestId: req.session.guestId
    });
  } else {
    res.json({
      loggedIn: false
    });
  }
});

// Steam 登录
app.get('/api/auth/steam', passport.authenticate('steam'));

// Steam 回调
app.get('/auth/steam/return', passport.authenticate('steam', {
  failureRedirect: '/login'
}), (req, res) => {
  res.redirect('/');
});

// 访客登录
app.post('/api/auth/guest', express.json(), (req, res) => {
  const guestName = req.body.guestName || `访客_${Math.random().toString(36).substr(2, 9)}`;
  const guestId = 'guest_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);

  db.run(`
    INSERT INTO guest_users (guestId, displayName)
    VALUES (?, ?)
  `, [guestId, guestName], (err) => {
    if (err) {
      console.error('保存访客失败:', err);
      return res.status(500).json({ error: '保存访客失败' });
    }

    req.session.guestId = guestId;
    req.session.guestName = guestName;

    res.json({
      success: true,
      guestId: guestId,
      displayName: guestName
    });
  });
});

// 退出登录
app.post('/api/auth/logout', (req, res) => {
  req.logout((err) => {
    if (err) {
      return res.status(500).json({ error: '退出失败' });
    }
    req.session.destroy((err) => {
      if (err) {
        return res.status(500).json({ error: '清除会话失败' });
      }
      res.json({ success: true });
    });
  });
});

// 获取用户信息
app.get('/api/user/info', (req, res) => {
  if (!req.isAuthenticated() && !req.session.guestId) {
    return res.status(401).json({ error: '未登录' });
  }

  if (req.isAuthenticated()) {
    db.get('SELECT * FROM users WHERE steamId = ?', [req.user.steamId], (err, user) => {
      if (err) {
        return res.status(500).json({ error: '查询失败' });
      }
      res.json(user);
    });
  } else {
    db.get('SELECT * FROM guest_users WHERE guestId = ?', [req.session.guestId], (err, user) => {
      if (err) {
        return res.status(500).json({ error: '查询失败' });
      }
      res.json(user);
    });
  }
});

// 更新访客活跃时间
app.post('/api/guest/active', express.json(), (req, res) => {
  if (!req.session.guestId) {
    return res.status(401).json({ error: '未登录' });
  }

  db.run(`
    UPDATE guest_users SET lastActive = CURRENT_TIMESTAMP
    WHERE guestId = ?
  `, [req.session.guestId], (err) => {
    if (err) {
      return res.status(500).json({ error: '更新失败' });
    }
    res.json({ success: true });
  });
});

// ==================== Vercel Serverless 导出 ====================
// Vercel 使用 module.exports 导出 app
if (process.env.VERCEL === '1' || process.env.NODE_ENV === 'production') {
  module.exports = app;
}

// ==================== 本地环境启动服务器 ====================
// 仅在本地开发环境启动服务器
if (process.env.VERCEL !== '1' && process.env.NODE_ENV !== 'production') {
  app.listen(PORT, () => {
    console.log(`
  ╔════════════════════════════════════════════════════════╗
  ║                                                        ║
  ║   SCP Foundation Terminal Backend                      ║
  ║   Site-119 Authentication Server                       ║
  ║                                                        ║
     服务器运行在：http://localhost:${PORT}                  ║
  ║   数据库：${process.env.DATABASE_PATH || './database.sqlite'}           ║
                                                          ║
     按 Ctrl+C 停止服务器                                  ║
  ║                                                        ║
  ════════════════════════════════════════════════════════╝
  `);
  });

  // 优雅关闭
  process.on('SIGINT', () => {
    console.log('\n正在关闭服务器...');
    db.close();
    process.exit(0);
  });
}
