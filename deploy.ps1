# SCP Foundation Terminal - Railway 一键部署脚本

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════╗"
Write-Host "║                                                        ║"
Write-Host "║   SCP Foundation Terminal - Railway 一键部署脚本       ║"
Write-Host "║   Site-119 Online Community Deployment                 ║"
Write-Host "║                                                        ║"
Write-Host "╚════════════════════════════════════════════════════════╝"
Write-Host ""

# 检查 Node.js
try {
    $nodeVersion = node --version
    Write-Host "[信息] Node.js 已安装：$nodeVersion" -ForegroundColor Green
} catch {
    Write-Host "[错误] 未检测到 Node.js，请先安装 Node.js" -ForegroundColor Red
    Write-Host "下载地址：https://nodejs.org/"
    pause
    exit 1
}

# 检查 Railway CLI
try {
    $railwayVersion = railway --version
    Write-Host "[信息] Railway CLI 已就绪：$railwayVersion" -ForegroundColor Green
} catch {
    Write-Host "[信息] 正在安装 Railway CLI..." -ForegroundColor Yellow
    npm install -g @railway/cli
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[错误] Railway CLI 安装失败，请检查网络连接" -ForegroundColor Red
        pause
        exit 1
    }
}

Write-Host ""
Write-Host "══════════════════════════════════════════════════════"
Write-Host "步骤 1: 登录 Railway 账户" -ForegroundColor Cyan
Write-Host "══════════════════════════════════════════════════════"
Write-Host ""

railway login
if ($LASTEXITCODE -ne 0) {
    Write-Host "[错误] 登录失败" -ForegroundColor Red
    pause
    exit 1
}

Write-Host ""
Write-Host "[成功] 登录成功！" -ForegroundColor Green
Write-Host ""

Write-Host "══════════════════════════════════════════════════════"
Write-Host "步骤 2: 初始化 Railway 项目" -ForegroundColor Cyan
Write-Host "══════════════════════════════════════════════════════"
Write-Host ""
Write-Host "如果是第一次部署，选择 'Create new project'"
Write-Host "如果已有项目，选择现有项目"
Write-Host ""
pause

railway init
if ($LASTEXITCODE -ne 0) {
    Write-Host "[错误] 项目初始化失败" -ForegroundColor Red
    pause
    exit 1
}

Write-Host ""
Write-Host "[成功] 项目初始化完成！" -ForegroundColor Green
Write-Host ""

Write-Host "══════════════════════════════════════════════════════"
Write-Host "步骤 3: 配置环境变量" -ForegroundColor Cyan
Write-Host "══════════════════════════════════════════════════════"
Write-Host ""

$SESSION_SECRET = Read-Host "请输入会话密钥 (或直接回车使用默认值)"
if ([string]::IsNullOrWhiteSpace($SESSION_SECRET)) {
    $SESSION_SECRET = "scp-foundation-secret-key-2026"
}

railway variables set SESSION_SECRET=$SESSION_SECRET
railway variables set NODE_ENV=production

Write-Host ""
Write-Host "[成功] 环境变量已设置！" -ForegroundColor Green
Write-Host ""

Write-Host "══════════════════════════════════════════════════════"
Write-Host "步骤 4: 开始部署" -ForegroundColor Cyan
Write-Host "══════════════════════════════════════════════════════"
Write-Host ""
Write-Host "这将上传代码并启动服务..."
Write-Host ""
pause

railway up
if ($LASTEXITCODE -ne 0) {
    Write-Host "[错误] 部署失败" -ForegroundColor Red
    pause
    exit 1
}

Write-Host ""
Write-Host "[成功] 部署成功！" -ForegroundColor Green
Write-Host ""

Write-Host "══════════════════════════════════════════════════════"
Write-Host "步骤 5: 分配公共域名" -ForegroundColor Cyan
Write-Host "══════════════════════════════════════════════════════"
Write-Host ""

Write-Host "正在分配域名..."
railway domain

Write-Host ""
Write-Host "══════════════════════════════════════════════════════"
Write-Host "🎉 部署完成！" -ForegroundColor Green
Write-Host "══════════════════════════════════════════════════════"
Write-Host ""
Write-Host "您的网站已上线！"
Write-Host ""
Write-Host "查看部署状态：railway open"
Write-Host "查看日志：railway logs"
Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════╗"
Write-Host "║  下一步操作：                                          ║"
Write-Host "║                                                        ║"
Write-Host "║  1. 访问 Railway 分配的域名                            ║"
Write-Host "║  2. 测试在线聊天功能                                   ║"
Write-Host "║  3. 测试在线投稿功能                                   ║"
Write-Host "║  4. 分享给其他人使用！                                 ║"
Write-Host "║                                                        ║"
Write-Host "║  管理控制台：https://railway.app                     ║"
Write-Host "╚════════════════════════════════════════════════════════╝"
Write-Host ""
pause
