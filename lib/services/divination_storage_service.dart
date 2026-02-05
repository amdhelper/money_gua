import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/divination_record.dart';
import '../data/hexagram_data.dart';

class DivinationStorageService {
  static const String _storageKey = 'divination_records';
  static DivinationStorageService? _instance;

  DivinationStorageService._();

  static DivinationStorageService get instance {
    _instance ??= DivinationStorageService._();
    return _instance!;
  }

  /// 保存占卜记录
  Future<void> saveRecord(DivinationRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final records = await getAllRecords();

    // 添加新记录到列表开头
    records.insert(0, record);

    // 限制最多保存100条记录
    if (records.length > 100) {
      records.removeRange(100, records.length);
    }

    final jsonList = records.map((r) => r.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  /// 获取所有占卜记录
  Future<List<DivinationRecord>> getAllRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);

    if (jsonString == null) return [];

    try {
      final jsonList = jsonDecode(jsonString) as List;
      return jsonList.map((json) => DivinationRecord.fromJson(json)).toList();
    } catch (e) {
      // 如果解析失败，返回空列表
      return [];
    }
  }

  /// 更新占卜记录
  Future<void> updateRecord(DivinationRecord updatedRecord) async {
    final records = await getAllRecords();
    final index = records.indexWhere((r) => r.id == updatedRecord.id);

    if (index != -1) {
      records[index] = updatedRecord;
      final prefs = await SharedPreferences.getInstance();
      final jsonList = records.map((r) => r.toJson()).toList();
      await prefs.setString(_storageKey, jsonEncode(jsonList));
    }
  }

  /// 删除占卜记录
  Future<void> deleteRecord(String recordId) async {
    final records = await getAllRecords();
    records.removeWhere((r) => r.id == recordId);

    final prefs = await SharedPreferences.getInstance();
    final jsonList = records.map((r) => r.toJson()).toList();
    await prefs.setString(_storageKey, jsonEncode(jsonList));
  }

  /// 根据ID获取单个记录
  Future<DivinationRecord?> getRecordById(String id) async {
    final records = await getAllRecords();
    try {
      return records.firstWhere((r) => r.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 搜索记录（根据问题或备注）
  Future<List<DivinationRecord>> searchRecords(String query) async {
    if (query.trim().isEmpty) return getAllRecords();

    final records = await getAllRecords();
    final lowerQuery = query.toLowerCase();

    return records.where((record) {
      return record.question.toLowerCase().contains(lowerQuery) ||
          (record.notes?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  /// 清空所有记录
  Future<void> clearAllRecords() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }

  /// 创建新的占卜记录
  DivinationRecord createRecord({
    required String question,
    required List<bool> lines,
    String? notes,
  }) {
    final binary = lines.map((e) => e ? '1' : '0').join('');
    final hexagram = getHexagram(binary);

    return DivinationRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      question: question.trim(),
      lines: binary,
      hexagram: hexagram,
      timestamp: DateTime.now(),
      notes: notes?.trim(),
    );
  }
}
