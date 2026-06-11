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

    return TaStatusBar(
      forceLight: true,
      child: Scaffold(
        backgroundColor: t.bg,
        body: Column(
          children: [
            _ProjetHeader(projet: projet),
            // ----- corps : devis reçus -----
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

/// En-tête vert à bas arrondi : retour, statut, titre, description et méta.
class _ProjetHeader extends ConsumerWidget {
  const _ProjetHeader({required this.projet});

  final Projet projet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.ta;
    final categories = ref.watch(categoriesProvider);
    var catLabel = 'Travaux';
    for (final c in categories) {
      if (c.id == projet.cat) catLabel = c.label;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        TaDims.pad,
        MediaQuery.paddingOf(context).top + 16,
        TaDims.pad,
        20,
      ),
      decoration: BoxDecoration(
        gradient: t.headerGrad,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(26)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              TaSquareButton(
                background: Colors.white.withValues(alpha: 0.16),
                onTap: () => context.pop(),
                child: TaIcon(
                  TaIcons.arrowLeft,
                  size: 17,
                  mono: true,
                  color: t.headerInk,
                ),
              ),
              const Spacer(),
              _HeaderStatut(statut: projet.statut),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            projet.titre,
            style: TextStyle(
              color: t.headerInk,
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.44,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$catLabel · ${projet.commune} · ${projet.date}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: t.headerInk2,
              fontSize: TaDims.fsSm,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          // ----- panneau translucide : description + méta -----
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DESCRIPTION',
                  style: TextStyle(
                    color: t.headerInk2,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  projet.description,
                  style: TextStyle(
                    color: t.headerInk,
                    fontSize: TaDims.fsSm,
                    fontWeight: FontWeight.w500,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  height: 1,
                  color: Colors.white.withValues(alpha: 0.15),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    _MetaChip(icon: TaIcons.clock, label: projet.urgence),
                    _MetaChip(icon: TaIcons.wallet, label: projet.budget),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Pastille de statut sur l'en-tête vert : carte blanche, texte coloré.
class _HeaderStatut extends StatelessWidget {
  const _HeaderStatut({required this.statut});

  final ProjetStatut statut;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    final (String label, Color color, TaIcons icon) = switch (statut) {
      ProjetStatut.enAttente => ('En attente', t.text2, TaIcons.clock),
      ProjetStatut.devisRecus => ('Devis reçus', t.accentStrong, TaIcons.doc),
      ProjetStatut.enCours => ('En cours', t.primary, TaIcons.wrench),
      ProjetStatut.termine => ('Terminé', t.primaryStrong, TaIcons.check),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(TaDims.rPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          TaIcon(icon, size: 12, mono: true, color: color),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Puce méta translucide de l'en-tête (urgence, budget).
class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

  final TaIcons icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(TaDims.rPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [
          TaIcon(icon, size: 13, mono: true, color: t.headerInk),
          Text(
            label,
            style: TextStyle(
              color: t.headerInk,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
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
