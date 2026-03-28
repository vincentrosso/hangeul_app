import 'package:shared_preferences/shared_preferences.dart';

class ProgressService {
  static const _key = 'completed_lessons';

  static Future<Set<int>> loadCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    return list.map(int.parse).toSet();
  }

  static Future<void> markComplete(int lessonNumber) async {
    final prefs = await SharedPreferences.getInstance();
    final current = (prefs.getStringList(_key) ?? []).toSet();
    current.add(lessonNumber.toString());
    await prefs.setStringList(_key, current.toList());
  }

  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
