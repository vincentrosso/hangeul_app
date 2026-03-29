import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../services/mastery_service.dart';
import '../theme/app_theme.dart';
import '../widgets/drawing_canvas_widget.dart';
import '../widgets/stroke_animation_widget.dart';

class WritingScreen extends StatefulWidget {
  final CharCard card;
  final CanvasMode mode;

  const WritingScreen({
    super.key,
    required this.card,
    required this.mode,
  });

  @override
  State<WritingScreen> createState() => _WritingScreenState();
}

class _WritingScreenState extends State<WritingScreen>
    with SingleTickerProviderStateMixin {
  double? _score;
  late AnimationController _scoreAnim;
  late Animation<double> _scoreFill;

  @override
  void initState() {
    super.initState();
    _scoreAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scoreFill = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scoreAnim, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _scoreAnim.dispose();
    super.dispose();
  }

  Future<void> _onSubmit(double score, List<List<Offset>> userStrokes) async {
    final quality = (score * 5).round().clamp(0, 5);
    await MasteryService.instance.applyReview(widget.card.audioStem, quality);
    setState(() => _score = score);
    _scoreAnim.forward(from: 0.0);
  }

  String _scoreMessage(double score) {
    if (score >= 0.8) return '완벽해요! Perfect.';
    if (score >= 0.6) return '잘했어요! Good.';
    if (score >= 0.4) return '괜찮아요. Keep trying.';
    return '다시 해봐요. Try again.';
  }

  Color _scoreColor(double score) {
    if (score >= 0.7) return AppTheme.done;
    if (score >= 0.4) return const Color(0xFFD4A017);
    return AppTheme.accent;
  }

  @override
  Widget build(BuildContext context) {
    final modeName = widget.mode == CanvasMode.trace ? 'TRACE MODE' : 'FREE DRAW';
    final instructions = widget.mode == CanvasMode.trace
        ? 'Trace the faint character below'
        : 'Draw the character from memory';

    return Scaffold(
      backgroundColor: const Color(0xFF151008),
      appBar: AppBar(
        backgroundColor: const Color(0xFF151008),
        foregroundColor: Colors.white54,
        elevation: 0,
        title: Text(
          '${widget.card.char}  ·  ${widget.card.romanized}',
          style: GoogleFonts.dmMono(
            fontSize: 13,
            color: Colors.white54,
            letterSpacing: 0.5,
          ),
        ),
      ),
      body: Column(
        children: [
          // Top row: animation + char info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            color: const Color(0xFF1A1208),
            child: Row(
              children: [
                StrokeAnimationWidget(
                  char: widget.card.char,
                  size: 100,
                  autoPlay: true,
                  strokeColor: AppTheme.paper,
                  backgroundColor: const Color(0xFF221C10),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.card.char,
                        style: GoogleFonts.notoSerifKr(
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.card.romanized,
                        style: GoogleFonts.dmMono(
                          fontSize: 16,
                          color: Colors.white60,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.card.example,
                        style: GoogleFonts.notoSansKr(
                          fontSize: 11,
                          color: Colors.white30,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Mode label
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            color: const Color(0xFF0F0C06),
            child: Row(
              children: [
                Container(width: 3, height: 14, color: AppTheme.accent),
                const SizedBox(width: 10),
                Text(
                  modeName,
                  style: GoogleFonts.dmMono(
                    fontSize: 10,
                    letterSpacing: 2,
                    color: AppTheme.accent,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  instructions,
                  style: GoogleFonts.dmMono(
                    fontSize: 10,
                    color: Colors.white30,
                  ),
                ),
              ],
            ),
          ),

          // Drawing canvas
          Expanded(
            child: _score == null
                ? DrawingCanvasWidget(
                    char: widget.card.char,
                    mode: widget.mode,
                    onSubmit: _onSubmit,
                    onSkip: () => Navigator.pop(context),
                  )
                : _buildScorePanel(),
          ),
        ],
      ),
    );
  }

  Widget _buildScorePanel() {
    final score = _score!;
    final msg = _scoreMessage(score);
    final color = _scoreColor(score);
    final pct = (score * 100).round();

    return Container(
      color: AppTheme.paper,
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$pct%',
            style: GoogleFonts.playfairDisplay(
              fontSize: 72,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 16),

          // Score bar
          AnimatedBuilder(
            animation: _scoreFill,
            builder: (_, __) => ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _scoreFill.value * score,
                minHeight: 10,
                backgroundColor: AppTheme.cream,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
          ),

          const SizedBox(height: 20),
          Text(
            msg,
            textAlign: TextAlign.center,
            style: GoogleFonts.playfairDisplay(
              fontSize: 20,
              fontStyle: FontStyle.italic,
              color: AppTheme.ink,
            ),
          ),

          const SizedBox(height: 40),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => setState(() {
                    _score = null;
                    _scoreAnim.reset();
                  }),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.ink,
                    side: BorderSide(color: AppTheme.border),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  child: Text(
                    'Try Again',
                    style: GoogleFonts.dmMono(fontSize: 12, letterSpacing: 0.5),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.ink,
                    foregroundColor: AppTheme.paper,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Done',
                    style: GoogleFonts.dmMono(fontSize: 12, letterSpacing: 0.5),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
