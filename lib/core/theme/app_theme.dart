import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'ta_tokens.dart';

/// Styles de texte du design system (helpers `.ta-h1`, `.ta-h2`, `.ta-sub`, `.ta-label`).
extension TaTextStyles on BuildContext {
  TextStyle get taH1 => TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.52,
    height: 1.15,
    color: ta.text,
  );

  TextStyle get taH2 => TextStyle(
    fontSize: TaDims.fsLg,
    fontWeight: FontWeight.w800,
    letterSpacing: -0.29,
    color: ta.text,
  );

  TextStyle get taSub => TextStyle(
    fontSize: TaDims.fsSm,
    fontWeight: FontWeight.w500,
    height: 1.45,
    color: ta.text2,
  );

  TextStyle get taLabel => TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.88,
    color: ta.text3,
  );

  TextStyle get taBody => TextStyle(
    fontSize: TaDims.fs,
    fontWeight: FontWeight.w500,
    letterSpacing: -0.16,
    color: ta.text,
  );
}

abstract final class AppTheme {
  static ThemeData light() => _build(TaTokens.light, Brightness.light);

  static ThemeData dark() => _build(TaTokens.dark, Brightness.dark);

  static ThemeData _build(TaTokens tokens, Brightness brightness) {
    final base = ThemeData(
      useMaterial3: true,
      brightness: brightness,
      scaffoldBackgroundColor: tokens.bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: tokens.primary,
        brightness: brightness,
        primary: tokens.primary,
        surface: tokens.surface,
        error: tokens.danger,
      ),
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
    );

    final textTheme = GoogleFonts.plusJakartaSansTextTheme(
      base.textTheme,
    ).apply(bodyColor: tokens.text, displayColor: tokens.text);

    return base.copyWith(textTheme: textTheme, extensions: [tokens]);
  }
}
