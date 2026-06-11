import 'package:flutter/material.dart';

import '../../core/theme/ta_tokens.dart';
import 'ta_icon.dart';

/// Carré arrondi centrant une icône — motif récurrent du design
/// (listes du compte, étapes « comment ça marche », stats pro…).
class TaIconBox extends StatelessWidget {
  const TaIconBox({
    super.key,
    required this.icon,
    this.size = 36,
    this.radius = 11,
    this.iconSize = 17,
    this.background,
    this.mono = false,
    this.iconColor,
  });

  final TaIcons icon;
  final double size;
  final double radius;
  final double iconSize;

  /// Par défaut : `surface-2`.
  final Color? background;
  final bool mono;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background ?? context.ta.surface2,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: TaIcon(icon, size: iconSize, mono: mono, color: iconColor),
    );
  }
}

/// Bouton carré arrondi (retour, tri, cloche…) — `38×38, r=12` par défaut.
class TaSquareButton extends StatelessWidget {
  const TaSquareButton({
    super.key,
    required this.child,
    this.onTap,
    this.size = 38,
    this.radius = 12,
    this.background,
    this.borderColor,
  });

  /// Bouton retour standard des en-têtes clairs.
  factory TaSquareButton.back(BuildContext context, {VoidCallback? onTap}) {
    final t = context.ta;
    return TaSquareButton(
      onTap: onTap,
      background: t.surface,
      borderColor: t.borderStrong,
      child: TaIcon(TaIcons.arrowLeft, size: 17, mono: true, color: t.text),
    );
  }

  final Widget child;
  final VoidCallback? onTap;
  final double size;
  final double radius;
  final Color? background;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background ?? Colors.transparent,
          borderRadius: BorderRadius.circular(radius),
          border: borderColor != null ? Border.all(color: borderColor!) : null,
        ),
        child: child,
      ),
    );
  }
}
