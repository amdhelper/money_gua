#!/bin/bash

# 金钱卦应用 DEB 打包脚本
# 包含图标配置，确保任务栏显示正确的应用图标

set -e

# 配置变量
APP_NAME="money-gua"
APP_DISPLAY_NAME="金钱卦"
APP_VERSION="1.0.0"
APP_DESCRIPTION="金钱卦占卜应用 - 传统易经占卜工具"
MAINTAINER="YourName <your.email@example.com>"
ARCHITECTURE="amd64"
CATEGORY="Education"

# 颜色输出
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

echo_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

echo_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

echo_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 检查依赖
check_dependencies() {
    echo_info "检查构建依赖..."
    
    if ! command -v flutter &> /dev/null; then
        echo_error "Flutter 未安装或不在 PATH 中"
        exit 1
    fi
    
    if ! command -v dpkg-deb &> /dev/null; then
        echo_error "dpkg-deb 未安装，请安装 dpkg-dev"
        echo "sudo apt install dpkg-dev"
        exit 1
    fi
    
    if ! command -v convert &> /dev/null; then
        echo_warning "ImageMagick 未安装，将跳过图标尺寸生成"
        echo "建议安装: sudo apt install imagemagick"
    fi
    
    echo_success "依赖检查完成"
}

# 清理旧的构建文件
clean_build() {
    echo_info "清理旧的构建文件..."
    
    rm -rf build/linux
    rm -rf build/deb
    rm -rf *.deb
    
    echo_success "清理完成"
}

# 构建 Flutter 应用
build_flutter_app() {
    echo_info "构建 Flutter Linux 应用..."
    
    # 清理并获取依赖
    flutter clean
    flutter pub get
    
    # 生成图标
    if command -v dart &> /dev/null; then
        echo_info "生成应用图标..."
        dart run flutter_launcher_icons:main
    fi
    
    # 构建 Linux 版本
    flutter build linux --release
    
    if [ ! -d "build/linux/x64/release/bundle" ]; then
        echo_error "Flutter 构建失败"
        exit 1
    fi
    
    echo_success "Flutter 应用构建完成"
}

# 创建 DEB 包目录结构
create_deb_structure() {
    echo_info "创建 DEB 包目录结构..."
    
    DEB_DIR="build/deb"
    mkdir -p "$DEB_DIR"
    
    # 创建标准的 Debian 包目录结构
    mkdir -p "$DEB_DIR/DEBIAN"
    mkdir -p "$DEB_DIR/usr/bin"
    mkdir -p "$DEB_DIR/usr/share/applications"
    mkdir -p "$DEB_DIR/usr/share/pixmaps"
    mkdir -p "$DEB_DIR/usr/share/icons/hicolor/16x16/apps"
    mkdir -p "$DEB_DIR/usr/share/icons/hicolor/32x32/apps"
    mkdir -p "$DEB_DIR/usr/share/icons/hicolor/48x48/apps"
    mkdir -p "$DEB_DIR/usr/share/icons/hicolor/64x64/apps"
    mkdir -p "$DEB_DIR/usr/share/icons/hicolor/128x128/apps"
    mkdir -p "$DEB_DIR/usr/share/icons/hicolor/256x256/apps"
    mkdir -p "$DEB_DIR/usr/share/$APP_NAME"
    
    echo_success "目录结构创建完成"
}

