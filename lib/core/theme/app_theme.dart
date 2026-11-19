import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_text.dart';

abstract final class AppTheme {
  static ThemeData light() {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ).copyWith(
          primary: AppColors.primary,
          onPrimary: AppColors.onPrimary,
          primaryContainer: AppColors.primarySoft,
          onPrimaryContainer: AppColors.text,
          secondary: AppColors.accent,
          onSecondary: AppColors.text,
          surface: AppColors.bg,
          onSurface: AppColors.text,
          onSurfaceVariant: AppColors.textMuted,
          surfaceContainerLowest: AppColors.card,
          surfaceContainerLow: AppColors.card,
          surfaceContainer: AppColors.surfaceMuted,
          surfaceContainerHigh: AppColors.surfaceMuted,
          outline: AppColors.border,
          outlineVariant: AppColors.border,
          error: AppColors.danger,
        );

    // google_fonts 9 memakai paket material_ui, jadi font dipasang lewat fontFamily
    // (bukan poppinsTextTheme) agar tipe TextTheme tetap milik Flutter.
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: GoogleFonts.poppins().fontFamily,
    );
    final textTheme = base.textTheme.apply(
      bodyColor: AppColors.text,
      displayColor: AppColors.text,
    );

    final buttonShape = RoundedRectangleBorder(borderRadius: Radii.mdAll);
    const buttonSize = Size.fromHeight(52);

    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
      borderRadius: Radii.mdAll,
      borderSide: BorderSide(color: c, width: w),
    );

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bg,
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: AppText.h2,
        foregroundColor: AppColors.text,
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.onPrimary,
          disabledBackgroundColor: AppColors.neutralSoft,
          disabledForegroundColor: AppColors.neutral,
          minimumSize: buttonSize,
          shape: buttonShape,
          textStyle: AppText.button,
          padding: const EdgeInsets.symmetric(horizontal: Gap.x20),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          backgroundColor: AppColors.card,
          minimumSize: buttonSize,
          shape: buttonShape,
          side: const BorderSide(color: AppColors.border),
          textStyle: AppText.button,
          padding: const EdgeInsets.symmetric(horizontal: Gap.x16),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppText.bodyMedium.semi,
          minimumSize: const Size(48, 48),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Gap.x16,
          vertical: 15,
        ),
        hintStyle: AppText.body.muted,
        prefixIconColor: AppColors.textMuted,
        suffixIconColor: AppColors.textMuted,
        border: border(AppColors.border),
        enabledBorder: border(AppColors.border),
        focusedBorder: border(AppColors.primary, 1.5),
        errorBorder: border(AppColors.danger),
        focusedErrorBorder: border(AppColors.danger, 1.5),
        errorStyle: AppText.caption.tint(AppColors.danger),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.bg,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: AppColors.neutral,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.lg)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.text,
        contentTextStyle: AppText.body.tint(Colors.white),
        actionTextColor: AppColors.accent,
        shape: RoundedRectangleBorder(borderRadius: Radii.mdAll),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? Colors.white
              : AppColors.neutral,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.primary
              : AppColors.neutralSoft,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
      radioTheme: const RadioThemeData(
        fillColor: WidgetStatePropertyAll(AppColors.primary),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.primary
              : Colors.transparent,
        ),
        side: const BorderSide(color: AppColors.neutral, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: AppColors.primary,
        selectionColor: AppColors.primarySoft,
        selectionHandleColor: AppColors.primary,
      ),
    );
  }
}
