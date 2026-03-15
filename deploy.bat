@echo off
chcp 65001 >nul
echo.
echo ╔════════════════════════════════════════════════════════╗
echo ║                                                        ║
echo ║   SCP Foundation Terminal - Railway 一键部署脚本       ║
echo ║   Site-119 Online Community Deployment                 ║
echo ║                                                        ║
echo ╚════════════════════════════════════════════════════════╝
echo.

REM 检查 Node.js
node --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] 未检测到 Node.js，请先安装 Node.js
    echo 下载地址：https://nodejs.org/
    pause
    exit /b 1
)

echo [信息] Node.js 已安装
echo.

REM 检查 Railway CLI
railway --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [信息] 正在安装 Railway CLI...
    npm install -g @railway/cli
    if %errorlevel% neq 0 (
        echo [错误] Railway CLI 安装失败，请检查网络连接
        pause
        exit /b 1
    )
)

echo [信息] Railway CLI 已就绪
echo.

REM 登录 Railway
echo ═══════════════════════════════════════════════════════
echo 步骤 1: 登录 Railway 账户
echo ═══════════════════════════════════════════════════════
echo.
railway login

if %errorlevel% neq 0 (
    echo [错误] 登录失败
    pause
    exit /b 1
)

echo.
echo [成功] 登录成功！
echo.

REM 初始化项目
echo ═══════════════════════════════════════════════════════
echo 步骤 2: 初始化 Railway 项目
echo ═══════════════════════════════════════════════════════
echo.
echo 如果是第一次部署，选择 "Create new project"
echo 如果已有项目，选择现有项目
echo.
pause

railway init

if %errorlevel% neq 0 (
    echo [错误] 项目初始化失败
    pause
    exit /b 1
)

echo.
echo [成功] 项目初始化完成！
echo.

REM 设置环境变量
echo ═══════════════════════════════════════════════════════
echo 步骤 3: 配置环境变量
echo ═══════════════════════════════════════════════════════
echo.

echo 设置 SESSION_SECRET...
set /p SESSION_SECRET=请输入会话密钥 (或直接回车使用默认值): 
if "%SESSION_SECRET%"=="" set SESSION_SECRET=scp-foundation-secret-key-2026

railway variables set SESSION_SECRET=%SESSION_SECRET%
railway variables set NODE_ENV=production

echo.
echo [成功] 环境变量已设置！
echo.

REM 部署
echo ═══════════════════════════════════════════════════════
echo 步骤 4: 开始部署
echo ═══════════════════════════════════════════════════════
echo.
echo 这将上传代码并启动服务...
echo.
pause

railway up

if %errorlevel% neq 0 (
    echo [错误] 部署失败
    pause
    exit /b 1
)

echo.
echo [成功] 部署成功！
echo.

REM 分配域名
echo ═══════════════════════════════════════════════════════
echo 步骤 5: 分配公共域名
echo ═══════════════════════════════════════════════════════
echo.

echo 正在分配域名...
railway domain

echo.
echo ═══════════════════════════════════════════════════════
echo 🎉 部署完成！
echo ═══════════════════════════════════════════════════════
echo.
echo 您的网站已上线！
echo.
echo 查看部署状态：railway open
echo 查看日志：railway logs
echo.
echo ╔════════════════════════════════════════════════════════╗
echo ║  下一步操作：                                          ║
echo ║                                                        ║
echo ║  1. 访问 Railway 分配的域名                            ║
echo ║  2. 测试在线聊天功能                                   ║
echo ║  3. 测试在线投稿功能                                   ║
echo   4. 分享给其他人使用！                                 ║
echo ║                                                        ║
echo ║  管理控制台：https://railway.app                     ║
echo ╚════════════════════════════════════════════════════════╝
echo.
pause
