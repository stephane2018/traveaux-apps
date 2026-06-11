import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/ta_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/models.dart';
import '../../providers/data_providers.dart';
import '../../shared/widgets/widgets.dart';
import 'widgets/demande_detail_sheet.dart';
import 'widgets/pro_bars.dart';
import 'widgets/pro_statut_badge.dart';

/// Page « Tableau de bord » : entête, stats, visibilité + demandes récentes.
/// En mode [compact] (mobile), le titre et la cloche vivent dans l'en-tête
/// vert du shell : seul le CTA pleine largeur reste ici.
class ProDashboardPage extends ConsumerWidget {
  const ProDashboardPage({
    super.key,
    this.compact = false,
    required this.onOpenDemandes,
  });

  final bool compact;
  final VoidCallback onOpenDemandes;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pro = ref.watch(proDataProvider);
    final me = ref.watch(artisansProvider).first;
    final demandes = ref.watch(demandesProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 700;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (compact)
              const _AddRealisationButton(expanded: true)
            else
              _DashHeader(narrow: narrow),
            SizedBox(height: compact ? TaDims.gap : 22),
            _StatsGrid(pro: pro, me: me, columns: narrow ? 2 : 4),
            const SizedBox(height: TaDims.gap),
            if (narrow)
              Column(
                spacing: TaDims.gap,
                children: [
                  _VisibilityCard(pro: pro),
                  _RecentDemandesCard(
                    demandes: demandes,
                    onSeeAll: onOpenDemandes,
                  ),
                ],
              )
            else
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: TaDims.gap,
                children: [
                  Expanded(flex: 5, child: _VisibilityCard(pro: pro)),
                  Expanded(
                    flex: 7,
                    child: _RecentDemandesCard(
                      demandes: demandes,
                      onSeeAll: onOpenDemandes,
                    ),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }
}

/// Titre du jour + cloche et CTA « Ajouter une réalisation ».
/// Sur largeur étroite (mobile), les actions passent sous le titre.
class _DashHeader extends StatelessWidget {
  const _DashHeader({required this.narrow});

  final bool narrow;

  @override
  Widget build(BuildContext context) {
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Bonjour M. Konan', style: context.taH1.copyWith(fontSize: 24)),
        const SizedBox(height: 3),
        Text(
          'Mardi 10 juin · 2 nouvelles demandes vous attendent',
          style: context.taSub,
        ),
      ],
    );

    if (narrow) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          title,
          const SizedBox(height: 14),
          Row(
            spacing: 10,
            children: const [
              _BellButton(),
              Expanded(child: _AddRealisationButton(expanded: true)),
            ],
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: title),
        const SizedBox(width: 10),
        const _BellButton(),
        const SizedBox(width: 10),
        const _AddRealisationButton(),
      ],
    );
  }
}

/// CTA « Ajouter une réalisation ».
class _AddRealisationButton extends StatelessWidget {
  const _AddRealisationButton({this.expanded = false});

  final bool expanded;

  @override
  Widget build(BuildContext context) {
    return TaButton(
      label: 'Ajouter une réalisation',
      variant: TaButtonVariant.primary,
      height: 42,
      fontSize: TaDims.fsSm,
      expanded: expanded,
      onPressed: () {},
      leading: TaIcon(
        TaIcons.plus,
        size: 15,
        mono: true,
        color: TaButton.inkColor(context, TaButtonVariant.primary),
      ),
    );
  }
}

/// Cloche avec point de notification.
class _BellButton extends StatelessWidget {
  const _BellButton();

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        TaSquareButton(
          size: 42,
          radius: 13,
          background: t.surface,
          borderColor: t.borderStrong,
          onTap: () => context.push('/pro/notifications'),
          child: const TaIcon(TaIcons.bell, size: 19),
        ),
        Positioned(
          top: 9,
          right: 10,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: t.accent,
              shape: BoxShape.circle,
              border: Border.all(color: t.surface, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

/// Grille des 4 indicateurs clés (2 colonnes sur largeur étroite).
class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.pro,
    required this.me,
    required this.columns,
  });

