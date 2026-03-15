# 🚀 Railway 部署完整指南

## ⚠️ 重要提示

由于网络原因，Railway CLI 可能无法自动安装。请按照以下步骤手动部署。

---

## 📋 方案一：使用 Railway 网页部署（推荐）

### 步骤 1：访问 Railway 官网

打开浏览器访问：
```
https://railway.app
```

### 步骤 2：注册/登录

1. 点击 **"Login"** 或 **"Sign Up"**
2. 选择登录方式：
   - GitHub 账号（推荐）
   - Google 账号
   - 邮箱

### 步骤 3：创建新项目

1. 登录后点击 **"New Project"**
2. 选择 **"Deploy from GitHub repo"**
3. 授权 Railway 访问您的 GitHub
4. 选择您的仓库：`LBWnb1145141918.github.io`

### 步骤 4：配置环境变量

在 Railway 面板中，点击 **"Variables"** 标签页，添加以下变量：

```
SESSION_SECRET = scp-foundation-secret-key-2026
NODE_ENV = production
PORT = 3000
```

### 步骤 5：部署

1. Railway 会自动检测 `package.json` 并开始部署
2. 等待部署完成（约 2-5 分钟）
3. 部署成功后会显示访问地址

### 步骤 6：启用公网访问

1. 点击 **"Settings"** 标签页
2. 找到 **"Domains"** 部分
3. 点击 **"Generate Domain"**
4. Railway 会为您分配一个免费域名（如：`your-project.railway.app`）

### 步骤 7：测试

访问分配的域名，测试以下功能：
- ✅ 在线聊天室
- ✅ 在线投稿
- ✅ 用户登录

---

## 📋 方案二：使用 Railway CLI（需要解决网络问题）

### 前置要求

1. **Node.js** 已安装
2. **稳定的网络环境**（能访问 GitHub）

### 步骤 1：安装 Railway CLI

```bash
npm install -g @railway/cli
```

如果遇到网络错误，可以尝试：
```bash
# 使用淘宝镜像
npm install -g @railway/cli --registry=https://registry.npmmirror.com
```

### 步骤 2：登录 Railway

```bash
railway login
```

这会打开浏览器让您登录。

### 步骤 3：初始化项目

```bash
railway init
```

选择：
- 如果是第一次部署：选择 **"Create new project"**
- 如果已有项目：选择现有项目

### 步骤 4：设置环境变量

```bash
railway variables set SESSION_SECRET=scp-foundation-secret-key-2026
railway variables set NODE_ENV=production
railway variables set PORT=3000
```

### 步骤 5：部署

```bash
railway up
```

这会上传代码并开始部署。

### 步骤 6：分配域名

```bash
railway domain
```

### 步骤 7：查看部署状态

```bash
railway open
```

这会打开 Railway 管理面板。

---

## 🔧 故障排除

### 问题 1：CLI 安装失败

**错误信息**：`UNABLE_TO_VERIFY_LEAF_SIGNATURE`

**解决方案**：
```bash
# 方法 1：使用国内镜像
npm install -g @railway/cli --registry=https://registry.npmmirror.com

# 方法 2：临时禁用 SSL 验证（不推荐）
npm config set strict-ssl false
npm install -g @railway/cli
```

### 问题 2：部署失败

**检查清单**：
- ✅ `package.json` 存在且正确
- ✅ `server.js` 存在
- ✅ 环境变量已设置
- ✅ 端口配置正确（PORT=3000）

### 问题 3：WebSocket 连接失败

Railway 支持 WebSocket，但需要确保：
1. 使用 `wss://` 协议（加密的 WebSocket）
2. 前端代码中的 WebSocket URL 应该使用 Railway 分配的域名

修改前端代码中的 WebSocket URL：
```javascript
// 生产环境
const wsUrl = `wss://${window.location.hostname}`;

// 本地开发
// const wsUrl = 'ws://localhost:3000';
```

---

## 📊 部署后的重要配置

### 1. 修改前端 WebSocket 连接

在 `index.html` 中找到 `initWebSocket()` 函数，修改为：

```javascript
function initWebSocket() {
    let wsUrl;
    
    // 检测是否为 Railway 部署
    if (window.location.hostname.includes('railway.app')) {
        // 生产环境 - 使用 wss://
        wsUrl = `wss://${window.location.hostname}`;
    } else {
        // 本地开发 - 使用 ws://
        wsUrl = 'ws://localhost:3000';
    }
    
    try {
        ws = new WebSocket(wsUrl);
        // ... 其余代码
    }
}
```

### 2. 数据库持久化

Railway 使用临时文件系统，重启后数据会丢失。**强烈建议**迁移到 Railway PostgreSQL：

#### 步骤：

1. 在 Railway 面板中添加 PostgreSQL：
   - 点击 **"+ New"**
   - 选择 **"Database"** → **"PostgreSQL"**

2. 获取连接字符串：
   - 点击 PostgreSQL 服务
   - 在 **"Variables"** 标签页找到 `DATABASE_URL`

3. 修改 `server.js` 使用 PostgreSQL：

```javascript
// 添加 PostgreSQL 依赖
const { Client } = require('pg');

// 创建客户端
const client = new Client({ 
    connectionString: process.env.DATABASE_URL,
    ssl: { rejectUnauthorized: false }
});

// 连接数据库
await client.connect();

// 替换所有 db.run 为 client.query
// 例如：
await client.query(`
    CREATE TABLE IF NOT EXISTS chat_messages (
        id SERIAL PRIMARY KEY,
        userId TEXT,
        username TEXT,
        message TEXT,
        emoji TEXT,
        createdAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
`);
```

4. 更新 `package.json`：
```json
{
  "dependencies": {
    "pg": "^8.11.3",
    // ... 其他依赖
  }
}
```

---

## ✅ 部署验证清单

部署完成后，请检查：

- [ ] 网站可以正常访问
- [ ] 聊天室可以发送消息
- [ ] 聊天消息实时同步（打开多个窗口测试）
- [ ] 投稿功能正常工作
- [ ] 刷新页面后数据仍然存在
- [ ] WebSocket 连接成功（检查浏览器控制台）

---

## 🎯 快速部署总结

**最简单的方式**：

1. 访问 https://railway.app
2. 用 GitHub 登录
3. 点击 "New Project" → "Deploy from GitHub repo"
4. 选择您的仓库
5. 添加环境变量
6. 等待自动部署
7. 生成域名
8. 完成！

---

## 📞 需要帮助？

如果遇到问题：
1. 查看 Railway 文档：https://docs.railway.app
2. 检查部署日志：Railway 面板 → "Deployments" → 点击最新部署
3. 查看浏览器控制台的错误信息

**祝部署顺利！** 🚀
