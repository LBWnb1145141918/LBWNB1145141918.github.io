@echo off
chcp 65001 >nul
title SCP 基金会终端服务器

echo ╔════════════════════════════════════════════════════════╗
echo ║                                                        ║
echo ║   SCP Foundation Terminal - Site-119                  ║
echo ║   后端服务器启动器                                     ║
echo ║                                                        ║
echo ════════════════════════════════════════════════════════╝
echo.

cd /d "%~dp0"

echo [信息] 正在检查 Node.js...
where node >nul 2>&1
if %errorlevel% neq 0 (
    echo [错误] 未检测到 Node.js！
    echo [解决] 请访问 https://nodejs.org/ 安装 Node.js
    pause
    exit /b 1
)

echo [信息] Node.js 版本:
node -v
echo.

echo [信息] 正在停止旧的 Node.js 进程...
taskkill /F /IM node.exe >nul 2>&1
timeout /t 2 /nobreak >nul

echo [信息] 正在启动服务器...
echo.

npm start

echo.
echo [信息] 服务器已关闭
pause
