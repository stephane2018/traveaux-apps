import 'package:flutter/material.dart';

import '../../core/theme/ta_tokens.dart';
import 'ta_pressable.dart';

/// Variantes du bouton `.ta-btn` du design.
enum TaButtonVariant {
  /// Bouton d'action principal (tweak « CTA vert » figé → vert).
  cta,

  /// `.primary` — toujours vert.
  primary,

  /// `.soft` — fond vert pâle, texte vert.
  soft,

  /// `.accent-soft` — fond orange pâle, texte orange foncé.
  accentSoft,

  /// `.outline` — transparent, liseré.
  outline,

  /// `.ghost` — transparent, texte secondaire.
  ghost,
}

class TaButton extends StatelessWidget {
  const TaButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = TaButtonVariant.cta,
    this.small = false,
    this.leading,
    this.trailing,
    this.height,
    this.width,
    this.expanded = false,
    this.fontSize,
  });

  final String label;
  final VoidCallback? onPressed;
  final TaButtonVariant variant;
  final bool small;
  final Widget? leading;
  final Widget? trailing;
  final double? height;
  final double? width;
  final bool expanded;
  final double? fontSize;

  /// Couleur d'encre du bouton selon sa variante (pour teinter les icônes).
  static Color inkColor(BuildContext context, TaButtonVariant variant) {
    final t = context.ta;
    return switch (variant) {
      TaButtonVariant.cta => t.ctaInk,
      TaButtonVariant.primary => t.primaryInk,
      TaButtonVariant.soft => t.primary,
      TaButtonVariant.accentSoft => t.accentStrong,
      TaButtonVariant.outline => t.text,
      TaButtonVariant.ghost => t.text2,
    };
  }

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    final (Color bg, Color ink) = switch (variant) {
      TaButtonVariant.cta => (t.ctaBg, t.ctaInk),
      TaButtonVariant.primary => (t.primary, t.primaryInk),
      TaButtonVariant.soft => (t.primarySoft, t.primary),
      TaButtonVariant.accentSoft => (t.accentSoft, t.accentStrong),
      TaButtonVariant.outline => (Colors.transparent, t.text),
      TaButtonVariant.ghost => (Colors.transparent, t.text2),
    };

    final h = height ?? (small ? TaDims.btnSmHeight : TaDims.btnHeight);
    final fs = fontSize ?? (small ? TaDims.fsSm : TaDims.fs);

    final button = TaPressable(
      onTap: onPressed,
      pressedScale: 0.98,
      child: Container(
        height: h,
        width: width,
        padding: EdgeInsets.symmetric(horizontal: small ? 14 : TaDims.pad + 4),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(TaDims.rPill),
          border: variant == TaButtonVariant.outline
              ? Border.all(color: t.borderStrong, width: 1.5)
              : null,
        ),
        child: Row(
          mainAxisSize: width == null && !expanded
              ? MainAxisSize.min
              : MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 8,
          children: [
            ?leading,
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: fs,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.01 * fs,
                  color: ink,
                ),
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
    return expanded ? SizedBox(width: double.infinity, child: button) : button;
  }
}
