import 'package:flutter/material.dart';

import 'app_palette.dart';

/// Dimensions figées du design (vibe « chaleureux » + densité « confort »).
abstract final class TaDims {
  static const double pad = 20;
  static const double gap = 15;
  static const double fs = 16;
  static const double fsSm = 13.5;
  static const double fsLg = 19;

  static const double rCard = 24;

  /// Vibe « chaleureux » : boutons / inputs / chips entièrement arrondis.
  static const double rPill = 999;

  static const double btnHeight = 50;
  static const double btnSmHeight = 38;
  static const double inputHeight = 50;
}

/// Tokens sémantiques (couleurs + ombres) — light & dark, fidèles à tokens.css.
@immutable
class TaTokens extends ThemeExtension<TaTokens> {
  const TaTokens({
    required this.bg,
    required this.surface,
    required this.surface2,
    required this.surface3,
    required this.text,
    required this.text2,
    required this.text3,
    required this.border,
    required this.borderStrong,
    required this.primary,
    required this.primaryStrong,
    required this.primaryInk,
    required this.primarySoft,
    required this.accent,
    required this.accentStrong,
    required this.accentInk,
    required this.accentSoft,
    required this.danger,
    required this.headerGradStart,
    required this.headerGradEnd,
    required this.headerInk,
    required this.headerInk2,
    required this.tabbarBg,
    required this.icMain,
    required this.icAcc,
    required this.star,
    required this.shadowCard,
    required this.shadowPop,
  });

  final Color bg;
  final Color surface;
  final Color surface2;
  final Color surface3;
  final Color text;
  final Color text2;
  final Color text3;
  final Color border;
  final Color borderStrong;
  final Color primary;
  final Color primaryStrong;
  final Color primaryInk;
  final Color primarySoft;
  final Color accent;
  final Color accentStrong;
  final Color accentInk;
  final Color accentSoft;
  final Color danger;
  final Color headerGradStart;
  final Color headerGradEnd;
  final Color headerInk;
  final Color headerInk2;
  final Color tabbarBg;
  final Color icMain;
  final Color icAcc;
  final Color star;
  final List<BoxShadow> shadowCard;
  final List<BoxShadow> shadowPop;

  /// Boutons d'action (tweak « CTA vert » figé) : le CTA principal est vert.
  Color get ctaBg => primary;
  Color get ctaInk => primaryInk;

  /// Dégradé d'en-tête (CSS : linear-gradient(160deg, …)).
  LinearGradient get headerGrad => LinearGradient(
    begin: const Alignment(-0.34, -0.94),
    end: const Alignment(0.34, 0.94),
    colors: [headerGradStart, headerGradEnd],
  );

  /// Light + vibe « chaleureux » (fond crème).
  static const light = TaTokens(
    bg: Color(0xFFF8F3E8),
    surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFF2EBDA),
    surface3: Color(0xFFDFE9DC),
    text: Color(0xFF15211A),
    text2: Color(0xFF54675A),
    text3: Color(0xFF8AA08F),
    border: Color(0xFFE8E0CC),
    borderStrong: Color(0xFFC9D6C6),
    primary: AppPalette.green600,
    primaryStrong: AppPalette.green700,
    primaryInk: Color(0xFFFFFFFF),
    primarySoft: Color(0xFFE2F0E0),
    accent: AppPalette.orange500,
    accentStrong: AppPalette.orange600,
    accentInk: Color(0xFFFFFFFF),
    accentSoft: Color(0xFFFCEEDB),
    danger: Color(0xFFCC4B43),
    headerGradStart: AppPalette.green700,
    headerGradEnd: AppPalette.green600,
    headerInk: Color(0xFFFFFFFF),
    headerInk2: Color(0xB8FFFFFF),
    tabbarBg: Color(0xEBFFFFFF),
    icMain: AppPalette.green600,
    icAcc: AppPalette.orange500,
    star: AppPalette.star,
    shadowCard: [
      BoxShadow(color: Color(0x0D15211A), offset: Offset(0, 1), blurRadius: 2),
      BoxShadow(color: Color(0x1215211A), offset: Offset(0, 5), blurRadius: 16),
    ],
    shadowPop: [
      BoxShadow(color: Color(0x2915211A), offset: Offset(0, 8), blurRadius: 30),
    ],
  );

  static const dark = TaTokens(
    bg: Color(0xFF0C1410),
    surface: Color(0xFF152019),
    surface2: Color(0xFF1C2B21),
    surface3: Color(0xFF25382B),
    text: Color(0xFFE9F1E9),
    text2: Color(0xFFA0B4A4),
    text3: Color(0xFF6C8071),
    border: Color(0xFF243428),
    borderStrong: Color(0xFF324736),
    primary: Color(0xFF41B566),
    primaryStrong: Color(0xFF5BCB7D),
    primaryInk: Color(0xFF07170C),
    primarySoft: Color(0xFF1A3424),
    accent: Color(0xFFF59E47),
    accentStrong: Color(0xFFF8B269),
    accentInk: Color(0xFF221204),
    accentSoft: Color(0xFF38260F),
    danger: Color(0xFFE2685F),
    headerGradStart: Color(0xFF122A1A),
    headerGradEnd: Color(0xFF173823),
    headerInk: Color(0xFFE9F1E9),
    headerInk2: Color(0xA3E9F1E9),
    tabbarBg: Color(0xF0121B15),
    icMain: Color(0xFF41B566),
    icAcc: Color(0xFFF59E47),
    star: AppPalette.star,
    shadowCard: [
      BoxShadow(color: Color(0x73000000), offset: Offset(0, 1), blurRadius: 2),
      BoxShadow(color: Color(0x59000000), offset: Offset(0, 6), blurRadius: 18),
    ],
    shadowPop: [
      BoxShadow(
        color: Color(0x8C000000),
        offset: Offset(0, 10),
        blurRadius: 34,
      ),
    ],
  );

  @override
  TaTokens copyWith() => this;

  @override
  TaTokens lerp(ThemeExtension<TaTokens>? other, double t) {
    if (other is! TaTokens) return this;
    return t < 0.5 ? this : other;
  }
}

extension TaTokensX on BuildContext {
  TaTokens get ta => Theme.of(this).extension<TaTokens>()!;
}
