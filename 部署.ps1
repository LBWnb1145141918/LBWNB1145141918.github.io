# SCP 终端快速部署脚本 (PowerShell)
# 自动提交并推送到 GitHub Pages

Write-Host "======================================" -ForegroundColor Cyan
Write-Host "  SCP 终端 - 快速部署工具" -ForegroundColor Cyan
Write-Host "======================================" -ForegroundColor Cyan
Write-Host ""

# 检查 Git 是否可用
try {
    $gitVersion = git --version
    Write-Host "✓ Git 已安装：$gitVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ 错误：未安装 Git，请先安装 Git" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "📊 检查仓库状态..." -ForegroundColor Yellow

# 检查当前状态
$status = git status --porcelain

if ([string]::IsNullOrWhiteSpace($status)) {
    Write-Host "✓ 工作区干净，无需提交" -ForegroundColor Green
} else {
    Write-Host "📝 检测到以下更改:" -ForegroundColor Yellow
    Write-Host $status -ForegroundColor Gray
    Write-Host ""
    
    # 添加所有更改
    Write-Host "📦 添加更改到暂存区..." -ForegroundColor Yellow
    git add .
    
    # 获取当前时间作为提交信息
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $commitMsg = "自动部署：$timestamp"
    
    # 提交更改
    Write-Host "💾 提交更改..." -ForegroundColor Yellow
    git commit -m $commitMsg
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ 已提交：$commitMsg" -ForegroundColor Green
    } else {
        Write-Host "❌ 提交失败" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "🚀 正在推送到 GitHub..." -ForegroundColor Cyan

# 推送到 GitHub
git push origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "======================================" -ForegroundColor Green
    Write-Host "  ✅ 部署成功！" -ForegroundColor Green
    Write-Host "======================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "⏳ GitHub Pages 正在自动部署中..." -ForegroundColor Yellow
    Write-Host "📱 访问地址：https://lbwnb1145141918.github.io" -ForegroundColor Cyan
    Write-Host "⏱️  部署完成约需 1-2 分钟" -ForegroundColor Gray
    Write-Host ""
    Write-Host "🔍 查看部署进度：" -ForegroundColor Yellow
    Write-Host "https://github.com/LBWnb1145141918/LBWNB1145141918.github.io/actions" -ForegroundColor Cyan
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "❌ 推送失败，请检查网络连接" -ForegroundColor Red
    Write-Host "如果持续失败，请尝试手动执行：git push origin main" -ForegroundColor Gray
    exit 1
}
