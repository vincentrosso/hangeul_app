# 한글 · Hangeul — Flutter iOS App

Learn the Korean alphabet in 8 lessons with native speaker audio,
flashcard quizzes, and multiple-choice mode.

---

## Quick Start

### 1. Prerequisites
```bash
flutter --version   # needs 3.16+
# Xcode 15+ installed and command line tools active
```

### 2. Get dependencies
```bash
cd hangeul_app
flutter pub get
```

### 3. Download audio assets (one-time)
```bash
python3 download_audio.py
```

This downloads:
- Native speaker `.ogg` files from Wikimedia Commons for ~30 characters
- Google Translate TTS `.mp3` for all 51 characters

**Without this step the app still works** — `flutter_tts` kicks in as a
runtime fallback using the device's built-in Korean TTS voice.

### 4. Run on iOS Simulator
```bash
open -a Simulator
flutter run
```

### 5. Run on physical iPhone
```bash
# Open Xcode, set your Team in Signing & Capabilities
open ios/Runner.xcworkspace
# Then:
flutter run --release
```

---

## Audio Priority (per character)

| Priority | Source | Quality |
|----------|--------|---------|
| 1 | `assets/audio/<hex>_native.ogg` | Native speaker (Wikimedia CC-BY-SA) |
| 2 | `assets/audio/<hex>.mp3` | Google Neural TTS |
| 3 | `flutter_tts` at runtime | Device ko-KR voice (offline, always works) |

The dot indicator on each card:
- 🔵 **Blue** = native speaker recording bundled
- 🟢 **Green** = Google Neural TTS bundled

---

## Project Structure

```
lib/
  main.dart                  # entry point
  models/models.dart         # CharCard, Lesson, QuizMode
  data/lessons.dart          # all 8 lessons with 51 characters
  services/
    audio_service.dart       # 3-tier audio (native → gtts → tts)
    progress_service.dart    # shared_preferences persistence
  theme/app_theme.dart       # paper/ink color scheme + typography
  screens/
    home_screen.dart         # lesson list + progress bar
    lesson_screen.dart       # study tab + quiz tab
    quiz_screen.dart         # flashcard + multiple choice + results
  widgets/
    char_card_widget.dart    # tappable char card with audio dot
assets/
  audio/                     # bundled mp3/ogg files (after download_audio.py)
download_audio.py            # one-time audio fetch script
```

---

## Dependencies

| Package | Purpose |
|---------|---------|
| `flutter_tts` | Offline ko-KR TTS fallback |
| `just_audio` | Plays bundled .mp3 / .ogg assets |
| `shared_preferences` | Lesson completion persistence |
| `google_fonts` | Noto Serif KR, DM Mono, Playfair Display |

---

## Adding More Lessons

1. Add entries to `lib/data/lessons.dart`
2. Add the new characters to the `CHARS` list in `download_audio.py`
3. Run `python3 download_audio.py` again (skips already-downloaded files)
4. Add any Wikimedia native chars to `_nativeChars` in `char_card_widget.dart`
   and `audio_service.dart`
