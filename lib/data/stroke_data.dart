import 'package:flutter/painting.dart';

// ─── Jamo stroke tables ───────────────────────────────────────────────────────
//
// Each entry: jamo char → list of strokes.
// Each stroke: list of Offset(x, y) in a 0.0–1.0 unit square.
// Standard Korean stroke order: horizontal before vertical, top→bottom, left→right.

const Map<String, List<List<Offset>>> _jamoStrokes = {
  // ── Consonants ──────────────────────────────────────────────────────────────

  'ㄱ': [
    // Stroke 1: horizontal
    [Offset(0.15, 0.30), Offset(0.35, 0.29), Offset(0.55, 0.28), Offset(0.75, 0.28), Offset(0.82, 0.28)],
    // Stroke 2: vertical down from right end
    [Offset(0.82, 0.28), Offset(0.82, 0.42), Offset(0.82, 0.58), Offset(0.82, 0.72), Offset(0.82, 0.82)],
  ],

  'ㄴ': [
    // Stroke 1: vertical down
    [Offset(0.25, 0.18), Offset(0.25, 0.32), Offset(0.25, 0.50), Offset(0.25, 0.65), Offset(0.25, 0.78)],
    // Stroke 2: horizontal right
    [Offset(0.25, 0.78), Offset(0.40, 0.78), Offset(0.57, 0.78), Offset(0.72, 0.78), Offset(0.82, 0.78)],
  ],

  'ㄷ': [
    // Stroke 1: top horizontal
    [Offset(0.18, 0.22), Offset(0.38, 0.22), Offset(0.58, 0.22), Offset(0.78, 0.22)],
    // Stroke 2: left vertical down
    [Offset(0.18, 0.22), Offset(0.18, 0.38), Offset(0.18, 0.55), Offset(0.18, 0.68), Offset(0.18, 0.78)],
    // Stroke 3: bottom horizontal
    [Offset(0.18, 0.78), Offset(0.38, 0.78), Offset(0.58, 0.78), Offset(0.78, 0.78)],
  ],

  'ㄹ': [
    // Stroke 1: top horizontal
    [Offset(0.18, 0.18), Offset(0.40, 0.18), Offset(0.62, 0.18), Offset(0.80, 0.18)],
    // Stroke 2: right short vertical down
    [Offset(0.80, 0.18), Offset(0.80, 0.28), Offset(0.80, 0.38), Offset(0.80, 0.42)],
    // Stroke 3: middle horizontal going right to left
    [Offset(0.80, 0.42), Offset(0.62, 0.42), Offset(0.44, 0.42), Offset(0.26, 0.42), Offset(0.18, 0.42)],
    // Stroke 4: left vertical down
    [Offset(0.18, 0.42), Offset(0.18, 0.52), Offset(0.18, 0.62), Offset(0.18, 0.72), Offset(0.18, 0.80)],
    // Stroke 5: bottom horizontal
    [Offset(0.18, 0.80), Offset(0.38, 0.80), Offset(0.58, 0.80), Offset(0.80, 0.80)],
  ],

  'ㅁ': [
    // Stroke 1: left vertical
    [Offset(0.18, 0.22), Offset(0.18, 0.38), Offset(0.18, 0.55), Offset(0.18, 0.72), Offset(0.18, 0.80)],
    // Stroke 2: top horizontal
    [Offset(0.18, 0.22), Offset(0.38, 0.22), Offset(0.58, 0.22), Offset(0.78, 0.22)],
    // Stroke 3: right vertical
    [Offset(0.80, 0.22), Offset(0.80, 0.38), Offset(0.80, 0.55), Offset(0.80, 0.72), Offset(0.80, 0.80)],
    // Stroke 4: bottom horizontal
    [Offset(0.18, 0.80), Offset(0.38, 0.80), Offset(0.58, 0.80), Offset(0.80, 0.80)],
  ],

  'ㅂ': [
    // Stroke 1: left vertical down
    [Offset(0.22, 0.18), Offset(0.22, 0.35), Offset(0.22, 0.52), Offset(0.22, 0.68), Offset(0.22, 0.82)],
    // Stroke 2: right vertical down
    [Offset(0.78, 0.18), Offset(0.78, 0.35), Offset(0.78, 0.52), Offset(0.78, 0.68), Offset(0.78, 0.82)],
    // Stroke 3: top horizontal (caps the two verticals)
    [Offset(0.22, 0.18), Offset(0.42, 0.18), Offset(0.62, 0.18), Offset(0.78, 0.18)],
    // Stroke 4: middle connecting horizontal
    [Offset(0.22, 0.50), Offset(0.42, 0.50), Offset(0.62, 0.50), Offset(0.78, 0.50)],
    // Stroke 5: bottom horizontal (wider)
    [Offset(0.14, 0.82), Offset(0.35, 0.82), Offset(0.55, 0.82), Offset(0.78, 0.82), Offset(0.86, 0.82)],
  ],

  'ㅅ': [
    // Stroke 1: left diagonal down-left
    [Offset(0.50, 0.25), Offset(0.40, 0.42), Offset(0.30, 0.58), Offset(0.20, 0.72), Offset(0.12, 0.82)],
    // Stroke 2: right diagonal down-right
    [Offset(0.50, 0.25), Offset(0.60, 0.42), Offset(0.70, 0.58), Offset(0.80, 0.72), Offset(0.88, 0.82)],
  ],

  'ㅇ': [
    // Single circular stroke (clockwise from top), 12 points
    [
      Offset(0.50, 0.18),
      Offset(0.65, 0.20),
      Offset(0.78, 0.30),
      Offset(0.84, 0.44),
      Offset(0.84, 0.58),
      Offset(0.78, 0.72),
      Offset(0.65, 0.80),
      Offset(0.50, 0.82),
      Offset(0.35, 0.80),
      Offset(0.22, 0.72),
      Offset(0.16, 0.58),
      Offset(0.16, 0.44),
      Offset(0.22, 0.30),
      Offset(0.35, 0.20),
      Offset(0.50, 0.18),
    ],
  ],

  'ㅈ': [
    // Stroke 1: horizontal
    [Offset(0.18, 0.30), Offset(0.38, 0.29), Offset(0.58, 0.29), Offset(0.78, 0.30)],
    // Stroke 2: left diagonal
    [Offset(0.50, 0.30), Offset(0.38, 0.46), Offset(0.26, 0.62), Offset(0.14, 0.80)],
    // Stroke 3: right diagonal
    [Offset(0.50, 0.30), Offset(0.62, 0.46), Offset(0.74, 0.62), Offset(0.86, 0.80)],
  ],

  'ㅊ': [
    // Stroke 1: short tick at top
    [Offset(0.42, 0.12), Offset(0.50, 0.14), Offset(0.58, 0.16)],
    // Stroke 2: horizontal
    [Offset(0.18, 0.32), Offset(0.38, 0.31), Offset(0.58, 0.31), Offset(0.78, 0.32)],
    // Stroke 3: left diagonal
    [Offset(0.50, 0.32), Offset(0.38, 0.48), Offset(0.26, 0.64), Offset(0.14, 0.82)],
    // Stroke 4: right diagonal
    [Offset(0.50, 0.32), Offset(0.62, 0.48), Offset(0.74, 0.64), Offset(0.86, 0.82)],
  ],

  'ㅋ': [
    // Stroke 1: top horizontal
    [Offset(0.18, 0.22), Offset(0.40, 0.22), Offset(0.62, 0.22), Offset(0.80, 0.22)],
    // Stroke 2: short middle horizontal
    [Offset(0.18, 0.50), Offset(0.40, 0.50), Offset(0.62, 0.50)],
    // Stroke 3: right vertical (full height)
    [Offset(0.80, 0.22), Offset(0.80, 0.38), Offset(0.80, 0.55), Offset(0.80, 0.72), Offset(0.80, 0.82)],
  ],

  'ㅌ': [
    // Stroke 1: top horizontal
    [Offset(0.18, 0.18), Offset(0.40, 0.18), Offset(0.62, 0.18), Offset(0.80, 0.18)],
    // Stroke 2: left vertical
    [Offset(0.18, 0.18), Offset(0.18, 0.35), Offset(0.18, 0.52), Offset(0.18, 0.68), Offset(0.18, 0.80)],
    // Stroke 3: middle horizontal
    [Offset(0.18, 0.48), Offset(0.38, 0.48), Offset(0.58, 0.48), Offset(0.78, 0.48)],
    // Stroke 4: bottom horizontal
    [Offset(0.18, 0.80), Offset(0.38, 0.80), Offset(0.58, 0.80), Offset(0.80, 0.80)],
  ],

  'ㅍ': [
    // Stroke 1: top horizontal
    [Offset(0.12, 0.22), Offset(0.35, 0.22), Offset(0.58, 0.22), Offset(0.80, 0.22), Offset(0.88, 0.22)],
    // Stroke 2: left vertical down
    [Offset(0.30, 0.22), Offset(0.30, 0.38), Offset(0.30, 0.55), Offset(0.30, 0.72), Offset(0.30, 0.82)],
    // Stroke 3: right vertical down
    [Offset(0.70, 0.22), Offset(0.70, 0.38), Offset(0.70, 0.55), Offset(0.70, 0.72), Offset(0.70, 0.82)],
    // Stroke 4: bottom horizontal
    [Offset(0.12, 0.82), Offset(0.35, 0.82), Offset(0.58, 0.82), Offset(0.80, 0.82), Offset(0.88, 0.82)],
  ],

  'ㅎ': [
    // Stroke 1: short top tick
    [Offset(0.42, 0.10), Offset(0.50, 0.12), Offset(0.58, 0.14)],
    // Stroke 2: long horizontal
    [Offset(0.18, 0.28), Offset(0.38, 0.28), Offset(0.58, 0.28), Offset(0.78, 0.28)],
    // Stroke 3: circle (left arc + right arc drawn as full circle)
    [
      Offset(0.50, 0.40),
      Offset(0.65, 0.42),
      Offset(0.76, 0.52),
      Offset(0.80, 0.62),
      Offset(0.76, 0.74),
      Offset(0.65, 0.80),
      Offset(0.50, 0.82),
      Offset(0.35, 0.80),
      Offset(0.24, 0.74),
      Offset(0.20, 0.62),
      Offset(0.24, 0.52),
      Offset(0.35, 0.42),
      Offset(0.50, 0.40),
    ],
  ],

  // ── Vowels ──────────────────────────────────────────────────────────────────

  'ㅏ': [
    // Stroke 1: vertical
    [Offset(0.42, 0.10), Offset(0.42, 0.28), Offset(0.42, 0.50), Offset(0.42, 0.72), Offset(0.42, 0.90)],
    // Stroke 2: right horizontal from midpoint
    [Offset(0.42, 0.50), Offset(0.58, 0.50), Offset(0.72, 0.50), Offset(0.88, 0.50)],
  ],

  'ㅑ': [
    // Stroke 1: vertical
    [Offset(0.42, 0.10), Offset(0.42, 0.28), Offset(0.42, 0.50), Offset(0.42, 0.72), Offset(0.42, 0.90)],
    // Stroke 2: right horizontal upper
    [Offset(0.42, 0.35), Offset(0.58, 0.35), Offset(0.72, 0.35), Offset(0.88, 0.35)],
    // Stroke 3: right horizontal lower
    [Offset(0.42, 0.60), Offset(0.58, 0.60), Offset(0.72, 0.60), Offset(0.88, 0.60)],
  ],

  'ㅓ': [
    // Stroke 1: vertical
    [Offset(0.58, 0.10), Offset(0.58, 0.28), Offset(0.58, 0.50), Offset(0.58, 0.72), Offset(0.58, 0.90)],
    // Stroke 2: left horizontal from midpoint
    [Offset(0.58, 0.50), Offset(0.44, 0.50), Offset(0.30, 0.50), Offset(0.12, 0.50)],
  ],

  'ㅕ': [
    // Stroke 1: vertical
    [Offset(0.58, 0.10), Offset(0.58, 0.28), Offset(0.58, 0.50), Offset(0.58, 0.72), Offset(0.58, 0.90)],
    // Stroke 2: left horizontal upper
    [Offset(0.58, 0.35), Offset(0.44, 0.35), Offset(0.30, 0.35), Offset(0.12, 0.35)],
    // Stroke 3: left horizontal lower
    [Offset(0.58, 0.60), Offset(0.44, 0.60), Offset(0.30, 0.60), Offset(0.12, 0.60)],
  ],

  'ㅗ': [
    // Stroke 1: horizontal
    [Offset(0.10, 0.65), Offset(0.30, 0.65), Offset(0.50, 0.65), Offset(0.70, 0.65), Offset(0.90, 0.65)],
    // Stroke 2: short vertical up from midpoint
    [Offset(0.50, 0.65), Offset(0.50, 0.52), Offset(0.50, 0.38), Offset(0.50, 0.25), Offset(0.50, 0.15)],
  ],

  'ㅛ': [
    // Stroke 1: short left vertical up
    [Offset(0.30, 0.65), Offset(0.30, 0.52), Offset(0.30, 0.38), Offset(0.30, 0.25), Offset(0.30, 0.15)],
    // Stroke 2: short right vertical up
    [Offset(0.70, 0.65), Offset(0.70, 0.52), Offset(0.70, 0.38), Offset(0.70, 0.25), Offset(0.70, 0.15)],
    // Stroke 3: horizontal
    [Offset(0.10, 0.65), Offset(0.30, 0.65), Offset(0.50, 0.65), Offset(0.70, 0.65), Offset(0.90, 0.65)],
  ],

  'ㅜ': [
    // Stroke 1: horizontal
    [Offset(0.10, 0.35), Offset(0.30, 0.35), Offset(0.50, 0.35), Offset(0.70, 0.35), Offset(0.90, 0.35)],
    // Stroke 2: short vertical down from midpoint
    [Offset(0.50, 0.35), Offset(0.50, 0.48), Offset(0.50, 0.62), Offset(0.50, 0.75), Offset(0.50, 0.85)],
  ],

  'ㅠ': [
    // Stroke 1: left short vertical down
    [Offset(0.30, 0.35), Offset(0.30, 0.48), Offset(0.30, 0.62), Offset(0.30, 0.75), Offset(0.30, 0.82)],
    // Stroke 2: right short vertical down
    [Offset(0.70, 0.35), Offset(0.70, 0.48), Offset(0.70, 0.62), Offset(0.70, 0.75), Offset(0.70, 0.82)],
    // Stroke 3: horizontal
    [Offset(0.10, 0.35), Offset(0.30, 0.35), Offset(0.50, 0.35), Offset(0.70, 0.35), Offset(0.90, 0.35)],
  ],

  'ㅡ': [
    // Single horizontal stroke
    [Offset(0.10, 0.50), Offset(0.28, 0.50), Offset(0.50, 0.50), Offset(0.72, 0.50), Offset(0.90, 0.50)],
  ],

  'ㅣ': [
    // Single vertical stroke
    [Offset(0.50, 0.10), Offset(0.50, 0.28), Offset(0.50, 0.50), Offset(0.50, 0.72), Offset(0.50, 0.90)],
  ],

  // ── Compound vowels ──────────────────────────────────────────────────────────

  // ㅐ = ㅏ + rightmost vertical line at x=0.85
  'ㅐ': [
    [Offset(0.35, 0.10), Offset(0.35, 0.28), Offset(0.35, 0.50), Offset(0.35, 0.72), Offset(0.35, 0.90)],
    [Offset(0.35, 0.50), Offset(0.55, 0.50), Offset(0.72, 0.50), Offset(0.82, 0.50)],
    [Offset(0.82, 0.10), Offset(0.82, 0.28), Offset(0.82, 0.50), Offset(0.82, 0.72), Offset(0.82, 0.90)],
  ],

  // ㅒ = ㅑ + rightmost vertical line
  'ㅒ': [
    [Offset(0.32, 0.10), Offset(0.32, 0.28), Offset(0.32, 0.50), Offset(0.32, 0.72), Offset(0.32, 0.90)],
    [Offset(0.32, 0.32), Offset(0.52, 0.32), Offset(0.68, 0.32), Offset(0.78, 0.32)],
    [Offset(0.32, 0.58), Offset(0.52, 0.58), Offset(0.68, 0.58), Offset(0.78, 0.58)],
    [Offset(0.78, 0.10), Offset(0.78, 0.28), Offset(0.78, 0.50), Offset(0.78, 0.72), Offset(0.78, 0.90)],
  ],

  // ㅔ = ㅓ + leftmost vertical line at x=0.15
  'ㅔ': [
    [Offset(0.65, 0.10), Offset(0.65, 0.28), Offset(0.65, 0.50), Offset(0.65, 0.72), Offset(0.65, 0.90)],
    [Offset(0.65, 0.50), Offset(0.48, 0.50), Offset(0.32, 0.50), Offset(0.15, 0.50)],
    [Offset(0.15, 0.10), Offset(0.15, 0.28), Offset(0.15, 0.50), Offset(0.15, 0.72), Offset(0.15, 0.90)],
  ],

  // ㅖ = ㅕ + leftmost vertical line
  'ㅖ': [
    [Offset(0.65, 0.10), Offset(0.65, 0.28), Offset(0.65, 0.50), Offset(0.65, 0.72), Offset(0.65, 0.90)],
    [Offset(0.65, 0.32), Offset(0.48, 0.32), Offset(0.32, 0.32), Offset(0.15, 0.32)],
    [Offset(0.65, 0.58), Offset(0.48, 0.58), Offset(0.32, 0.58), Offset(0.15, 0.58)],
    [Offset(0.15, 0.10), Offset(0.15, 0.28), Offset(0.15, 0.50), Offset(0.15, 0.72), Offset(0.15, 0.90)],
  ],

  // ㅘ = left ㅗ portion + right ㅏ portion
  'ㅘ': [
    // ㅗ horizontal (left half)
    [Offset(0.05, 0.65), Offset(0.22, 0.65), Offset(0.40, 0.65), Offset(0.52, 0.65)],
    // ㅗ vertical up
    [Offset(0.28, 0.65), Offset(0.28, 0.50), Offset(0.28, 0.35), Offset(0.28, 0.20)],
    // ㅏ vertical
    [Offset(0.65, 0.10), Offset(0.65, 0.30), Offset(0.65, 0.50), Offset(0.65, 0.70), Offset(0.65, 0.90)],
    // ㅏ horizontal right
    [Offset(0.65, 0.50), Offset(0.75, 0.50), Offset(0.88, 0.50)],
  ],

  // ㅙ = ㅘ + vertical line on right
  'ㅙ': [
    [Offset(0.05, 0.65), Offset(0.20, 0.65), Offset(0.35, 0.65), Offset(0.46, 0.65)],
    [Offset(0.25, 0.65), Offset(0.25, 0.50), Offset(0.25, 0.35), Offset(0.25, 0.20)],
    [Offset(0.58, 0.10), Offset(0.58, 0.30), Offset(0.58, 0.50), Offset(0.58, 0.70), Offset(0.58, 0.90)],
    [Offset(0.58, 0.50), Offset(0.68, 0.50), Offset(0.80, 0.50)],
    [Offset(0.88, 0.10), Offset(0.88, 0.30), Offset(0.88, 0.50), Offset(0.88, 0.70), Offset(0.88, 0.90)],
  ],

  // ㅚ = ㅗ + right vertical
  'ㅚ': [
    [Offset(0.10, 0.65), Offset(0.32, 0.65), Offset(0.55, 0.65), Offset(0.78, 0.65)],
    [Offset(0.44, 0.65), Offset(0.44, 0.50), Offset(0.44, 0.35), Offset(0.44, 0.20)],
    [Offset(0.88, 0.10), Offset(0.88, 0.30), Offset(0.88, 0.50), Offset(0.88, 0.70), Offset(0.88, 0.90)],
  ],

  // ㅝ = left ㅜ portion + right ㅓ portion
  'ㅝ': [
    // ㅜ horizontal
    [Offset(0.05, 0.35), Offset(0.22, 0.35), Offset(0.40, 0.35), Offset(0.52, 0.35)],
    // ㅜ vertical down
    [Offset(0.28, 0.35), Offset(0.28, 0.50), Offset(0.28, 0.65), Offset(0.28, 0.80)],
    // ㅓ vertical
    [Offset(0.65, 0.10), Offset(0.65, 0.30), Offset(0.65, 0.50), Offset(0.65, 0.70), Offset(0.65, 0.90)],
    // ㅓ horizontal left
    [Offset(0.65, 0.50), Offset(0.52, 0.50), Offset(0.38, 0.50)],
  ],

  // ㅞ = ㅝ + vertical line on right
  'ㅞ': [
    [Offset(0.05, 0.35), Offset(0.20, 0.35), Offset(0.35, 0.35), Offset(0.46, 0.35)],
    [Offset(0.25, 0.35), Offset(0.25, 0.50), Offset(0.25, 0.65), Offset(0.25, 0.78)],
    [Offset(0.58, 0.10), Offset(0.58, 0.30), Offset(0.58, 0.50), Offset(0.58, 0.70), Offset(0.58, 0.90)],
    [Offset(0.58, 0.50), Offset(0.46, 0.50), Offset(0.32, 0.50)],
    [Offset(0.88, 0.10), Offset(0.88, 0.30), Offset(0.88, 0.50), Offset(0.88, 0.70), Offset(0.88, 0.90)],
  ],

  // ㅟ = ㅜ + right vertical
  'ㅟ': [
    [Offset(0.10, 0.35), Offset(0.32, 0.35), Offset(0.55, 0.35), Offset(0.78, 0.35)],
    [Offset(0.44, 0.35), Offset(0.44, 0.50), Offset(0.44, 0.65), Offset(0.44, 0.80)],
    [Offset(0.88, 0.10), Offset(0.88, 0.30), Offset(0.88, 0.50), Offset(0.88, 0.70), Offset(0.88, 0.90)],
  ],

  // ㅢ = ㅡ + right vertical
  'ㅢ': [
    [Offset(0.10, 0.50), Offset(0.30, 0.50), Offset(0.55, 0.50), Offset(0.78, 0.50)],
    [Offset(0.88, 0.10), Offset(0.88, 0.30), Offset(0.88, 0.50), Offset(0.88, 0.70), Offset(0.88, 0.90)],
  ],

  // ── Doubled consonants (same strokes as base, slightly adjusted) ─────────────

  'ㄲ': [
    [Offset(0.08, 0.30), Offset(0.28, 0.29), Offset(0.38, 0.28)],
    [Offset(0.38, 0.28), Offset(0.38, 0.42), Offset(0.38, 0.60), Offset(0.38, 0.72)],
    [Offset(0.48, 0.30), Offset(0.68, 0.29), Offset(0.82, 0.28)],
    [Offset(0.82, 0.28), Offset(0.82, 0.42), Offset(0.82, 0.60), Offset(0.82, 0.72)],
  ],

  'ㄸ': [
    [Offset(0.08, 0.22), Offset(0.25, 0.22), Offset(0.38, 0.22)],
    [Offset(0.08, 0.22), Offset(0.08, 0.38), Offset(0.08, 0.52), Offset(0.08, 0.62)],
    [Offset(0.08, 0.62), Offset(0.22, 0.62), Offset(0.38, 0.62)],
    [Offset(0.48, 0.22), Offset(0.65, 0.22), Offset(0.80, 0.22)],
    [Offset(0.48, 0.22), Offset(0.48, 0.38), Offset(0.48, 0.52), Offset(0.48, 0.62)],
    [Offset(0.48, 0.62), Offset(0.62, 0.62), Offset(0.80, 0.62)],
  ],

  'ㅃ': [
    [Offset(0.10, 0.18), Offset(0.10, 0.40), Offset(0.10, 0.62)],
    [Offset(0.30, 0.18), Offset(0.30, 0.40), Offset(0.30, 0.62)],
    [Offset(0.10, 0.18), Offset(0.20, 0.18), Offset(0.30, 0.18)],
    [Offset(0.10, 0.40), Offset(0.20, 0.40), Offset(0.30, 0.40)],
    [Offset(0.06, 0.62), Offset(0.18, 0.62), Offset(0.34, 0.62)],
    [Offset(0.50, 0.18), Offset(0.50, 0.40), Offset(0.50, 0.62)],
    [Offset(0.70, 0.18), Offset(0.70, 0.40), Offset(0.70, 0.62)],
    [Offset(0.50, 0.18), Offset(0.60, 0.18), Offset(0.70, 0.18)],
    [Offset(0.50, 0.40), Offset(0.60, 0.40), Offset(0.70, 0.40)],
    [Offset(0.46, 0.62), Offset(0.58, 0.62), Offset(0.74, 0.62)],
  ],

  'ㅆ': [
    [Offset(0.25, 0.28), Offset(0.18, 0.44), Offset(0.10, 0.62), Offset(0.06, 0.80)],
    [Offset(0.25, 0.28), Offset(0.32, 0.44), Offset(0.38, 0.62), Offset(0.40, 0.80)],
    [Offset(0.58, 0.28), Offset(0.52, 0.44), Offset(0.46, 0.62), Offset(0.42, 0.80)],
    [Offset(0.58, 0.28), Offset(0.65, 0.44), Offset(0.74, 0.62), Offset(0.82, 0.80)],
  ],

  'ㅉ': [
    [Offset(0.12, 0.28), Offset(0.28, 0.28), Offset(0.38, 0.28)],
    [Offset(0.25, 0.28), Offset(0.18, 0.48), Offset(0.10, 0.68)],
    [Offset(0.25, 0.28), Offset(0.32, 0.48), Offset(0.38, 0.68)],
    [Offset(0.52, 0.28), Offset(0.68, 0.28), Offset(0.80, 0.28)],
    [Offset(0.65, 0.28), Offset(0.56, 0.48), Offset(0.48, 0.68)],
    [Offset(0.65, 0.28), Offset(0.72, 0.48), Offset(0.82, 0.68)],
  ],
};

