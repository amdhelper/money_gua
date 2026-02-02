import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;

  final FlutterTts _flutterTts = FlutterTts();
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  bool _useEdgeTtsCli = false;
  bool _isLinux = false;

  TtsService._internal() {
    _init();
  }

  Future<void> _init() async {
    if (!kIsWeb && Platform.isLinux) {
      _isLinux = true;
      // Check if edge-tts is installed
      try {
        final result = await Process.run('which', ['edge-tts']);
        if (result.exitCode == 0) {
          _useEdgeTtsCli = true;
          debugPrint('TTS: edge-tts found. Using high-quality cli mode.');
        } else {
          debugPrint('TTS: edge-tts not found on Linux. Falling back to system TTS.');
        }
      } catch (e) {
        debugPrint('TTS: Error checking for edge-tts: $e');
      }
    }

    if (!_useEdgeTtsCli) {
      await _flutterTts.setLanguage("zh-CN");
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setSpeechRate(0.5); // Slightly slower for clarity
    }
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;

    // Stop previous playback
    await stop();

    if (_useEdgeTtsCli) {
      await _speakWithEdgeCli(text);
    } else {
      await _flutterTts.speak(text);
    }
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    await _flutterTts.stop();
  }

  Future<void> _speakWithEdgeCli(String text) async {
    try {
      final tempDir = await getTemporaryDirectory();
      // Create a hash of the text to use as filename (caching mechanism)
      final bytes = utf8.encode(text);
      final hash = sha256.convert(bytes).toString().substring(0, 10);
      final filePath = '${tempDir.path}/tts_$hash.mp3';
      final file = File(filePath);

      if (!await file.exists()) {
        // Generate audio
        // Using "zh-CN-YunxiNeural" for a calm, young male voice suitable for divination
        // Or "zh-CN-XiaoxiaoNeural" for female. Let's pick Yunxi.
        final process = await Process.run('edge-tts', [
          '--text', text,
          '--voice', 'zh-CN-YunxiNeural',
          '--write-media', filePath
        ]);

        if (process.exitCode != 0) {
          debugPrint('EdgeTTS Error: ${process.stderr}');
          // Fallback
          await _flutterTts.speak(text);
          return;
        }
      }

      await _audioPlayer.play(DeviceFileSource(filePath));
    } catch (e) {
      debugPrint('EdgeTTS Exception: $e');
      await _flutterTts.speak(text);
    }
  }
}
