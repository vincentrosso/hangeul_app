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

enum QuizMode { flashcard, multipleChoice }

class QuizCardResult {
  final CharCard card;
  final bool correct;
  const QuizCardResult({required this.card, required this.correct});
}
