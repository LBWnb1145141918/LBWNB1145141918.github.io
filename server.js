const express = require('express');
const session = require('express-session');
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
// Vercel Serverless 环境使用内存数据库，避免文件 IO 延迟
const isVercel = process.env.VERCEL === '1';
const dbPath = isVercel ? ':memory:' : (process.env.DATABASE_PATH || './database.sqlite');
const db = new sqlite3.Database(dbPath);

// 创建访客表
db.serialize(() => {
  db.run(`
    CREATE TABLE IF NOT EXISTS guest_users (
      guestId TEXT PRIMARY KEY,
      displayName TEXT,
      createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
      lastActive DATETIME DEFAULT CURRENT_TIMESTAMP
    )
  `);

  if (!isVercel) {
    console.log('数据库初始化完成');
  }
});

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

// 静态文件服务
app.use(express.static(path.join(__dirname)));

// ==================== 路由 ====================

// 检查登录状态
app.get('/api/auth/status', (req, res) => {
  if (req.session.guestId) {
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

// 访客登录
app.post('/api/auth/guest', express.json(), (req, res) => {
  console.log('=== 收到访客登录请求 ===');
  console.log('请求体:', req.body);
  
  const guestName = req.body.guestName || `访客_${Math.random().toString(36).substr(2, 9)}`;
  const guestId = 'guest_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9);

  console.log('生成的访客 ID:', guestId);
  console.log('访客昵称:', guestName);

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

    console.log('访客登录成功，Session 已设置');

    res.json({
      success: true,
      guestId: guestId,
      displayName: guestName
    });
  });
});

// 退出登录
app.post('/api/auth/logout', (req, res) => {
  req.session.destroy((err) => {
    if (err) {
      return res.status(500).json({ error: '清除会话失败' });
    }
    res.json({ success: true });
  });
});

// 获取用户信息
app.get('/api/user/info', (req, res) => {
  if (!req.session.guestId) {
    return res.status(401).json({ error: '未登录' });
  }

  db.get('SELECT * FROM guest_users WHERE guestId = ?', [req.session.guestId], (err, user) => {
    if (err) {
      return res.status(500).json({ error: '查询失败' });
    }
    res.json(user);
  });
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