  final ProData pro;
  final Artisan me;
  final int columns;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _StatCard(
        icon: TaIcons.eye,
        label: 'Vues du profil (7 j)',
        value: formatNumber(pro.stats.vues),
        delta: pro.stats.vuesDelta,
        up: true,
      ),
      _StatCard(
        icon: TaIcons.doc,
        label: 'Demandes reçues',
        value: '${pro.stats.demandes}',
        delta: pro.stats.demandesDelta,
        up: true,
      ),
      _StatCard(
        icon: TaIcons.star,
        label: 'Note moyenne',
        value: '${pro.stats.noteMoy}',
        delta: '${me.avis} avis',
      ),
      _StatCard(
        icon: TaIcons.wallet,
        label: 'Revenus du mois',
        value: '${pro.stats.revenus} F',
        delta: pro.stats.revenusDelta,
        up: true,
        accent: true,
      ),
    ];
    return Column(
      spacing: TaDims.gap,
      children: [
        for (var i = 0; i < cards.length; i += columns)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: TaDims.gap,
            children: [
              for (var j = i; j < i + columns && j < cards.length; j++)
                Expanded(child: cards[j]),
            ],
          ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.delta,
    this.up = false,
    this.accent = false,
  });

  final TaIcons icon;
  final String label;
  final String value;
  final String delta;
  final bool up;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    return TaCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: 6,
            children: [
              TaIconBox(
                icon: icon,
                background: accent ? t.accentSoft : t.primarySoft,
              ),
              Flexible(
                child: TaBadge(
                  label: delta,
                  background: up ? t.primarySoft : t.surface2,
                  foreground: up ? t.primary : t.text2,
                  icon: up ? TaIcons.trend : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.48,
              color: t.text,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: context.taSub.copyWith(fontSize: 11.5)),
        ],
      ),
    );
  }
}

/// Carte « Visibilité du profil » : graphique barres + conseil.
class _VisibilityCard extends StatelessWidget {
  const _VisibilityCard({required this.pro});

  final ProData pro;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    return TaCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 8,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Visibilité du profil',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                        color: t.text,
                      ),
                    ),
                    Text(
                      'Vues cette semaine',
                      style: context.taSub.copyWith(fontSize: 11.5),
                    ),
                  ],
                ),
              ),
              TaBadge(
                label: 'Boost actif',
                background: t.accentSoft,
                foreground: t.accentStrong,
                icon: TaIcons.crown,
              ),
            ],
          ),
          const SizedBox(height: 18),
          ProBars(data: pro.semaine, jours: pro.jours),
          const TaDivider(margin: EdgeInsets.only(top: 16, bottom: 12)),
          Row(
            spacing: 8,
            children: [
              const TaIcon(TaIcons.trend, size: 15),
              Expanded(
                child: Text(
                  'Vos photos avant/après génèrent 2× plus de contacts.',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: t.text2,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Carte « Demandes récentes » : 4 dernières demandes + lien « Tout voir ».
class _RecentDemandesCard extends StatelessWidget {
  const _RecentDemandesCard({required this.demandes, required this.onSeeAll});

  final List<Demande> demandes;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    final visible = demandes.take(4).toList();
    return TaCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 8,
            children: [
              Expanded(
                child: Text(
                  'Demandes récentes',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: t.text,
                  ),
                ),
              ),
              GestureDetector(
                onTap: onSeeAll,
                child: Row(
                  spacing: 2,
                  children: [
                    Text(
                      'Tout voir',
                      style: TextStyle(
                        color: t.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    TaIcon(
                      TaIcons.chevronRight,
                      size: 11,
                      mono: true,
                      color: t.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < visible.length; i++) ...[
            if (i > 0) const TaDivider(),
            _DemandeRow(demande: visible[i]),
          ],
        ],
      ),
    );
  }
}

class _DemandeRow extends StatelessWidget {
  const _DemandeRow({required this.demande});

  final Demande demande;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    return TaPressable(
      onTap: () => showDemandeDetailSheet(context, demande: demande),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11),
        child: Row(
          spacing: 12,
          children: [
            TaClientAvatar(name: demande.client, size: 38),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    spacing: 8,
                    children: [
                      Flexible(
                        child: Text(
                          demande.client,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: t.text,
                          ),
                        ),
                      ),
                      Flexible(
                        child: Text(
                          '· ${demande.commune}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.taSub.copyWith(fontSize: 11),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    demande.projet,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12.5, color: t.text2),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                ProStatutBadge(statut: demande.statut),
                const SizedBox(height: 3),
                Text(
                  demande.date,
                  style: context.taSub.copyWith(fontSize: 10.5),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
