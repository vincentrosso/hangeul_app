import 'dart:math';
import 'package:flutter/painting.dart';

class StrokeScorer {
  /// Resample a stroke to [n] evenly-spaced points using arc-length parameterization.
  static List<Offset> resample(List<Offset> stroke, int n) {
    if (stroke.isEmpty) return List.filled(n, Offset.zero);
    if (stroke.length == 1) return List.filled(n, stroke.first);

    // Compute total arc length
    double totalLength = 0;
    for (int i = 1; i < stroke.length; i++) {
      totalLength += (stroke[i] - stroke[i - 1]).distance;
    }

    if (totalLength == 0) return List.filled(n, stroke.first);

    final interval = totalLength / (n - 1);
    final result = <Offset>[stroke.first];
    double distAccum = 0;
    int si = 0;

    for (int i = 1; i < n - 1; i++) {
      final targetDist = i * interval;
      while (si < stroke.length - 2) {
        final segLen = (stroke[si + 1] - stroke[si]).distance;
        if (distAccum + segLen >= targetDist) break;
        distAccum += segLen;
        si++;
      }
      if (si >= stroke.length - 1) {
        result.add(stroke.last);
      } else {
        final segLen = (stroke[si + 1] - stroke[si]).distance;
        final t = segLen == 0 ? 0.0 : (targetDist - distAccum) / segLen;
        final pt = Offset.lerp(stroke[si], stroke[si + 1], t.clamp(0.0, 1.0))!;
        result.add(pt);
      }
    }
    result.add(stroke.last);
    return result;
  }

  /// Discrete Fréchet distance between two sampled stroke paths (O(n^2) DP).
  static double frechetDistance(List<Offset> a, List<Offset> b) {
    final n = a.length;
    final m = b.length;
    if (n == 0 || m == 0) return double.infinity;

    final dp = List.generate(n, (_) => List.filled(m, -1.0));

    double dist(int i, int j) {
      if (dp[i][j] >= 0) return dp[i][j];

      final d = (a[i] - b[j]).distance;
      if (i == 0 && j == 0) {
        dp[i][j] = d;
      } else if (i == 0) {
        dp[i][j] = max(d, dist(0, j - 1));
      } else if (j == 0) {
        dp[i][j] = max(d, dist(i - 1, 0));
      } else {
        dp[i][j] = max(
          d,
          min(dist(i - 1, j), min(dist(i - 1, j - 1), dist(i, j - 1))),
        );
      }
      return dp[i][j];
    }

    return dist(n - 1, m - 1);
  }

  /// Score user strokes against reference strokes. Returns 0.0–1.0.
  static double score({
    required List<List<Offset>> userStrokes,
    required List<List<Offset>> referenceStrokes,
    required Size canvasSize,
  }) {
    if (referenceStrokes.isEmpty) return 0.0;
    if (userStrokes.isEmpty) return 0.0;

    const resampleN = 20;
    final diagonal = sqrt(
      canvasSize.width * canvasSize.width + canvasSize.height * canvasSize.height,
    );
    final threshold = 0.3 * diagonal;

    // Normalize reference strokes from 0-1 space to canvas space
    final refNorm = referenceStrokes
        .map((s) => s.map((p) => Offset(p.dx * canvasSize.width, p.dy * canvasSize.height)).toList())
        .toList();

    // Resample all strokes
    final refResampled = refNorm.map((s) => resample(s, resampleN)).toList();
    final userResampled = userStrokes.map((s) => resample(s, resampleN)).toList();

    // For each reference stroke, find best matching user stroke
    double totalScore = 0.0;
    for (final ref in refResampled) {
      double bestScore = 0.0;
      for (final user in userResampled) {
        final fd = frechetDistance(ref, user);
        final s = (1.0 - (fd / threshold)).clamp(0.0, 1.0);
        if (s > bestScore) bestScore = s;
      }
      totalScore += bestScore;
    }

    final avgScore = totalScore / refResampled.length;

    // Penalize stroke count mismatch
    final refCount = refResampled.length;
    final userCount = userResampled.length;
    final countRatio = refCount == 0
        ? 0.0
        : min(userCount, refCount) / max(userCount, refCount).toDouble();

    return (avgScore * countRatio).clamp(0.0, 1.0);
  }
}
