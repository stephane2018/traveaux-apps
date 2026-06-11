import 'package:flutter/material.dart';

import '../../core/theme/ta_tokens.dart';
import 'ta_icon.dart';

/// Placeholder photo stylisé (avant/après, réalisations, chantier).
class TaPhoto extends StatelessWidget {
  const TaPhoto({
    super.key,
    this.label,
    this.height = 110,
    this.tone = 0,
    this.icon = TaIcons.image,
    this.radius,
  });

  final String? label;
  final double height;

  /// 0 = neutre, 1 = vert pâle, 2 = orange pâle.
  final int tone;
  final TaIcons icon;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    final tones = [
      [t.surface2, t.surface3],
      [t.primarySoft, t.surface2],
      [t.accentSoft, t.surface2],
    ];
    final colors = tones[tone % 3];
    final r = radius ?? TaDims.rCard - 6;

    return Container(
      height: height,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(r),
        border: Border.all(color: t.border),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.5,
              child: CustomPaint(painter: _StripesPainter(t.border)),
            ),
          ),
          Center(
            child: Opacity(
              opacity: 0.55,
              child: TaIcon(icon, size: (height * 0.3).clamp(0, 30)),
            ),
          ),
          if (label != null)
            Positioned(
              left: 8,
              bottom: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: t.surface,
                  borderRadius: BorderRadius.circular(TaDims.rPill),
                  border: Border.all(color: t.border),
                ),
                child: Text(
                  label!.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: t.text2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Hachures diagonales 45° (repeating-linear-gradient du design).
class _StripesPainter extends CustomPainter {
  _StripesPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.4;
    const step = 15.0 * 1.414; // période de 15px le long de l'axe du dégradé
    for (var x = -size.height; x < size.width; x += step) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_StripesPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Bloc « Avant / Après » avec flèche orange centrale.
class TaBeforeAfter extends StatelessWidget {
  const TaBeforeAfter({super.key, this.height = 116});

  final double height;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        Row(
          spacing: 6,
          children: [
            Expanded(
              child: TaPhoto(label: 'Avant', height: height, tone: 0, icon: TaIcons.camera),
            ),
            Expanded(
              child: TaPhoto(label: 'Après', height: height, tone: 1, icon: TaIcons.image),
            ),
          ],
        ),
        Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: t.accent,
            shape: BoxShape.circle,
            boxShadow: t.shadowPop,
          ),
          child: TaIcon(TaIcons.arrowRight, size: 15, mono: true, color: t.accentInk),
        ),
      ],
    );
  }
}
