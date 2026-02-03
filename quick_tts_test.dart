import 'dart:io';
import 'lib/services/tts_service.dart';

void main() async {
  print('=== 快速 TTS 功能测试 ===');

  // 初始化 TTS 服务
  final tts = TtsService();

  // 等待初始化完成
  await Future.delayed(Duration(seconds: 2));

  print('测试语音合成...');

  try {
    await tts.speak('测试金钱卦应用的语音功能');
    print('✓ TTS 调用成功');

    // 等待播放完成
    await Future.delayed(Duration(seconds: 3));

    await tts.stop();
    print('✓ TTS 停止成功');
  } catch (e) {
    print('✗ TTS 调用失败: $e');
  }

  print('测试完成');
  exit(0);
}
