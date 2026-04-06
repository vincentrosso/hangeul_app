import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/lessons.dart';
import '../models/models.dart';
import '../services/audio_service.dart';
import '../services/mastery_service.dart';
import '../theme/app_theme.dart';
import '../widgets/drawing_canvas_widget.dart';
import 'writing_screen.dart';

class PracticeScreen extends StatefulWidget {
  final List<Lesson> lessons;

  const PracticeScreen({super.key, required this.lessons});

  @override
  State<PracticeScreen> createState() => _PracticeScreenState();
}

class _PracticeScreenState extends State<PracticeScreen> {
  List<CharCard> _queue = [];
  int _idx = 0;
  bool _loading = true;
  int _doneCount = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final allCards = kLessons.expand((l) => l.chars).toList();
    final dueIds = MasteryService.instance.getDueCardIds(allCards);

    final queue = dueIds
        .map((id) => allCards.firstWhere(
              (c) => c.audioStem == id,
              orElse: () => allCards.first,
            ))
        .toList();

    setState(() {
      _queue = queue;
      _loading = false;
    });
  }

  void _advance() {
    setState(() {
      _doneCount++;
      _idx++;
    });
  }

  Future<void> _markFlashcard(CharCard card, bool correct) async {
    await MasteryService.instance.applyReview(
      card.audioStem,
      correct ? 4 : 1,
    );
    _advance();
  }

  bool get _done => !_loading && (_queue.isEmpty || _idx >= _queue.length);

  DateTime? get _nextDueDate {
    final allCards = kLessons.expand((l) => l.chars).toList();
    DateTime? earliest;
    for (final card in allCards) {
      final m = MasteryService.instance.get(card.audioStem);
      if (m.level != MasteryLevel.unseen && m.dueDate.isAfter(DateTime.now())) {
        if (earliest == null || m.dueDate.isBefore(earliest)) {
          earliest = m.dueDate;
        }
      }
    }
    return earliest;
  }

  Map<MasteryLevel, int> _computeSummary() {
    final allCards = kLessons.expand((l) => l.chars).toList();
    final counts = <MasteryLevel, int>{};
    for (final level in MasteryLevel.values) {
      counts[level] = 0;
    }
    for (final card in allCards) {
      final m = MasteryService.instance.get(card.audioStem);
      counts[m.level] = (counts[m.level] ?? 0) + 1;
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: const Color(0xFF151008),
        body: const Center(
          child: CircularProgressIndicator(color: AppTheme.accent),
        ),
      );
    }

    if (_done) {
      return _buildDoneScreen();
    }

    return _buildPracticeScreen();
  }

  Widget _buildPracticeScreen() {
    final card = _queue[_idx];
    final mastery = MasteryService.instance.get(card.audioStem);
    final total = _queue.length;
    final progress = total == 0 ? 0.0 : _doneCount / total;

    return Scaffold(
      backgroundColor: const Color(0xFF151008),
      appBar: AppBar(
        backgroundColor: const Color(0xFF151008),
        foregroundColor: Colors.white54,
        elevation: 0,
        title: Text(
          'Daily Practice',
          style: GoogleFonts.dmMono(
            fontSize: 13, color: Colors.white38, letterSpacing: 1,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(36),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$_doneCount / $total done',
                      style: GoogleFonts.dmMono(
                        fontSize: 10, color: Colors.white30,
                      ),
                    ),
                    Text(
                      '${total - _doneCount} remaining',
                      style: GoogleFonts.dmMono(
                        fontSize: 10, color: Colors.white30,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white12,
                  valueColor: const AlwaysStoppedAnimation(AppTheme.accent),
                  minHeight: 3,
                  borderRadius: BorderRadius.circular(2),
                ),
              ],
            ),
          ),
        ),
      ),
      body: mastery.level == MasteryLevel.unseen || mastery.level == MasteryLevel.seen
          ? _FlashcardReview(
              card: card,
              onCorrect: () => _markFlashcard(card, true),
              onIncorrect: () => _markFlashcard(card, false),
              onSkip: _advance,
            )
          : _WriteReview(
              card: card,
              mode: mastery.level == MasteryLevel.recognized
                  ? CanvasMode.trace
                  : CanvasMode.freeDraw,
              onDone: _advance,
            ),
    );
  }

  Widget _buildDoneScreen() {
    final summary = _computeSummary();
    final next = _nextDueDate;

    return Scaffold(
      backgroundColor: const Color(0xFF151008),
      appBar: AppBar(
        backgroundColor: const Color(0xFF151008),
        foregroundColor: Colors.white54,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _queue.isEmpty ? '✓' : '★',
                style: const TextStyle(fontSize: 48, color: Colors.white54),
              ),
              const SizedBox(height: 16),
              Text(
                _queue.isEmpty ? 'All caught up!' : 'Session complete!',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 28,
                  fontStyle: FontStyle.italic,
                  color: Colors.white,
                ),
              ),
              if (_queue.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  '$_doneCount card${_doneCount == 1 ? '' : 's'} reviewed',
                  style: GoogleFonts.dmMono(
                    fontSize: 12, color: Colors.white38,
                  ),
                ),
              ],
              const SizedBox(height: 32),

              // Mastery summary
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MASTERY OVERVIEW',
                      style: GoogleFonts.dmMono(
                        fontSize: 10, letterSpacing: 2, color: Colors.white30,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _masteryRow('Unseen', summary[MasteryLevel.unseen] ?? 0,
                        Colors.white24),
                    _masteryRow('Seen', summary[MasteryLevel.seen] ?? 0,
                        const Color(0xFFAAAAAA)),
                    _masteryRow('Recognized', summary[MasteryLevel.recognized] ?? 0,
                        const Color(0xFFD4A017)),
                    _masteryRow('Can Write', summary[MasteryLevel.canWrite] ?? 0,
                        AppTheme.done),
                  ],
                ),
              ),

              if (next != null) ...[
                const SizedBox(height: 20),
                Text(
                  'Next review: ${_formatDate(next)}',
                  style: GoogleFonts.dmMono(
                    fontSize: 11, color: Colors.white30,
                  ),
                ),
              ],

              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Back to Home',
                  style: GoogleFonts.dmMono(
                    fontSize: 13, letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _masteryRow(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8, height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.dmMono(fontSize: 12, color: Colors.white54),
            ),
          ),
          Text(
            '$count',
            style: GoogleFonts.dmMono(
              fontSize: 12, color: Colors.white70,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = dt.difference(now);
    if (diff.inHours < 1) return 'in ${diff.inMinutes}m';
    if (diff.inDays < 1) return 'in ${diff.inHours}h';
    if (diff.inDays == 1) return 'tomorrow';
    return 'in ${diff.inDays} days';
  }
}

