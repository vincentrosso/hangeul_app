import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/lessons.dart';
import '../models/models.dart';
import '../services/audio_service.dart';
import '../services/mastery_service.dart';
import '../theme/app_theme.dart';
import '../widgets/drawing_canvas_widget.dart';

class QuizScreen extends StatefulWidget {
  final Lesson lesson;
  const QuizScreen({super.key, required this.lesson});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  QuizMode _mode = QuizMode.flashcard;
  late List<CharCard> _cards;
  int _idx = 0;
  int _correct = 0;
  final List<bool> _results = [];
  bool _done = false;

  @override
  void initState() {
    super.initState();
    _shuffle();
  }

  void _shuffle() {
    _cards = [...widget.lesson.chars]..shuffle();
    _idx = 0;
    _correct = 0;
    _results.clear();
    _done = false;
  }

  void _recordResult(bool correct, {String? charId}) {
    _results.add(correct);
    if (correct) _correct++;
    if (charId != null) {
      MasteryService.instance.applyReview(charId, correct ? 4 : 1);
    }
  }

  void _advance() {
    if (_idx >= _cards.length - 1) {
      setState(() => _done = true);
    } else {
      setState(() => _idx++);
    }
  }

  void _retry() => setState(() => _shuffle());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF151008),
      appBar: AppBar(
        backgroundColor: const Color(0xFF151008),
        foregroundColor: Colors.white54,
        elevation: 0,
        title: Text(
          'Lesson ${widget.lesson.number} · ${widget.lesson.titleEn}',
          style: GoogleFonts.dmMono(
            fontSize: 11, letterSpacing: 0.5, color: Colors.white38,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(32),
          child: _ProgressDots(
            total: _cards.length,
            current: _idx,
            results: _results,
          ),
        ),
      ),
      body: _done
          ? _ResultScreen(
              correct: _correct,
              total: _cards.length,
              onRetry: _retry,
              onDone: () => Navigator.pop(context),
            )
          : Column(
              children: [
                // Mode toggle
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: _ModeToggle(
                    mode: _mode,
                    onChanged: (m) => setState(() {
                      _mode = m;
                      _shuffle();
                    }),
                  ),
                ),

                // Quiz card area
                Expanded(
                  child: _buildCardArea(),
                ),

                // Progress text
                Padding(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Text(
                    '${_idx + 1} / ${_cards.length}',
                    style: GoogleFonts.dmMono(
                      fontSize: 11, color: Colors.white24,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCardArea() {
    final card = _cards[_idx];

    switch (_mode) {
      case QuizMode.flashcard:
        return _FlashcardView(
          key: ValueKey('fc_$_idx'),
          card: card,
          onResult: (correct) {
            _recordResult(correct, charId: card.audioStem);
            _advance();
          },
        );

      case QuizMode.multipleChoice:
        return _MultipleChoiceView(
          key: ValueKey('mc_$_idx'),
          card: card,
          allCards: kLessons.expand((l) => l.chars).toList(),
          onResult: (correct) {
            _recordResult(correct, charId: card.audioStem);
          },
          onNext: _advance,
        );

      case QuizMode.trace:
        return _DrawingView(
          key: ValueKey('trace_$_idx'),
          card: card,
          mode: CanvasMode.trace,
          onSubmit: (score, strokes) {
            final quality = (score * 5).round().clamp(0, 5);
            MasteryService.instance.applyReview(card.audioStem, quality);
            _recordResult(score >= 0.5, charId: null);
            _advance();
          },
          onSkip: _advance,
        );

      case QuizMode.freeDraw:
        return _DrawingView(
          key: ValueKey('free_$_idx'),
          card: card,
          mode: CanvasMode.freeDraw,
          onSubmit: (score, strokes) {
            final quality = (score * 5).round().clamp(0, 5);
            MasteryService.instance.applyReview(card.audioStem, quality);
            _recordResult(score >= 0.5, charId: null);
            _advance();
          },
          onSkip: _advance,
        );
    }
  }
}

// ─── Progress dots ──────────────────────────────────────────────────────────

class _ProgressDots extends StatelessWidget {
  final int total, current;
  final List<bool> results;
  const _ProgressDots({required this.total, required this.current, required this.results});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: Row(
        children: List.generate(total, (i) {
          Color c;
          if (i < results.length) {
            c = results[i] ? const Color(0xFF4CAF7D) : AppTheme.accent;
          } else if (i == current) {
            c = Colors.white54;
          } else {
            c = Colors.white12;
          }
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 2),
              height: 3,
              decoration: BoxDecoration(
                color: c, borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── Mode toggle ─────────────────────────────────────────────────────────────

class _ModeToggle extends StatelessWidget {
  final QuizMode mode;
  final ValueChanged<QuizMode> onChanged;
  const _ModeToggle({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _tab('↩ Flashcard', QuizMode.flashcard),
              Container(width: 1, color: Colors.white12),
              _tab('⊞ Multiple Choice', QuizMode.multipleChoice),
            ],
          ),
          Container(height: 1, color: Colors.white12),
          Row(
            children: [
              _tab('✎ Trace', QuizMode.trace),
              Container(width: 1, color: Colors.white12),
              _tab('✏ Free Draw', QuizMode.freeDraw),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tab(String label, QuizMode m) {
    final active = mode == m;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(m),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: active ? Colors.white10 : Colors.transparent,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.dmMono(
              fontSize: 11, letterSpacing: 0.8,
              color: active ? Colors.white : Colors.white30,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Drawing view wrapper ────────────────────────────────────────────────────

class _DrawingView extends StatelessWidget {
  final CharCard card;
  final CanvasMode mode;
  final void Function(double score, List<List<Offset>> strokes) onSubmit;
  final VoidCallback onSkip;

  const _DrawingView({
    super.key,
    required this.card,
    required this.mode,
    required this.onSubmit,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Row(
            children: [
              Text(
                card.char,
                style: GoogleFonts.notoSerifKr(
                  fontSize: 40, fontWeight: FontWeight.w700, color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    card.romanized,
                    style: GoogleFonts.dmMono(
                      fontSize: 16, color: Colors.white60, letterSpacing: 0.5,
                    ),
                  ),
                  Text(
                    mode == CanvasMode.trace ? 'Trace the character' : 'Draw from memory',
                    style: GoogleFonts.dmMono(
                      fontSize: 10, color: Colors.white30,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: DrawingCanvasWidget(
            char: card.char,
            mode: mode,
            onSubmit: onSubmit,
            onSkip: onSkip,
          ),
        ),
      ],
    );
  }
}

// ─── Flashcard ───────────────────────────────────────────────────────────────

class _FlashcardView extends StatefulWidget {
  final CharCard card;
  final ValueChanged<bool> onResult;
  const _FlashcardView({super.key, required this.card, required this.onResult});

  @override
  State<_FlashcardView> createState() => _FlashcardViewState();
}

class _FlashcardViewState extends State<_FlashcardView>
    with SingleTickerProviderStateMixin {
  late AnimationController _flip;
  late Animation<double> _angle;
  bool _flipped = false;
  bool _answered = false;

  // Extract the Korean example word if it's multi-syllable and contains the card's char.
  String? get _exampleWord {
    final match = RegExp(r'[가-힣]+').firstMatch(widget.card.example);
    if (match == null) return null;
    final word = match.group(0)!;
    final syllables = word.runes.where((r) => r >= 0xAC00 && r <= 0xD7A3).length;
    if (syllables < 2) return null;
    if (!word.contains(widget.card.char)) return null;
    return word;
  }

  @override
  void initState() {
    super.initState();
    _flip = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 500),
    );
    _angle = Tween(begin: 0.0, end: pi).animate(
      CurvedAnimation(parent: _flip, curve: Curves.easeInOutCubic),
    );
  }

  @override
  void dispose() {
    _flip.dispose();
    super.dispose();
  }

  Future<void> _doFlip() async {
    if (_flipped) return;
    HapticFeedback.lightImpact();
    await _flip.forward();
    setState(() => _flipped = true);
    // Auto-play audio on reveal
    await AudioService.instance.play(widget.card);
  }

  @override
  Widget build(BuildContext context) {
    final exampleWord = _exampleWord;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          // Card + optional context card
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: _flipped ? null : _doFlip,
                    child: AnimatedBuilder(
                      animation: _angle,
                      builder: (_, __) {
                        final showFront = _angle.value < pi / 2;
                        return Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.identity()
                            ..setEntry(3, 2, 0.001)
                            ..rotateY(_angle.value),
                          child: showFront ? _cardFront() : _cardBack(),
                        );
                      },
                    ),
                  ),
                ),
                if (_flipped && exampleWord != null) ...[
                  const SizedBox(height: 8),
                  _exampleWordCard(exampleWord),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Verdict buttons (after flip)
          if (_flipped && !_answered)
            Row(
              children: [
                Expanded(
                  child: _actionBtn(
                    '✗  Missed it',
                    const Color(0x33C0392B),
                    const Color(0xFFE07A72),
                    () {
                      setState(() => _answered = true);
                      widget.onResult(false);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _actionBtn(
                    '✓  Got it',
                    const Color(0x334CAF7D),
                    const Color(0xFF7DDCAA),
                    () {
                      setState(() => _answered = true);
                      widget.onResult(true);
                    },
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _cardFront() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1810),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.07)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
              fontSize: 80, fontWeight: FontWeight.w700, color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _listenBtn(() => AudioService.instance.play(widget.card)),
        ],
      ),
    );
  }

  Widget _cardBack() {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..rotateY(pi),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF142014),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF4CAF7D).withOpacity(0.3),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.card.char,
              style: GoogleFonts.notoSerifKr(
                fontSize: 52, fontWeight: FontWeight.w700,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8),
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
            const SizedBox(height: 20),
            _listenBtn(() => AudioService.instance.play(widget.card)),
          ],
        ),
      ),
    );
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

  Widget _listenBtn(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white24),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          '▶  Listen',
          style: GoogleFonts.dmMono(
            fontSize: 11, color: Colors.white54, letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _actionBtn(
    String label, Color bg, Color fg, VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.dmMono(
            fontSize: 13, letterSpacing: 0.5, color: fg,
          ),
        ),
      ),
    );
  }
}

// ─── Multiple Choice ──────────────────────────────────────────────────────────

class _MultipleChoiceView extends StatefulWidget {
  final CharCard card;
  final List<CharCard> allCards;
  final ValueChanged<bool> onResult;
  final VoidCallback onNext;

  const _MultipleChoiceView({
    super.key,
    required this.card,
    required this.allCards,
    required this.onResult,
    required this.onNext,
  });

  @override
  State<_MultipleChoiceView> createState() => _MultipleChoiceViewState();
}

class _MultipleChoiceViewState extends State<_MultipleChoiceView> {
  late List<CharCard> _options;
  int? _selected;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    _buildOptions();
  }

  void _buildOptions() {
    final wrong = widget.allCards
        .where((c) => c.romanized != widget.card.romanized)
        .toList()
      ..shuffle();
    final seen = <String>{};
    final unique = wrong
        .where((c) => seen.add(c.romanized))
        .take(3)
        .toList();
    _options = [...unique, widget.card]..shuffle();
  }

  Future<void> _pick(int i) async {
    if (_answered) return;
    HapticFeedback.selectionClick();
    setState(() {
      _selected = i;
      _answered = true;
    });
    final correct = _options[i].romanized == widget.card.romanized;
    widget.onResult(correct);
    // Auto-play after answering
    await AudioService.instance.play(widget.card);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        children: [
          // Character card (static, no flip)
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1810),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.07)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'WHAT IS THE ROMANIZATION?',
                    style: GoogleFonts.dmMono(
                      fontSize: 10, letterSpacing: 2, color: Colors.white24,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.card.char,
                    style: GoogleFonts.notoSerifKr(
                      fontSize: 80, fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () => AudioService.instance.play(widget.card),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white24),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '▶  Listen',
                        style: GoogleFonts.dmMono(
                          fontSize: 11, color: Colors.white54,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Answer grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 3.0,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: List.generate(_options.length, (i) {
              final isCorrect = _options[i].romanized == widget.card.romanized;
              Color bg = Colors.white.withOpacity(0.05);
              Color border = Colors.white.withOpacity(0.09);
              Color fg = Colors.white.withOpacity(0.7);

              if (_answered) {
                if (isCorrect) {
                  bg = const Color(0xFF4CAF7D).withOpacity(0.18);
                  border = const Color(0xFF4CAF7D);
                  fg = const Color(0xFF7DDCAA);
                } else if (i == _selected) {
                  bg = AppTheme.accent.withOpacity(0.18);
                  border = AppTheme.accent;
                  fg = const Color(0xFFE07A72);
                }
              }

              return GestureDetector(
                onTap: () => _pick(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: border),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    _options[i].romanized,
                    style: GoogleFonts.dmMono(
                      fontSize: 16, color: fg,
                    ),
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: 16),

          // Next button (after answer)
          if (_answered)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Next →',
                  style: GoogleFonts.dmMono(
                    fontSize: 13, letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Result screen ────────────────────────────────────────────────────────────

class _ResultScreen extends StatelessWidget {
  final int correct, total;
  final VoidCallback onRetry, onDone;

  const _ResultScreen({
    required this.correct,
    required this.total,
    required this.onRetry,
    required this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    final pct = (correct / total * 100).round();
    final String stars;
    final String msg;
    if (pct == 100) { stars = '★★★'; msg = '완벽해요! Perfect score!'; }
    else if (pct >= 70) { stars = '★★☆'; msg = '잘했어요! Almost there.'; }
    else { stars = '★☆☆'; msg = '괜찮아요. Keep going!'; }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(stars,
              style: const TextStyle(fontSize: 36, letterSpacing: 10, color: Colors.white70)),
            const SizedBox(height: 16),
            Text('$correct/$total',
              style: GoogleFonts.notoSerifKr(
                fontSize: 72, fontWeight: FontWeight.w700, color: Colors.white,
              )),
            const SizedBox(height: 4),
            Text('$pct% correct',
              style: GoogleFonts.dmMono(
                fontSize: 12, letterSpacing: 2, color: Colors.white30,
              )),
            const SizedBox(height: 24),
            Text(msg,
              style: GoogleFonts.playfairDisplay(
                fontSize: 18, fontStyle: FontStyle.italic, color: Colors.white60,
              )),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: onRetry,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Colors.white24),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 14),
                  ),
                  child: Text('Retry',
                    style: GoogleFonts.dmMono(fontSize: 12, letterSpacing: 0.5)),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: onDone,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 14),
                    elevation: 0,
                  ),
                  child: Text('Back to Lesson',
                    style: GoogleFonts.dmMono(fontSize: 12, letterSpacing: 0.5)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
