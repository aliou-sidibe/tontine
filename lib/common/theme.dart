import 'package:flutter/material.dart';

/// Colors read from the validated mockup. Do not add or approximate a color:
/// every screen uses these values, including screens the mockup does not
/// show.
abstract final class AppColors {
  static const background = Color(0xFFF5F7F6);
  static const surface = Color(0xFFFFFFFF);
  static const text = Color(0xFF17201B);
  static const textSecondary = Color(0xFF56615B);
  static const textTertiary = Color(0xFF8A948F);
  static const cardBorder = Color(0xFFE3E7E4);
  static const controlBorder = Color(0xFFDCE2DE);
  static const divider = Color(0xFFEEF0EF);

  static const primary = Color(0xFF1F6B4A);
  static const primaryPale = Color(0xFFE3F1E9);
  static const onPrimaryPale = Color(0xFF17583C);

  /// Late members and money advanced by the organizer.
  static const warningPale = Color(0xFFFCEADB);
  static const onWarningPale = Color(0xFF7A3A00);

  /// "À encaisser", "À venir".
  static const neutralPale = Color(0xFFEEF0EF);
  static const onNeutralPale = Color(0xFF3E4843);

  /// A member paid ahead.
  static const infoPale = Color(0xFFE4ECF8);
  static const onInfoPale = Color(0xFF1D4F91);

  static const segmentTrackSheet = Color(0xFFEEF0EF);
  static const segmentTrackScreen = Color(0xFFE7EBE9);
  static const keypadKey = Color(0xFFF2F4F3);
  static const stepInactive = Color(0xFFD6DCD8);
  static const scrim = Color(0xFF5E6762);
  static const scrimText = Color(0xFFDDE3DF);
  static const sheetHandle = Color(0xFFCBD2CE);

  /// Track of the progress bar on the green tour card (white at 25 %).
  static const onPrimaryTrack = Color(0x40FFFFFF);
}

abstract final class AppFonts {
  static const text = 'Inter';
  static const display = 'SpaceGrotesk';
}

/// Text styles of the mockup, by size and weight. Names describe where the
/// mockup uses them.
abstract final class AppText {
  static const screenTitle = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: AppColors.text,
    height: 1.2,
  );

  static const homeTitle = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.text,
    height: 1.2,
  );

  static const appBarTitle = TextStyle(
    fontFamily: AppFonts.text,
    fontSize: 17,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
  );

  static const caption = TextStyle(
    fontFamily: AppFonts.text,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const body = TextStyle(
    fontFamily: AppFonts.text,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.text,
  );

  static const rowTitle = TextStyle(
    fontFamily: AppFonts.text,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.text,
  );

  static const small = TextStyle(
    fontFamily: AppFonts.text,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const badge = TextStyle(
    fontFamily: AppFonts.text,
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  static const sectionLabel = TextStyle(
    fontFamily: AppFonts.text,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    letterSpacing: 0.48,
  );

  static const button = TextStyle(
    fontFamily: AppFonts.text,
    fontSize: 16,
    fontWeight: FontWeight.w700,
  );

  static const amountLarge = TextStyle(
    fontFamily: AppFonts.display,
    fontSize: 34,
    fontWeight: FontWeight.w700,
    color: AppColors.text,
  );
}

ThemeData appTheme() {
  const scheme = ColorScheme.light(
    primary: AppColors.primary,
    onPrimary: Colors.white,
    surface: AppColors.surface,
    onSurface: AppColors.text,
    outline: AppColors.controlBorder,
    outlineVariant: AppColors.cardBorder,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.background,
    fontFamily: AppFonts.text,
    textTheme: const TextTheme(
      bodyMedium: AppText.body,
      bodySmall: AppText.small,
      titleMedium: AppText.rowTitle,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.text,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: AppText.appBarTitle,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surface,
      labelStyle: AppText.small,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.controlBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.controlBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: AppText.button,
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.text,
        backgroundColor: AppColors.surface,
        minimumSize: const Size(44, 46),
        side: const BorderSide(color: AppColors.controlBorder),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(
          fontFamily: AppFonts.text,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        minimumSize: const Size(44, 44),
      ),
    ),
  );
}
