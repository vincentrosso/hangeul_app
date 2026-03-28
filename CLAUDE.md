# CLAUDE.md

This file provides guidance to Claude Code when working in this directory.

---

## Output Defaults

Default output format is raw text — no markdown formatting, no code fences, no bold/italic, no bullet lists, unless specifically requested or the content type clearly requires it (e.g., a code file, a shell script).

---

## Project Overview

hangeul_app is a Flutter iOS app for learning the Korean alphabet (한글).
8 lessons, 51 characters, native speaker audio, flashcard and multiple-choice quiz modes.

App name: hangeul
Version: 1.0.0+1
Flutter SDK: >=3.16 (environment requires >=3.2.0 <4.0.0)
Target platform: iOS (Simulator + physical device)

---

## Structure

lib/main.dart                        entry point
lib/models/models.dart               CharCard, Lesson, QuizMode
lib/data/lessons.dart                all 8 lessons / 51 characters
lib/services/audio_service.dart      3-tier audio: native .ogg → Google TTS .mp3 → flutter_tts fallback
lib/services/progress_service.dart   lesson completion via shared_preferences
lib/theme/app_theme.dart             paper/ink color scheme, typography
lib/screens/home_screen.dart         lesson list + progress
lib/screens/lesson_screen.dart       study tab + quiz tab
lib/screens/quiz_screen.dart         flashcard + multiple choice + results
lib/widgets/char_card_widget.dart    tappable character card with audio dot indicator
assets/audio/                        bundled .mp3 / .ogg files (populated by download_audio.py)
download_audio.py                    one-time script to fetch audio assets

---

## Dependencies

flutter_tts ^4.0.2          offline ko-KR TTS fallback
just_audio ^0.9.38          plays bundled mp3/ogg assets
shared_preferences ^2.2.3   progress persistence
google_fonts ^6.2.1         Noto Serif KR, DM Mono, Playfair Display

---

## Common Commands

flutter pub get              install dependencies
python3 download_audio.py    fetch audio assets (one-time, skips already-downloaded)
open -a Simulator            launch iOS Simulator
flutter run                  run on simulator
flutter run --release        run on physical device (requires Xcode signing)
open ios/Runner.xcworkspace  open in Xcode for signing / device config

---

## Audio Priority

1. assets/audio/<hex>_native.ogg  — native speaker (Wikimedia CC-BY-SA)
2. assets/audio/<hex>.mp3         — Google Neural TTS
3. flutter_tts at runtime         — device ko-KR voice, always available as fallback

Card dot indicator: blue = native speaker bundled, green = Google TTS bundled.

---

## Extending Lessons

1. Add entries to lib/data/lessons.dart
2. Add new characters to the CHARS list in download_audio.py
3. Run python3 download_audio.py again (safe to re-run, skips existing files)
4. Add any Wikimedia native chars to _nativeChars in char_card_widget.dart and audio_service.dart
