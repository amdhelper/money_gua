import 'package:flutter/material.dart';
import '../services/divination_storage_service.dart';
import '../widgets/yin_yang_switch.dart';
import '../data/hexagram_data.dart';

class AddRecordPage extends StatefulWidget {
  const AddRecordPage({super.key});

  @override
  State<AddRecordPage> createState() => _AddRecordPageState();
}

class _AddRecordPageState extends State<AddRecordPage> {
  final DivinationStorageService _storageService =
      DivinationStorageService.instance;
  final TextEditingController _questionController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  // 默认为乾卦（全阳）
  List<bool> lines = List.filled(6, true);
  bool _isSaving = false;

  @override
  void dispose() {
    _questionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _toggleLine(int index) {
    setState(() {
      lines[index] = !lines[index];
    });
  }

  String get _currentBinary {
    return lines.map((e) => e ? '1' : '0').join('');
  }

  Future<void> _saveRecord() async {
    if (_questionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请输入占卜问题')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final record = _storageService.createRecord(
        question: _questionController.text,
        lines: lines,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text,
      );

      await _storageService.saveRecord(record);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('占卜记录已保存')));
        Navigator.pop(context, true); // 返回 true 表示已保存
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('保存失败: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentHexagram = getHexagram(_currentBinary);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('添加占卜记录'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: _saveRecord,
              child: const Text(
                '保存',
                style: TextStyle(color: Color(0xFFFFD700), fontSize: 16),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 占卜问题输入
            const Text(
              '占卜问题',
              style: TextStyle(
                color: Color(0xFFFFD700),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _questionController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: '请输入你想要占卜的问题...',
                hintStyle: TextStyle(color: Colors.white54),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Color(0xFF1E1E1E),
              ),
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),

            const SizedBox(height: 32),

            // 爻象设置
            const Text(
              '设置爻象',
              style: TextStyle(
                color: Color(0xFFFFD700),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '请自下而上设置爻象（点击切换阴阳）',
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
            const SizedBox(height: 16),

            // 爻象显示和编辑
            ...List.generate(6, (index) {
              int lineIndex = 5 - index; // 从上到下显示，但索引是从下到上
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 40,
                      child: Text(
                        '${lineIndex + 1}',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: YinYangSwitch(
                        isYang: lines[lineIndex],
                        onToggle: () => _toggleLine(lineIndex),
                        activeColor: const Color(0xFFFFD700),
                        inactiveColor: const Color(0xFF424242),
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 32),

            // 当前卦象预览
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    '当前卦象',
                    style: TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    currentHexagram.name,
                    style: const TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currentHexagram.title,
                    style: const TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    currentHexagram.summary,
                    style: const TextStyle(color: Colors.white60, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // 备注输入
            const Text(
              '备注（可选）',
              style: TextStyle(
                color: Color(0xFFFFD700),
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: '添加你的备注、感想或其他信息...',
                hintStyle: TextStyle(color: Colors.white54),
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Color(0xFF1E1E1E),
              ),
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
