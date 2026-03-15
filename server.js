const express = require('express');
const session = require('express-session');
const sqlite3 = require('sqlite3').verbose();
const cors = require('cors');
const path = require('path');
const WebSocket = require('ws');
const http = require('http');

// 加载环境变量（Vercel 会自动处理）
try {
  require('dotenv').config();
} catch (e) {
  // Vercel 环境不需要 dotenv
}

const app = express();
const PORT = process.env.PORT || 3000;

// 创建 HTTP 服务器
const server = http.createServer(app);

// ==================== CORS 配置 ====================
// 允许所有来源（生产环境）
app.use((req, res, next) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  res.header('Access-Control-Allow-Credentials', 'true');
  
  // 处理预检请求
  if (req.method === 'OPTIONS') {
    return res.sendStatus(200);
  }
  next();
});

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

let dbInitialized = false;
let wss = null;

// 创建聊天消息表和投稿表
db.serialize(() => {
  // 聊天消息表
db.run(`
    CREATE TABLE IF NOT EXISTS chat_messages (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      userId TEXT,
      username TEXT,
      message TEXT,
      emoji TEXT,
      createdAt DATETIME DEFAULT CURRENT_TIMESTAMP
    )
  `);
  
  // 投稿表
db.run(`
    CREATE TABLE IF NOT EXISTS submissions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      title TEXT,
      author TEXT,
      type TEXT,
      content TEXT,
      image TEXT,
      status TEXT DEFAULT 'pending',
      createdAt DATETIME DEFAULT CURRENT_TIMESTAMP
    )
  `);
  
  if (!isVercel && !dbInitialized) {
    console.log('聊天和投稿表初始化完成');
    dbInitialized = true;
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

// ==================== WebSocket 服务器 ====================
// 在非 Vercel 环境启动 WebSocket（包括 Railway）
if (process.env.VERCEL !== '1') {
  try {
    wss = new WebSocket.Server({ server });
    
    console.log('WebSocket 服务器已启动');
    
    wss.on('connection', (ws) => {
      console.log('新 WebSocket 连接');
      
      // 发送历史消息
      db.all('SELECT * FROM chat_messages ORDER BY createdAt DESC LIMIT 50', [], (err, rows) => {
        if (!err) {
          ws.send(JSON.stringify({ type: 'history', messages: rows.reverse() }));
        }
      });
      
      ws.on('message', (message) => {
        try {
          const data = JSON.parse(message);
          
          if (data.type === 'chat') {
            // 保存聊天消息
            db.run(`
              INSERT INTO chat_messages (userId, username, message, emoji)
              VALUES (?, ?, ?, ?)
            `, [data.userId || 'anonymous', data.username || '匿名用户', data.message, data.emoji || ''], (err) => {
              if (!err) {
                // 广播给所有客户端
                const newMessage = {
                  type: 'chat',
                  userId: data.userId,
                  username: data.username,
                  message: data.message,
                  emoji: data.emoji,
                  createdAt: new Date().toISOString()
                };
                
                wss.clients.forEach((client) => {
                  if (client !== ws && client.readyState === WebSocket.OPEN) {
                    client.send(JSON.stringify(newMessage));
                  }
                });
              }
            });
          }
        } catch (e) {
          console.error('WebSocket 消息处理错误:', e);
        }
      });
      
      ws.on('close', () => {
        console.log('WebSocket 连接关闭');
      });
    });
    
  } catch (err) {
    console.error('WebSocket 服务器启动失败:', err);
  }
}

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

// ==================== 聊天相关 API ====================

// 获取聊天历史
app.get('/api/chat/history', (req, res) => {
  db.all('SELECT * FROM chat_messages ORDER BY createdAt DESC LIMIT 100', [], (err, rows) => {
    if (err) {
      return res.status(500).json({ error: '查询失败' });
    }
    res.json(rows.reverse());
  });
});

// 发送聊天消息（HTTP 备用方案）
app.post('/api/chat/send', express.json(), (req, res) => {
  const { userId, username, message, emoji } = req.body;
  
  if (!message) {
    return res.status(400).json({ error: '消息不能为空' });
  }
  
  db.run(`
    INSERT INTO chat_messages (userId, username, message, emoji)
    VALUES (?, ?, ?, ?)
  `, [userId || 'anonymous', username || '匿名用户', message, emoji || ''], function(err) {
    if (err) {
      return res.status(500).json({ error: '保存失败' });
    }
    
    // 如果 WebSocket 可用，广播消息
    if (wss) {
      const newMessage = {
        type: 'chat',
        userId,
        username,
        message,
        emoji,
        createdAt: new Date().toISOString()
      };
      
      wss.clients.forEach((client) => {
        if (client.readyState === WebSocket.OPEN) {
          client.send(JSON.stringify(newMessage));
        }
      });
    }
    
    res.json({ success: true, id: this.lastID });
  });
});

// ==================== 投稿相关 API ====================

// 获取投稿列表
app.get('/api/submissions', (req, res) => {
  db.all('SELECT * FROM submissions ORDER BY createdAt DESC', [], (err, rows) => {
    if (err) {
      return res.status(500).json({ error: '查询失败' });
    }
    res.json(rows);
  });
});

// 提交投稿
app.post('/api/submissions', express.json(), (req, res) => {
  const { title, author, type, content, image } = req.body;
  
  if (!title || !content) {
    return res.status(400).json({ error: '标题和内容不能为空' });
  }
  
  db.run(`
    INSERT INTO submissions (title, author, type, content, image, status)
    VALUES (?, ?, ?, ?, ?, 'pending')
  `, [title, author || '匿名', type || 'other', content, image || null], function(err) {
    if (err) {
      return res.status(500).json({ error: '保存失败' });
    }
    
    res.json({ success: true, id: this.lastID });
  });
});

// 审核投稿（管理员）
app.post('/api/submissions/:id/review', express.json(), (req, res) => {
  const { id } = req.params;
  const { status } = req.body; // approved, rejected
  
  if (!['approved', 'rejected'].includes(status)) {
    return res.status(400).json({ error: '无效的状态' });
  }
  
  db.run(`
    UPDATE submissions SET status = ? WHERE id = ?
  `, [status, id], (err) => {
    if (err) {
      return res.status(500).json({ error: '更新失败' });
    }
    res.json({ success: true });
  });
});

// 删除投稿（管理员）
app.delete('/api/submissions/:id', (req, res) => {
  const { id } = req.params;
  
  db.run('DELETE FROM submissions WHERE id = ?', [id], (err) => {
    if (err) {
      return res.status(500).json({ error: '删除失败' });
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
// 在非 Vercel 环境启动服务器（包括 Railway 和本地）
if (process.env.VERCEL !== '1') {
  server.listen(PORT, () => {
    console.log(`
  ╔════════════════════════════════════════════════════════╗
  ║                                                        ║
  ║   SCP Foundation Terminal Backend                      ║
  ║   Site-119 Authentication Server                       ║
  ║   with WebSocket Support                               ║
  ║                                                        ║
     服务器运行在：http://localhost:${PORT}                  ║
  ║   数据库：${process.env.DATABASE_PATH || './database.sqlite'}           ║
  ║   WebSocket: ws://localhost:${PORT}                     ║
                                                          ║
     按 Ctrl+C 停止服务器                                  ║
  ║                                                        ║
  ════════════════════════════════════════════════════════╝
  `);
  });

  // 优雅关闭
  process.on('SIGINT', () => {
    console.log('\n正在关闭服务器...');
    if (wss) {
      wss.close();
    }
    db.close();
    process.exit(0);
  });
}
