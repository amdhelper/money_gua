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

  String? _edgeTtsPath;
  String? _edgeTtsPythonPath;
  bool _edgeTtsNeedsPython = false;
  late final Future<void> _initFuture;

  TtsService._internal() {
    _initFuture = _init();
  }

  Future<void> _init() async {
    if (!kIsWeb && Platform.isLinux) {
      // 1. Check for installed app's python_env (when installed via DEB)
      final installedPath = '/usr/share/money-gua/python_env/bin/edge-tts';
      if (await File(installedPath).exists()) {
        if (await _configureEdgeTts(installedPath)) {
          debugPrint('TTS: Found installed edge-tts at $_edgeTtsPath');
        }
      } else {
        // 2. Check for local python_env (Development/Portable)
        final localPath = '${Directory.current.path}/python_env/bin/edge-tts';
        if (await File(localPath).exists()) {
          if (await _configureEdgeTts(localPath)) {
            debugPrint('TTS: Found local edge-tts at $_edgeTtsPath');
          }
        } else {
          // 3. Check system path
          try {
            final result = await Process.run('which', ['edge-tts']);
            if (result.exitCode == 0) {
              final systemPath = result.stdout.toString().trim();
              if (await _configureEdgeTts(systemPath)) {
                debugPrint('TTS: Found system edge-tts at $_edgeTtsPath');
              }
            }
          } catch (e) {
            debugPrint('TTS: Error checking for system edge-tts: $e');
          }
        }
      }

      if (!_useEdgeTtsCli) {
        debugPrint('TTS: edge-tts not found. Falling back to system TTS.');
      }
    }

    if (!_useEdgeTtsCli) {
      try {
        await _flutterTts.setLanguage("zh-CN");
        await _flutterTts.setPitch(1.0);
        await _flutterTts.setSpeechRate(0.5);
      } catch (e) {
        debugPrint('TTS: Error initializing flutter_tts: $e');
      }
    }
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;

    await _initFuture;

    // Stop previous playback
    await stop();

    if (_useEdgeTtsCli && _edgeTtsPath != null) {
      await _speakWithEdgeCli(text);
    } else {
      try {
        await _flutterTts.speak(text);
      } catch (e) {
        debugPrint('TTS: Error with flutter_tts, trying edge-tts fallback: $e');
        if (_edgeTtsPath != null) {
          await _speakWithEdgeCli(text);
        }
      }
    }
  }

  Future<void> stop() async {
    await _initFuture;
    await _audioPlayer.stop();

    // Only call flutter_tts.stop() if not using edge-tts CLI
    if (!_useEdgeTtsCli) {
      try {
        await _flutterTts.stop();
      } catch (e) {
        debugPrint('TTS: Error stopping flutter_tts: $e');
      }
    }
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
        final args = [
          '--text',
          text,
          '--voice',
          'zh-CN-YunxiNeural',
          '--write-media',
          filePath,
        ];
        final process = _edgeTtsNeedsPython && _edgeTtsPythonPath != null
            ? await Process.run(_edgeTtsPythonPath!, [_edgeTtsPath!, ...args])
            : await Process.run(_edgeTtsPath!, args);

        if (process.exitCode != 0) {
          debugPrint('EdgeTTS Error: ${process.stderr}');
          // Fallback to flutter_tts only if edge-tts fails
          try {
            await _flutterTts.speak(text);
          } catch (e) {
            debugPrint('TTS: Both edge-tts and flutter_tts failed: $e');
          }
          return;
        }
      }

      debugPrint('TTS: Playing audio file: $filePath');
      await _audioPlayer.play(DeviceFileSource(filePath));
    } catch (e) {
      debugPrint('EdgeTTS Exception: $e');
      // Fallback to flutter_tts only if edge-tts fails
      try {
        await _flutterTts.speak(text);
      } catch (e2) {
        debugPrint('TTS: Both edge-tts and flutter_tts failed: $e2');
      }
    }
  }

  Future<bool> _configureEdgeTts(String path) async {
    final normalized = path.trim();
    if (normalized.isEmpty) return false;
    if (!await _isExecutable(normalized)) {
      final binDir = File(normalized).parent.path;
      final python3Path = '$binDir/python3';
      final pythonPath = '$binDir/python';
      if (await File(python3Path).exists()) {
        _edgeTtsPythonPath = python3Path;
        _edgeTtsNeedsPython = true;
      } else if (await File(pythonPath).exists()) {
        _edgeTtsPythonPath = pythonPath;
        _edgeTtsNeedsPython = true;
      } else {
        debugPrint('TTS: edge-tts exists but not executable: $normalized');
        return false;
      }
    }

    _edgeTtsPath = normalized;
    _useEdgeTtsCli = true;
    return true;
  }

  Future<bool> _isExecutable(String path) async {
    try {
      final stat = await File(path).stat();
      return (stat.mode & 0x49) != 0;
    } catch (_) {
      return false;
    }
  }
}
