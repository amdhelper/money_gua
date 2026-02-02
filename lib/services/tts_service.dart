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

  String? _edgeTtsPath;

  TtsService._internal() {
    _init();
  }

  Future<void> _init() async {
    if (!kIsWeb && Platform.isLinux) {
      _isLinux = true;
      
      // 1. Check for local python_env (Development/Portable)
      // We check current directory first.
      final localPath = '${Directory.current.path}/python_env/bin/edge-tts';
      if (await File(localPath).exists()) {
        _edgeTtsPath = localPath;
        _useEdgeTtsCli = true;
        debugPrint('TTS: Found local edge-tts at $_edgeTtsPath');
      } else {
        // 2. Check system path
        try {
          final result = await Process.run('which', ['edge-tts']);
          if (result.exitCode == 0) {
            _edgeTtsPath = result.stdout.toString().trim();
            _useEdgeTtsCli = true;
            debugPrint('TTS: Found system edge-tts at $_edgeTtsPath');
          }
        } catch (e) {
          debugPrint('TTS: Error checking for system edge-tts: $e');
        }
      }
      
      if (!_useEdgeTtsCli) {
         debugPrint('TTS: edge-tts not found. Falling back to system TTS.');
      }
    }

    if (!_useEdgeTtsCli) {
      await _flutterTts.setLanguage("zh-CN");
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setSpeechRate(0.5);
    }
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;

    // Stop previous playback
    await stop();

    if (_useEdgeTtsCli && _edgeTtsPath != null) {
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
      final bytes = utf8.encode(text);
      final hash = sha256.convert(bytes).toString().substring(0, 10);
      final filePath = '${tempDir.path}/tts_$hash.mp3';
      final file = File(filePath);

      if (!await file.exists()) {
        debugPrint('TTS: Generating audio for "$text" using $_edgeTtsPath');
        final process = await Process.run(_edgeTtsPath!, [
          '--text', text,
          '--voice', 'zh-CN-YunxiNeural',
          '--write-media', filePath
        ]);

        if (process.exitCode != 0) {
          debugPrint('EdgeTTS Error: ${process.stderr}');
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
