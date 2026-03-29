import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/models.dart';

class MasteryService {
  static final instance = MasteryService._();
  MasteryService._();

  static const _prefKey = 'char_mastery';

  Map<String, CharMastery> _cache = {};

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefKey);
    if (raw != null && raw.isNotEmpty) {
      try {
        _cache = CharMastery.decodeAll(raw);
      } catch (_) {
        _cache = {};
      }
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, CharMastery.encodeAll(_cache));
  }

  CharMastery get(String charId) {
    return _cache[charId] ?? CharMastery.initial(charId);
  }

  /// Apply SM-2 review. quality: 0–5
  Future<void> applyReview(String charId, int quality) async {
    final current = get(charId);

    int newInterval;
    double newEase;

    if (quality < 3) {
      newInterval = 1;
      newEase = current.easeFactor;
    } else {
      newInterval = max(1, (current.intervalDays * current.easeFactor).round());
      newEase = max(
        1.3,
        current.easeFactor + 0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02),
      );
    }

    final newDue = DateTime.now().add(Duration(days: newInterval));

    // Upgrade mastery level based on quality
    MasteryLevel newLevel = current.level;
    if (quality >= 4) {
      if (current.level == MasteryLevel.unseen ||
          current.level == MasteryLevel.seen) {
        newLevel = MasteryLevel.recognized;
      } else if (current.level == MasteryLevel.recognized) {
        newLevel = MasteryLevel.canWrite;
      }
    } else if (quality >= 3) {
      if (current.level == MasteryLevel.unseen) {
        newLevel = MasteryLevel.seen;
      }
    }

    _cache[charId] = current.copyWith(
      level: newLevel,
      easeFactor: newEase,
      intervalDays: newInterval,
      dueDate: newDue,
      totalReviews: current.totalReviews + 1,
    );
    await _save();
  }

  /// Mark as seen (level = max(current, seen))
  Future<void> markSeen(String charId) async {
    final current = get(charId);
    if (current.level == MasteryLevel.unseen) {
      _cache[charId] = current.copyWith(level: MasteryLevel.seen);
      await _save();
    }
  }

  /// Get all card IDs due today or overdue, sorted by dueDate ascending
  List<String> getDueCardIds(List<CharCard> allCards) {
    final now = DateTime.now();
    final due = <CharMastery>[];

    for (final card in allCards) {
      final m = get(card.audioStem);
      if (m.level != MasteryLevel.unseen) {
        if (!m.dueDate.isAfter(now)) {
          due.add(m);
        }
      }
    }

    due.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    return due.map((m) => m.charId).toList();
  }

  /// Get completed lesson numbers — a lesson is complete if all chars are
  /// recognized or canWrite.
  Future<Set<int>> getCompletedLessonNumbers(List<Lesson> lessons) async {
    final completed = <int>{};
    for (final lesson in lessons) {
      final allDone = lesson.chars.every((c) {
        final m = get(c.audioStem);
        return m.level == MasteryLevel.recognized ||
            m.level == MasteryLevel.canWrite;
      });
      if (allDone) completed.add(lesson.number);
    }
    return completed;
  }

  Future<void> reset() async {
    _cache = {};
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
  }
}
