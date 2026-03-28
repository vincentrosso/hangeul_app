import '../models/models.dart';

const List<Lesson> kLessons = [
  Lesson(
    number: 1,
    titleEn: 'Basic Vowels of Hangeul',
    titleKr: '한글의 기본 모음',
    note:
        'Korean has 10 basic vowels. They always combine with a silent consonant placeholder (ㅇ) when written alone. Vowels are either vertical or horizontal strokes.',
    chars: [
      CharCard(char: '아', romanized: 'a',   example: '아이 (child)'),
      CharCard(char: '야', romanized: 'ya',  example: '야구 (baseball)'),
      CharCard(char: '어', romanized: 'eo',  example: '어머니 (mother)'),
      CharCard(char: '여', romanized: 'yeo', example: '여자 (woman)'),
      CharCard(char: '오', romanized: 'o',   example: '오리 (duck)'),
      CharCard(char: '요', romanized: 'yo',  example: '요리 (cooking)'),
      CharCard(char: '우', romanized: 'u',   example: '우유 (milk)'),
      CharCard(char: '유', romanized: 'yu',  example: '유리 (glass)'),
      CharCard(char: '으', romanized: 'eu',  example: '으뜸 (top)'),
      CharCard(char: '이', romanized: 'i',   example: '이름 (name)'),
    ],
  ),
  Lesson(
    number: 2,
    titleEn: 'Basic Consonants of Hangeul',
    titleKr: '한글의 기본 자음',
    note:
        '14 basic consonants, each shaped after the mouth position that produces the sound. ㄱ looks like the back of the tongue blocking the throat.',
    chars: [
      CharCard(char: '가', romanized: 'g/k',    example: '가방 (bag)'),
      CharCard(char: '나', romanized: 'n',      example: '나무 (tree)'),
      CharCard(char: '다', romanized: 'd/t',    example: '다리 (bridge)'),
      CharCard(char: '라', romanized: 'r/l',    example: '라디오 (radio)'),
      CharCard(char: '마', romanized: 'm',      example: '마음 (heart)'),
      CharCard(char: '바', romanized: 'b/p',    example: '바다 (sea)'),
      CharCard(char: '사', romanized: 's',      example: '사랑 (love)'),
      CharCard(char: '아', romanized: 'silent', example: '아침 (morning)'),
      CharCard(char: '자', romanized: 'j',      example: '자다 (sleep)'),
      CharCard(char: '하', romanized: 'h',      example: '하늘 (sky)'),
    ],
  ),
  Lesson(
    number: 3,
    titleEn: 'More Consonants of Hangeul',
    titleKr: '더 많은 자음',
    note:
        'These 4 consonants are aspirated — released with a puff of air. Korean makes the aspirated/unaspirated distinction explicit in its alphabet.',
    chars: [
      CharCard(char: '카', romanized: 'k',  example: '카페 (café)'),
      CharCard(char: '타', romanized: 't',  example: '타다 (ride)'),
      CharCard(char: '파', romanized: 'p',  example: '파다 (dig)'),
      CharCard(char: '차', romanized: 'ch', example: '차 (tea/car)'),
    ],
  ),
  Lesson(
    number: 4,
    titleEn: 'Compound Vowels of Hangeul',
    titleKr: '합성 모음',
    note:
        'Compound vowels blend two basic vowels. 애 = 아+이, 에 = 어+이. Your mouth starts in one position and glides to another.',
    chars: [
      CharCard(char: '애', romanized: 'ae',  example: '애인 (lover)'),
      CharCard(char: '에', romanized: 'e',   example: '에어컨 (AC)'),
      CharCard(char: '얘', romanized: 'yae', example: '얘기 (story)'),
      CharCard(char: '예', romanized: 'ye',  example: '예쁘다 (pretty)'),
      CharCard(char: '와', romanized: 'wa',  example: '와인 (wine)'),
      CharCard(char: '왜', romanized: 'wae', example: '왜 (why)'),
      CharCard(char: '외', romanized: 'oe',  example: '외국 (foreign)'),
      CharCard(char: '워', romanized: 'wo',  example: '워크 (work)'),
      CharCard(char: '웨', romanized: 'we',  example: '웨딩 (wedding)'),
      CharCard(char: '위', romanized: 'wi',  example: '위 (stomach)'),
      CharCard(char: '의', romanized: 'ui',  example: '의사 (doctor)'),
    ],
  ),
  Lesson(
    number: 5,
    titleEn: '"Y" in Hangeul',
    titleKr: "한글의 'Y' 소리",
    note:
        'No standalone "Y" letter — an extra stroke added to a vowel creates the Y-glide. ㅏ→ㅑ (a→ya). One stroke becomes two.',
    chars: [
      CharCard(char: '야', romanized: 'ya',  example: '야채 (vegetable)'),
      CharCard(char: '여', romanized: 'yeo', example: '여행 (travel)'),
      CharCard(char: '요', romanized: 'yo',  example: '요가 (yoga)'),
      CharCard(char: '유', romanized: 'yu',  example: '유행 (trend)'),
      CharCard(char: '얘', romanized: 'yae', example: '얘기 (talk)'),
      CharCard(char: '예', romanized: 'ye',  example: '예의 (courtesy)'),
    ],
  ),
  Lesson(
    number: 6,
    titleEn: 'Final Consonants in Hangeul',
    titleKr: '받침',
    note:
        '받침 sit at the bottom of a syllable block. Structure: (C)V(C). The final consonant subtly closes the sound.',
    chars: [
      CharCard(char: '닭', romanized: 'dak',   example: '닭 (chicken)'),
      CharCard(char: '밥', romanized: 'bap',   example: '밥 (rice/meal)'),
      CharCard(char: '책', romanized: 'chaek', example: '책 (book)'),
      CharCard(char: '물', romanized: 'mul',   example: '물 (water)'),
      CharCard(char: '산', romanized: 'san',   example: '산 (mountain)'),
      CharCard(char: '봄', romanized: 'bom',   example: '봄 (spring)'),
      CharCard(char: '강', romanized: 'gang',  example: '강 (river)'),
    ],
  ),
  Lesson(
    number: 7,
    titleEn: 'Review & Practice',
    titleKr: '복습 및 연습',
    note:
        'Every syllable block needs at least one consonant + one vowel, built top-left to bottom-right. Practice reading these common words.',
    chars: [
      CharCard(char: '한국', romanized: 'han-guk', example: 'Korea'),
      CharCard(char: '사람', romanized: 'sa-ram',  example: 'person'),
      CharCard(char: '음식', romanized: 'eum-sik', example: 'food'),
      CharCard(char: '학교', romanized: 'hak-gyo', example: 'school'),
      CharCard(char: '친구', romanized: 'chin-gu', example: 'friend'),
      CharCard(char: '가족', romanized: 'ga-jok',  example: 'family'),
    ],
  ),
  Lesson(
    number: 8,
    titleEn: 'How to Write Hangeul',
    titleKr: '한글 쓰는 방법',
    note:
        'Write top-to-bottom, left-to-right. Every character fits an imaginary square. The syllable block is the fundamental unit — never write letters alone.',
    chars: [
      CharCard(char: 'ㄱ', romanized: 'g/k', example: '← 2 strokes'),
      CharCard(char: 'ㄴ', romanized: 'n',   example: '← 2 strokes'),
      CharCard(char: 'ㅏ', romanized: 'a',   example: '← 2 strokes'),
      CharCard(char: 'ㅣ', romanized: 'i',   example: '← 1 stroke'),
      CharCard(char: '가', romanized: 'ga',  example: '← syllable block'),
      CharCard(char: '나', romanized: 'na',  example: '← syllable block'),
    ],
  ),
];
