import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_palette.dart';
import '../../core/theme/ta_tokens.dart';

const _logoSvg = '''
<svg viewBox="0 0 48 56" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M24 55c-1 0-9-6.5-9-11h18c0 4.5-8 11-9 11Z" fill="#F28C28"/>
  <circle cx="24" cy="23" r="21" fill="url(#ta-ring)"/>
  <circle cx="24" cy="23" r="16.2" fill="#fff"/>
  <path d="M14.5 22.8 24 14.6l9.5 8.2v9.4a1.6 1.6 0 0 1-1.6 1.6H16.1a1.6 1.6 0 0 1-1.6-1.6v-9.4Z" fill="#F28C28"/>
  <rect x="20.4" y="20.6" width="7.2" height="6.4" rx="0.8" fill="#fff"/>
  <path d="M24 21v5.6M20.8 23.8h6.4" stroke="#F28C28" stroke-width="1.3"/>
  <path d="M12.6 13.2a4 4 0 0 1 5.2-.6l-1.8 1.8.5 1.9 1.9.5 1.8-1.8a4 4 0 0 1-5.4 5l-2.2-2.2a4 4 0 0 1 0-4.6Z" fill="#56B947"/>
  <path d="M29.5 10.8c1.6-1.3 3.8-1.3 5.3-.2l1.3.9-1.5.4c-.5.1-.8.4-1 .8l-.3.6 1 1c.3.3.3.8 0 1.1l-.7.7c-.3.3-.8.3-1.1 0l-3.2-3.2c-.3-.3-.3-.8 0-1.1l.2-1Z" fill="#F28C28"/>
  <rect x="28.2" y="14.4" width="2.6" height="7.5" rx="1.1" transform="rotate(45 28.2 14.4)" fill="#56B947"/>
  <defs>
    <linearGradient id="ta-ring" x1="6" y1="6" x2="42" y2="42" gradientUnits="userSpaceOnUse">
      <stop stop-color="#56B947"/>
      <stop offset="1" stop-color="#11502A"/>
    </linearGradient>
  </defs>
</svg>
''';

/// Logo TravauxAbidjan : pin vert + maison/outils orange.
class TaLogo extends StatelessWidget {
  const TaLogo({super.key, this.size = 36});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(_logoSvg, width: size, height: size * 1.18);
  }
}

/// Mot-symbole « TravauxAbidjan ».
class TaWordmark extends StatelessWidget {
  const TaWordmark({super.key, this.size = 20, this.light = false});

  final double size;
  final bool light;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: 'Travaux',
            style: TextStyle(color: light ? Colors.white : AppPalette.green700),
          ),
          TextSpan(
            text: 'Abidjan',
            style: TextStyle(
              color: light ? AppPalette.orange300 : AppPalette.orange500,
            ),
          ),
        ],
      ),
      maxLines: 1,
      style: TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: size,
        letterSpacing: -0.02 * size,
        height: 1,
      ),
    );
  }
}

/// En-tête de section `.ta-section-head` : titre + action « Tout voir ».
class TaSectionHead extends StatelessWidget {
  const TaSectionHead({
    super.key,
    required this.title,
    this.action,
    this.onAction,
  });

  final String title;
  final String? action;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    return Padding(
      padding: const EdgeInsets.only(left: 2, right: 2, bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: TaDims.fsLg,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.29,
                color: t.text,
              ),
            ),
          ),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Row(
                spacing: 2,
                children: [
                  Text(
                    action!,
                    style: TextStyle(
                      color: t.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: TaDims.fsSm,
                    ),
                  ),
                  TaIconTinted.chevron(t.primary),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Petit chevron teinté (usage interne en fin de lien d'action).
class TaIconTinted {
  static Widget chevron(Color color) =>
      CustomPaint(size: const Size(12, 12), painter: _ChevronPainter(color));
}

class _ChevronPainter extends CustomPainter {
  _ChevronPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4 * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final path = Path()
      ..moveTo(9 * s, 5 * s)
      ..lineTo(16 * s, 12 * s)
      ..lineTo(9 * s, 19 * s);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_ChevronPainter oldDelegate) => oldDelegate.color != color;
}
