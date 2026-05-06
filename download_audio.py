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

# All unique characters across all lessons + example words used in the web UI
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
    # L9 jamo (writing lesson)
    'ㄱ', 'ㄴ', 'ㅏ', 'ㅣ',
    # Example words shown in the web UI (one per lesson card)
    '아이', '야구', '어머니', '여자', '오리', '요리', '우유', '유리', '으뜸', '이름',
    '가방', '나무', '다리', '라디오', '마음', '바다', '사랑', '아침', '자다', '하늘',
    '카페', '타다', '파도',
    '애인', '에어컨', '얘기', '예쁘다', '와인', '왜냐면', '외국', '워크샵', '웨딩', '위험', '의사',
    '야채', '여행', '요가', '유행', '예의',
    '닭고기', '밥그릇', '책상', '물병', '산책', '봄바람', '강물',
    '한국어', '사람들', '음식점', '학교생활', '친구들', '가족들',
    # L8 loan words (외래어), Korean alphabetical order
    '게임', '골프', '기타', '뉴스', '다이어트', '댄스', '데이터', '데이트', '드라마', '드레스',
    '디자인', '디저트', '라디오', '레몬', '로션', '리더', '리포트', '마라톤', '마우스', '마케팅',
    '마트', '매니저', '메뉴', '모델', '모텔', '무비', '미팅', '바나나', '버스', '버터',
    '벨트', '볼링', '부츠', '블로그', '비디오', '비자', '비즈니스', '빌딩', '사이트', '샌드위치',
    '샐러드', '샴푸', '서비스', '선글라스', '셔츠', '소스', '스카프', '스커트', '스케이트', '스케줄',
    '스키', '스타', '스테이크', '시스템', '아이돌', '아이스크림', '아파트', '앱', '에스컬레이터', '엘리베이터',
    '오렌지', '오피스', '오피스텔', '와인', '요가', '요거트', '워크숍', '웨딩', '이메일', '이벤트',
    '인터넷', '재킷', '주스', '진', '초콜릿', '치즈', '카드', '카메라', '캠핑', '캡',
    '커피', '컴퓨터', '케이크', '케첩', '코트', '콘서트', '콜라', '쿠키', '키보드', '택시',
    '테니스', '텔레비전', '토스트', '투어', '티셔츠', '티켓', '팀', '파스타', '파일', '파티',
    '팬', '프로젝트', '프린터', '피아노', '피자', '햄버거', '허니문', '헬스', '호텔',
]

# Try Wikimedia native audio for every char — script skips silently on 404/too-small
WIKI_NATIVES = set(CHARS)

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
