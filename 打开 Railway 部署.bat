@echo off
chcp 65001 >nul
echo.
echo ╔════════════════════════════════════════════════════════╗
echo ║                                                        ║
echo ║   正在打开 Railway 部署页面...                         ║
echo ║   SCP Foundation Terminal Deployment                   ║
echo ║                                                        ║
echo ╚════════════════════════════════════════════════════════╝
echo.
echo [信息] 即将在浏览器中打开 Railway 官网
echo.
echo 请在打开的网页中：
echo 1. 登录 Railway（使用 GitHub 账号）
echo 2. 点击 "New Project"
echo 3. 选择 "Deploy from GitHub repo"
echo 4. 选择您的仓库：LBWnb1145141918.github.io
echo 5. 添加环境变量（详见 立即部署.md）
echo.
echo 按任意键继续...
pause >nul
echo.
echo [打开浏览器...]
start https://railway.app
echo.
echo [完成] Railway 已打开，请按照网页提示进行部署！
echo.
echo 详细的部署步骤请查看：立即部署.md
echo.
pause
