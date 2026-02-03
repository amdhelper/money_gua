# 金钱卦应用 DEB 打包指南

## 概述

本指南介绍如何将金钱卦 Flutter 应用打包成 DEB 格式，确保在 Linux 系统上正确安装和显示，特别是任务栏图标的正确显示。

## 🎯 关键特性

- ✅ **正确的任务栏图标**：不再显示默认齿轮图标
- ✅ **多尺寸图标支持**：适配不同显示环境
- ✅ **完整的桌面集成**：应用菜单、MIME 类型等
- ✅ **自动依赖管理**：包含所需的系统库
- ✅ **安装后脚本**：自动更新系统缓存

## 📋 前置要求

### 系统依赖
```bash
# Ubuntu/Debian
sudo apt install dpkg-dev imagemagick

# 可选：用于包验证
sudo apt install lintian
```

### Flutter 环境
```bash
# 确保 Flutter 已安装并配置
flutter doctor
flutter config --enable-linux-desktop
```

## 🚀 快速打包

### 方法一：使用快速打包脚本（推荐）
```bash
# 在 money_gua 目录下运行
./quick_build_deb.sh
```

### 方法二：使用完整打包脚本
```bash
# 功能更全面，包含更多验证
./build_deb.sh
```

## 📁 打包脚本说明

### quick_build_deb.sh
- **用途**：快速打包，适合日常开发
- **特点**：简化流程，专注核心功能
- **输出**：`money-gua_1.0.0_amd64.deb`

### build_deb.sh
- **用途**：完整打包，适合正式发布
- **特点**：包含完整验证和错误处理
- **输出**：详细的构建日志和包信息

### test_icon.sh
- **用途**：测试图标配置
- **特点**：验证图标文件和配置是否正确

## 🎨 图标配置详解

### 图标文件结构
```
assets/
└── icon.png                    # 主图标文件 (建议 512x512)

# 打包后的系统图标位置
/usr/share/pixmaps/money-gua.png
/usr/share/icons/hicolor/*/apps/money-gua.png
```

### 任务栏图标配置

#### 1. 桌面文件配置
```ini
# /usr/share/applications/money-gua.desktop
[Desktop Entry]
Name=金钱卦
Icon=money-gua                   # 指向系统图标
StartupWMClass=money_gua         # 关键：与应用窗口类名匹配
```

#### 2. 应用代码配置
```cpp
// linux/flutter/my_application.cc
gtk_window_set_wmclass(window, "money_gua", "Money Gua");
gtk_window_set_icon_name(window, "money-gua");
```

#### 3. 图标安装位置
- `/usr/share/pixmaps/money-gua.png` - 向后兼容
- `/usr/share/icons/hicolor/*/apps/money-gua.png` - 现代图标主题

## 📦 DEB 包结构

```
money-gua_1.0.0_amd64.deb
├── DEBIAN/
│   ├── control                  # 包信息
│   ├── postinst                 # 安装后脚本
│   └── postrm                   # 卸载后脚本
└── usr/
    ├── bin/
    │   └── money-gua            # 启动脚本
    ├── share/
    │   ├── applications/
    │   │   └── money-gua.desktop # 桌面文件
    │   ├── pixmaps/
    │   │   └── money-gua.png    # 主图标
    │   ├── icons/hicolor/       # 多尺寸图标
    │   └── money-gua/           # 应用文件
    │       ├── money_gua        # 主程序
    │       ├── lib/             # 依赖库
    │       └── data/            # 资源文件
```

## 🔧 安装和使用

### 安装 DEB 包
```bash
# 安装
sudo dpkg -i money-gua_1.0.0_amd64.deb

# 如果有依赖问题
sudo apt-get install -f
```

### 启动应用
```bash
# 方法1：命令行启动
money-gua

# 方法2：从应用菜单启动
# 在应用菜单中找到"金钱卦"
```

### 卸载应用
```bash
sudo apt remove money-gua
```

## 🐛 故障排除

### 图标不显示问题

#### 检查图标文件
```bash
# 检查图标是否存在
ls -la /usr/share/pixmaps/money-gua.png
ls -la /usr/share/icons/hicolor/48x48/apps/money-gua.png
```

#### 更新图标缓存
```bash
sudo gtk-update-icon-cache -f -t /usr/share/icons/hicolor
sudo update-desktop-database /usr/share/applications
```

#### 检查桌面文件
```bash
# 验证桌面文件语法
desktop-file-validate /usr/share/applications/money-gua.desktop
```

### 任务栏显示齿轮图标

#### 原因分析
1. **WM_CLASS 不匹配**：桌面文件中的 `StartupWMClass` 与应用实际的窗口类名不一致
2. **图标名称错误**：桌面文件中的 `Icon` 字段指向的图标不存在
3. **图标缓存未更新**：系统图标缓存没有及时更新

#### 解决方案
```bash
# 1. 检查应用的实际窗口类名
xprop WM_CLASS  # 然后点击应用窗口

# 2. 确保桌面文件中的 StartupWMClass 匹配
grep StartupWMClass /usr/share/applications/money-gua.desktop

# 3. 更新缓存
sudo gtk-update-icon-cache -f -t /usr/share/icons/hicolor
```

### 应用无法启动

#### 检查依赖
```bash
# 检查缺失的依赖
ldd /usr/share/money-gua/money_gua
```

#### 检查权限
```bash
# 确保执行权限
ls -la /usr/bin/money-gua
ls -la /usr/share/money-gua/money_gua
```

## 📝 自定义配置

### 修改应用信息
编辑打包脚本中的变量：
```bash
APP_NAME="money-gua"
APP_DISPLAY_NAME="金钱卦"
APP_VERSION="1.0.0"
APP_DESCRIPTION="金钱卦占卜应用 - 传统易经占卜工具"
```

### 修改图标
1. 替换 `assets/icon.png`
2. 重新运行打包脚本

### 添加依赖
编辑 `DEBIAN/control` 文件中的 `Depends` 字段：
```
Depends: libc6, libgtk-3-0, libglib2.0-0, 你的新依赖
```

## 🎯 最佳实践

### 图标设计
- **尺寸**：建议使用 512x512 或更大的 PNG 图标
- **背景**：使用透明背景
- **清晰度**：确保在小尺寸下仍然清晰可见
- **风格**：遵循目标桌面环境的设计规范

### 版本管理
- 使用语义化版本号（如 1.0.0）
- 在 `DEBIAN/control` 中正确设置版本
- 考虑使用构建号区分不同构建

### 测试
- 在不同的 Linux 发行版上测试
- 验证图标在不同主题下的显示
- 测试安装、运行、卸载流程

## 📚 参考资料

- [Debian 包管理指南](https://www.debian.org/doc/debian-policy/)
- [Flutter Linux 桌面开发](https://docs.flutter.dev/platform-integration/linux/building)
- [GTK 应用图标规范](https://developer.gnome.org/hig/patterns/app-icons.html)
- [桌面文件规范](https://specifications.freedesktop.org/desktop-entry-spec/desktop-entry-spec-latest.html)

## 🎉 完成

按照本指南，您应该能够成功创建一个在 Linux 系统上正确显示图标的 DEB 包。如果遇到问题，请参考故障排除部分或检查相关日志文件。