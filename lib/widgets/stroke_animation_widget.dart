import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../data/stroke_data.dart';
import '../theme/app_theme.dart';

class StrokeAnimationWidget extends StatefulWidget {
  final String char;
  final double size;
  final bool autoPlay;
  final Color strokeColor;
  final Color backgroundColor;

  const StrokeAnimationWidget({
    super.key,
    required this.char,
    this.size = 120,
    this.autoPlay = true,
    this.strokeColor = AppTheme.ink,
    this.backgroundColor = AppTheme.paper,
  });

  @override
  State<StrokeAnimationWidget> createState() => _StrokeAnimationWidgetState();
}

class _StrokeAnimationWidgetState extends State<StrokeAnimationWidget>
    with TickerProviderStateMixin {
  List<List<Offset>>? _strokes;
  List<AnimationController> _controllers = [];
  List<Animation<double>> _animations = [];
  int _currentStroke = 0;
  bool _playing = false;

  @override
  void initState() {
    super.initState();
    _strokes = getCharStrokes(widget.char);
    if (_strokes != null && _strokes!.isNotEmpty) {
      _setupControllers();
      if (widget.autoPlay) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _play());
      }
    }
  }

  void _setupControllers() {
    for (final c in _controllers) {
      c.dispose();
    }
    _controllers = [];
    _animations = [];

    for (int i = 0; i < _strokes!.length; i++) {
      final ctrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 600),
      );
      final anim = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: ctrl, curve: Curves.easeInOut),
      );
      _controllers.add(ctrl);
      _animations.add(anim);
    }
  }

  void _play() {
    if (_strokes == null || _strokes!.isEmpty) return;
    setState(() {
      _playing = true;
      _currentStroke = 0;
    });
    for (final c in _controllers) {
      c.reset();
    }
    _playStroke(0);
  }

  void _playStroke(int idx) {
    if (idx >= _controllers.length) {
      setState(() => _playing = false);
      return;
    }
    setState(() => _currentStroke = idx);
    _controllers[idx].addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controllers[idx].removeStatusListener((s) {});
        if (mounted) _playStroke(idx + 1);
      }
    });
    _controllers[idx].forward(from: 0.0);
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_strokes == null || _strokes!.isEmpty) {
      return SizedBox(
        width: widget.size,
        height: widget.size,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.char,
              style: GoogleFonts.notoSerifKr(
                fontSize: widget.size * 0.45,
                fontWeight: FontWeight.w700,
                color: widget.strokeColor,
              ),
            ),
            Text(
              'No stroke data',
              style: GoogleFonts.dmMono(
                fontSize: 9,
                color: AppTheme.lightMuted,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.border),
          ),
          child: AnimatedBuilder(
            animation: Listenable.merge(_controllers.isEmpty ? [] : _controllers),
            builder: (context, _) {
              return CustomPaint(
                painter: _StrokeAnimationPainter(
                  strokes: _strokes!,
                  controllers: _controllers,
                  currentStroke: _currentStroke,
                  strokeColor: widget.strokeColor,
                  playing: _playing,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_strokes != null && _strokes!.isNotEmpty)
              Text(
                _playing
                    ? 'Stroke ${_currentStroke + 1} of ${_strokes!.length}'
                    : '${_strokes!.length} stroke${_strokes!.length == 1 ? '' : 's'}',
                style: GoogleFonts.dmMono(
                  fontSize: 9,
                  color: AppTheme.lightMuted,
                  letterSpacing: 0.3,
                ),
              ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _playing ? null : _play,
              child: Icon(
                Icons.replay,
                size: 14,
                color: _playing ? AppTheme.lightMuted : AppTheme.accent,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StrokeAnimationPainter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<AnimationController> controllers;
  final int currentStroke;
  final Color strokeColor;
  final bool playing;

  _StrokeAnimationPainter({
    required this.strokes,
    required this.controllers,
    required this.currentStroke,
    required this.strokeColor,
    required this.playing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final completedPaint = Paint()
      ..color = strokeColor
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final ghostPaint = Paint()
      ..color = strokeColor.withOpacity(0.08)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < strokes.length; i++) {
      final pts = strokes[i]
          .map((p) => Offset(p.dx * size.width, p.dy * size.height))
          .toList();

      if (i < currentStroke) {
        // Completed strokes — full opacity
        _drawPath(canvas, pts, completedPaint);
      } else if (i == currentStroke && playing) {
        // Current animating stroke — partial
        final progress = controllers.isNotEmpty && i < controllers.length
            ? controllers[i].value
            : 1.0;
        final partialPts = _partialPoints(pts, progress);
        _drawPath(canvas, partialPts, completedPaint);
      } else if (!playing && i <= currentStroke) {
        // After animation done
        _drawPath(canvas, pts, completedPaint);
      } else {
        // Upcoming strokes — ghost
        _drawPath(canvas, pts, ghostPaint);
      }
    }
  }

  List<Offset> _partialPoints(List<Offset> pts, double progress) {
    if (pts.isEmpty) return [];
    if (progress <= 0) return [pts.first];
    if (progress >= 1.0) return pts;

    double totalLen = 0;
    for (int i = 1; i < pts.length; i++) {
      totalLen += (pts[i] - pts[i - 1]).distance;
    }

    final targetLen = totalLen * progress;
    double acc = 0;
    final result = <Offset>[pts.first];

    for (int i = 1; i < pts.length; i++) {
      final segLen = (pts[i] - pts[i - 1]).distance;
      if (acc + segLen >= targetLen) {
        final t = segLen == 0 ? 0.0 : (targetLen - acc) / segLen;
        result.add(Offset.lerp(pts[i - 1], pts[i], t.clamp(0.0, 1.0))!);
        break;
      }
      acc += segLen;
      result.add(pts[i]);
    }

    return result;
  }

  void _drawPath(Canvas canvas, List<Offset> pts, Paint paint) {
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
  bool shouldRepaint(_StrokeAnimationPainter old) => true;
}
