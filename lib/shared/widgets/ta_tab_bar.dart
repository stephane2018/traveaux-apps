import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/ta_tokens.dart';
import 'ta_icon.dart';

/// Barre translucide collée en bas (tab bar, barres CTA) : flou 16 +
/// fond `tabbarBg` + liseré supérieur.
class TaBlurBar extends StatelessWidget {
  const TaBlurBar({super.key, required this.child, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: t.tabbarBg,
            border: Border(top: BorderSide(color: t.border)),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Onglet de la tab bar.
class TaTabItem {
  const TaTabItem({
    required this.icon,
    required this.label,
    this.showDot = false,
  });

  final TaIcons icon;
  final String label;

  /// Point orange de notification (Messages).
  final bool showDot;
}

/// Tab bar du design : 5 onglets, icône duotone si actif, mono sinon.
class TaTabBar extends StatelessWidget {
  const TaTabBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<TaTabItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return TaBlurBar(
      padding: EdgeInsets.only(
        top: 10,
        left: 8,
        right: 8,
        bottom: bottomInset > 20 ? bottomInset + 6 : 30,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final (i, item) in items.indexed)
            Expanded(child: Center(child: _tab(t, i, item))),
        ],
      ),
    );
  }

  Widget _tab(TaTokens t, int index, TaTabItem item) {
    final active = index == currentIndex;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        constraints: const BoxConstraints(minWidth: 56),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 3,
              children: [
                SizedBox(
                  height: 26,
                  child: Center(
                    child: TaIcon(
                      item.icon,
                      size: 23,
                      mono: !active,
                      color: t.text3,
                    ),
                  ),
                ),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: active ? t.primary : t.text3,
                  ),
                ),
              ],
            ),
            if (item.showDot)
              Positioned(
                top: -1,
                right: -6,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: t.accent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Barre CTA collée en bas (profil artisan, devis) : flou + padding standard.
class TaBottomCtaBar extends StatelessWidget {
  const TaBottomCtaBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return TaBlurBar(
      padding: EdgeInsets.only(
        top: 12,
        left: TaDims.pad,
        right: TaDims.pad,
        bottom: bottomInset > 20 ? bottomInset + 8 : 32,
      ),
      child: child,
    );
  }
}
