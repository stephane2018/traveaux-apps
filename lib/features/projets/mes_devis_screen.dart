import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_palette.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/ta_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/models.dart';
import '../../providers/data_providers.dart';
import '../../providers/projets_provider.dart';
import '../../shared/widgets/widgets.dart';
import 'widgets/devis_detail_sheet.dart';

/// Page « Mes devis » : tous les devis reçus, en 2 onglets (Reçus / Traités).
class MesDevisScreen extends ConsumerStatefulWidget {
  const MesDevisScreen({super.key});

  @override
  ConsumerState<MesDevisScreen> createState() => _MesDevisScreenState();
}

class _MesDevisScreenState extends ConsumerState<MesDevisScreen> {
  int _tab = 0; // 0 = Reçus (proposés), 1 = Traités (acceptés/refusés)

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    final projets = ref.watch(projetsProvider);
    final allDevis = ref.watch(devisDocsProvider);

    // Devis sur les projets du client, plus récents d'abord.
    final projetIds = projets.map((p) => p.id).toSet();
    final devis =
        allDevis.where((d) => projetIds.contains(d.projetId)).toList();
    final recus =
        devis.where((d) => d.statut == DevisStatut.propose).toList();
    final traites =
        devis.where((d) => d.statut != DevisStatut.propose).toList();
    final acceptes =
        devis.where((d) => d.statut == DevisStatut.accepte).length;

    final liste = _tab == 0 ? recus : traites;

    return TaStatusBar(
      forceLight: true,
      child: Scaffold(
        backgroundColor: t.bg,
        body: Column(
          children: [
            _Header(total: devis.length, acceptes: acceptes),
            // ----- onglets -----
            Padding(
              padding: const EdgeInsets.fromLTRB(
                TaDims.pad,
                TaDims.pad,
                TaDims.pad,
                4,
              ),
              child: TaSegmented<int>(
                value: _tab,
                expand: true,
                onChanged: (v) => setState(() => _tab = v),
                activeShadow: true,
                background: t.surface2,
                activeBackground: t.surface,
                activeForeground: t.text,
                height: 38,
                fontSize: TaDims.fsSm,
                options: [
                  TaSegmentOption(0, 'Reçus (${recus.length})'),
                  TaSegmentOption(1, 'Traités (${traites.length})'),
                ],
              ),
            ),
            Expanded(
              child: liste.isEmpty
                  ? _EmptyDevis(tab: _tab)
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        TaDims.pad,
                        TaDims.gap,
                        TaDims.pad,
                        32,
                      ),
                      itemCount: liste.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: TaDims.gap),
                      itemBuilder: (context, i) =>
                          _DevisCard(devis: liste[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// En-tête vert à bas arrondi : retour, titre, détails simples.
class _Header extends StatelessWidget {
  const _Header({required this.total, required this.acceptes});

  final int total;
  final int acceptes;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        TaDims.pad,
        MediaQuery.paddingOf(context).top + 16,
        TaDims.pad,
        18,
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
                background: Colors.white.withValues(alpha: 0.14),
                onTap: () => context.pop(),
                child: TaIcon(
                  TaIcons.arrowLeft,
                  size: 17,
                  mono: true,
                  color: t.headerInk,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Mes devis',
                  style: TextStyle(
                    color: t.headerInk,
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // ----- détails simples ----
          Row(
            spacing: 16,
            children: [
              _HeaderStat(value: '$total', label: 'devis reçus'),
              Container(
                width: 1,
                height: 28,
                color: Colors.white.withValues(alpha: 0.18),
              ),
              _HeaderStat(
                value: '$acceptes',
                label: 'accepté${acceptes > 1 ? 's' : ''}',
                dot: AppPalette.lime500,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderStat extends StatelessWidget {
  const _HeaderStat({required this.value, required this.label, this.dot});

  final String value;
  final String label;
  final Color? dot;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 7,
      children: [
        Text(
          value,
          style: TextStyle(
            color: t.headerInk,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.44,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 5,
          children: [
            if (dot != null)
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(color: dot, shape: BoxShape.circle),
              ),
            Text(
              label,
              style: TextStyle(
                color: t.headerInk2,
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Carte d'un devis dans la liste : artisan, projet, total, statut.
class _DevisCard extends ConsumerWidget {
  const _DevisCard({required this.devis});

  final DevisDoc devis;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.ta;
    final d = devis;
    final artisan = ref.watch(artisanProvider(d.artisanId));
    final projet = ref.watch(projetProvider(d.projetId));

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
                    const SizedBox(height: 1),
                    Text(
                      projet?.titre ?? d.titre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.taSub.copyWith(fontSize: 12),
                    ),
                  ],
                ),
              ),
              _statutBadge(context, d),
            ],
          ),
          const TaDivider(margin: EdgeInsets.only(top: 12, bottom: 10)),
          Row(
            children: [
              Text(
                formatFcfa(d.total),
                style: TextStyle(
                  fontSize: TaDims.fs,
                  fontWeight: FontWeight.w800,
                  color: t.text,
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  '${d.lignes.length} lignes · ${d.date}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.taSub.copyWith(fontSize: 11.5),
                ),
              ),
              const Spacer(),
              TaIcon(
                TaIcons.chevronRight,
                size: 13,
                mono: true,
                color: t.text3,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statutBadge(BuildContext context, DevisDoc d) {
    final t = context.ta;
    return switch (d.statut) {
      DevisStatut.propose => TaBadge(
        label: 'À traiter',
        background: t.accentSoft,
        foreground: t.accentStrong,
        icon: TaIcons.clock,
      ),
      DevisStatut.accepte => TaBadge(
        label: 'Accepté',
        background: t.primary,
        foreground: t.primaryInk,
        icon: TaIcons.check,
      ),
      DevisStatut.refuse => TaBadge(
        label: 'Refusé',
        background: t.surface2,
        foreground: t.danger,
        icon: TaIcons.close,
      ),
    };
  }
}

/// État vide selon l'onglet.
class _EmptyDevis extends StatelessWidget {
  const _EmptyDevis({required this.tab});

  final int tab;

  @override
  Widget build(BuildContext context) {
    final recus = tab == 0;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TaIconBox(
            icon: recus ? TaIcons.doc : TaIcons.check,
            size: 76,
            radius: 28,
            iconSize: 34,
          ),
          const SizedBox(height: 14),
          Text(
            recus ? 'Aucun devis en attente' : 'Aucun devis traité',
            style: context.taH2,
          ),
          const SizedBox(height: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: Text(
              recus
                  ? 'Les nouveaux devis de vos artisans apparaîtront ici.'
                  : 'Vos devis acceptés ou refusés s’afficheront ici.',
              textAlign: TextAlign.center,
              style: context.taSub,
            ),
          ),
        ],
      ),
    );
  }
}
