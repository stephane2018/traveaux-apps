import 'package:flutter/material.dart';

import '../../core/theme/ta_tokens.dart';
import 'ta_icon.dart';

/// Pastille `.ta-badge` générique.
class TaBadge extends StatelessWidget {
  const TaBadge({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
    this.icon,
    this.small = false,
  });

  /// `.ta-badge.verified`
  factory TaBadge.verified(BuildContext context, {bool small = false}) {
    final t = context.ta;
    return TaBadge(
      label: 'Vérifié',
      background: t.primarySoft,
      foreground: t.primary,
      icon: TaIcons.badge,
      small: small,
    );
  }

  /// `.ta-badge.featured`
  factory TaBadge.featured(BuildContext context, {bool small = false}) {
    final t = context.ta;
    return TaBadge(
      label: 'Mis en avant',
      background: t.accentSoft,
      foreground: t.accentStrong,
      icon: TaIcons.crown,
      small: small,
    );
  }

  /// Pastille neutre (commune, dispo…).
  factory TaBadge.neutral(
    BuildContext context, {
    required String label,
    TaIcons? icon,
    bool small = false,
  }) {
    final t = context.ta;
    return TaBadge(
      label: label,
      background: t.surface2,
      foreground: t.text2,
      icon: icon,
      small: small,
    );
  }

  final String label;
  final Color background;
  final Color foreground;
  final TaIcons? icon;
  final bool small;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: small
          ? const EdgeInsets.symmetric(horizontal: 6, vertical: 2)
          : const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(TaDims.rPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          if (icon != null)
            TaIcon(icon!, size: small ? 10 : 12, mono: true, color: foreground),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: small ? 10 : 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.11,
                color: foreground,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Compteur non lu (pastille orange circulaire).
class TaUnreadBadge extends StatelessWidget {
  const TaUnreadBadge({super.key, required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    return Container(
      constraints: const BoxConstraints(minWidth: 19),
      height: 19,
      padding: const EdgeInsets.symmetric(horizontal: 5),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: t.accent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w800,
          color: t.accentInk,
        ),
      ),
    );
  }
}
