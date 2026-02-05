import 'package:intl/intl.dart';
import 'hexagram.dart';

class DivinationRecord {
  final String id;
  final String question;
  final String lines; // 六爻线条，如 "111111"
  final Hexagram hexagram;
  final DateTime timestamp;
  final String? notes;

  DivinationRecord({
    required this.id,
    required this.question,
    required this.lines,
    required this.hexagram,
    required this.timestamp,
    this.notes,
  });

  factory DivinationRecord.fromJson(Map<String, dynamic> json) {
    return DivinationRecord(
      id: json['id'],
      question: json['question'],
      lines: json['lines'],
      hexagram: Hexagram.fromJson(json['hexagram']),
      timestamp: DateTime.parse(json['timestamp']),
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question': question,
      'lines': lines,
      'hexagram': hexagram.toJson(),
      'timestamp': timestamp.toIso8601String(),
      'notes': notes,
    };
  }

  DivinationRecord copyWith({
    String? id,
    String? question,
    String? lines,
    Hexagram? hexagram,
    DateTime? timestamp,
    String? notes,
  }) {
    return DivinationRecord(
      id: id ?? this.id,
      question: question ?? this.question,
      lines: lines ?? this.lines,
      hexagram: hexagram ?? this.hexagram,
      timestamp: timestamp ?? this.timestamp,
      notes: notes ?? this.notes,
    );
  }

  String get formattedDate {
    return DateFormat('yyyy-MM-dd HH:mm').format(timestamp);
  }

  String get shortDate {
    return DateFormat('MM-dd HH:mm').format(timestamp);
  }
}
