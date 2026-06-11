import 'package:flutter/material.dart';

import '../../core/theme/ta_tokens.dart';

/// Puce filtrante `.ta-chip` (pill). [active] : fond vert, encre claire.
class TaChip extends StatelessWidget {
  const TaChip({
    super.key,
    required this.label,
    this.active = false,
    this.onTap,
    this.icon,
    this.padding = const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
  });

  final String label;
  final bool active;
  final VoidCallback? onTap;

  /// Icône optionnelle, déjà teintée par l'appelant.
  final Widget? icon;

  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: padding,
        decoration: BoxDecoration(
          color: active ? t.primary : t.surface,
          borderRadius: BorderRadius.circular(TaDims.rPill),
          border: Border.all(color: active ? t.primary : t.borderStrong),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            ?icon,
            Text(
              label,
              style: TextStyle(
                fontSize: TaDims.fsSm,
                fontWeight: FontWeight.w600,
                color: active ? t.primaryInk : t.text2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
