#!/bin/bash

# 金钱卦应用图标测试脚本
# 验证图标配置是否正确

echo "🎨 金钱卦应用图标配置测试"
echo "================================"

# 检查图标文件
echo "📁 检查图标文件..."
if [ -f "assets/icon.png" ]; then
    echo "✅ 主图标文件存在: assets/icon.png"
    
    # 显示图标信息
    if command -v identify &> /dev/null; then
        echo "📏 图标信息:"
        identify assets/icon.png
    fi
else
    echo "❌ 主图标文件不存在: assets/icon.png"
    exit 1
fi

# 检查 pubspec.yaml 配置
echo
echo "📄 检查 pubspec.yaml 图标配置..."
if grep -q "flutter_launcher_icons:" pubspec.yaml; then
    echo "✅ flutter_launcher_icons 配置存在"
    
    if grep -q "linux: true" pubspec.yaml; then
        echo "✅ Linux 图标生成已启用"
    else
        echo "⚠️  Linux 图标生成未启用"
    fi
    
    if grep -q 'image_path: "assets/icon.png"' pubspec.yaml; then
        echo "✅ 图标路径配置正确"
    else
        echo "⚠️  图标路径配置可能有问题"
    fi
else
    echo "❌ flutter_launcher_icons 配置不存在"
fi

# 检查生成的图标
echo
echo "🔍 检查生成的 Linux 图标..."
LINUX_ICON_DIR="linux/runner/resources"
if [ -d "$LINUX_ICON_DIR" ]; then
    echo "✅ Linux 图标目录存在: $LINUX_ICON_DIR"
    ls -la "$LINUX_ICON_DIR"
else
    echo "⚠️  Linux 图标目录不存在，可能需要运行图标生成"
    echo "   运行: dart run flutter_launcher_icons:main"
fi

# 检查构建后的图标
echo
echo "🔨 检查构建后的图标..."
BUILD_ASSETS_DIR="build/linux/x64/release/bundle/data/flutter_assets/assets"
if [ -d "$BUILD_ASSETS_DIR" ] && [ -f "$BUILD_ASSETS_DIR/icon.png" ]; then
    echo "✅ 构建后的图标存在: $BUILD_ASSETS_DIR/icon.png"
else
    echo "⚠️  构建后的图标不存在，需要重新构建应用"
fi

# 检查系统图标工具
echo
echo "🛠️  检查系统图标工具..."
if command -v gtk-update-icon-cache &> /dev/null; then
    echo "✅ gtk-update-icon-cache 可用"
else
    echo "⚠️  gtk-update-icon-cache 不可用"
fi

if command -v update-desktop-database &> /dev/null; then
    echo "✅ update-desktop-database 可用"
else
    echo "⚠️  update-desktop-database 不可用"
fi

if command -v convert &> /dev/null; then
    echo "✅ ImageMagick convert 可用"
else
    echo "⚠️  ImageMagick convert 不可用，无法生成多尺寸图标"
fi

# 生成图标建议
echo
echo "💡 图标优化建议:"
echo "1. 确保图标是 PNG 格式，建议尺寸 512x512 或更大"
echo "2. 图标应该有透明背景"
echo "3. 图标设计应该在小尺寸下仍然清晰可见"
echo "4. 运行 'dart run flutter_launcher_icons:main' 生成各平台图标"

# 测试图标生成
echo
echo "🚀 测试图标生成..."
if command -v dart &> /dev/null; then
    echo "正在生成图标..."
    dart run flutter_launcher_icons:main
    echo "✅ 图标生成完成"
else
    echo "⚠️  Dart 不可用，无法生成图标"
fi

echo
echo "🎯 任务栏图标显示说明:"
echo "- 应用使用 StartupWMClass=money_gua 确保图标正确关联"
echo "- 桌面文件中的 Icon=money-gua 指向系统图标"
echo "- 应用代码中设置了 gtk_window_set_wmclass 和图标"
echo "- DEB 包会将图标安装到系统图标目录"

echo
echo "✨ 图标测试完成！"