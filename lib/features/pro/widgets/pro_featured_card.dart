import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/ta_tokens.dart';
import '../../../shared/widgets/widgets.dart';

/// Carte « Profil mis en avant » avec CTA Prolonger — sidebar tablette
/// et bas du tableau de bord sur mobile.
class ProFeaturedCard extends StatelessWidget {
  const ProFeaturedCard({super.key, this.margin});

  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    return Container(
      margin: margin,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(TaDims.rCard),
        // linear-gradient(140deg, accent-soft, surface-2)
        gradient: LinearGradient(
          begin: const Alignment(-0.64, -0.77),
          end: const Alignment(0.64, 0.77),
          colors: [t.accentSoft, t.surface2],
        ),
        border: Border.all(color: t.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 7,
            children: [
              const TaIcon(TaIcons.crown, size: 18),
              Flexible(
                child: Text(
                  'Profil mis en avant',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                    color: t.text,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 6, bottom: 10),
            child: Text(
              'Actif jusqu’au 24 juin · 3× plus de vues en moyenne.',
              style: context.taSub.copyWith(fontSize: 11.5),
            ),
          ),
          TaButton(
            label: 'Prolonger',
            small: true,
            expanded: true,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}
