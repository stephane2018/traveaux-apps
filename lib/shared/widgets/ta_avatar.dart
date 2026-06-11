import 'package:flutter/material.dart';

import '../../core/theme/ta_tokens.dart';
import '../../data/mock_data.dart';
import '../../data/models/models.dart';
import 'ta_icon.dart';

/// Avatar artisan stylisé : initiales sur dégradé de marque + pastille métier.
class TaAvatar extends StatelessWidget {
  const TaAvatar({
    super.key,
    required this.artisan,
    this.size = 52,
    this.showMetier = true,
  });

  final Artisan artisan;
  final double size;
  final bool showMetier;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    final cat = MockData.categoryById(artisan.cat);
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(size * 0.32),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [artisan.c1, artisan.c2],
              ),
            ),
            foregroundDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(size * 0.32),
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.7, 1],
                colors: [Colors.transparent, Color(0x2E000000)],
              ),
            ),
            child: Text(
              artisan.initials,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: size * 0.36,
                letterSpacing: 0.01 * size * 0.36,
              ),
            ),
          ),
          if (showMetier && cat != null)
            Positioned(
              right: -4,
              bottom: -4,
              child: Container(
                width: size * 0.44,
                height: size * 0.44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: t.surface,
                  borderRadius: BorderRadius.circular(size * 0.44 * 0.4),
                  border: Border.all(color: t.border, width: 1.5),
                ),
                child: TaIcon(cat.icon, size: size * 0.26),
              ),
            ),
        ],
      ),
    );
  }
}

/// Avatar client : initiales sur fond neutre circulaire.
class TaClientAvatar extends StatelessWidget {
  const TaClientAvatar({super.key, required this.name, this.size = 40});

  final String name;
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    final initials = name.split(' ').map((w) => w[0]).take(2).join();
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: t.surface3, shape: BoxShape.circle),
      child: Text(
        initials,
        style: TextStyle(
          color: t.text2,
          fontWeight: FontWeight.w800,
          fontSize: size * 0.34,
        ),
      ),
    );
  }
}
