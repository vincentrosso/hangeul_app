import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/stroke_data.dart';
import '../services/stroke_scorer.dart';
import '../theme/app_theme.dart';

enum CanvasMode { trace, freeDraw }

class DrawingCanvasWidget extends StatefulWidget {
  final String char;
  final CanvasMode mode;
  final void Function(double score, List<List<Offset>> userStrokes) onSubmit;
  final VoidCallback? onSkip;

  const DrawingCanvasWidget({
    super.key,
    required this.char,
    required this.mode,
    required this.onSubmit,
    this.onSkip,
  });

  @override
  State<DrawingCanvasWidget> createState() => _DrawingCanvasWidgetState();
}

class _DrawingCanvasWidgetState extends State<DrawingCanvasWidget> {
  final List<List<Offset>> _userStrokes = [];
  List<Offset> _currentStroke = [];
  List<List<Offset>>? _refStrokes;

  @override
  void initState() {
    super.initState();
    _refStrokes = getCharStrokes(widget.char);
  }

  void _onPanStart(DragStartDetails d) {
    setState(() {
      _currentStroke = [_localOffset(d.localPosition)];
    });
  }

  void _onPanUpdate(DragUpdateDetails d) {
    setState(() {
      _currentStroke.add(_localOffset(d.localPosition));
    });
  }

  void _onPanEnd(DragEndDetails d) {
    if (_currentStroke.isNotEmpty) {
      setState(() {
        _userStrokes.add(List.of(_currentStroke));
        _currentStroke = [];
      });
    }
  }

  Offset _localOffset(Offset local) => local;

  void _clear() {
    setState(() {
      _userStrokes.clear();
      _currentStroke = [];
    });
  }

  void _submit(Size canvasSize) {
    final all = [..._userStrokes];
    if (_currentStroke.isNotEmpty) all.add(_currentStroke);

    double sc = 0.0;
    if (_refStrokes != null && _refStrokes!.isNotEmpty && all.isNotEmpty) {
      sc = StrokeScorer.score(
        userStrokes: all,
        referenceStrokes: _refStrokes!,
        canvasSize: canvasSize,
      );
    } else if (all.isNotEmpty) {
      sc = 0.5; // no reference — give partial credit
    }

    widget.onSubmit(sc, all);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Canvas area
        Expanded(
          child: LayoutBuilder(
            builder: (context, _) {
              return GestureDetector(
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                child: Container(
                  color: AppTheme.paper,
                  child: CustomPaint(
                    painter: _CanvasPainter(
                      userStrokes: _userStrokes,
                      currentStroke: _currentStroke,
                      refStrokes: widget.mode == CanvasMode.trace ? _refStrokes : null,
                      strokeCount: _userStrokes.length + (_currentStroke.isNotEmpty ? 1 : 0),
                    ),
                    child: const SizedBox.expand(),
                  ),
                ),
              );
            },
          ),
        ),

        // Bottom bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: AppTheme.cream,
            border: Border(top: BorderSide(color: AppTheme.border)),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final canvasHeight = MediaQuery.of(context).size.height * 0.5;
              final canvasWidth = constraints.maxWidth;
              final canvasSize = Size(canvasWidth, canvasHeight);

              return Row(
                children: [
                  TextButton(
                    onPressed: _clear,
                    child: Text(
                      'Clear',
                      style: GoogleFonts.dmMono(
                        fontSize: 12,
                        color: AppTheme.muted,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (widget.onSkip != null)
                    TextButton(
                      onPressed: widget.onSkip,
                      child: Text(
                        'Skip',
                        style: GoogleFonts.dmMono(
                          fontSize: 12,
                          color: AppTheme.lightMuted,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _userStrokes.isEmpty && _currentStroke.isEmpty
                        ? null
                        : () => _submit(canvasSize),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.ink,
                      foregroundColor: AppTheme.paper,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Submit',
                      style: GoogleFonts.dmMono(fontSize: 12, letterSpacing: 0.5),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CanvasPainter extends CustomPainter {
  final List<List<Offset>> userStrokes;
  final List<Offset> currentStroke;
  final List<List<Offset>>? refStrokes;
  final int strokeCount;

  _CanvasPainter({
    required this.userStrokes,
    required this.currentStroke,
    this.refStrokes,
    required this.strokeCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Background grid dots
    final gridPaint = Paint()
      ..color = AppTheme.ink.withOpacity(0.06)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.fill;

    const gridSpacing = 24.0;
    for (double x = gridSpacing; x < size.width; x += gridSpacing) {
      for (double y = gridSpacing; y < size.height; y += gridSpacing) {
        canvas.drawCircle(Offset(x, y), 1.0, gridPaint);
      }
    }

    // Ghost reference strokes (trace mode)
    if (refStrokes != null) {
      final ghostPaint = Paint()
        ..color = AppTheme.ink.withOpacity(0.10)
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      for (final stroke in refStrokes!) {
        _drawStroke(
          canvas,
          stroke.map((p) => Offset(p.dx * size.width, p.dy * size.height)).toList(),
          ghostPaint,
        );
      }
    }

    // User strokes
    final userPaint = Paint()
      ..color = AppTheme.ink
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in userStrokes) {
      _drawStroke(canvas, stroke, userPaint);
    }

    // Current in-progress stroke
    if (currentStroke.isNotEmpty) {
      _drawStroke(canvas, currentStroke, userPaint);
    }

    // Stroke count indicator (top-right)
    final countText = TextPainter(
      text: TextSpan(
        text: 'Stroke: $strokeCount',
        style: TextStyle(
          fontFamily: 'monospace',
          fontSize: 11,
          color: AppTheme.muted.withOpacity(0.6),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    countText.paint(canvas, Offset(size.width - countText.width - 10, 8));
  }

  void _drawStroke(Canvas canvas, List<Offset> pts, Paint paint) {
    if (pts.length < 2) {
      if (pts.length == 1) {
        canvas.drawCircle(pts.first, paint.strokeWidth / 2, paint);
      }
      return;
    }
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length; i++) {
      path.lineTo(pts[i].dx, pts[i].dy);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CanvasPainter old) =>
      old.userStrokes != userStrokes ||
      old.currentStroke != currentStroke ||
      old.refStrokes != refStrokes;
}
