# 🌐 在线聊天和投稿功能部署指南

## ✅ 功能说明

您的网站现在已升级为**多人在线实时互动**模式！

### 🎯 新增功能：

1. **在线聊天室**
   - ✅ WebSocket 实时通信
   - ✅ 所有用户消息实时同步
   - ✅ 消息持久化存储（刷新页面仍保留）
   - ✅ 支持表情包

2. **在线投稿系统**
   - ✅ 投稿数据实时同步到服务器
   - ✅ 所有用户可见投稿内容
   - ✅ 支持文字和图片投稿

---

## 🚀 本地开发环境运行

### 1. 安装依赖
```bash
npm install
```

### 2. 启动服务器
```bash
npm start
```

服务器启动后会显示：
```
╔════════════════════════════════════════════════════════╗
║   SCP Foundation Terminal Backend                      ║
║   Site-119 Authentication Server                       ║
║   with WebSocket Support                               ║
║                                                        ║
   服务器运行在：http://localhost:3000
║   数据库：./database.sqlite
║   WebSocket: ws://localhost:3000
╚════════════════════════════════════════════════════════╝
```

### 3. 访问网站
打开浏览器访问：`http://localhost:3000`

---

## 🌍 生产环境部署（Railway）

### 部署步骤：

1. **安装 Railway CLI**
```bash
npm install -g @railway/cli
```

2. **登录 Railway**
```bash
railway login
```

3. **初始化项目**
```bash
railway init
```

4. **添加环境变量**
```bash
railway variables set SESSION_SECRET=your-secret-key-here
railway variables set NODE_ENV=production
```

5. **部署**
```bash
railway up
```

6. **分配域名**
```bash
railway domain
```

---

## 📊 数据库说明

### 数据表结构：

1. **guest_users** - 访客用户表
   - `guestId`: 访客 ID（主键）
   - `displayName`: 显示昵称
   - `createdAt`: 创建时间
   - `lastActive`: 最后活跃时间

2. **chat_messages** - 聊天消息表
   - `id`: 消息 ID（自增）
   - `userId`: 用户 ID
   - `username`: 用户名
   - `message`: 消息内容
   - `emoji`: 表情包
   - `createdAt`: 时间戳

3. **submissions** - 投稿表
   - `id`: 投稿 ID（自增）
   - `title`: 标题
   - `author`: 作者
   - `type`: 类型（text/image）
   - `content`: 内容
   - `image`: 图片 Base64
   - `status`: 状态（pending/approved/rejected）
   - `createdAt`: 时间戳

---

## 🔧 API 接口文档

### 聊天相关

#### 获取聊天历史
```
GET /api/chat/history
```

#### 发送消息
```
POST /api/chat/send
Content-Type: application/json

{
  "userId": "user123",
  "username": "深渊用户",
  "message": "你好！",
  "emoji": "😀"
}
```

### 投稿相关

#### 获取投稿列表
```
GET /api/submissions
```

#### 提交投稿
```
POST /api/submissions
Content-Type: application/json

{
  "title": "我的投稿",
  "author": "深渊用户",
  "type": "text",
  "content": "这是投稿内容..."
}
```

#### 审核投稿（管理员）
```
POST /api/submissions/:id/review
Content-Type: application/json

{
  "status": "approved"  // 或 "rejected"
}
```

#### 删除投稿（管理员）
```
DELETE /api/submissions/:id
```

---

##  WebSocket 通信

### 连接 WebSocket
```javascript
const ws = new WebSocket('ws://localhost:3000');

ws.onopen = () => {
    console.log('WebSocket 连接成功');
};

ws.onmessage = (event) => {
    const data = JSON.parse(event.data);
    if (data.type === 'chat') {
        // 接收聊天消息
        addChatMessage(data.username, data.message, data.emoji);
    }
};

// 发送消息
ws.send(JSON.stringify({
    type: 'chat',
    userId: 'user123',
    username: '深渊用户',
    message: '你好！',
    emoji: '😀'
}));
```

---

## 🔐 安全说明

1. **CORS 配置**：已配置允许所有来源（生产环境）
2. **会话管理**：使用 express-session 管理用户登录状态
3. **数据验证**：所有输入都经过验证和转义，防止 XSS 攻击
4. **数据库**：SQLite 持久化存储，数据不会丢失

---

## 📝 注意事项

### 本地开发
- ✅ 数据库文件：`./database.sqlite`
- ✅ WebSocket 地址：`ws://localhost:3000`
- ✅ HTTP 地址：`http://localhost:3000`

### 生产环境
- ⚠️ Railway 使用临时文件系统
- ⚠️ 数据库数据会在重启后丢失
- ⚠️ 建议使用 Railway PostgreSQL 插件

### 迁移到 PostgreSQL（生产环境推荐）
```bash
railway add postgresql
railway variables set DATABASE_URL=<postgresql-connection-string>
```

然后修改 `server.js` 使用 PostgreSQL：
```javascript
const { Client } = require('pg');
const client = new Client({ connectionString: process.env.DATABASE_URL });
await client.connect();
```

---

## 🎉 测试步骤

1. **启动服务器**
   ```bash
   npm start
   ```

2. **打开多个浏览器窗口**
   - 窗口 1：`http://localhost:3000`
   - 窗口 2：`http://localhost:3000`（隐身模式）

3. **测试聊天功能**
   - 在窗口 1 发送消息
   - 窗口 2 应该实时收到消息

4. **测试投稿功能**
   - 在窗口 1 提交投稿
   - 窗口 2 刷新后应该能看到投稿

---

## 🐛 常见问题

### Q: WebSocket 连接失败
**A:** 检查防火墙是否允许 3000 端口，或浏览器是否支持 WebSocket

### Q: 数据丢失
**A:** Railway 使用临时文件系统，重启后数据会丢失。生产环境请使用 PostgreSQL

### Q: CORS 错误
**A:** 检查服务器 CORS 配置，确保允许正确的来源

---

## 📞 技术支持

如有问题，请检查：
1. 服务器日志输出
2. 浏览器控制台错误
3. 网络连接状态

**祝您的深渊社区运营顺利！** 🚀
