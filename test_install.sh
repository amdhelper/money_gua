#!/bin/bash

# 金钱卦应用 DEB 包安装测试脚本

set -e

DEB_FILE="money-gua_1.0.0_amd64.deb"

echo "🧪 金钱卦应用 DEB 包安装测试"
echo "================================"

# 检查 DEB 文件是否存在
if [ ! -f "$DEB_FILE" ]; then
    echo "❌ DEB 文件不存在: $DEB_FILE"
    echo "请先运行 ./quick_build_deb.sh 构建 DEB 包"
    exit 1
fi

echo "✅ 找到 DEB 文件: $DEB_FILE"

# 显示包信息
echo
echo "📦 包信息:"
dpkg-deb --info "$DEB_FILE"

# 检查包内容
echo
echo "📁 关键文件检查:"
echo "检查桌面文件..."
if dpkg-deb --contents "$DEB_FILE" | grep -q "money-gua.desktop"; then
    echo "✅ 桌面文件存在"
else
    echo "❌ 桌面文件缺失"
fi

echo "检查图标文件..."
if dpkg-deb --contents "$DEB_FILE" | grep -q "pixmaps/money-gua.png"; then
    echo "✅ 主图标文件存在"
else
    echo "❌ 主图标文件缺失"
fi

echo "检查多尺寸图标..."
ICON_SIZES="16x16 32x32 48x48 64x64 128x128 256x256"
for size in $ICON_SIZES; do
    if dpkg-deb --contents "$DEB_FILE" | grep -q "hicolor/$size/apps/money-gua.png"; then
        echo "✅ $size 图标存在"
    else
        echo "⚠️  $size 图标缺失"
    fi
done

echo "检查启动脚本..."
if dpkg-deb --contents "$DEB_FILE" | grep -q "usr/bin/money-gua"; then
    echo "✅ 启动脚本存在"
else
    echo "❌ 启动脚本缺失"
fi

echo "检查主程序..."
if dpkg-deb --contents "$DEB_FILE" | grep -q "money-gua/money_gua"; then
    echo "✅ 主程序存在"
else
    echo "❌ 主程序缺失"
fi

# 提供安装选项
echo
echo "🚀 安装选项:"
echo "1. 模拟安装 (不实际安装，只检查依赖)"
echo "2. 实际安装 (需要 sudo 权限)"
echo "3. 跳过安装"
echo

read -p "请选择 (1/2/3): " choice

case $choice in
    1)
        echo "🔍 模拟安装..."
        sudo dpkg --dry-run -i "$DEB_FILE"
        echo "✅ 模拟安装完成，无依赖问题"
        ;;
    2)
        echo "📥 开始实际安装..."
        sudo dpkg -i "$DEB_FILE"
        
        # 检查是否需要修复依赖
        if [ $? -ne 0 ]; then
            echo "⚠️  安装过程中出现依赖问题，尝试修复..."
            sudo apt-get install -f
        fi
        
        # 验证安装
        if dpkg -l | grep -q "money-gua"; then
            echo "✅ 安装成功！"
            
            # 测试启动
            echo
            echo "🧪 测试应用启动..."
            echo "请在新终端中运行以下命令测试："
            echo "  money-gua"
            echo
            echo "或者在应用菜单中查找 '金钱卦'"
            
            # 检查图标缓存更新
            echo
            echo "🔄 检查图标缓存..."
            if [ -f "/usr/share/icons/hicolor/48x48/apps/money-gua.png" ]; then
                echo "✅ 图标文件已安装"
            else
                echo "❌ 图标文件安装失败"
            fi
            
            # 手动更新缓存
            echo "🔄 更新系统缓存..."
            sudo gtk-update-icon-cache -f -t /usr/share/icons/hicolor 2>/dev/null || true
            sudo update-desktop-database /usr/share/applications 2>/dev/null || true
            echo "✅ 缓存更新完成"
            
        else
            echo "❌ 安装失败"
        fi
        ;;
    3)
        echo "⏭️  跳过安装"
        ;;
    *)
        echo "❌ 无效选择"
        exit 1
        ;;
esac

echo
echo "📋 安装后检查清单:"
echo "1. 运行 'money-gua' 命令启动应用"
echo "2. 在应用菜单中查找 '金钱卦'"
echo "3. 检查任务栏是否显示正确的应用图标"
echo "4. 测试 TTS 语音功能"

echo
echo "🗑️  卸载命令:"
echo "  sudo apt remove money-gua"

echo
echo "✨ 测试完成！"