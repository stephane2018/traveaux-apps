import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/ta_tokens.dart';
import '../../../data/models/models.dart';
import '../../../shared/widgets/widgets.dart';
import 'create_devis_sheet.dart';
import 'pro_statut_badge.dart';

/// Ouvre le détail d'une demande de devis (bottom sheet côté artisan).
Future<void> showDemandeDetailSheet(
  BuildContext context, {
  required Demande demande,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    builder: (ctx) => _DemandeDetailSheet(
      demande: demande,
      onCreateDevis: () {
        // Ferme le détail puis ouvre la création de devis sur le
        // context parent (toujours monté après le pop).
        Navigator.pop(ctx);
        showCreateDevisSheet(context, demande: demande);
      },
    ),
  );
}

class _DemandeDetailSheet extends StatelessWidget {
  const _DemandeDetailSheet({
    required this.demande,
    required this.onCreateDevis,
  });

  final Demande demande;
  final VoidCallback onCreateDevis;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    final media = MediaQuery.of(context);

    // Collé en bas, largeur limitée sur tablette.
    return Center(
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 560,
          maxHeight: media.size.height * 0.9,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: t.bg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: EdgeInsets.fromLTRB(
            20,
            12,
            20,
            20 + media.viewInsets.bottom + media.padding.bottom,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Poignée.
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: t.surface3,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'DEMANDE DE DEVIS',
                        style: context.taLabel.copyWith(color: t.accentStrong),
                      ),
                    ),
                    Text(demande.date, style: context.taSub),
                  ],
                ),
                const SizedBox(height: 12),
                _ClientRow(demande: demande),
                const SizedBox(height: 16),
                Text(demande.projet, style: context.taH2),
                const SizedBox(height: 6),
                // Description fictive (absente du modèle Demande).
                Text(
                  'Le client souhaite une intervention rapide. Contactez-le '
                  'pour préciser l’étendue des travaux avant '
                  'd’envoyer votre devis.',
                  style: context.taSub.copyWith(height: 1.6),
                ),
                const SizedBox(height: 14),
                _MetaCard(demande: demande),
                const SizedBox(height: 16),
                Row(
                  spacing: 10,
                  children: [
                    Expanded(
                      child: TaButton(
                        label: 'Contacter',
                        variant: TaButtonVariant.soft,
                        onPressed: () => Navigator.pop(context),
                        leading: const TaIcon(TaIcons.chat, size: 16),
                      ),
                    ),
                    Expanded(
                      child: TaButton(
                        label: 'Envoyer un devis',
                        onPressed: onCreateDevis,
                        leading: TaIcon(
                          TaIcons.doc,
                          size: 15,
                          mono: true,
                          color: TaButton.inkColor(
                            context,
                            TaButtonVariant.cta,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Avatar + identité du demandeur, statut et urgence à droite.
class _ClientRow extends StatelessWidget {
  const _ClientRow({required this.demande});

  final Demande demande;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    return Row(
      spacing: 12,
      children: [
        TaClientAvatar(name: demande.client, size: 52),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                demande.client,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: t.text,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                spacing: 4,
                children: [
                  TaIcon(TaIcons.mapPin, size: 12, mono: true, color: t.text3),
                  Flexible(
                    child: Text(
                      demande.commune,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.taSub.copyWith(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          spacing: 4,
          children: [
            ProStatutBadge(statut: demande.statut),
            if (demande.urgence == 'Urgent')
              TaBadge(
                label: 'Urgent',
                background: t.danger,
                foreground: Colors.white,
              ),
          ],
        ),
      ],
    );
  }
}

/// Carte des informations clés de la demande.
class _MetaCard extends StatelessWidget {
  const _MetaCard({required this.demande});

  final Demande demande;

  @override
  Widget build(BuildContext context) {
    final rows = [
      (TaIcons.user, 'Demandeur', demande.client),
      (TaIcons.wallet, 'Budget estimé', demande.budget),
      (TaIcons.clock, 'Urgence', demande.urgence),
      (TaIcons.mapPin, 'Lieu', demande.commune),
    ];
    return TaCard(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const TaDivider(),
            _MetaRow(icon: rows[i].$1, label: rows[i].$2, value: rows[i].$3),
          ],
        ],
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final TaIcons icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        spacing: 10,
        children: [
          TaIconBox(icon: icon, size: 34, radius: 10, iconSize: 16),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: t.text3,
            ),
          ),
          Expanded(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: t.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
