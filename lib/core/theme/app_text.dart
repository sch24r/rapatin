import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

/// Text style Rapatin/ dari Figma (Poppins + JetBrains Mono).
abstract final class AppText {
  static TextStyle _p(double size, double height, FontWeight w) =>
      GoogleFonts.poppins(
        fontSize: size,
        height: height / size,
        fontWeight: w,
        color: AppColors.text,
      );

  static final display = _p(28, 36, FontWeight.w700);
  static final h1 = _p(22, 30, FontWeight.w700);
  static final h2 = _p(18, 26, FontWeight.w600);
  static final h3 = _p(16, 24, FontWeight.w600);
  static final body = _p(14, 22, FontWeight.w400);
  static final bodyMedium = _p(14, 22, FontWeight.w500);
  static final caption = _p(
    12,
    18,
    FontWeight.w400,
  ).copyWith(color: AppColors.textMuted);
  static final label = _p(12, 16, FontWeight.w500);
  static final button = _p(15, 20, FontWeight.w600);

  static final monoLabel = GoogleFonts.jetBrainsMono(
    fontSize: 11,
    height: 14 / 11,
    fontWeight: FontWeight.w500,
    letterSpacing: 11 * 0.08,
    color: AppColors.textMuted,
  );
  static final monoCode = GoogleFonts.jetBrainsMono(
    fontSize: 16,
    height: 20 / 16,
    fontWeight: FontWeight.w700,
    letterSpacing: 16 * 0.04,
    color: AppColors.text,
  );
}

extension TextStyleX on TextStyle {
  TextStyle get muted => copyWith(color: AppColors.textMuted);
  TextStyle tint(Color c) => copyWith(color: c);
  TextStyle get bold => copyWith(fontWeight: FontWeight.w700);
  TextStyle get semi => copyWith(fontWeight: FontWeight.w600);
}
