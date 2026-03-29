import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/lessons.dart';
import '../models/models.dart';
import '../services/mastery_service.dart';
import '../theme/app_theme.dart';
import 'lesson_screen.dart';
import 'practice_screen.dart';
import 'quiz_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Set<int> _completed = {};
  Map<int, Map<MasteryLevel, int>> _lessonMastery = {};
  int _dueCount = 0;

  static const _heroChars = ['가','나','다','라','마','바','사','아'];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final completed = await MasteryService.instance.getCompletedLessonNumbers(kLessons);
    final allCards = kLessons.expand((l) => l.chars).toList();
    final dueIds = MasteryService.instance.getDueCardIds(allCards);

    // Build per-lesson mastery counts
    final mastery = <int, Map<MasteryLevel, int>>{};
    for (final lesson in kLessons) {
      final counts = <MasteryLevel, int>{};
      for (final level in MasteryLevel.values) {
        counts[level] = 0;
      }
      for (final card in lesson.chars) {
        final m = MasteryService.instance.get(card.audioStem).level;
        counts[m] = (counts[m] ?? 0) + 1;
      }
      mastery[lesson.number] = counts;
    }

    if (mounted) {
      setState(() {
        _completed = completed;
        _lessonMastery = mastery;
        _dueCount = dueIds.length;
      });
    }
  }

  String get _heroChar =>
      _heroChars[_completed.length.clamp(0, _heroChars.length - 1)];

  double get _progress => _completed.length / kLessons.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('한글'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${_completed.length} / ${kLessons.length} lessons',
                  style: GoogleFonts.dmMono(
                    fontSize: 10, letterSpacing: 1,
                    color: AppTheme.lightMuted,
                  ),
                ),
                const SizedBox(height: 3),
                SizedBox(
                  width: 80,
                  child: LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: Colors.white24,
                    valueColor: const AlwaysStoppedAnimation(AppTheme.accent),
                    minHeight: 3,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Hero
          SliverToBoxAdapter(child: _buildHero()),

          // Practice banner
          if (_dueCount > 0)
            SliverToBoxAdapter(child: _buildPracticeBanner()),

          // Section label
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Row(
                children: [
                  Container(width: 3, height: 16, color: AppTheme.accent),
                  const SizedBox(width: 10),
                  Text(
                    'CURRICULUM · 교과 과정',
                    style: GoogleFonts.dmMono(
                      fontSize: 10, letterSpacing: 2, color: AppTheme.muted,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Lesson list
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) => _LessonRow(
                lesson: kLessons[i],
                isDone: _completed.contains(kLessons[i].number),
                isNext: !_completed.contains(kLessons[i].number) &&
                    (i == 0 ||
                        _completed.contains(kLessons[i - 1].number)),
                masteryCount: _lessonMastery[kLessons[i].number] ?? {},
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => LessonScreen(
                        lesson: kLessons[i],
                        onComplete: () async {
                          // Mark all chars as seen when completing
                          for (final c in kLessons[i].chars) {
                            await MasteryService.instance.markSeen(c.audioStem);
                          }
                          _load();
                        },
                      ),
                    ),
                  );
                  _load();
                },
                onQuizTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QuizScreen(lesson: kLessons[i]),
                    ),
                  );
                  _load();
                },
              ),
              childCount: kLessons.length,
            ),
          ),

          // Footer quote
          SliverToBoxAdapter(child: _buildFooter()),
        ],
      ),
    );
  }

  Widget _buildPracticeBanner() {
    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PracticeScreen(lessons: kLessons),
          ),
        );
        _load();
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.accent.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.accent.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: AppTheme.accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.local_fire_department_outlined,
                color: AppTheme.accent,
                size: 18,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'PRACTICE · 연습',
                    style: GoogleFonts.dmMono(
                      fontSize: 10, letterSpacing: 2, color: AppTheme.accent,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$_dueCount card${_dueCount == 1 ? '' : 's'} due for review',
                    style: GoogleFonts.dmMono(
                      fontSize: 12, color: AppTheme.ink,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: AppTheme.accent.withOpacity(0.6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHero() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Text(
            _heroChar,
            style: GoogleFonts.notoSerifKr(
              fontSize: 88, fontWeight: FontWeight.w700, color: AppTheme.ink,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'The Korean Alphabet',
            style: GoogleFonts.playfairDisplay(
              fontSize: 22, fontStyle: FontStyle.italic, color: AppTheme.ink,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'LEARN TO READ & WRITE IN 8 LESSONS',
            style: GoogleFonts.dmMono(
              fontSize: 10, letterSpacing: 2, color: AppTheme.muted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 60),
      child: Column(
        children: [
          const Divider(),
          const SizedBox(height: 20),
          Text(
            '천 리 길도 한 걸음부터',
            style: GoogleFonts.notoSerifKr(fontSize: 16, color: AppTheme.ink),
          ),
          const SizedBox(height: 6),
          Text(
            'A JOURNEY OF A THOUSAND MILES BEGINS WITH A SINGLE STEP',
            textAlign: TextAlign.center,
            style: GoogleFonts.dmMono(
              fontSize: 9, letterSpacing: 1.5, color: AppTheme.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonRow extends StatelessWidget {
  final Lesson lesson;
  final bool isDone;
  final bool isNext;
  final Map<MasteryLevel, int> masteryCount;
  final VoidCallback onTap;
  final VoidCallback onQuizTap;

  const _LessonRow({
    required this.lesson,
    required this.isDone,
    required this.isNext,
    required this.masteryCount,
    required this.onTap,
    required this.onQuizTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: AppTheme.border)),
        ),
        child: Row(
          children: [
            // Number column
            Container(
              width: 54,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                border: Border(right: BorderSide(color: AppTheme.border)),
              ),
              alignment: Alignment.center,
              child: Text(
                isDone ? '✓' : lesson.number.toString().padLeft(2, '0'),
                style: GoogleFonts.dmMono(
                  fontSize: 12,
                  color: isDone ? AppTheme.done : AppTheme.lightMuted,
                  fontWeight: isDone ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),

            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 12, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.titleEn,
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 15, color: AppTheme.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      lesson.titleKr,
                      style: GoogleFonts.notoSansKr(
                        fontSize: 12, color: AppTheme.muted,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 6),
                    // Mastery micro-bar
                    _MasteryBar(counts: masteryCount, total: lesson.chars.length),
                  ],
                ),
              ),
            ),

            // Tags
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Quiz badge
                GestureDetector(
                  onTap: onQuizTap,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFB8860B).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(3),
                      border: Border.all(
                        color: const Color(0xFFB8860B).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      'QUIZ ↗',
                      style: GoogleFonts.dmMono(
                        fontSize: 9, letterSpacing: 0.8,
                        color: const Color(0xFF7A5800),
                      ),
                    ),
                  ),
                ),

                // Status tag
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: isDone
                        ? AppTheme.done.withOpacity(0.1)
                        : isNext
                            ? AppTheme.accent.withOpacity(0.1)
                            : AppTheme.cream,
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(
                      color: isDone
                          ? AppTheme.done.withOpacity(0.3)
                          : isNext
                              ? AppTheme.accent.withOpacity(0.3)
                              : AppTheme.border,
                    ),
                  ),
                  child: Text(
                    isDone ? 'Done' : isNext ? 'Up next' : 'Locked',
                    style: GoogleFonts.dmMono(
                      fontSize: 9, letterSpacing: 0.8,
                      color: isDone
                          ? AppTheme.done
                          : isNext
                              ? AppTheme.accent
                              : AppTheme.muted,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(width: 16),
          ],
        ),
      ),
    );
  }
}

class _MasteryBar extends StatelessWidget {
  final Map<MasteryLevel, int> counts;
  final int total;

  const _MasteryBar({required this.counts, required this.total});

  @override
  Widget build(BuildContext context) {
    if (total == 0) return const SizedBox.shrink();

    final seenN = counts[MasteryLevel.seen] ?? 0;
    final recognizedN = counts[MasteryLevel.recognized] ?? 0;
    final canWriteN = counts[MasteryLevel.canWrite] ?? 0;

    return Row(
      children: [
        // Segmented bar
        Expanded(
          child: SizedBox(
            height: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: Row(
                children: [
                  _seg(
                    (total - seenN - recognizedN - canWriteN) / total,
                    Colors.black12,
                  ),
                  _seg(seenN / total, const Color(0xFFAAAAAA)),
                  _seg(recognizedN / total, const Color(0xFFD4A017)),
                  _seg(canWriteN / total, AppTheme.done),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$canWriteN/$total',
          style: GoogleFonts.dmMono(
            fontSize: 9, color: AppTheme.lightMuted,
          ),
        ),
      ],
    );
  }

  Widget _seg(double frac, Color color) {
    if (frac <= 0) return const SizedBox.shrink();
    return Expanded(
      flex: (frac * 1000).round(),
      child: Container(color: color),
    );
  }
}
