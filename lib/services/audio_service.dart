import 'package:flutter/services.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/models.dart';

/// Plays Korean audio with a 3-tier priority:
///   1. Bundled native speaker .ogg  (assets/audio/<stem>_native.ogg)
///   2. Bundled Google TTS .mp3      (assets/audio/<stem>.mp3)
///   3. flutter_tts at runtime       (ko-KR, works offline)
class AudioService {
  AudioService._();
  static final AudioService instance = AudioService._();

  final AudioPlayer _player = AudioPlayer();
  final FlutterTts _tts = FlutterTts();
  bool _ttsReady = false;

  Future<void> init() async {
    await _tts.setLanguage('ko-KR');
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);
    _ttsReady = true;
  }

  Future<void> play(CharCard card) async {
    await _stop();

    // Tier 1: bundled native .ogg
    if (await _tryAsset(card.nativeAsset)) return;

    // Tier 2: bundled Google TTS .mp3
    if (await _tryAsset(card.gttsAsset)) return;

    // Tier 3: flutter_tts runtime
    await _speakTts(card.char);
  }

  Future<void> playChar(String char) async {
    // Convenience: play by raw character string (used in quiz)
    final stem = char.codeUnits
        .map((c) => c.toRadixString(16).padLeft(4, '0'))
        .join('_');

    await _stop();

    if (await _tryAsset('assets/audio/${stem}_native.ogg')) return;
    if (await _tryAsset('assets/audio/$stem.mp3')) return;
    await _speakTts(char);
  }

  Future<bool> _tryAsset(String assetPath) async {
    try {
      // Check the asset exists in the bundle before trying to play
      await rootBundle.load(assetPath);
      await _player.setAudioSource(AudioSource.asset(assetPath));
      await _player.play();
      return true;
    } on FlutterError {
      // Asset not found in bundle
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> _speakTts(String text) async {
    if (!_ttsReady) await init();
    await _tts.speak(text);
  }

  Future<void> _stop() async {
    await _tts.stop();
    await _player.stop();
  }

  Future<void> dispose() async {
    await _stop();
    await _player.dispose();
  }
}
