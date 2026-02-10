import 'package:flutter/material.dart';
import '../models/divination_record.dart';
import '../services/divination_storage_service.dart';
import 'record_detail_page.dart';
import 'add_record_page.dart';

class HistoryPageMobile extends StatefulWidget {
  const HistoryPageMobile({super.key});

  @override
  State<HistoryPageMobile> createState() => _HistoryPageMobileState();
}

class _HistoryPageMobileState extends State<HistoryPageMobile> {
  final DivinationStorageService _storageService =
      DivinationStorageService.instance;
  List<DivinationRecord> _records = [];
  List<DivinationRecord> _filteredRecords = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadRecords();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRecords() async {
    setState(() => _isLoading = true);
    try {
      final records = await _storageService.getAllRecords();
      setState(() {
        _records = records;
        _filteredRecords = records;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('加载记录失败: $e')));
      }
    }
  }

  void _filterRecords(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredRecords = _records;
      } else {
        _filteredRecords = _records.where((record) {
          return record.question.toLowerCase().contains(query.toLowerCase()) ||
              (record.notes?.toLowerCase().contains(query.toLowerCase()) ??
                  false);
        }).toList();
      }
    });
  }

  Future<void> _deleteRecord(DivinationRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除占卜记录"${record.question}"吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _storageService.deleteRecord(record.id);
        await _loadRecords();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('记录已删除')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('删除失败: $e')));
        }
      }
    }
  }

  Future<void> _clearAllRecords() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认清空'),
        content: const Text('确定要清空所有占卜记录吗？此操作不可恢复。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('清空'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _storageService.clearAllRecords();
        await _loadRecords();
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('所有记录已清空')));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('清空失败: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('占卜历史'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_records.isNotEmpty)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'clear') {
                  _clearAllRecords();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'clear',
                  child: Row(
                    children: [
                      Icon(Icons.clear_all, color: Colors.red),
                      SizedBox(width: 8),
                      Text('清空所有记录', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterRecords,
              decoration: InputDecoration(
                hintText: '搜索问题或备注...',
                hintStyle: const TextStyle(color: Colors.white54),
                prefixIcon: const Icon(Icons.search, color: Colors.white54),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, color: Colors.white54),
                        onPressed: () {
                          _searchController.clear();
                          _filterRecords('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFF1E1E1E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredRecords.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
                    onRefresh: _loadRecords,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredRecords.length,
                      itemBuilder: (context, index) {
                        final record = _filteredRecords[index];
                        return _buildRecordCard(record);
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (context) => const AddRecordPage()),
          );
          if (result == true) {
            _loadRecords();
          }
        },
        backgroundColor: const Color(0xFFFFD700),
        foregroundColor: Colors.black87,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Colors.white.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            _searchController.text.isNotEmpty ? '没有找到相关记录' : '还没有占卜记录',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchController.text.isNotEmpty ? '尝试其他关键词' : '开始你的第一次占卜吧',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecordCard(DivinationRecord record) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (context) => RecordDetailPage(record: record),
            ),
          );
          if (result == true) {
            _loadRecords();
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final baseWidth = (constraints.maxWidth / 27).clamp(14.0, 72.0);
            final lineWidth = baseWidth * 3;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: lineWidth,
                    child: _buildLinePreview(
                      record.lines,
                      lineWidth: lineWidth,
                      barHeight: 6,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildRecordText(record),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildRecordText(DivinationRecord record) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                record.question,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  _deleteRecord(record);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('删除', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              child: const Icon(Icons.more_vert, color: Colors.white54),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700).withOpacity(0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                record.hexagram.name,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFFFFD700),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                record.hexagram.title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          '${record.hexagram.upperTrigram}${record.hexagram.lowerTrigram}${record.hexagram.title}卦',
          style: const TextStyle(fontSize: 12, color: Colors.white60),
        ),
        if (record.notes != null && record.notes!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            record.notes!,
            style: const TextStyle(fontSize: 14, color: Colors.white60),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
        const SizedBox(height: 8),
        Text(
          record.formattedDate,
          style: const TextStyle(fontSize: 12, color: Colors.white38),
        ),
      ],
    );
  }

  Widget _buildLinePreview(
    String lines, {
    required double lineWidth,
    required double barHeight,
  }) {
    final bits = lines.split('');
    return Column(
      children: List.generate(6, (index) {
        final bitIndex = 5 - index;
        final isYang = bits[bitIndex] == '1';
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              SizedBox(
                width: lineWidth,
                child: isYang
                    ? Container(
                        height: barHeight,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: barHeight,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFD700),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Container(
                              height: barHeight,
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFD700),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
