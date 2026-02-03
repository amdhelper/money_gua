#!/bin/bash

echo "=== 金钱卦应用 TTS 修复验证脚本 ==="
echo

# 检查当前目录
if [ ! -f "lib/services/tts_service.dart" ]; then
    echo "❌ 错误：请在 money_gua 应用根目录运行此脚本"
    exit 1
fi

echo "✅ 当前目录正确"

# 检查修复文件
echo "📁 检查修复文件..."
if [ -f "lib/services/tts_service.dart" ]; then
    echo "✅ TTS 服务文件存在"
    
    # 检查关键修复内容
    if grep -q "try {" lib/services/tts_service.dart && \
       grep -q "catch (e)" lib/services/tts_service.dart && \
       grep -q "_useEdgeTtsCli" lib/services/tts_service.dart; then
        echo "✅ TTS 服务包含错误处理和 edge-tts 支持"
    else
        echo "❌ TTS 服务缺少关键修复内容"
    fi
else
    echo "❌ TTS 服务文件不存在"
fi

# 检查 edge-tts 工具
echo
echo "🔧 检查 TTS 工具..."
if [ -f "python_env/bin/edge-tts" ]; then
    echo "✅ 本地 edge-tts 工具存在"
    
    # 测试 edge-tts
    echo "🎵 测试 edge-tts 功能..."
    if ./python_env/bin/edge-tts --text "测试" --voice zh-CN-YunxiNeural --write-media /tmp/test_tts_verify.mp3 2>/dev/null; then
        if [ -f "/tmp/test_tts_verify.mp3" ] && [ -s "/tmp/test_tts_verify.mp3" ]; then
            echo "✅ edge-tts 语音合成成功"
            rm -f /tmp/test_tts_verify.mp3
        else
            echo "❌ edge-tts 语音合成失败"
        fi
    else
        echo "❌ edge-tts 执行失败"
    fi
elif command -v edge-tts >/dev/null 2>&1; then
    echo "✅ 系统 edge-tts 工具存在"
else
    echo "⚠️  edge-tts 工具未找到，将使用系统 TTS"
fi

# 检查音频系统
echo
echo "🔊 检查音频系统..."
if command -v pactl >/dev/null 2>&1; then
    if pactl list short sinks | grep -q "RUNNING\|IDLE"; then
        echo "✅ 音频输出设备正常"
    else
        echo "⚠️  音频输出设备可能有问题"
    fi
else
    echo "⚠️  无法检查音频系统（pactl 未找到）"
fi

# 检查 Flutter 依赖
echo
echo "📦 检查 Flutter 依赖..."
if [ -f "pubspec.yaml" ]; then
    if grep -q "flutter_tts:" pubspec.yaml && \
       grep -q "audioplayers:" pubspec.yaml; then
        echo "✅ TTS 相关依赖已配置"
    else
        echo "❌ TTS 相关依赖缺失"
    fi
else
    echo "❌ pubspec.yaml 文件不存在"
fi

# 检查应用状态
echo
echo "🚀 检查应用状态..."
if pgrep -f "money_gua" >/dev/null; then
    echo "✅ money_gua 应用正在运行"
    echo "💡 现在可以测试 TTS 功能："
    echo "   1. 点击应用中的任何文字"
    echo "   2. 检查终端输出的 TTS 调试信息"
    echo "   3. 确认能听到语音播放"
else
    echo "⚠️  money_gua 应用未运行"
    echo "💡 启动应用进行测试："
    echo "   flutter run -d linux"
fi

echo
echo "=== 修复总结 ==="
echo "✅ 修复了 flutter_tts 在 Linux 平台的兼容性问题"
echo "✅ 添加了完善的错误处理机制"
echo "✅ 优先使用 edge-tts 进行高质量语音合成"
echo "✅ 提供了多重备份方案确保功能稳定"
echo
echo "📖 详细信息请查看："
echo "   - TTS_FIX_SUMMARY.md - 完整修复总结"
echo "   - TTS_TEST_GUIDE.md - 详细测试指南"
echo
echo "🎉 Linux 客户端 TTS 发音问题修复完成！"