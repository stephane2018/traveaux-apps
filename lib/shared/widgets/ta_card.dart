import 'package:flutter/material.dart';

import '../../core/theme/ta_tokens.dart';
import 'ta_pressable.dart';

/// Carte `.ta-card` : surface, arrondi 24, liseré + ombre douce.
class TaCard extends StatelessWidget {
  const TaCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.gradient,
    this.color,
    this.radius = TaDims.rCard,
    this.border = true,
    this.shadow = true,
    this.popShadow = false,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Gradient? gradient;
  final Color? color;
  final double radius;
  final bool border;
  final bool shadow;

  /// Ombre « pop » plus marquée (barre de recherche flottante…).
  final bool popShadow;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    final card = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? t.surface) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        border: border ? Border.all(color: t.border) : null,
        boxShadow: popShadow ? t.shadowPop : (shadow ? t.shadowCard : null),
      ),
      child: child,
    );
    if (onTap == null) return card;
    return TaPressable(onTap: onTap, child: card);
  }
}

/// Séparateur `.ta-divider`.
class TaDivider extends StatelessWidget {
  const TaDivider({super.key, this.vertical = false, this.margin});

  final bool vertical;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      width: vertical ? 1 : null,
      height: vertical ? null : 1,
      color: context.ta.border,
    );
  }
}
