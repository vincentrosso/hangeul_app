import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const ink        = Color(0xFF1A1208);
  static const paper      = Color(0xFFF5F0E8);
  static const cream      = Color(0xFFEDE8DC);
  static const accent     = Color(0xFFC0392B);
  static const muted      = Color(0xFF7A6F5E);
  static const lightMuted = Color(0xFFC4B99E);
  static const border     = Color(0xFFD4C9B0);
  static const done       = Color(0xFF2D6A4F);
  static const nativeBlue = Color(0xFF1A4A6B);
  static const gttGreen   = Color(0xFF5A9E6F);

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary:    accent,
      secondary:  ink,
      surface:    paper,
      onPrimary:  paper,
      onSurface:  ink,
    ),
    scaffoldBackgroundColor: paper,
    textTheme: GoogleFonts.notoSerifKrTextTheme().copyWith(
      displayLarge: GoogleFonts.playfairDisplay(
        fontSize: 32, fontWeight: FontWeight.w400, fontStyle: FontStyle.italic, color: ink,
      ),
      displayMedium: GoogleFonts.playfairDisplay(
        fontSize: 24, fontWeight: FontWeight.w700, color: ink,
      ),
      titleLarge: GoogleFonts.playfairDisplay(
        fontSize: 18, fontWeight: FontWeight.w400, color: ink,
      ),
      bodyMedium: GoogleFonts.dmMono(fontSize: 13, color: ink),
      bodySmall:  GoogleFonts.dmMono(fontSize: 11, color: muted),
      labelSmall: GoogleFonts.dmMono(
        fontSize: 10, letterSpacing: 1.5, color: muted,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: ink,
      foregroundColor: paper,
      elevation: 0,
      titleTextStyle: GoogleFonts.notoSerifKr(
        fontSize: 18, fontWeight: FontWeight.w700,
        color: accent, letterSpacing: 2,
      ),
    ),
    cardTheme: CardThemeData(
      color: cream,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: border),
      ),
    ),
    dividerColor: border,
    dividerTheme: DividerThemeData(color: border, thickness: 1),
  );
}
