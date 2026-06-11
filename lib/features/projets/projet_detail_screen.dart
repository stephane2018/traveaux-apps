import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/ta_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/models.dart';
import '../../providers/data_providers.dart';
import '../../providers/projets_provider.dart';
import '../../shared/widgets/widgets.dart';
import 'projets_screen.dart' show projetStatutBadge;
import 'widgets/devis_detail_sheet.dart';

/// Détail d'un projet client : description, méta et devis reçus.
class ProjetDetailScreen extends ConsumerWidget {
  const ProjetDetailScreen({super.key, required this.projetId});

  final String projetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.ta;
    final projet = ref.watch(projetProvider(projetId));
    if (projet == null) {
      return Scaffold(
        body: Center(child: Text('Projet introuvable', style: context.taSub)),
      );
    }
    final devis = ref.watch(devisForProjetProvider(projetId));
    final topPad = MediaQuery.paddingOf(context).top;

    return TaStatusBar(
      child: Scaffold(
        body: Column(
          children: [
            // ----- en-tête -----
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(
                TaDims.pad,
                topPad + 16,
                TaDims.pad,
                12,
              ),
              decoration: BoxDecoration(
                color: t.surface,
                border: Border(bottom: BorderSide(color: t.border)),
              ),
              child: Row(
                spacing: 10,
                children: [
                  TaSquareButton.back(context, onTap: () => context.pop()),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          projet.titre,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: t.text,
                          ),
                        ),
                        Text(
                          '${projet.commune} · ${projet.urgence}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.taSub,
                        ),
                      ],
                    ),
                  ),
                  projetStatutBadge(context, projet.statut),
                ],
              ),
            ),
            // ----- corps -----
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  TaDims.pad,
                  TaDims.pad,
                  TaDims.pad,
                  40,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: TaDims.gap,
                  children: [
                    _DescriptionCard(projet: projet),
                    TaSectionHead(title: 'Devis reçus (${devis.length})'),
                    if (devis.isEmpty)
                      const _WaitingCard()
                    else
                      for (final d in devis) _DevisCard(devis: d),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Carte description + méta (commune, urgence, budget).
class _DescriptionCard extends StatelessWidget {
  const _DescriptionCard({required this.projet});

  final Projet projet;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    return TaCard(
      padding: const EdgeInsets.all(TaDims.pad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DESCRIPTION', style: context.taLabel),
          const SizedBox(height: 7),
          Text(
            projet.description,
            style: TextStyle(
              fontSize: TaDims.fsSm,
              fontWeight: FontWeight.w500,
              height: 1.6,
              color: t.text2,
            ),
          ),
          const TaDivider(margin: EdgeInsets.symmetric(vertical: 12)),
          Column(
            spacing: 10,
            children: [
              _metaRow(t, TaIcons.mapPin, projet.commune),
              _metaRow(t, TaIcons.clock, projet.urgence),
              _metaRow(t, TaIcons.wallet, projet.budget),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metaRow(TaTokens t, TaIcons icon, String label) {
    return Row(
      spacing: 8,
      children: [
        TaIcon(icon, size: 14, mono: true, color: t.text3),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: t.text2,
            ),
          ),
        ),
      ],
    );
  }
}

/// Carte d'un devis reçu : artisan, montant, actions.
class _DevisCard extends ConsumerWidget {
  const _DevisCard({required this.devis});

  final DevisDoc devis;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.ta;
    final d = devis;
    final artisan = ref.watch(artisanProvider(d.artisanId));
    final accepte = d.statut == DevisStatut.accepte;
    final refuse = d.statut == DevisStatut.refuse;

    return TaCard(
      padding: const EdgeInsets.all(TaDims.pad),
      onTap: () => showDevisDetailSheet(context, devisId: d.id),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            spacing: 11,
            children: [
              TaAvatar(artisan: artisan, size: 44),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      spacing: 5,
                      children: [
                        Flexible(
                          child: Text(
                            artisan.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: TaDims.fsSm,
                              fontWeight: FontWeight.w800,
                              color: t.text,
                            ),
                          ),
                        ),
                        if (artisan.verified)
                          const TaIcon(TaIcons.badge, size: 13),
                      ],
                    ),
                    Text(
                      d.titre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.taSub.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (accepte)
                TaBadge(
                  label: 'Accepté',
                  background: t.primary,
                  foreground: t.primaryInk,
                  icon: TaIcons.check,
                )
              else if (refuse)
                TaBadge(
                  label: 'Refusé',
                  background: t.surface2,
                  foreground: t.danger,
                  icon: TaIcons.close,
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 2),
            child: Text(
              formatFcfa(d.total),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.44,
                color: t.text,
              ),
            ),
          ),
          Text('${d.lignes.length} lignes · ${d.date}', style: context.taSub),
          Padding(
            padding: const EdgeInsets.only(top: 12),
            // Tout passe par le sheet : détail, refus, acceptation + RDV.
            child: TaButton(
              label: d.statut == DevisStatut.propose
                  ? 'Voir le devis'
                  : 'Voir le détail',
              variant: d.statut == DevisStatut.propose
                  ? TaButtonVariant.primary
                  : TaButtonVariant.outline,
              small: true,
              expanded: true,
              onPressed: () => showDevisDetailSheet(context, devisId: d.id),
            ),
          ),
        ],
      ),
    );
  }
}

/// Carte d'attente quand aucun devis n'a encore été reçu.
class _WaitingCard extends StatelessWidget {
  const _WaitingCard();

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    return TaCard(
      padding: const EdgeInsets.all(TaDims.pad),
      child: Column(
        children: [
          const Opacity(opacity: 0.6, child: TaIcon(TaIcons.clock, size: 26)),
          const SizedBox(height: 8),
          Text(
            'En attente de devis',
            style: TextStyle(
              fontSize: TaDims.fsSm,
              fontWeight: FontWeight.w700,
              color: t.text,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            'Les artisans contactés ont 24 h pour répondre.',
            textAlign: TextAlign.center,
            style: context.taSub,
          ),
        ],
      ),
    );
  }
}
