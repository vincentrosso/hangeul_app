#!/usr/bin/env python3
"""
Run this ONCE from the hangeul_app/ directory before building:
    python3 download_audio.py

It downloads:
  1. Native speaker .ogg files from Wikimedia Commons (CC-BY-SA)
     → saved as assets/audio/<hex>_native.mp3
  2. Google Translate TTS .mp3 for every character
     → saved as assets/audio/<hex>.mp3

The Flutter app prefers _native files when present, falls back to .mp3,
then falls back to flutter_tts at runtime.
"""

import os, time, urllib.parse, urllib.request, ssl

OUT = os.path.join(os.path.dirname(__file__), 'assets', 'audio')
os.makedirs(OUT, exist_ok=True)

# All unique characters across all 8 lessons
CHARS = [
    # L1 basic vowels
    '아', '야', '어', '여', '오', '요', '우', '유', '으', '이',
    # L2 basic consonants
    '가', '나', '다', '라', '마', '바', '사', '자', '하',
    # L3 aspirated consonants
    '카', '타', '파', '차',
    # L4 compound vowels
    '애', '에', '얘', '예', '와', '왜', '외', '워', '웨', '위', '의',
    # L6 final consonant words
    '닭', '밥', '책', '물', '산', '봄', '강',
    # L7 review words
    '한국', '사람', '음식', '학교', '친구', '가족',
    # L8 jamo
    'ㄱ', 'ㄴ', 'ㅏ', 'ㅣ',
]

# Characters that have confirmed Ko-*.ogg files on Wikimedia Commons
WIKI_NATIVES = {
    '가', '나', '다', '라', '마', '바', '사', '자', '하',
    '카', '타', '파', '차',
    '닭', '밥', '책', '물', '산', '봄', '강',
    '한국', '사람', '음식', '학교', '친구', '가족',
}

HEADERS = {
    'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) '
                  'AppleWebKit/537.36 (KHTML, like Gecko) '
                  'Chrome/120.0.0.0 Safari/537.36',
    'Referer': 'https://translate.google.com/',
}

ctx = ssl.create_default_context()

def hex_name(char):
    return '_'.join(f'{ord(c):04x}' for c in char)

def fetch(url, extra_headers=None):
    req = urllib.request.Request(url, headers={**HEADERS, **(extra_headers or {})})
    with urllib.request.urlopen(req, context=ctx, timeout=12) as r:
        return r.read()

ok_native = []
ok_gtts = []
failed = []

for char in CHARS:
    stem = hex_name(char)
    gtts_path = os.path.join(OUT, f'{stem}.mp3')
    native_path = os.path.join(OUT, f'{stem}_native.ogg')

    # --- Wikimedia native ---
    if char in WIKI_NATIVES and not os.path.exists(native_path):
        try:
            wiki_url = f'https://commons.wikimedia.org/wiki/Special:FilePath/Ko-{urllib.parse.quote(char)}.ogg'
            data = fetch(wiki_url)
            if len(data) > 2000:
                with open(native_path, 'wb') as f:
                    f.write(data)
                ok_native.append(char)
                print(f'  ✓ native  {char}')
            else:
                print(f'  ~ native  {char}  (too small, skipped)')
        except Exception as e:
            print(f'  ~ native  {char}  ({e})')
        time.sleep(0.2)
    elif os.path.exists(native_path):
        ok_native.append(char)

    # --- Google TTS ---
    if not os.path.exists(gtts_path):
        try:
            gtts_url = (
                f'https://translate.googleapis.com/translate_tts'
                f'?ie=UTF-8&tl=ko&client=gtx&q={urllib.parse.quote(char)}'
            )
            data = fetch(gtts_url)
            if len(data) > 1000:
                with open(gtts_path, 'wb') as f:
                    f.write(data)
                ok_gtts.append(char)
                print(f'  ✓ gtts    {char}')
            else:
                print(f'  ✗ gtts    {char}  (response too small)')
                failed.append(char)
        except Exception as e:
            print(f'  ✗ gtts    {char}  ({e})')
            failed.append(char)
        time.sleep(0.3)
    else:
        ok_gtts.append(char)

print(f'\n{"="*50}')
print(f'Native recordings : {len(ok_native)}/{len(CHARS)}')
print(f'Google TTS        : {len(ok_gtts)}/{len(CHARS)}')
if failed:
    print(f'Failed (will use flutter_tts at runtime): {failed}')
print('\nAll done! Now run: flutter pub get && flutter run')
