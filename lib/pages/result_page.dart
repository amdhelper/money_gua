import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../models/hexagram.dart';
import '../services/divination_storage_service.dart';
import '../services/hexagram_note_service.dart';
import '../widgets/tap_to_read.dart';
import '../services/tts_service.dart';
import '../data/hexagram_data.dart';
import 'history_page.dart';

class ResultPage extends StatefulWidget {
  final Hexagram hexagram;
  final List<bool> lines;

  const ResultPage({super.key, required this.hexagram, required this.lines});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  final DivinationStorageService _storageService =
      DivinationStorageService.instance;
  final HexagramNoteService _noteService = HexagramNoteService.instance;
  late TextEditingController _noteController;
  String? _savedNote;
  bool _isSaving = false;
  bool _isSavingNote = false;
  bool _hasSavedRecord = false;
  String? _savedRecordId;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController();
    _loadSavedNote();
    _autoSaveRecord();
  }

  Future<void> _loadSavedNote() async {
    final note = await _noteService.getNoteForHexagram(widget.hexagram.id);
    if (!mounted) return;
    setState(() {
      _savedNote = note;
      _noteController.text = note ?? '';
    });
  }

  @override
  void dispose() {
    TtsService().stop();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _showSaveRecordDialog() async {
    final questionController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('保存占卜记录', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: questionController,
              decoration: const InputDecoration(
                labelText: '占卜问题',
                labelStyle: TextStyle(color: Colors.white70),
                hintText: '请输入你占卜时想问的问题...',
                hintStyle: TextStyle(color: Colors.white54),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Color(0xFF2D2D2D),
              ),
              style: const TextStyle(color: Colors.white),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              if (questionController.text.trim().isNotEmpty) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('保存', style: TextStyle(color: Color(0xFFFFD700))),
          ),
        ],
      ),
    );

    if (result == true && questionController.text.trim().isNotEmpty) {
      await _saveRecord(questionController.text.trim());
    }

    questionController.dispose();
  }

  Future<void> _autoSaveRecord() async {
    if (_hasSavedRecord) return;
    setState(() => _isSaving = true);

    try {
      final record = _storageService.createRecord(
        question: '未标注问题',
        lines: widget.lines,
        notes: null,
      );

      await _storageService.saveRecord(record);

      if (mounted) {
        setState(() {
          _hasSavedRecord = true;
          _savedRecordId = record.id;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _saveRecord(String question) async {
    if (_hasSavedRecord) {
      if (_savedRecordId != null) {
        try {
          final existing = await _storageService.getRecordById(_savedRecordId!);
          if (existing != null) {
            final updated = existing.copyWith(question: question.trim());
            await _storageService.updateRecord(updated);
            if (mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('问题已更新')));
            }
            return;
          }
        } catch (_) {
          // Fallback below to create new record
        }
      }
    }
    setState(() => _isSaving = true);

    try {
      final record = _storageService.createRecord(
        question: question,
        lines: widget.lines,
        notes: null,
      );

      await _storageService.saveRecord(record);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('占卜记录已保存')));
        setState(() {
          _hasSavedRecord = true;
          _savedRecordId = record.id;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('保存失败: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  Future<void> _saveHexagramNote() async {
    setState(() => _isSavingNote = true);
    try {
      await _noteService.saveNoteForHexagram(
        widget.hexagram.id,
        _noteController.text,
      );
      if (!mounted) return;
      setState(() {
        _savedNote = _noteController.text.trim().isEmpty
            ? null
            : _noteController.text.trim();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('笔记已保存')));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('保存笔记失败: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSavingNote = false);
      }
    }
  }

  void _openHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HistoryPage()),
    );
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
            icon: const Icon(Icons.access_time),
            onPressed: _openHistory,
            tooltip: '历史记录',
          ),
          IconButton(
            icon: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.save),
            onPressed: _isSaving ? null : _showSaveRecordDialog,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Visual Representation (Small)
            Center(child: _buildHexagramVisual()),
            const SizedBox(height: 24),

            // 2. Composite Name (New)
            Center(
              child: TapToRead(
                text:
                    "上${widget.hexagram.upperTrigram}下${widget.hexagram.lowerTrigram}，${widget.hexagram.title}，第${widget.hexagram.id}卦",
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white10,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "上${widget.hexagram.upperTrigram}下${widget.hexagram.lowerTrigram} = ${widget.hexagram.title}（第 ${widget.hexagram.id} 卦）",
                    style: const TextStyle(
                      color: Color(0xFFA8D8B9),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // 3. Breakdown with Visuals & Attributes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Upper Trigram (Indices 3,4,5)
                _buildEnhancedTrigramInfo(
                  "上卦",
                  widget.hexagram.upperTrigram,
                  widget.hexagram.binary.substring(3, 6),
                ),
                const Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Icon(Icons.add, color: Colors.white24),
                ),
                // Lower Trigram (Indices 0,1,2)
                _buildEnhancedTrigramInfo(
                  "下卦",
                  widget.hexagram.lowerTrigram,
                  widget.hexagram.binary.substring(0, 3),
                ),
              ],
            ),
            const Divider(color: Colors.white24, height: 48),

            // 4. Vernacular Translation
            if (widget.hexagram.translation.isNotEmpty) ...[
              const Text(
                "白话译文",
                style: TextStyle(
                  color: Color(0xFFA8D8B9),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TapToRead(
                text: widget.hexagram.translation,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2D2D2D),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.hexagram.translation,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      height: 1.6,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],

            // 4.5 Detailed Interpretation (New)
            if (widget.hexagram.detailedInterpretation.isNotEmpty) ...[
              const Text(
                "深度解析",
                style: TextStyle(
                  color: Color(0xFFA8D8B9),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TapToRead(
                text: widget.hexagram.detailedInterpretation,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A2F),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Text(
                    widget.hexagram.detailedInterpretation,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      height: 1.7,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],

            // 5. Waterfall Content (Images & Detailed Meanings)
            if (widget.hexagram.imageLeft.isNotEmpty ||
                widget.hexagram.imageRight.isNotEmpty) ...[
              const Text(
                "图解卦义",
                style: TextStyle(
                  color: Color(0xFFA8D8B9),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              MasonryGridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount:
                    (widget.hexagram.imageLeft.isNotEmpty ? 1 : 0) +
                    (widget.hexagram.imageRight.isNotEmpty ? 1 : 0),
                itemBuilder: (context, index) {
                  bool isLeft =
                      index == 0 && widget.hexagram.imageLeft.isNotEmpty;
                  String imgPath = isLeft
                      ? widget.hexagram.imageLeft
                      : widget.hexagram.imageRight;
                  String meaning = isLeft
                      ? widget.hexagram.leftMeaning
                      : widget.hexagram.rightMeaning;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          TtsService().speak(meaning);
                          showDialog(
                            context: context,
                            builder: (context) => Dialog(
                              backgroundColor: Colors.transparent,
                              insetPadding: EdgeInsets.zero,
                              child: Stack(
                                children: [
                                  InteractiveViewer(
                                    panEnabled: true,
                                    minScale: 0.5,
                                    maxScale: 4.0,
                                    child: Center(
                                      child: Image.asset(
                                        imgPath,
                                        fit: BoxFit.contain,
                                        width: MediaQuery.of(
                                          context,
                                        ).size.width,
                                        height: MediaQuery.of(
                                          context,
                                        ).size.height,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 40,
                                    right: 20,
                                    child: IconButton(
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 30,
                                      ),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            imgPath,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  height: 100,
                                  color: Colors.white10,
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    color: Colors.white24,
                                  ),
                                ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TapToRead(
                        text: meaning,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Text(
                            meaning,
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 32),
            ],

            // 6. Details & Editing
            const Text(
              "卦辞解读 & 笔记",
              style: TextStyle(
                color: Color(0xFFA8D8B9),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // The content itself should be clickable to read
            TapToRead(
              text:
                  "断曰：${widget.hexagram.summary}。${widget.hexagram.description}",
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
                      style: const TextStyle(
                        color: Color(0xFFFFD700),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.hexagram.description,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Text(
              "您的感悟",
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 8),

            TextField(
              controller: _noteController,
              maxLines: null,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                height: 1.5,
              ),
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
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isSavingNote ? null : _saveHexagramNote,
                icon: _isSavingNote
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: const Text('保存笔记'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFD700),
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            if (_savedNote != null && _savedNote!.trim().isNotEmpty) ...[
              const SizedBox(height: 16),
              TapToRead(
                text: _savedNote!,
                label: "笔记",
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Text(
                    _savedNote!,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHexagramVisual() {
    List<String> bits = widget.hexagram.binary.split('');
    return Column(
      children: List.generate(6, (index) {
        int bitIndex = 5 - index;
        bool isYang = bits[bitIndex] == '1';
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0),
          child: SizedBox(
            width: 120,
            height: 24,
            child: CustomPaint(
              painter: _BarPainter(
                isYang: isYang,
                color: const Color(0xFFFFD700),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildEnhancedTrigramInfo(String label, String name, String binary) {
    String attributes = trigramAttributes[binary] ?? "";

    return TapToRead(
      text: "$label $name卦。$attributes",
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white54, fontSize: 14),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 60,
            height: 40,
            child: _TrigramPainter(
              binary: binary,
              color: const Color(0xFFFFD700),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "($attributes)",
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _TrigramPainter extends StatelessWidget {
  final String binary;
  final Color color;

  const _TrigramPainter({required this.binary, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildLine(binary[2] == '1'), // Top
        _buildLine(binary[1] == '1'), // Middle
        _buildLine(binary[0] == '1'), // Bottom
      ],
    );
  }

  Widget _buildLine(bool isYang) {
    return Container(
      height: 8,
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Row(
        children: isYang
            ? [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ]
            : [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
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
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, size.width, size.height),
          const Radius.circular(4),
        ),
        paint,
      );
    } else {
      double w = (size.width - size.height) / 2;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(0, 0, w, size.height),
          const Radius.circular(4),
        ),
        paint,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(size.width - w, 0, w, size.height),
          const Radius.circular(4),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
