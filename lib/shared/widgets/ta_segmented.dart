import 'package:flutter/material.dart';

import '../../core/theme/ta_tokens.dart';

/// Option d'un contrôle segmenté.
class TaSegmentOption<T> {
  const TaSegmentOption(this.value, this.label);

  final T value;
  final String label;
}

/// Contrôle segmenté pill générique — réutilisé pour FR/EN (onboarding,
/// compte), les onglets du profil artisan, etc.
class TaSegmented<T> extends StatelessWidget {
  const TaSegmented({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.background,
    this.activeBackground,
    this.activeForeground,
    this.foreground,
    this.height = 30,
    this.fontSize = 11.5,
    this.itemPadding = const EdgeInsets.symmetric(horizontal: 13),
    this.padding = const EdgeInsets.all(3),
    this.gap = 3,
    this.expand = false,
    this.radius = TaDims.rPill,
    this.activeShadow = false,
  });

  final List<TaSegmentOption<T>> options;
  final T value;
  final ValueChanged<T> onChanged;
  final Color? background;
  final Color? activeBackground;
  final Color? activeForeground;
  final Color? foreground;
  final double height;
  final double fontSize;
  final EdgeInsetsGeometry itemPadding;
  final EdgeInsetsGeometry padding;
  final double gap;

  /// Étire chaque segment à largeur égale (onglets du profil).
  final bool expand;
  final double radius;
  final bool activeShadow;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    final bg = background ?? t.surface2;
    final activeBg = activeBackground ?? t.primary;
    final activeFg = activeForeground ?? t.primaryInk;
    final fg = foreground ?? t.text2;

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        spacing: gap,
        children: [
          for (final option in options)
            _segment(t, option, activeBg, activeFg, fg),
        ],
      ),
    );
  }

  Widget _segment(
    TaTokens t,
    TaSegmentOption<T> option,
    Color activeBg,
    Color activeFg,
    Color fg,
  ) {
    final active = option.value == value;
    final child = GestureDetector(
      onTap: () => onChanged(option.value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: height,
        padding: itemPadding,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? activeBg : Colors.transparent,
          borderRadius: BorderRadius.circular(radius),
          boxShadow: active && activeShadow ? t.shadowCard : null,
        ),
        child: Text(
          option.label,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
            color: active ? activeFg : fg,
          ),
        ),
      ),
    );
    return expand ? Expanded(child: child) : child;
  }
}

/// Interrupteur du design (46×27, pouce blanc).
class TaToggle extends StatelessWidget {
  const TaToggle({super.key, required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 46,
        height: 27,
        padding: const EdgeInsets.all(3),
        alignment: value ? Alignment.centerRight : Alignment.centerLeft,
        decoration: BoxDecoration(
          color: value ? t.primary : t.surface3,
          borderRadius: BorderRadius.circular(TaDims.rPill),
        ),
        child: Container(
          width: 21,
          height: 21,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(0x40000000),
                offset: Offset(0, 1),
                blurRadius: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
