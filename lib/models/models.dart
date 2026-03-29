import 'dart:convert';

class CharCard {
  final String char;
  final String romanized;
  final String example;

  const CharCard({
    required this.char,
    required this.romanized,
    required this.example,
  });

  String get audioStem =>
      char.codeUnits.map((c) => c.toRadixString(16).padLeft(4, '0')).join('_');

  String get gttsAsset => 'assets/audio/$audioStem.mp3';
  String get nativeAsset => 'assets/audio/${audioStem}_native.ogg';
}

class Lesson {
  final int number;
  final String titleEn;
  final String titleKr;
  final String note;
  final List<CharCard> chars;

  const Lesson({
    required this.number,
    required this.titleEn,
    required this.titleKr,
    required this.note,
    required this.chars,
  });
}

enum QuizMode { flashcard, multipleChoice, trace, freeDraw }

enum MasteryLevel { unseen, seen, recognized, canWrite }

class QuizCardResult {
  final CharCard card;
  final bool correct;
  const QuizCardResult({required this.card, required this.correct});
}

class CharMastery {
  final String charId;
  final MasteryLevel level;
  final double easeFactor;
  final int intervalDays;
  final DateTime dueDate;
  final int totalReviews;

  const CharMastery({
    required this.charId,
    required this.level,
    required this.easeFactor,
    required this.intervalDays,
    required this.dueDate,
    required this.totalReviews,
  });

  factory CharMastery.initial(String charId) {
    return CharMastery(
      charId: charId,
      level: MasteryLevel.unseen,
      easeFactor: 2.5,
      intervalDays: 1,
      dueDate: DateTime.now(),
      totalReviews: 0,
    );
  }

  CharMastery copyWith({
    String? charId,
    MasteryLevel? level,
    double? easeFactor,
    int? intervalDays,
    DateTime? dueDate,
    int? totalReviews,
  }) {
    return CharMastery(
      charId: charId ?? this.charId,
      level: level ?? this.level,
      easeFactor: easeFactor ?? this.easeFactor,
      intervalDays: intervalDays ?? this.intervalDays,
      dueDate: dueDate ?? this.dueDate,
      totalReviews: totalReviews ?? this.totalReviews,
    );
  }

  Map<String, dynamic> toJson() => {
        'charId': charId,
        'level': level.index,
        'easeFactor': easeFactor,
        'intervalDays': intervalDays,
        'dueDate': dueDate.toIso8601String(),
        'totalReviews': totalReviews,
      };

  factory CharMastery.fromJson(Map<String, dynamic> json) {
    return CharMastery(
      charId: json['charId'] as String,
      level: MasteryLevel.values[json['level'] as int],
      easeFactor: (json['easeFactor'] as num).toDouble(),
      intervalDays: json['intervalDays'] as int,
      dueDate: DateTime.parse(json['dueDate'] as String),
      totalReviews: json['totalReviews'] as int,
    );
  }

  static String encodeAll(Map<String, CharMastery> map) {
    final encoded = map.map((k, v) => MapEntry(k, v.toJson()));
    return jsonEncode(encoded);
  }

  static Map<String, CharMastery> decodeAll(String json) {
    final decoded = jsonDecode(json) as Map<String, dynamic>;
    return decoded.map((k, v) => MapEntry(k, CharMastery.fromJson(v as Map<String, dynamic>)));
  }
}
