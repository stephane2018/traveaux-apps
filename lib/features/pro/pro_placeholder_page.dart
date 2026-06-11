import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/ta_tokens.dart';
import '../../shared/widgets/widgets.dart';

/// Page non détaillée (messages, réalisations, profil) : pictogramme + retour.
class ProPlaceholderPage extends StatelessWidget {
  const ProPlaceholderPage({
    super.key,
    required this.icon,
    required this.title,
    required this.onBack,
  });

  final TaIcons icon;
  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 14,
        children: [
          Container(
            width: 76,
            height: 76,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: t.surface2,
              borderRadius: BorderRadius.circular(76 * 0.36),
            ),
            child: TaIcon(icon, size: 34),
          ),
          Column(
            children: [
              Text(title, style: context.taH2, textAlign: TextAlign.center),
              const SizedBox(height: 4),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: Text(
                  'Section à détailler dans une prochaine itération — '
                  'dites-moi si vous la voulez en priorité.',
                  textAlign: TextAlign.center,
                  style: context.taSub,
                ),
              ),
            ],
          ),
          TaButton(
            label: 'Retour au tableau de bord',
            variant: TaButtonVariant.soft,
            small: true,
            onPressed: onBack,
          ),
        ],
      ),
    );
  }
}
