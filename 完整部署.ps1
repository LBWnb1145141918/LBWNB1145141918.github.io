# SCP Foundation Terminal - Railway 完整部署脚本

$ErrorActionPreference = "Continue"

Write-Host ""
Write-Host "╔════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                        ║"
Write-Host "║   SCP Foundation Terminal - Railway 部署脚本           ║"
Write-Host "║   Site-119 Online Community Deployment                 ║"
Write-Host "║                                                        ║"
Write-Host "╚════════════════════════════════════════════════════════╝"
Write-Host ""

# 步骤 1: 登录
Write-Host "══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "步骤 1: 登录 Railway" -ForegroundColor Yellow
Write-Host "══════════════════════════════════════════════════════"
Write-Host ""
Write-Host "正在打开浏览器，请在浏览器中登录 Railway 账号..."
Write-Host ""
Start-Process "https://railway.app"
Write-Host "按任意键继续（登录完成后）..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# 步骤 2: 初始化项目
Write-Host ""
Write-Host "══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "步骤 2: 初始化 Railway 项目" -ForegroundColor Yellow
Write-Host "══════════════════════════════════════════════════════"
Write-Host ""
Write-Host "提示：如果是第一次部署，选择 'Create new project'"
Write-Host "      如果已有项目，选择现有项目"
Write-Host ""
Write-Host "按任意键开始初始化..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

railway init

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "[错误] 项目初始化失败" -ForegroundColor Red
    Write-Host "请检查是否已成功登录 Railway"
    Write-Host ""
    pause
    exit 1
}

Write-Host ""
Write-Host "[成功] 项目初始化完成！" -ForegroundColor Green

# 步骤 3: 设置环境变量
Write-Host ""
Write-Host "══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "步骤 3: 配置环境变量" -ForegroundColor Yellow
Write-Host "══════════════════════════════════════════════════════"
Write-Host ""

$SESSION_SECRET = Read-Host "请输入会话密钥 (或直接回车使用默认值)"
if ([string]::IsNullOrWhiteSpace($SESSION_SECRET)) {
    $SESSION_SECRET = "scp-foundation-secret-key-2026"
}

Write-Host ""
Write-Host "正在设置环境变量..."
railway variables set SESSION_SECRET=$SESSION_SECRET
railway variables set NODE_ENV=production
railway variables set PORT=3000

Write-Host ""
Write-Host "[成功] 环境变量已设置！" -ForegroundColor Green
Write-Host "  - SESSION_SECRET = $SESSION_SECRET"
Write-Host "  - NODE_ENV = production"
Write-Host "  - PORT = 3000"

# 步骤 4: 部署
Write-Host ""
Write-Host "══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "步骤 4: 开始部署" -ForegroundColor Yellow
Write-Host "══════════════════════════════════════════════════════"
Write-Host ""
Write-Host "这将上传代码并启动服务..."
Write-Host ""
Write-Host "按任意键开始部署..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

railway up

if ($LASTEXITCODE -ne 0) {
    Write-Host ""
    Write-Host "[错误] 部署失败" -ForegroundColor Red
    Write-Host "请查看错误信息"
    Write-Host ""
    pause
    exit 1
}

Write-Host ""
Write-Host "[成功] 部署成功！" -ForegroundColor Green

# 步骤 5: 分配域名
Write-Host ""
Write-Host "══════════════════════════════════════════════════════" -ForegroundColor Cyan
Write-Host "步骤 5: 分配公共域名" -ForegroundColor Yellow
Write-Host "══════════════════════════════════════════════════════"
Write-Host ""

Write-Host "正在分配域名..."
railway domain

Write-Host ""
Write-Host "══════════════════════════════════════════════════════" -ForegroundColor Green
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
Write-Host "║  1. 访问 Railway 分配的域名（见上方输出）              ║"
Write-Host "║  2. 测试在线聊天功能                                   ║"
Write-Host "║  3. 测试在线投稿功能                                   ║"
Write-Host "║  4. 分享给其他人使用！                                 ║"
Write-Host "║                                                        ║"
Write-Host "║  管理控制台：https://railway.app                     ║"
Write-Host "╚════════════════════════════════════════════════════════╝"
Write-Host ""
pause
