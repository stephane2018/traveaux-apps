import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/ta_tokens.dart';
import '../../data/models/models.dart';
import '../../providers/data_providers.dart';
import '../../shared/widgets/widgets.dart';
import 'widgets/create_devis_sheet.dart';
import 'widgets/demande_detail_sheet.dart';
import 'widgets/pro_statut_badge.dart';

/// Page « Demandes de devis » : filtres + liste détaillée.
/// En mode [compact] (mobile), le titre vit dans l'en-tête vert du shell :
/// les filtres passent en rangée scrollable horizontalement.
class ProDemandesPage extends ConsumerWidget {
  const ProDemandesPage({super.key, this.compact = false});

  final bool compact;

  static const _filtres = ['Toutes', 'Nouvelles', 'Devis envoyés', 'Acceptées'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demandes = ref.watch(demandesProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (compact)
          _compactHeader(context, demandes.length)
        else
          _fullHeader(context, demandes.length),
        const SizedBox(height: 18),
        Column(
          spacing: TaDims.gap,
          children: [for (final d in demandes) _DemandeCard(demande: d)],
        ),
      ],
    );
  }

  /// Titre + sous-titre + filtres (tablette).
  Widget _fullHeader(BuildContext context, int count) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 12,
      runSpacing: 12,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Demandes de devis',
              style: context.taH1.copyWith(fontSize: 24),
            ),
            const SizedBox(height: 3),
            Text('$count demandes · 2 nouvelles', style: context.taSub),
          ],
        ),
        Wrap(spacing: 7, runSpacing: 7, children: _chips()),
      ],
    );
  }

  /// Compteur + filtres scrollables (mobile, le titre est dans l'en-tête).
  Widget _compactHeader(BuildContext context, int count) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$count demandes · 2 nouvelles', style: context.taSub),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(spacing: 7, children: _chips()),
        ),
      ],
    );
  }

  List<Widget> _chips() => [
    for (var i = 0; i < _filtres.length; i++)
      TaChip(label: _filtres[i], active: i == 0, onTap: () {}),
  ];
}

/// Carte d'une demande : bandeau client + statut, projet, méta, actions.
class _DemandeCard extends StatelessWidget {
  const _DemandeCard({required this.demande});

  final Demande demande;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    final d = demande;
    return TaCard(
      padding: const EdgeInsets.all(16),
      onTap: () => showDemandeDetailSheet(context, demande: d),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bandeau haut : avatar + nom/commune, puis statut + date à droite.
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              TaClientAvatar(name: d.client, size: 44),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      d.client,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: t.text,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      spacing: 4,
                      children: [
                        TaIcon(
                          TaIcons.mapPin,
                          size: 12,
                          mono: true,
                          color: t.text3,
                        ),
                        Flexible(
                          child: Text(
                            d.commune,
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
                children: [
                  ProStatutBadge(statut: d.statut),
                  const SizedBox(height: 5),
                  Text(
                    d.date,
                    style: context.taSub.copyWith(fontSize: 11, color: t.text3),
                  ),
                ],
              ),
            ],
          ),
          const TaDivider(margin: EdgeInsets.symmetric(vertical: 12)),
          // Projet.
          Text(
            d.projet,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 1.35,
              color: t.text,
            ),
          ),
          // Puces méta : budget + urgence.
          const SizedBox(height: 10),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              TaBadge.neutral(context, label: d.budget, icon: TaIcons.wallet),
              if (d.urgence == 'Urgent')
                TaBadge(
                  label: d.urgence,
                  background: t.accentSoft,
                  foreground: t.accentStrong,
                  icon: TaIcons.clock,
                )
              else
                TaBadge.neutral(context, label: d.urgence, icon: TaIcons.clock),
            ],
          ),
          // Actions selon le statut.
          const SizedBox(height: 14),
          _DemandeActions(demande: d),
        ],
      ),
    );
  }
}

/// Actions de la carte : devis (nouvelle) ou conversation (sinon).
class _DemandeActions extends StatelessWidget {
  const _DemandeActions({required this.demande});

  final Demande demande;

  @override
  Widget build(BuildContext context) {
    if (demande.statut == DemandeStatut.nouvelle) {
      return Row(
        spacing: 8,
        children: [
          Expanded(
            child: TaButton(
              label: 'Détails',
              variant: TaButtonVariant.outline,
              small: true,
              expanded: true,
              onPressed: () =>
                  showDemandeDetailSheet(context, demande: demande),
            ),
          ),
          Expanded(
            child: TaButton(
              label: 'Envoyer un devis',
              small: true,
              expanded: true,
              onPressed: () => showCreateDevisSheet(context, demande: demande),
              leading: TaIcon(
                TaIcons.doc,
                size: 13,
                mono: true,
                color: TaButton.inkColor(context, TaButtonVariant.cta),
              ),
            ),
          ),
        ],
      );
    }
    // Statuts non nouveaux : ouvrir la conversation (détail pour l'instant).
    return TaButton(
      label: 'Ouvrir la conversation',
      variant: TaButtonVariant.soft,
      small: true,
      expanded: true,
      onPressed: () => showDemandeDetailSheet(context, demande: demande),
      leading: const TaIcon(TaIcons.chat, size: 13),
    );
  }
}
