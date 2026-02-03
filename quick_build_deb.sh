#!/bin/bash

# 金钱卦应用快速 DEB 打包脚本
# 简化版本，专注于核心功能

set -e

APP_NAME="money-gua"
APP_VERSION="1.0.0"
ARCHITECTURE="amd64"

echo "🚀 开始快速构建金钱卦 DEB 包..."

# 检查环境
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ 错误：请在 money_gua 应用根目录运行此脚本"
    exit 1
fi

# 清理并构建
echo "📦 构建 Flutter 应用..."
flutter clean
flutter pub get
flutter build linux --release

# 创建 DEB 目录结构
echo "📁 创建 DEB 包结构..."
DEB_DIR="build/deb"
rm -rf "$DEB_DIR"
mkdir -p "$DEB_DIR"/{DEBIAN,usr/{bin,share/{applications,pixmaps,icons/hicolor/{16x16,32x32,48x48,64x64,128x128,256x256}/apps,$APP_NAME}}}

# 复制应用文件
echo "📋 复制应用文件..."
cp -r build/linux/x64/release/bundle/* "$DEB_DIR/usr/share/$APP_NAME/"

# 创建启动脚本
cat > "$DEB_DIR/usr/bin/$APP_NAME" << EOF
#!/bin/bash
cd "/usr/share/$APP_NAME"
exec "./money_gua" "\$@"
EOF
chmod +x "$DEB_DIR/usr/bin/$APP_NAME"

# 处理图标
echo "🎨 设置应用图标..."
cp assets/icon.png "$DEB_DIR/usr/share/pixmaps/$APP_NAME.png"

# 如果有 ImageMagick，生成多尺寸图标
if command -v convert &> /dev/null; then
    for size in 16 32 48 64 128 256; do
        convert assets/icon.png -resize ${size}x${size} "$DEB_DIR/usr/share/icons/hicolor/${size}x${size}/apps/$APP_NAME.png"
    done
    echo "✅ 多尺寸图标生成完成"
else
    # 直接复制原始图标
    for size in 16x16 32x32 48x48 64x64 128x128 256x256; do
        cp assets/icon.png "$DEB_DIR/usr/share/icons/hicolor/$size/apps/$APP_NAME.png"
    done
    echo "⚠️  ImageMagick 未安装，使用原始图标"
fi

# 创建桌面文件
echo "🖥️  创建桌面文件..."
cat > "$DEB_DIR/usr/share/applications/$APP_NAME.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=金钱卦
Name[zh_CN]=金钱卦
Comment=金钱卦占卜应用 - 传统易经占卜工具
Comment[zh_CN]=金钱卦占卜应用 - 传统易经占卜工具
Exec=$APP_NAME
Icon=$APP_NAME
Terminal=false
Categories=Education;Utility;
Keywords=易经;占卜;金钱卦;divination;iching;
StartupNotify=true
StartupWMClass=money_gua
EOF

# 创建控制文件
echo "📄 创建控制文件..."
INSTALLED_SIZE=$(du -sk "$DEB_DIR/usr" | cut -f1)

cat > "$DEB_DIR/DEBIAN/control" << EOF
Package: $APP_NAME
Version: $APP_VERSION
Section: Education
Priority: optional
Architecture: $ARCHITECTURE
Installed-Size: $INSTALLED_SIZE
Depends: libc6, libgtk-3-0, libglib2.0-0
Maintainer: Money Gua Developer <developer@example.com>
Description: 金钱卦占卜应用
 基于传统易经的金钱卦占卜应用，提供简单易用的卦象解读功能。
 .
 主要功能包括传统金钱卦占卜、卦象详细解读、语音朗读功能等。
EOF

# 创建安装后脚本
cat > "$DEB_DIR/DEBIAN/postinst" << 'EOF'
#!/bin/bash
set -e

# 更新图标缓存
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
    gtk-update-icon-cache -f -t /usr/share/icons/hicolor >/dev/null 2>&1 || true
fi

# 更新桌面数据库
if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database /usr/share/applications >/dev/null 2>&1 || true
fi

echo "金钱卦应用安装完成！可在应用菜单中找到或运行 'money-gua' 启动。"
exit 0
EOF

chmod 755 "$DEB_DIR/DEBIAN/postinst"

# 设置权限
echo "🔐 设置文件权限..."
find "$DEB_DIR" -type f -exec chmod 644 {} \;
find "$DEB_DIR" -type d -exec chmod 755 {} \;
chmod 755 "$DEB_DIR/usr/bin/$APP_NAME"
chmod 755 "$DEB_DIR/usr/share/$APP_NAME/money_gua"
chmod 755 "$DEB_DIR/DEBIAN/postinst"

# 构建 DEB 包
echo "🔨 构建 DEB 包..."
DEB_FILE="${APP_NAME}_${APP_VERSION}_${ARCHITECTURE}.deb"
dpkg-deb --build "$DEB_DIR" "$DEB_FILE"

# 显示结果
if [ -f "$DEB_FILE" ]; then
    FILE_SIZE=$(du -h "$DEB_FILE" | cut -f1)
    echo
    echo "🎉 DEB 包构建成功！"
    echo "📦 文件名: $DEB_FILE"
    echo "📏 大小: $FILE_SIZE"
    echo
    echo "📥 安装命令:"
    echo "   sudo dpkg -i $DEB_FILE"
    echo "   sudo apt-get install -f  # 如果有依赖问题"
    echo
    echo "🚀 启动命令:"
    echo "   $APP_NAME"
    echo
    echo "✨ 图标已正确配置，任务栏将显示应用专用图标！"
else
    echo "❌ DEB 包构建失败"
    exit 1
fi