// ─── Index arrays for Unicode arithmetic ─────────────────────────────────────

const _initials = [
  'ㄱ', 'ㄲ', 'ㄴ', 'ㄷ', 'ㄸ', 'ㄹ', 'ㅁ', 'ㅂ', 'ㅃ',
  'ㅅ', 'ㅆ', 'ㅇ', 'ㅈ', 'ㅉ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ'
];

// Vowel index table (index 12 = ㅛ)
const _vowelCharsFixed = [
  'ㅏ', 'ㅐ', 'ㅑ', 'ㅒ', 'ㅓ', 'ㅔ', 'ㅕ', 'ㅖ', 'ㅗ', 'ㅘ',
  'ㅙ', 'ㅚ', 'ㅛ', 'ㅜ', 'ㅝ', 'ㅞ', 'ㅟ', 'ㅠ', 'ㅡ', 'ㅢ', 'ㅣ'
];

const _finals = [
  '', 'ㄱ', 'ㄲ', 'ㄳ', 'ㄴ', 'ㄵ', 'ㄶ', 'ㄷ', 'ㄹ', 'ㄺ',
  'ㄻ', 'ㄼ', 'ㄽ', 'ㄾ', 'ㄿ', 'ㅀ', 'ㅁ', 'ㅂ', 'ㅄ', 'ㅅ',
  'ㅆ', 'ㅇ', 'ㅈ', 'ㅊ', 'ㅋ', 'ㅌ', 'ㅍ', 'ㅎ'
];

