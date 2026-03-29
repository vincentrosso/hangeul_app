import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../services/mastery_service.dart';
import '../theme/app_theme.dart';
import '../widgets/char_card_widget.dart';
import '../widgets/drawing_canvas_widget.dart';
import 'quiz_screen.dart';
import 'writing_screen.dart';

class LessonScreen extends StatefulWidget {
  final Lesson lesson;
  final VoidCallback onComplete;

  const LessonScreen({
    super.key,
    required this.lesson,
    required this.onComplete,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  bool _marked = false;

  static const _nativeChars = {
    '가','나','다','라','마','바','사','자','하',
    '카','타','파','차',
    '닭','밥','책','물','산','봄','강',
    '한국','사람','음식','학교','친구','가족',
  };

  int get _nativeCount =>
      widget.lesson.chars.where((c) => _nativeChars.contains(c.char)).length;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.paper,
      appBar: AppBar(
        title: Text(
          '${widget.lesson.number.toString().padLeft(2, '0')} · ${widget.lesson.titleEn}',
          style: GoogleFonts.dmMono(
            fontSize: 13, color: AppTheme.lightMuted, letterSpacing: 0.5,
          ),
        ),
        bottom: TabBar(
          controller: _tab,
          labelColor: AppTheme.accent,
          unselectedLabelColor: AppTheme.lightMuted,
          indicatorColor: AppTheme.accent,
          indicatorSize: TabBarIndicatorSize.label,
          labelStyle: GoogleFonts.dmMono(
            fontSize: 11, letterSpacing: 1.5,
          ),
          tabs: const [
            Tab(text: 'STUDY'),
            Tab(text: 'QUIZ'),
            Tab(text: 'WRITE'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: [
          _StudyTab(
            lesson: widget.lesson,
            nativeCount: _nativeCount,
            marked: _marked,
            onMarkComplete: () {
              setState(() => _marked = true);
              widget.onComplete();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Lesson ${widget.lesson.number} complete!',
                    style: GoogleFonts.dmMono(fontSize: 13),
                  ),
                  backgroundColor: AppTheme.done,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            onStartQuiz: () => _tab.animateTo(1),
          ),
          _QuizTab(lesson: widget.lesson),
          _WriteTab(lesson: widget.lesson),
        ],
      ),
    );
  }
}

class _StudyTab extends StatefulWidget {
  final Lesson lesson;
  final int nativeCount;
  final bool marked;
  final VoidCallback onMarkComplete;
  final VoidCallback onStartQuiz;

  const _StudyTab({
    required this.lesson,
    required this.nativeCount,
    required this.marked,
    required this.onMarkComplete,
    required this.onStartQuiz,
  });

  @override
  State<_StudyTab> createState() => _StudyTabState();
}

class _StudyTabState extends State<_StudyTab> {
  Map<String, MasteryLevel> _masteryMap = {};

  @override
  void initState() {
    super.initState();
    _loadMastery();
  }

  Future<void> _loadMastery() async {
    // Mark all chars as seen and load their mastery
    for (final card in widget.lesson.chars) {
      await MasteryService.instance.markSeen(card.audioStem);
    }
    if (mounted) {
      setState(() {
        _masteryMap = {
          for (final card in widget.lesson.chars)
            card.audioStem: MasteryService.instance.get(card.audioStem).level
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Korean title
          Text(
            widget.lesson.titleKr,
            style: GoogleFonts.notoSerifKr(
              fontSize: 14, color: AppTheme.muted, fontWeight: FontWeight.w300,
            ),
          ),
          const SizedBox(height: 12),

          // Note card
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.accent.withOpacity(0.05),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(6),
                bottomRight: Radius.circular(6),
              ),
              border: Border(
                left: BorderSide(color: AppTheme.accent, width: 3),
              ),
            ),
            child: Text(
              widget.lesson.note,
              style: GoogleFonts.dmMono(
                fontSize: 12, color: AppTheme.ink, height: 1.7,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Characters header + legend
          Row(
            children: [
              Text(
                'CHARACTERS · 글자',
                style: GoogleFonts.dmMono(
                  fontSize: 10, letterSpacing: 1.5, color: AppTheme.muted,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '(tap to hear)',
                style: GoogleFonts.dmMono(
                  fontSize: 10, color: AppTheme.lightMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          AudioLegend(
            nativeCount: widget.nativeCount,
            total: widget.lesson.chars.length,
          ),

          // Char grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 110,
              mainAxisExtent: 120,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: widget.lesson.chars.length,
            itemBuilder: (_, i) {
              final card = widget.lesson.chars[i];
              return CharCardWidget(
                card: card,
                mastery: _masteryMap[card.audioStem],
              );
            },
          ),

          const SizedBox(height: 28),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onStartQuiz,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.ink,
                    side: BorderSide(color: AppTheme.border),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: Text(
                    'Quiz this lesson →',
                    style: GoogleFonts.dmMono(fontSize: 12, letterSpacing: 0.5),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: widget.marked ? null : widget.onMarkComplete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.marked ? AppTheme.done : AppTheme.ink,
                    foregroundColor: AppTheme.paper,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    widget.marked ? '✓ Completed' : 'Mark Complete',
                    style: GoogleFonts.dmMono(
                      fontSize: 12, letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _QuizTab extends StatelessWidget {
  final Lesson lesson;
  const _QuizTab({required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              lesson.chars.first.char,
              style: GoogleFonts.notoSerifKr(
                fontSize: 72, fontWeight: FontWeight.w700, color: AppTheme.ink,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Test yourself on all ${lesson.chars.length} characters.\nFlashcard or multiple-choice — your pick.',
              textAlign: TextAlign.center,
              style: GoogleFonts.dmMono(
                fontSize: 13, color: AppTheme.muted, height: 1.7,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QuizScreen(lesson: lesson),
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.ink,
                foregroundColor: AppTheme.paper,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32, vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
                elevation: 0,
              ),
              child: Text(
                'Start Quiz →',
                style: GoogleFonts.dmMono(
                  fontSize: 13, letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WriteTab extends StatelessWidget {
  final Lesson lesson;
  const _WriteTab({required this.lesson});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WRITE · 쓰기',
            style: GoogleFonts.dmMono(
              fontSize: 10, letterSpacing: 2, color: AppTheme.muted,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Practice writing each character. Follow the stroke order animation.',
            style: GoogleFonts.dmMono(
              fontSize: 12, color: AppTheme.muted, height: 1.6,
            ),
          ),
          const SizedBox(height: 16),
          ...lesson.chars.map(
            (card) => _WriteRow(card: card),
          ),
        ],
      ),
    );
  }
}

class _WriteRow extends StatelessWidget {
  final CharCard card;
  const _WriteRow({required this.card});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.cream,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Text(
            card.char,
            style: GoogleFonts.notoSerifKr(
              fontSize: 28, fontWeight: FontWeight.w700, color: AppTheme.ink,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  card.romanized,
                  style: GoogleFonts.dmMono(
                    fontSize: 13, color: AppTheme.muted,
                  ),
                ),
                Text(
                  card.example,
                  style: GoogleFonts.notoSansKr(
                    fontSize: 10, color: AppTheme.lightMuted,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WritingScreen(
                  card: card,
                  mode: CanvasMode.trace,
                ),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.ink,
              foregroundColor: AppTheme.paper,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
              elevation: 0,
            ),
            child: Text(
              '✎ Trace',
              style: GoogleFonts.dmMono(fontSize: 11, letterSpacing: 0.3),
            ),
          ),
        ],
      ),
    );
  }
}
