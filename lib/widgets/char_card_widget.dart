import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';

class CharCardWidget extends StatefulWidget {
  final CharCard card;
  final MasteryLevel? mastery;

  const CharCardWidget({
    super.key,
    required this.card,
    this.mastery,
  });

  @override
  State<CharCardWidget> createState() => _CharCardWidgetState();
}

class _CharCardWidgetState extends State<CharCardWidget>
    with SingleTickerProviderStateMixin {
  bool _playing = false;
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..addStatusListener((s) {
        if (s == AnimationStatus.completed) _pulse.reverse();
      });
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _play() async {
    setState(() => _playing = true);
    HapticFeedback.lightImpact();
    _pulse.forward();
    await AudioService.instance.play(widget.card);
    if (mounted) setState(() => _playing = false);
  }

  // Detect if bundled native ogg likely exists (heuristic based on known set)
  static const _nativeChars = {
    '가','나','다','라','마','바','사','자','하',
    '카','타','파','차',
    '닭','밥','책','물','산','봄','강',
    '한국','사람','음식','학교','친구','가족',
  };

  Color get _dotColor {
    if (_nativeChars.contains(widget.card.char)) return AppTheme.nativeBlue;
    return AppTheme.gttGreen;
  }

  String get _dotTooltip {
    if (_nativeChars.contains(widget.card.char)) return 'Native speaker';
    return 'Google Neural TTS';
  }

  Color? get _masteryPipColor {
    switch (widget.mastery) {
      case MasteryLevel.unseen:
        return null; // no pip
      case MasteryLevel.seen:
        return const Color(0xFFAAAAAA);
      case MasteryLevel.recognized:
        return const Color(0xFFD4A017);
      case MasteryLevel.canWrite:
        return AppTheme.done;
      case null:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _play,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: _playing
              ? AppTheme.nativeBlue.withOpacity(0.06)
              : AppTheme.cream,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: _playing ? AppTheme.accent : AppTheme.border,
            width: _playing ? 1.5 : 1,
          ),
        ),
        child: Stack(
          children: [
            // Audio source dot (top-right)
            Positioned(
              top: 6, right: 6,
              child: Tooltip(
                message: _dotTooltip,
                child: Container(
                  width: 6, height: 6,
                  decoration: BoxDecoration(
                    color: _dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),

            // Mastery pip (bottom-left)
            if (_masteryPipColor != null)
              Positioned(
                bottom: 6, left: 6,
                child: Container(
                  width: 6, height: 6,
                  decoration: BoxDecoration(
                    color: _masteryPipColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),

            // Card content
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 14, 8, 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Big Korean character — shrink-to-fit for long loan words like 에스컬레이터
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      widget.card.char,
                      maxLines: 1,
                      style: GoogleFonts.notoSerifKr(
                        fontSize: 34,
                        fontWeight: FontWeight.w700,
                        color: _playing ? AppTheme.accent : AppTheme.ink,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Romanization
                  Text(
                    widget.card.romanized,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.dmMono(
                      fontSize: 11,
                      color: AppTheme.muted,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Example word
                  Text(
                    widget.card.example,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.notoSansKr(
                      fontSize: 9,
                      color: AppTheme.lightMuted,
                    ),
                  ),

                  const SizedBox(height: 6),
                  // Speaker icon
                  Icon(
                    _playing ? Icons.volume_up : Icons.volume_up_outlined,
                    size: 14,
                    color: _playing ? AppTheme.accent : AppTheme.lightMuted,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Legend row shown above char grid
class AudioLegend extends StatelessWidget {
  final int nativeCount;
  final int total;
  const AudioLegend({super.key, required this.nativeCount, required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          _dot(AppTheme.nativeBlue),
          const SizedBox(width: 4),
          Text('Native recording', style: _label),
          const SizedBox(width: 14),
          _dot(AppTheme.gttGreen),
          const SizedBox(width: 4),
          Text('Google Neural TTS', style: _label),
          const Spacer(),
          Text(
            '$nativeCount/$total native',
            style: _label.copyWith(color: AppTheme.lightMuted),
          ),
        ],
      ),
    );
  }

  Widget _dot(Color c) => Container(
        width: 7, height: 7,
        decoration: BoxDecoration(color: c, shape: BoxShape.circle),
      );

  TextStyle get _label => GoogleFonts.dmMono(
        fontSize: 10,
        letterSpacing: 0.8,
        color: AppTheme.muted,
      );
}
