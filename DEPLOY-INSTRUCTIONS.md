# 🚀 Railway 部署指南

## 分离部署架构

```
前端：GitHub Pages (LBWNB1145141918.github.io)
后端：Railway
```

---

## 📋 部署步骤

### 1️⃣ 部署后端到 Railway

#### 方法：创建新仓库专门部署后端

1. 在 GitHub 创建新仓库：`scp-terminal-backend`
2. 只包含后端文件：
   - server.js
   - package.json
   - .env.example
   - .gitignore

3. 推送到新仓库：
```powershell
cd "c:\Users\Administrator\Desktop\LBWnb1145141918.github.io"

# 创建新分支或新仓库
git init
git remote add origin https://github.com/LBWNB1145141918/scp-terminal-backend.git
git add server.js package.json .env.example .gitignore
git commit -m "Backend for Railway deployment"
git branch -M main
git push -u origin main
```

#### 连接 Railway

1. 访问 https://railway.app/
2. 登录 GitHub
3. New Project → Deploy from GitHub repo
4. 选择 `scp-terminal-backend`
5. Deploy Now

#### 配置环境变量

在 Railway Variables 添加：
```
STEAM_API_KEY=你的真实 SteamAPIKey
SESSION_SECRET=scp-foundation-site119-secret-key-2026
PORT=3000
DATABASE_PATH=/data/database.sqlite
NODE_ENV=production
```

#### 添加持久化存储

1. New → Persistent Disk
2. Mount path: `/data`
3. Size: 1GB
4. Add

---

### 2️⃣ 修改前端 API 地址

部署成功后，Railway 会给你分配一个域名，例如：
```
https://scp-terminal-backend-production.up.railway.app
```

**修改 index.html：**

找到第 1167-1170 行，修改为：

```javascript
// 本地测试使用
// const API_BASE = 'http://localhost:3000/api';

// 部署到 Railway 后使用
const API_BASE = 'https://scp-terminal-backend-production.up.railway.app/api';
```

---

### 3️⃣ 推送到 GitHub Pages

```powershell
cd "c:\Users\Administrator\Desktop\LBWnb1145141918.github.io"
git add .
git commit -m "Update API endpoint for Railway deployment"
git push origin main
```

---

### 4️⃣ 配置 Steam API Key

1. 复制 Railway 域名
2. 访问 https://steamcommunity.com/dev/apikey
3. 修改域名配置：
   ```
   域名：scp-terminal-backend-production.up.railway.app
   OpenID 关联：https://scp-terminal-backend-production.up.railway.app
   ```
4. 保存

---

### 5️⃣ 更新 Railway 环境变量

在 Railway Variables 中更新 `STEAM_API_KEY`，然后重启服务。

---

## ✅ 验证

1. 访问：https://lbwnb1145141918.github.io
2. 点击"使用 Steam 账号登录"
3. 应该能正常跳转和授权！

---

## 🎯 快速部署命令

### 创建后端仓库并推送

```powershell
# 创建临时目录
mkdir temp-backend
cd temp-backend

# 从主项目复制后端文件
cp ../server.js .
cp ../package.json .
cp ../.env.example .
cp ../.gitignore .

# 初始化 Git
git init
git remote add origin https://github.com/LBWNB1145141918/scp-terminal-backend.git
git add .
git commit -m "Initial backend deployment"
git branch -M main
git push -u origin main

# 返回
cd ..
rmdir temp-backend
```

---

## 📊 部署检查清单

- [ ] 创建后端仓库 `scp-terminal-backend`
- [ ] 推送后端文件
- [ ] 连接 Railway
- [ ] 配置环境变量
- [ ] 添加持久化存储
- [ ] 获取 Railway 域名
- [ ] 修改前端 API_BASE 地址
- [ ] 推送前端到 GitHub Pages
- [ ] 配置 Steam API Key 域名
- [ ] 更新 Railway 环境变量
- [ ] 测试 Steam 登录
- [ ] 测试访客登录

---

## 💡 注意事项

1. **CORS 配置**：server.js 已经配置好 CORS，允许 GitHub Pages 访问
2. **Credentials**：前端使用 `credentials: 'include'` 传递会话 cookie
3. **HTTPS**：Railway 自动提供 HTTPS，无需额外配置

---

**部署成功后，你的网站就可以使用 Steam 登录了！** 🎉
