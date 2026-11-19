import 'package:flutter/material.dart';

/// Token warna Rapatin. Nilai sama dengan koleksi variabel "Rapatin" di Figma.
abstract final class AppColors {
  static const primary = Color(0xFF6F4E37);
  static const primaryPressed = Color(0xFF5A3E2B);
  static const onPrimary = Color(0xFFFFFFFF);
  static const primarySoft = Color(0xFFEADBC8);

  static const bg = Color(0xFFFAF6F1);
  static const card = Color(0xFFFFFFFF);
  static const surfaceMuted = Color(0xFFF3ECE4);
  static const border = Color(0xFFEDE4DA);
  static const paper = Color(0xFFF3EEDF);

  static const text = Color(0xFF2B1D14);
  static const textMuted = Color(0xFF7A6A5D);

  static const accent = Color(0xFFE8A33D);
  static const accentSoft = Color(0xFFFBEBCF);

  static const success = Color(0xFF2E7D57);
  static const successSoft = Color(0xFFDDEFE5);
  static const warning = Color(0xFFB7790F);
  static const warningSoft = Color(0xFFFBEBCF);
  static const danger = Color(0xFFC0392B);
  static const dangerSoft = Color(0xFFF7DEDA);
  static const neutral = Color(0xFFB9B0A8);
  static const neutralSoft = Color(0xFFEFEAE5);
}

/// Spasi dan radius (space/4–32, radius sm/md/lg/pill).
abstract final class Gap {
  static const x4 = 4.0;
  static const x8 = 8.0;
  static const x12 = 12.0;
  static const x16 = 16.0;
  static const x20 = 20.0;
  static const x24 = 24.0;
  static const x32 = 32.0;
}

abstract final class Radii {
  static const sm = 8.0;
  static const md = 14.0;
  static const lg = 20.0;
  static const pill = 999.0;

  static final smAll = BorderRadius.circular(sm);
  static final mdAll = BorderRadius.circular(md);
  static final lgAll = BorderRadius.circular(lg);
  static final pillAll = BorderRadius.circular(pill);
}
