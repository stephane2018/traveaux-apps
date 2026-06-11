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
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 640;
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
              children: [
                for (final d in demandes)
                  _DemandeCard(demande: d, narrow: narrow),
              ],
            ),
          ],
        );
      },
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

/// Carte d'une demande : avatar, projet + méta, actions selon le statut.
class _DemandeCard extends StatelessWidget {
  const _DemandeCard({required this.demande, required this.narrow});

  final Demande demande;
  final bool narrow;

  @override
  Widget build(BuildContext context) {
    final info = _DemandeInfo(demande: demande);
    final actions = _DemandeActions(demande: demande);
    return TaCard(
      padding: const EdgeInsets.all(18),
      onTap: () => showDemandeDetailSheet(context, demande: demande),
      child: narrow
          // Largeur étroite : les actions passent sous le contenu.
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: 16,
                  children: [
                    TaClientAvatar(name: demande.client, size: 46),
                    Expanded(child: info),
                  ],
                ),
                const SizedBox(height: 12),
                actions,
              ],
            )
          : Row(
              spacing: 16,
              children: [
                TaClientAvatar(name: demande.client, size: 46),
                Expanded(child: info),
                actions,
              ],
            ),
    );
  }
}

class _DemandeInfo extends StatelessWidget {
  const _DemandeInfo({required this.demande});

  final Demande demande;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              demande.projet,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 14.5,
                color: t.text,
              ),
            ),
            ProStatutBadge(statut: demande.statut),
            if (demande.urgence == 'Urgent')
              TaBadge(
                label: 'Urgent',
                background: t.danger,
                foreground: Colors.white,
              ),
          ],
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 14,
          runSpacing: 6,
          children: [
            _Meta(icon: TaIcons.user, value: demande.client),
            _Meta(icon: TaIcons.mapPin, value: demande.commune),
            _Meta(icon: TaIcons.wallet, value: demande.budget),
            _Meta(icon: TaIcons.clock, value: demande.date),
          ],
        ),
      ],
    );
  }
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.value});

  final TaIcons icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 4,
      children: [
        TaIcon(icon, size: 13, mono: true, color: t.text3),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: t.text2,
          ),
        ),
      ],
    );
  }
}

class _DemandeActions extends StatelessWidget {
  const _DemandeActions({required this.demande});

  final Demande demande;

  @override
  Widget build(BuildContext context) {
    if (demande.statut == DemandeStatut.nouvelle) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          TaButton(
            label: 'Détails',
            variant: TaButtonVariant.outline,
            small: true,
            onPressed: () => showDemandeDetailSheet(context, demande: demande),
          ),
          TaButton(
            label: 'Envoyer un devis',
            small: true,
            onPressed: () => showCreateDevisSheet(context, demande: demande),
            leading: TaIcon(
              TaIcons.doc,
              size: 13,
              mono: true,
              color: TaButton.inkColor(context, TaButtonVariant.cta),
            ),
          ),
        ],
      );
    }
    return TaButton(
      label: 'Ouvrir la conversation',
      variant: TaButtonVariant.soft,
      small: true,
      onPressed: () {},
      leading: const TaIcon(TaIcons.chat, size: 13),
    );
  }
}
