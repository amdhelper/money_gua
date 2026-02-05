import 'package:flutter/material.dart';
import '../models/divination_record.dart';
import '../services/divination_storage_service.dart';
import '../widgets/yin_yang_switch.dart';

class RecordDetailPage extends StatefulWidget {
  final DivinationRecord record;

  const RecordDetailPage({super.key, required this.record});

  @override
  State<RecordDetailPage> createState() => _RecordDetailPageState();
}

class _RecordDetailPageState extends State<RecordDetailPage> {
  final DivinationStorageService _storageService =
      DivinationStorageService.instance;
  late TextEditingController _questionController;
  late TextEditingController _notesController;
  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.record.question);
    _notesController = TextEditingController(text: widget.record.notes ?? '');
  }

  @override
  void dispose() {
    _questionController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (_questionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('问题不能为空')));
      return;
    }

    setState(() => _isSaving = true);

    try {
      final updatedRecord = widget.record.copyWith(
        question: _questionController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      await _storageService.updateRecord(updatedRecord);

      setState(() {
        _isEditing = false;
        _isSaving = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('保存成功')));
        Navigator.pop(context, true); // 返回 true 表示有更新
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

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _questionController.text = widget.record.question;
      _notesController.text = widget.record.notes ?? '';
    });
  }

  List<bool> _getLinesFromBinary(String binary) {
    return binary.split('').map((e) => e == '1').toList();
  }

  @override
  Widget build(BuildContext context) {
    final lines = _getLinesFromBinary(widget.record.lines);

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('占卜详情'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_isEditing) ...[
            if (_isSaving)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else ...[
              TextButton(
                onPressed: _cancelEdit,
                child: const Text(
                  '取消',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
              TextButton(
                onPressed: _saveChanges,
                child: const Text(
                  '保存',
                  style: TextStyle(color: Color(0xFFFFD700)),
                ),
              ),
            ],
          ] else
            IconButton(
              onPressed: () => setState(() => _isEditing = true),
              icon: const Icon(Icons.edit),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 占卜问题
            _buildSection(
              title: '占卜问题',
              child: _isEditing
                  ? TextField(
                      controller: _questionController,
                      maxLines: null,
                      decoration: const InputDecoration(
                        hintText: '请输入占卜问题...',
                        hintStyle: TextStyle(color: Colors.white54),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Color(0xFF1E1E1E),
                      ),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    )
                  : Text(
                      widget.record.question,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
            ),

            const SizedBox(height: 24),

            // 卦象显示
            _buildSection(
              title: '卦象',
              child: Column(
                children: [
                  // 卦名和标题
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          widget.record.hexagram.name,
                          style: const TextStyle(
                            color: Color(0xFFFFD700),
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.record.hexagram.title,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 爻象显示
                  ...List.generate(6, (index) {
                    int lineIndex = 5 - index; // 从上到下显示
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4.0),
                      child: YinYangSwitch(
                        isYang: lines[lineIndex],
                        onToggle: null, // 不可编辑
                        activeColor: const Color(0xFFFFD700),
                        inactiveColor: const Color(0xFF424242),
                      ),
                    );
                  }),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 卦象解释
            _buildSection(
              title: '卦象解释',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoCard('卦辞', widget.record.hexagram.description),
                  const SizedBox(height: 12),
                  _buildInfoCard('总结', widget.record.hexagram.summary),
                  const SizedBox(height: 12),
                  _buildInfoCard('解读', widget.record.hexagram.translation),
                  if (widget
                      .record
                      .hexagram
                      .detailedInterpretation
                      .isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildInfoCard(
                      '详细解释',
                      widget.record.hexagram.detailedInterpretation,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 备注
            _buildSection(
              title: '备注',
              child: _isEditing
                  ? TextField(
                      controller: _notesController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: '添加你的备注...',
                        hintStyle: TextStyle(color: Colors.white54),
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Color(0xFF1E1E1E),
                      ),
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    )
                  : Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1E1E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        widget.record.notes?.isNotEmpty == true
                            ? widget.record.notes!
                            : '暂无备注',
                        style: TextStyle(
                          color: widget.record.notes?.isNotEmpty == true
                              ? Colors.white70
                              : Colors.white38,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
            ),

            const SizedBox(height: 24),

            // 占卜时间
            _buildSection(
              title: '占卜时间',
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.record.formattedDate,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFFFFD700),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildInfoCard(String title, String content) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFFFFD700),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
