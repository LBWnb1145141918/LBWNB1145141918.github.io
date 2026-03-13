# SCP 基金会终端 - Railway 部署指南

## 🚀 快速部署到 Railway

### 方法 1：一键部署（推荐）

#### 步骤 1：准备项目

确保你的项目根目录有以下文件：
- ✅ `server.js` - 后端主程序
- ✅ `package.json` - 项目配置
- ✅ `.env.example` - 环境变量模板
- ✅ `index.html` - 前端页面

#### 步骤 2：创建 GitHub 仓库

1. 访问 https://github.com/new
2. 仓库名称：`scp-terminal`（或其他你喜欢的名字）
3. 设为 **Public**（公开）
4. 点击 "Create repository"

#### 步骤 3：上传代码到 GitHub

在本地项目目录执行：

```powershell
# 初始化 Git
git init

# 添加所有文件
git add .

# 提交
git commit -m "Initial commit - SCP Terminal with Steam Login"

# 关联远程仓库（替换为你的仓库地址）
git remote add origin https://github.com/YOUR_USERNAME/scp-terminal.git

# 推送
git branch -M main
git push -u origin main
```

#### 步骤 4：连接到 Railway

1. 访问 https://railway.app/
2. 点击 "Login" → 使用 GitHub 账号登录
3. 点击 "New Project"
4. 选择 "Deploy from GitHub repo"
5. 选择你刚才创建的仓库 `scp-terminal`
6. 点击 "Deploy Now"

#### 步骤 5：配置环境变量

1. 在 Railway 项目页面，点击 "Variables"
2. 添加以下环境变量：

```
STEAM_API_KEY=你的 SteamAPIKey
SESSION_SECRET=scp-foundation-site119-secret-key-2026
PORT=3000
DATABASE_PATH=/data/database.sqlite
NODE_ENV=production
```

3. 点击 "Save"

#### 步骤 6：配置持久化存储（重要！）

SQLite 需要持久化存储：

1. 在 Railway 项目页面，点击 "New" → "Persistent Disk"
2. 挂载路径填写：`/data`
3. 大小选择：1GB（免费额度够用）
4. 点击 "Add"

#### 步骤 7：等待部署完成

Railway 会自动：
- 安装依赖（`npm install`）
- 启动服务器（`npm start`）
- 分配域名（例如：`https://scp-terminal-production.up.railway.app`）

部署完成后，你会看到一个绿色的 ✅ 和访问链接！

#### 步骤 8：配置 Steam API Key

1. 复制 Railway 分配的域名（例如：`https://scp-terminal-production.up.railway.app`）
2. 访问 https://steamcommunity.com/dev/apikey
3. 修改域名配置：
   ```
   域名：scp-terminal-production.up.railway.app
   OpenID 关联：https://scp-terminal-production.up.railway.app
   ```
4. 保存

#### 步骤 9：测试 Steam 登录

1. 访问 Railway 分配的域名
2. 点击 "使用 Steam 账号登录"
3. 应该能正常跳转和授权！

---

### 方法 2：使用 Railway CLI（高级）

```powershell
# 安装 Railway CLI
npm i -g @railway/cli

# 登录 Railway
railway login

# 初始化项目
railway init

# 添加环境变量
railway variables set STEAM_API_KEY=你的 Key
railway variables set SESSION_SECRET=scp-foundation-site119-secret-key-2026
railway variables set NODE_ENV=production

# 部署
railway up
```

---

## 🎯 使用 Render 部署（备选）

### 步骤 1：创建 Render 账号

访问 https://render.com/ 并使用 GitHub 登录

### 步骤 2：创建 Web Service

1. 点击 "New +" → "Web Service"
2. 选择你的 GitHub 仓库
3. 配置：
   - **Name**: scp-terminal
   - **Environment**: Node
   - **Build Command**: `npm install`
   - **Start Command**: `npm start`
   - **Instance Type**: Free

### 步骤 3：配置环境变量

在 Render 控制台添加：
```
STEAM_API_KEY=你的 SteamAPIKey
SESSION_SECRET=scp-foundation-site119-secret-key-2026
NODE_ENV=production
```

### 步骤 4：部署

点击 "Create Web Service"，等待部署完成！

---

## ⚠️ 注意事项

### Railway 免费额度
- 每月 500 小时运行时间
- 如果超出额度，服务会暂停
- 解决方法：升级到付费计划（$5/月）

### Render 免费计划
- 服务会在 15 分钟无访问后休眠
- 首次访问需要等待 30 秒启动
- 适合测试和个人使用

### 数据库迁移
- SQLite 文件会保存在持久化存储中
- 如果需要迁移数据，可以下载数据库文件

---

## 🔧 部署后配置

### 更新 Steam API Key

1. 访问 https://steamcommunity.com/dev/apikey
2. 使用你的正式域名注册
3. 在 Railway/Render 后台更新 `STEAM_API_KEY` 环境变量
4. 重启服务

### 自定义域名（可选）

**Railway:**
1. 在项目设置中找到 "Domains"
2. 添加你的域名
3. 配置 DNS CNAME 记录

**Render:**
1. 在服务设置中找到 "Custom Domains"
2. 添加域名
3. 按指引配置 DNS

---

## 📊 部署检查清单

- [ ] 创建 GitHub 账号
- [ ] 创建仓库并上传代码
- [ ] 注册 Railway/Render 账号
- [ ] 连接 GitHub 仓库
- [ ] 配置环境变量（特别是 STEAM_API_KEY）
- [ ] 配置持久化存储（Railway）
- [ ] 等待部署完成
- [ ] 获取部署域名
- [ ] 更新 Steam API Key 的域名配置
- [ ] 测试 Steam 登录
- [ ] 测试访客登录
- [ ] 配置自定义域名（可选）

---

## 💡 常见问题

### Q: 部署后访问很慢？
A: Railway/Render 的免费服务器在海外，国内访问可能较慢。可以考虑国内服务器。

### Q: 数据库会丢失吗？
A: 配置了持久化存储就不会丢失。Railway 需要手动添加 Persistent Disk。

### Q: 如何查看日志？
A: 
- Railway: 点击项目 → "Deployments" → 查看日志
- Render: 点击服务 → "Logs"

### Q: 如何更新代码？
A: 推送到 GitHub 后，Railway/Render 会自动重新部署！

---

## 🎉 部署成功标志

✅ 访问部署域名显示登录页面
✅ Steam 登录能正常跳转和授权
✅ 访客登录功能正常
✅ 所有页面跳转正常
✅ 聊天记录功能正常

---

**祝你部署成功！有任何问题随时问我！** 🚀
