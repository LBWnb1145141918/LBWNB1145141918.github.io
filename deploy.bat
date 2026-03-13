@echo off
chcp 65001 >nul
cd /d "%~dp0"

echo ======================================
echo   SCP 终端 - 快速部署工具
echo ======================================
echo.

REM 检查 Git 是否可用
git --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ 错误：未安装 Git，请先安装 Git
    pause
    exit /b 1
)
echo ✓ Git 已安装

echo.
echo 📊 检查仓库状态...

REM 检查是否有更改
git status --porcelain > temp_status.txt
if %errorlevel% neq 0 (
    echo ❌ Git 状态检查失败
    del temp_status.txt
    pause
    exit /b 1
)

for %%a in (temp_status.txt) do set "filesize=%%~za"
if %filesize% equ 0 (
    echo ✓ 工作区干净，无需提交
    del temp_status.txt
) else (
    echo 📝 检测到更改，正在添加...
    git add .
    
    REM 获取当前时间
    for /f "tokens=2 delims==" %%i in ('wmic os get localdatetime /value 2^>nul') do set "dt=%%i"
    if defined dt (
        set "YEAR=%dt:~0,4%"
        set "MONTH=%dt:~4,2%"
        set "DAY=%dt:~6,2%"
        set "HOUR=%dt:~8,2%"
        set "MIN=%dt:~10,2%"
    ) else (
        REM 如果 wmic 不可用，使用 date 和 time 命令
        for /f "tokens=1-3 delims=/-" %%a in ('date /t') do set "YEAR=%%c" & set "MONTH=%%b" & set "DAY=%%a"
        for /f "tokens=1-2 delims=:" %%a in ('time /t') do set "HOUR=%%a" & set "MIN=%%b"
    )
    
    set "commitMsg=自动部署：%YEAR%-%MONTH%-%DAY% %HOUR%:%MIN%"
    echo 💾 提交更改...
    git commit -m "%commitMsg%"
    
    if %errorlevel% equ 0 (
        echo ✓ 已提交：%commitMsg%
    ) else (
        echo ❌ 提交失败
        del temp_status.txt
        pause
        exit /b 1
    )
    del temp_status.txt
)

echo.
echo 🚀 正在推送到 GitHub...
git push origin main

if %errorlevel% equ 0 (
    echo.
    echo ======================================
    echo   ✅ 部署成功！
    echo ======================================
    echo.
    echo ⏳ GitHub Pages 正在自动部署中...
    echo 📱 访问地址：https://lbwnb1145141918.github.io
    echo ⏱️  部署完成约需 1-2 分钟
    echo.
    echo 🔍 查看部署进度：
    echo https://github.com/LBWnb1145141918/LBWNB1145141918.github.io/actions
    echo.
) else (
    echo.
    echo ❌ 推送失败，请检查网络连接
    echo 如果持续失败，请尝试手动执行：git push origin main
)

pause