// Vowels that are "horizontal" (crossbar at bottom) — initial goes top half
const _horizontalVowels = {'ㅗ', 'ㅛ', 'ㅜ', 'ㅠ', 'ㅡ'};

// Compound vowels list
const _compoundVowels = {'ㅘ', 'ㅙ', 'ㅚ', 'ㅝ', 'ㅞ', 'ㅟ', 'ㅢ'};

// ─── Public API ───────────────────────────────────────────────────────────────

/// Returns stroke data for a single Korean character, or null if unsupported.
/// For multi-character strings returns null.
List<List<Offset>>? getCharStrokes(String char) {
  if (char.isEmpty) return null;
  if (char.length > 1) return null; // multi-char string

  final cp = char.codeUnitAt(0);

  // Jamo (isolated consonants/vowels) — direct lookup
  if ((cp >= 0x3131 && cp <= 0x318E) || (cp >= 0x3200 && cp <= 0x321E)) {
    return _jamoStrokes[char];
  }

  // Precomposed syllable block (AC00–D7A3)
  if (cp >= 0xAC00 && cp <= 0xD7A3) {
    return _decomposeSyllable(cp);
  }

  // Direct lookup for anything else already in the table
  return _jamoStrokes[char];
}

/// Decomposes a syllable block into strokes via Unicode arithmetic.
List<List<Offset>>? _decomposeSyllable(int cp) {
  final idx = cp - 0xAC00;
  final leadIdx = idx ~/ 588;
  final vowelIdx = (idx % 588) ~/ 28;
  final trailIdx = idx % 28;

  final lead = leadIdx < _initials.length ? _initials[leadIdx] : null;
  final vowel = vowelIdx < _vowelCharsFixed.length ? _vowelCharsFixed[vowelIdx] : null;
  final trail = trailIdx < _finals.length ? _finals[trailIdx] : null;

  if (lead == null || vowel == null) return null;

  final leadStrokes = _jamoStrokes[lead];
  final vowelStrokes = _jamoStrokes[vowel];
  if (leadStrokes == null || vowelStrokes == null) return null;

  // Determine layout
  final hasTrail = trail != null && trail.isNotEmpty;
  final isHorizontalVowel = _horizontalVowels.contains(vowel);
  final isCompoundVowel = _compoundVowels.contains(vowel);

  List<List<Offset>> result = [];

  if (!hasTrail) {
    if (isHorizontalVowel || isCompoundVowel) {
      // Initial top 45%, vowel bottom 55%
      for (final s in leadStrokes) {
        result.add(_transformStroke(s, 0.0, 0.0, 1.0, 0.45));
      }
      for (final s in vowelStrokes) {
        result.add(_transformStroke(s, 0.0, 0.43, 1.0, 0.57));
      }
    } else {
      // Vertical vowel: initial left 43%, vowel right 57%
      for (final s in leadStrokes) {
        result.add(_transformStroke(s, 0.0, 0.0, 0.43, 1.0));
      }
      for (final s in vowelStrokes) {
        result.add(_transformStroke(s, 0.43, 0.0, 0.57, 1.0));
      }
    }
  } else {
    // Has trail (받침)
    final trailStrokes = _jamoStrokes[trail];
    // If no stroke data for compound final, still show initial+vowel

    if (isHorizontalVowel || isCompoundVowel) {
      // initial top, vowel middle, final bottom
      for (final s in leadStrokes) {
        result.add(_transformStroke(s, 0.0, 0.0, 1.0, 0.40));
      }
      for (final s in vowelStrokes) {
        result.add(_transformStroke(s, 0.0, 0.38, 1.0, 0.28));
      }
      if (trailStrokes != null) {
        for (final s in trailStrokes) {
          result.add(_transformStroke(s, 0.0, 0.62, 1.0, 0.38));
        }
      }
    } else {
      // Vertical vowel with trail: initial top-left, vowel right, final bottom-left
      for (final s in leadStrokes) {
        result.add(_transformStroke(s, 0.0, 0.0, 0.43, 0.58));
      }
      for (final s in vowelStrokes) {
        result.add(_transformStroke(s, 0.43, 0.0, 0.57, 1.0));
      }
      if (trailStrokes != null) {
        for (final s in trailStrokes) {
          result.add(_transformStroke(s, 0.0, 0.55, 0.43, 0.45));
        }
      }
    }
  }

  return result.isEmpty ? null : result;
}

/// Transform stroke points: apply offset and scale within a sub-region.
/// xOff, yOff: top-left corner of the sub-region in 0-1 space
/// xScale, yScale: width and height of the sub-region as fraction of total
List<Offset> _transformStroke(
  List<Offset> stroke,
  double xOff,
  double yOff,
  double xScale,
  double yScale,
) {
  return stroke
      .map((p) => Offset(xOff + p.dx * xScale, yOff + p.dy * yScale))
      .toList();
}
