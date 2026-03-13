# SCP 基金会终端 - Steam 登录系统配置指南

## 🚀 快速开始

### 第一步：获取 Steam API Key

1. 访问 https://steamcommunity.com/dev/apikey
2. 登录你的 Steam 账号
3. 填写域名：
   - 本地测试填写：`localhost`
   - 域名：`localhost`
4. 点击"注册"获取 API Key
5. 复制你的 API Key

### 第二步：配置环境变量

1. 复制 `.env.example` 文件并重命名为 `.env`
2. 编辑 `.env` 文件：

```env
STEAM_API_KEY=你的 SteamAPIKey
SESSION_SECRET=scp-foundation-site119-secret-key-2026
PORT=3000
DATABASE_PATH=./database.sqlite
```

### 第三步：安装依赖

打开终端（PowerShell 或 CMD），进入项目目录：

```bash
cd "c:\Users\Administrator\Desktop\LBWnb1145141918.github.io"
npm install
```

### 第四步：启动后端服务器

```bash
npm start
```

或者使用开发模式（自动重启）：

```bash
npm run dev
```

看到以下提示说明服务器启动成功：

```
╔════════════════════════════════════════════════════════╗
║   SCP Foundation Terminal Backend                      ║
║   Site-119 Authentication Server                       ║
║   服务器运行在：http://localhost:3000                  ║
╚════════════════════════════════════════════════════════╝
```

### 第五步：打开网站

在浏览器中访问：`http://localhost:3000`

## 🎮 功能说明

### Steam 登录
1. 点击"使用 Steam 账号登录"按钮
2. 跳转到 Steam 登录页面
3. 授权登录
4. 自动返回网站并显示你的 Steam 昵称

### 访客登录
1. 点击"访客登录（无需账号）"按钮
2. 输入访客昵称（可选）
3. 立即登录成功

### 退出登录
- 在主菜单右下角点击"退出登录"选项

## 📊 数据库

系统会自动创建 SQLite 数据库文件 `database.sqlite`

包含的表：
- `users` - Steam 用户信息
- `guest_users` - 访客用户信息

## ⚙️ 配置说明

### 修改端口
如果 3000 端口被占用，修改 `.env` 文件：

```env
PORT=3001
```

然后重启服务器。

### 会话有效期
默认会话有效期为 7 天，修改 `.env`：

```env
SESSION_SECRET=你的随机密钥
```

## 🔧 故障排除

### 问题 1：无法连接服务器
**错误信息：** "连接服务器失败，请确保后端服务正在运行"

**解决方案：**
1. 确保后端服务器正在运行
2. 检查终端是否有报错
3. 确认端口是 3000

### 问题 2：Steam 登录回调失败
**错误信息：** "Invalid returnURL"

**解决方案：**
1. 检查 `.env` 中的配置
2. 确保 Steam API Key 正确
3. 确认 returnURL 是 `http://localhost:3000/auth/steam/return`

### 问题 3：数据库错误
**错误信息：** "unable to open database file"

**解决方案：**
1. 确保有写入权限
2. 删除 `database.sqlite` 文件
3. 重启服务器会自动重建

## 🌐 部署到服务器

### 购买云服务器
推荐：
- 阿里云
- 腾讯云
- 华为云

### 部署步骤

1. 上传项目到服务器
2. 安装 Node.js
3. 安装依赖：`npm install`
4. 配置 `.env` 文件
5. 启动服务：`npm start`
6. 配置域名和 SSL 证书

### 生产环境配置

修改 `.env`：

```env
# 使用你的域名
STEAM_API_KEY=你的 APIKey
SESSION_SECRET=强随机密钥
PORT=80
DATABASE_PATH=/var/data/scp-terminal.db
```

## 📝 注意事项

1. **本地测试**：仅使用 `localhost` 域名
2. **生产环境**：必须使用 HTTPS
3. **API Key 安全**：不要将 `.env` 文件上传到 GitHub
4. **数据库备份**：定期备份 `database.sqlite`

## 🎯 下一步功能

- [ ] 用户等级系统
- [ ] 聊天记录保存
- [ ] 违规记录关联用户
- [ ] 管理员权限
- [ ] 用户个人资料

## 💡 技术支持

如有问题，请检查：
1. 终端的服务器日志
2. 浏览器控制台（F12）
3. `.env` 配置是否正确

---

**SCP Foundation - Site-119 Terminal**
**Secure. Contain. Protect.**