# 复制应用文件
copy_app_files() {
    echo_info "复制应用文件..."
    
    DEB_DIR="build/deb"
    
    # 复制整个应用包到 /usr/share/money-gua/
    cp -r build/linux/x64/release/bundle/* "$DEB_DIR/usr/share/$APP_NAME/"
    
    # 创建启动脚本
    cat > "$DEB_DIR/usr/bin/$APP_NAME" << EOF
#!/bin/bash
# 金钱卦应用启动脚本

# 设置应用目录
APP_DIR="/usr/share/$APP_NAME"

# 切换到应用目录
cd "\$APP_DIR"

# 启动应用
exec "./money_gua" "\$@"
EOF
    
    chmod +x "$DEB_DIR/usr/bin/$APP_NAME"
    
    echo_success "应用文件复制完成"
}

# 处理图标文件
setup_icons() {
    echo_info "设置应用图标..."
    
    DEB_DIR="build/deb"
    ICON_SOURCE="assets/icon.png"
    
    if [ ! -f "$ICON_SOURCE" ]; then
        echo_error "图标文件不存在: $ICON_SOURCE"
        exit 1
    fi
    
    # 复制主图标到 pixmaps (用于向后兼容)
    cp "$ICON_SOURCE" "$DEB_DIR/usr/share/pixmaps/$APP_NAME.png"
    
    # 如果有 ImageMagick，生成不同尺寸的图标
    if command -v convert &> /dev/null; then
        echo_info "生成不同尺寸的图标..."
        
        # 生成各种尺寸的图标
        convert "$ICON_SOURCE" -resize 16x16 "$DEB_DIR/usr/share/icons/hicolor/16x16/apps/$APP_NAME.png"
        convert "$ICON_SOURCE" -resize 32x32 "$DEB_DIR/usr/share/icons/hicolor/32x32/apps/$APP_NAME.png"
        convert "$ICON_SOURCE" -resize 48x48 "$DEB_DIR/usr/share/icons/hicolor/48x48/apps/$APP_NAME.png"
        convert "$ICON_SOURCE" -resize 64x64 "$DEB_DIR/usr/share/icons/hicolor/64x64/apps/$APP_NAME.png"
        convert "$ICON_SOURCE" -resize 128x128 "$DEB_DIR/usr/share/icons/hicolor/128x128/apps/$APP_NAME.png"
        convert "$ICON_SOURCE" -resize 256x256 "$DEB_DIR/usr/share/icons/hicolor/256x256/apps/$APP_NAME.png"
        
        echo_success "多尺寸图标生成完成"
    else
        echo_warning "ImageMagick 未安装，使用原始图标"
        # 直接复制原始图标到各个目录
        for size in 16x16 32x32 48x48 64x64 128x128 256x256; do
            cp "$ICON_SOURCE" "$DEB_DIR/usr/share/icons/hicolor/$size/apps/$APP_NAME.png"
        done
    fi
    
    echo_success "图标设置完成"
}

# 创建桌面文件
create_desktop_file() {
    echo_info "创建桌面文件..."
    
    DEB_DIR="build/deb"
    
    cat > "$DEB_DIR/usr/share/applications/$APP_NAME.desktop" << EOF
[Desktop Entry]
Version=1.0
Type=Application
Name=$APP_DISPLAY_NAME
Name[zh_CN]=$APP_DISPLAY_NAME
Comment=$APP_DESCRIPTION
Comment[zh_CN]=$APP_DESCRIPTION
Exec=$APP_NAME
Icon=$APP_NAME
Terminal=false
Categories=$CATEGORY;Utility;
Keywords=易经;占卜;金钱卦;divination;iching;
StartupNotify=true
StartupWMClass=money_gua
MimeType=
EOF
    
    echo_success "桌面文件创建完成"
}

# 创建 DEBIAN 控制文件
create_control_files() {
    echo_info "创建 DEBIAN 控制文件..."
    
    DEB_DIR="build/deb"
    
    # 计算安装大小 (KB)
    INSTALLED_SIZE=$(du -sk "$DEB_DIR/usr" | cut -f1)
    
    # 创建 control 文件
    cat > "$DEB_DIR/DEBIAN/control" << EOF
Package: $APP_NAME
Version: $APP_VERSION
Section: $CATEGORY
Priority: optional
Architecture: $ARCHITECTURE
Installed-Size: $INSTALLED_SIZE
Depends: libc6, libgtk-3-0, libglib2.0-0, libgstreamer1.0-0, libgstreamer-plugins-base1.0-0
Maintainer: $MAINTAINER
Description: $APP_DESCRIPTION
 金钱卦是一个基于传统易经的占卜应用，提供简单易用的卦象解读功能。
 .
 主要功能：
 - 传统金钱卦占卜
 - 卦象详细解读
 - 语音朗读功能
 - 历史记录保存
Homepage: https://github.com/yourusername/money-gua
EOF
    
    # 创建 postinst 脚本 (安装后执行)
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

# 更新 MIME 数据库
if command -v update-mime-database >/dev/null 2>&1; then
    update-mime-database /usr/share/mime >/dev/null 2>&1 || true
fi

echo "金钱卦应用安装完成！"
echo "您可以在应用菜单中找到它，或者在终端中运行 'money-gua' 启动。"

exit 0
EOF
    
    # 创建 prerm 脚本 (卸载前执行)
    cat > "$DEB_DIR/DEBIAN/prerm" << 'EOF'
#!/bin/bash
set -e

echo "正在卸载金钱卦应用..."

exit 0
EOF
    
    # 创建 postrm 脚本 (卸载后执行)
    cat > "$DEB_DIR/DEBIAN/postrm" << 'EOF'
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

echo "金钱卦应用已完全卸载。"

exit 0
EOF
    
    # 设置脚本权限
    chmod 755 "$DEB_DIR/DEBIAN/postinst"
    chmod 755 "$DEB_DIR/DEBIAN/prerm"
    chmod 755 "$DEB_DIR/DEBIAN/postrm"
    
    echo_success "DEBIAN 控制文件创建完成"
}

# 构建 DEB 包
build_deb_package() {
    echo_info "构建 DEB 包..."
    
    DEB_DIR="build/deb"
    DEB_FILE="${APP_NAME}_${APP_VERSION}_${ARCHITECTURE}.deb"
    
    # 设置正确的文件权限
    find "$DEB_DIR" -type f -exec chmod 644 {} \;
    find "$DEB_DIR" -type d -exec chmod 755 {} \;
    chmod 755 "$DEB_DIR/usr/bin/$APP_NAME"
    chmod 755 "$DEB_DIR/usr/share/$APP_NAME/money_gua"
    
    # 构建 DEB 包
    dpkg-deb --build "$DEB_DIR" "$DEB_FILE"
    
    if [ -f "$DEB_FILE" ]; then
        echo_success "DEB 包构建完成: $DEB_FILE"
        
        # 显示包信息
        echo_info "包信息:"
        dpkg-deb --info "$DEB_FILE"
        
        echo_info "包内容:"
        dpkg-deb --contents "$DEB_FILE"
        
        # 显示文件大小
        FILE_SIZE=$(du -h "$DEB_FILE" | cut -f1)
        echo_success "包大小: $FILE_SIZE"
        
    else
        echo_error "DEB 包构建失败"
        exit 1
    fi
}

# 验证 DEB 包
verify_deb_package() {
    echo_info "验证 DEB 包..."
    
    DEB_FILE="${APP_NAME}_${APP_VERSION}_${ARCHITECTURE}.deb"
    
    # 检查包的完整性
    if dpkg-deb --info "$DEB_FILE" >/dev/null 2>&1; then
        echo_success "DEB 包验证通过"
    else
        echo_error "DEB 包验证失败"
        exit 1
    fi
    
    # 检查 lintian (如果可用)
    if command -v lintian &> /dev/null; then
        echo_info "运行 lintian 检查..."
        lintian "$DEB_FILE" || echo_warning "lintian 检查发现一些警告，但不影响使用"
    fi
}

# 显示安装说明
show_install_instructions() {
    echo_success "=== DEB 包构建完成 ==="
    echo
    echo_info "安装方法:"
    echo "  sudo dpkg -i ${APP_NAME}_${APP_VERSION}_${ARCHITECTURE}.deb"
    echo "  sudo apt-get install -f  # 如果有依赖问题"
    echo
    echo_info "卸载方法:"
    echo "  sudo apt remove $APP_NAME"
    echo
    echo_info "启动方法:"
    echo "  1. 在应用菜单中找到 '$APP_DISPLAY_NAME'"
    echo "  2. 或在终端中运行: $APP_NAME"
    echo
    echo_info "图标说明:"
    echo "  - 应用图标已正确配置"
    echo "  - 任务栏将显示应用专用图标而非默认齿轮图标"
    echo "  - 支持多种尺寸以适应不同的显示环境"
    echo
    echo_success "打包完成！"
}

# 主函数
main() {
    echo_info "开始构建金钱卦应用 DEB 包..."
    echo
    
    # 检查是否在正确的目录
    if [ ! -f "pubspec.yaml" ] || [ ! -f "lib/main.dart" ]; then
        echo_error "请在 money_gua 应用根目录运行此脚本"
        exit 1
    fi
    
    # 执行构建步骤
    check_dependencies
    clean_build
    build_flutter_app
    create_deb_structure
    copy_app_files
    setup_icons
    create_desktop_file
    create_control_files
    build_deb_package
    verify_deb_package
    show_install_instructions
}

# 运行主函数
main "$@"