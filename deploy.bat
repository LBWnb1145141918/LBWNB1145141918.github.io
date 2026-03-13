#!/bin/bash
# 快速部署脚本 - 自动提交并推送到 GitHub Pages

# 检查是否有未提交的更改
if git diff --quiet && git diff --staged --quiet; then
    echo "✓ 工作区干净，无需提交"
else
    echo "📝 检测到更改..."
    
    # 添加所有更改
    git add .
    
    # 获取当前时间作为提交信息
    COMMIT_MSG="自动部署: $(date '+%Y-%m-%d %H:%M:%S')"
    
    # 提交更改
    git commit -m "$COMMIT_MSG"
    
    echo "✓ 已提交：$COMMIT_MSG"
fi

# 推送到 GitHub
echo "🚀 正在推送到 GitHub..."
git push origin main

if [ $? -eq 0 ]; then
    echo "✅ 推送成功！"
    echo "⏳ GitHub Pages 正在部署中..."
    echo "📱 访问：https://lbwnb1145141918.github.io"
    echo "⏱️  部署完成后约需 1-2 分钟"
else
    echo "❌ 推送失败，请检查网络连接"
fi
