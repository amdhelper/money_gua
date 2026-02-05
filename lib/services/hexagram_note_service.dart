import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HexagramNoteService {
  static const String _storageKey = 'hexagram_notes';
  static HexagramNoteService? _instance;

  HexagramNoteService._();

  static HexagramNoteService get instance {
    _instance ??= HexagramNoteService._();
    return _instance!;
  }

  Future<Map<String, String>> _getAllNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);

    if (jsonString == null || jsonString.trim().isEmpty) return {};

    try {
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      return decoded.map((key, value) => MapEntry(key, value.toString()));
    } catch (_) {
      return {};
    }
  }

  Future<String?> getNoteForHexagram(int hexagramId) async {
    final notes = await _getAllNotes();
    return notes[hexagramId.toString()];
  }

  Future<void> saveNoteForHexagram(int hexagramId, String note) async {
    final prefs = await SharedPreferences.getInstance();
    final notes = await _getAllNotes();

    if (note.trim().isEmpty) {
      notes.remove(hexagramId.toString());
    } else {
      notes[hexagramId.toString()] = note.trim();
    }

    await prefs.setString(_storageKey, jsonEncode(notes));
  }
}
