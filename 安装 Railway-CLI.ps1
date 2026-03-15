# 手动安装 Railway CLI 脚本

$ErrorActionPreference = "Stop"

Write-Host "正在下载 Railway CLI..." -ForegroundColor Cyan

# 下载地址
$downloadUrl = "https://github.com/railwayapp/cli/releases/download/v4.31.0/railway-v4.31.0-x86_64-pc-windows-gnu.tar.gz"
$tempDir = [System.IO.Path]::GetTempPath()
$downloadPath = Join-Path $tempDir "railway.tar.gz"
$extractPath = Join-Path $tempDir "railway-cli"

try {
    # 下载文件
    Invoke-WebRequest -Uri $downloadUrl -OutFile $downloadPath -UseBasicParsing
    Write-Host "下载完成！" -ForegroundColor Green
    
    # 创建解压目录
    if (Test-Path $extractPath) {
        Remove-Item $extractPath -Recurse -Force
    }
    New-Item -ItemType Directory -Path $extractPath | Out-Null
    
    # 解压文件
    Write-Host "正在解压..." -ForegroundColor Cyan
    tar -xzf $downloadPath -C $extractPath
    
    # 找到 railway.exe
    $railwayExe = Get-ChildItem -Path $extractPath -Filter "railway.exe" -Recurse | Select-Object -First 1
    
    if ($railwayExe) {
        Write-Host "找到 railway.exe: $($railwayExe.FullName)" -ForegroundColor Green
        
        # 添加到 PATH
        $userPath = [Environment]::GetEnvironmentVariable("Path", "User")
        if ($userPath -notlike "*$($railwayExe.DirectoryName)*") {
            [Environment]::SetEnvironmentVariable("Path", "$userPath;$($railwayExe.DirectoryName)", "User")
            Write-Host "已添加到系统 PATH" -ForegroundColor Green
        }
        
        Write-Host "`nRailway CLI 安装完成！" -ForegroundColor Green
        Write-Host "请关闭并重新打开 PowerShell，然后运行：railway --version" -ForegroundColor Yellow
    } else {
        Write-Host "错误：未找到 railway.exe" -ForegroundColor Red
    }
    
} catch {
    Write-Host "错误：$($_.Exception.Message)" -ForegroundColor Red
    Write-Host "`n如果下载失败，请手动下载：" -ForegroundColor Yellow
    Write-Host $downloadUrl -ForegroundColor Cyan
}
