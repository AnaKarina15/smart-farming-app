import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Tipografía AgroField (Lexend) - escala del mockup.
class AppText {
  AppText._();

  // h1 - 40px, 1.2, 0.02em, w600
  static TextStyle h1({Color color = AppColors.onSurface}) =>
      GoogleFonts.lexend(
        fontSize: 40,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 0.8,
        color: color,
      );

  // h2 - 32px, 1.2, 0.01em, w600
  static TextStyle h2({Color color = AppColors.onSurface}) =>
      GoogleFonts.lexend(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        height: 1.2,
        letterSpacing: 0.32,
        color: color,
      );

  // h3 - 24px, 1.3, 0.01em, w500
  static TextStyle h3({Color color = AppColors.onSurface}) =>
      GoogleFonts.lexend(
        fontSize: 24,
        fontWeight: FontWeight.w500,
        height: 1.3,
        letterSpacing: 0.24,
        color: color,
      );

  // body-lg - 18px, 1.6, 0.02em, w400
  static TextStyle bodyLg({Color color = AppColors.onSurface}) =>
      GoogleFonts.lexend(
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 1.6,
        letterSpacing: 0.36,
        color: color,
      );

  // body-md - 16px, 1.6, 0.02em, w400
  static TextStyle bodyMd({Color color = AppColors.onSurface}) =>
      GoogleFonts.lexend(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.6,
        letterSpacing: 0.32,
        color: color,
      );

  // label-caps - 12px, 1.0, 0.08em, w600 (UPPERCASE)
  static TextStyle labelCaps({Color color = AppColors.onSurfaceVariant}) =>
      GoogleFonts.lexend(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.0,
        letterSpacing: 0.96,
        color: color,
      );

  // label-caps grande (14px) para botones primarios
  static TextStyle labelCapsLg({Color color = AppColors.onPrimary}) =>
      GoogleFonts.lexend(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.0,
        letterSpacing: 1.12,
        color: color,
      );
}
