import 'package:flutter/material.dart';
import '../services/tts_service.dart';

class TapToRead extends StatelessWidget {
  final String text;
  final Widget child;
  final String? label; // Optional semantic label

  const TapToRead({
    super.key,
    required this.text,
    required this.child,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        TtsService().speak(text);
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('正在朗读: ${label ?? "..."}'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFF333333),
          ),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: child,
    );
  }
}