// ─── Flashcard review (for unseen/seen cards) ─────────────────────────────────

class _FlashcardReview extends StatefulWidget {
  final CharCard card;
  final VoidCallback onCorrect;
  final VoidCallback onIncorrect;
  final VoidCallback onSkip;

  const _FlashcardReview({
    required this.card,
    required this.onCorrect,
    required this.onIncorrect,
    required this.onSkip,
  });

  @override
  State<_FlashcardReview> createState() => _FlashcardReviewState();
}

class _FlashcardReviewState extends State<_FlashcardReview> {
  bool _revealed = false;

  String? get _exampleWord {
    final match = RegExp(r'[가-힣]+').firstMatch(widget.card.example);
    if (match == null) return null;
    final word = match.group(0)!;
    final syllables = word.runes.where((r) => r >= 0xAC00 && r <= 0xD7A3).length;
    if (syllables < 2) return null;
    if (!word.contains(widget.card.char)) return null;
    return word;
  }

  Widget _exampleWordCard(String word) {
    final charIdx = word.indexOf(widget.card.char);
    final before = charIdx > 0 ? word.substring(0, charIdx) : '';
    final after = charIdx + widget.card.char.length < word.length
        ? word.substring(charIdx + widget.card.char.length)
        : '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF12180E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF4CAF7D).withOpacity(0.15),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: RichText(
                text: TextSpan(
                  style: GoogleFonts.notoSerifKr(
                    fontSize: 34, fontWeight: FontWeight.w700,
                  ),
                  children: [
                    if (before.isNotEmpty)
                      TextSpan(
                        text: before,
                        style: const TextStyle(color: Colors.white30),
                      ),
                    TextSpan(
                      text: widget.card.char,
                      style: const TextStyle(color: Colors.white),
                    ),
                    if (after.isNotEmpty)
                      TextSpan(
                        text: after,
                        style: const TextStyle(color: Colors.white30),
                      ),
                  ],
                ),
              ),
            ),
          ),
          GestureDetector(
            onTap: () => AudioService.instance.playChar(word),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white24),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '▶  Listen',
                style: GoogleFonts.dmMono(
                  fontSize: 10, color: Colors.white38, letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final exampleWord = _exampleWord;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _revealed ? null : () => setState(() => _revealed = true),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1810),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.07)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!_revealed)
                            Text(
                              'TAP TO REVEAL',
                              style: GoogleFonts.dmMono(
                                fontSize: 10, letterSpacing: 2, color: Colors.white24,
                              ),
                            ),
                          const SizedBox(height: 16),
                          Text(
                            widget.card.char,
                            style: GoogleFonts.notoSerifKr(
                              fontSize: 80,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          if (_revealed) ...[
                            const SizedBox(height: 12),
                            Text(
                              widget.card.romanized,
                              style: GoogleFonts.dmMono(
                                fontSize: 28, color: Colors.white, letterSpacing: 1,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              widget.card.example,
                              style: GoogleFonts.notoSansKr(
                                fontSize: 14, color: Colors.white38,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                if (_revealed && exampleWord != null) ...[
                  const SizedBox(height: 8),
                  _exampleWordCard(exampleWord),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_revealed)
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      widget.onIncorrect();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: AppTheme.accent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '✗  Missed it',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmMono(
                          fontSize: 13,
                          color: const Color(0xFFE07A72),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      widget.onCorrect();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF7D).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '✓  Got it',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmMono(
                          fontSize: 13,
                          color: const Color(0xFF7DDCAA),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            TextButton(
              onPressed: widget.onSkip,
              child: Text(
                'Skip',
                style: GoogleFonts.dmMono(
                  fontSize: 12, color: Colors.white30,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Write review (for recognized/canWrite cards) ────────────────────────────

class _WriteReview extends StatefulWidget {
  final CharCard card;
  final CanvasMode mode;
  final VoidCallback onDone;

  const _WriteReview({
    required this.card,
    required this.mode,
    required this.onDone,
  });

  @override
  State<_WriteReview> createState() => _WriteReviewState();
}

class _WriteReviewState extends State<_WriteReview> {
  @override
  Widget build(BuildContext context) {
    return WritingScreen(
      card: widget.card,
      mode: widget.mode,
    );
  }
}
