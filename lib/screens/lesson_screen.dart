import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/char_card_widget.dart';
import 'quiz_screen.dart';

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
    _tab = TabController(length: 2, vsync: this);
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
        ],
      ),
    );
  }
}

class _StudyTab extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Korean title
          Text(
            lesson.titleKr,
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
              lesson.note,
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

          AudioLegend(nativeCount: nativeCount, total: lesson.chars.length),

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
            itemCount: lesson.chars.length,
            itemBuilder: (_, i) => CharCardWidget(card: lesson.chars[i]),
          ),

          const SizedBox(height: 28),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onStartQuiz,
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
                  onPressed: marked ? null : onMarkComplete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: marked ? AppTheme.done : AppTheme.ink,
                    foregroundColor: AppTheme.paper,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    marked ? '✓ Completed' : 'Mark Complete',
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
