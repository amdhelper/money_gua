import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/hexagram.dart';
import '../widgets/yin_yang_switch.dart';
import '../widgets/tap_to_read.dart';
import '../services/tts_service.dart';

class ResultPage extends StatefulWidget {
  final Hexagram hexagram;

  const ResultPage({super.key, required this.hexagram});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  late TextEditingController _noteController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill with description? Or empty for user notes?
    // Let's pre-fill with the summary + description to allow them to edit/annotate it.
    _noteController = TextEditingController(
      text: "${widget.hexagram.summary}\n\n${widget.hexagram.description}"
    );
  }

  @override
  void dispose() {
    TtsService().stop();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _saveRecord() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> history = prefs.getStringList('gua_history') ?? [];
      
      Map<String, dynamic> record = {
        'timestamp': DateTime.now().toIso8601String(),
        'hexagram_id': widget.hexagram.id,
        'hexagram_name': widget.hexagram.name,
        'binary': widget.hexagram.binary,
        'note': _noteController.text,
      };
      
      history.insert(0, jsonEncode(record)); // Add to top
      await prefs.setStringList('gua_history', history);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('卦象已保存')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: TapToRead(
          text: widget.hexagram.title,
          child: Text(widget.hexagram.title),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: _isSaving 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                : const Icon(Icons.save),
            onPressed: _isSaving ? null : _saveRecord,
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Visual Representation (Small)
            Center(child: _buildHexagramVisual()),
            const SizedBox(height: 32),
            
            // 2. Breakdown
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTrigramInfo("上卦", widget.hexagram.upperTrigram),
                const Icon(Icons.add, color: Colors.white24),
                _buildTrigramInfo("下卦", widget.hexagram.lowerTrigram),
              ],
            ),
            const Divider(color: Colors.white24, height: 48),

            // 3. Details & Editing
            const Text(
              "卦辞解读 & 笔记",
              style: TextStyle(color: Color(0xFFA8D8B9), fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // The content itself should be clickable to read
            TapToRead(
              text: "断曰：${widget.hexagram.summary}。${widget.hexagram.description}",
              label: "卦辞",
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.hexagram.summary,
                      style: const TextStyle(color: Color(0xFFFFD700), fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.hexagram.description,
                      style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Text("您的感悟", style: TextStyle(color: Colors.white54, fontSize: 14)),
            const SizedBox(height: 8),

            TextField(
              controller: _noteController,
              maxLines: null,
              style: const TextStyle(color: Colors.white70, fontSize: 16, height: 1.5),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                hintText: "在此记录您的感悟...",
                hintStyle: const TextStyle(color: Colors.white30),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHexagramVisual() {
    // Top (index 5) to Bottom (index 0)
    List<String> bits = widget.hexagram.binary.split('');
    return Column(
      children: List.generate(6, (index) {
        int bitIndex = 5 - index;
        bool isYang = bits[bitIndex] == '1';
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: SizedBox(
            width: 120, // Smaller than home page
            height: 24,
            child: CustomPaint(
              painter: _BarPainter(isYang: isYang, color: const Color(0xFFFFD700)),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildTrigramInfo(String label, String name) {
    return TapToRead(
      text: "$label $name",
      child: Column(
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 14)),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _BarPainter extends CustomPainter {
  final bool isYang;
  final Color color;

  _BarPainter({required this.isYang, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    if (isYang) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, size.width, size.height), const Radius.circular(4)),
        paint,
      );
    } else {
      double w = (size.width - size.height) / 2; // Gap approx height width
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, size.height), const Radius.circular(4)),
        paint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(size.width - w, 0, w, size.height), const Radius.circular(4)),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
