import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/ta_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/models.dart';
import '../../providers/data_providers.dart';
import '../../providers/results_provider.dart';
import '../../shared/widgets/widgets.dart';

/// « 4.9 » mais « 5 » si la note est entière (comme le proto JS).
String _formatNote(double note) =>
    note == note.roundToDouble() ? note.toStringAsFixed(0) : note.toString();

/// Écran Résultats : recherche d'artisans filtrée par métier et commune.
class ResultsScreen extends ConsumerStatefulWidget {
  const ResultsScreen({super.key, this.initialCat});

  final String? initialCat;

  @override
  ConsumerState<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends ConsumerState<ResultsScreen> {
  @override
  void initState() {
    super.initState();
    _seedCat();
  }

  @override
  void didUpdateWidget(ResultsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCat != oldWidget.initialCat) _seedCat();
  }

  /// Applique la catégorie passée en paramètre de route.
  /// Différé : Riverpod interdit de modifier un provider pendant le build.
  void _seedCat() {
    final cat = widget.initialCat;
    if (cat == null) return;
    Future.microtask(() {
      if (mounted) ref.read(resultsFilterProvider.notifier).reset(cat: cat);
    });
  }

  @override
  Widget build(BuildContext context) {
    final list = ref.watch(filteredArtisansProvider);
    return TaStatusBar(
      forceLight: true,
      child: Scaffold(
        backgroundColor: context.ta.bg,
        body: Column(
          children: [
            const _ResultsHeader(),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  TaDims.pad,
                  TaDims.pad,
                  TaDims.pad,
                  116,
                ),
                itemCount: list.length + 1,
                separatorBuilder: (_, _) => const SizedBox(height: TaDims.gap),
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Text(
                        '${list.length} artisan${list.length > 1 ? 's' : ''}'
                        ' · triés par pertinence',
                        style: context.taSub,
                      ),
                    );
                  }
                  return _ArtisanCard(artisan: list[index - 1]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// En-tête : retour + faux champ recherche + tri, puis chips métier/commune.
class _ResultsHeader extends ConsumerWidget {
  const _ResultsHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.ta;
    final filter = ref.watch(resultsFilterProvider);
    final categories = ref.watch(categoriesProvider);
    final communes = ref.watch(communesProvider);
    final notifier = ref.read(resultsFilterProvider.notifier);

    var catLabel = 'Tous les artisans';
    for (final c in categories) {
      if (c.id == filter.cat) catLabel = c.label;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ----- barre du haut sur en-tête vert arrondi -----
        Container(
          padding: EdgeInsets.fromLTRB(
            TaDims.pad,
            MediaQuery.paddingOf(context).top + 16,
            TaDims.pad,
            18,
          ),
          decoration: BoxDecoration(
            gradient: t.headerGrad,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(26),
            ),
          ),
          child: Row(
            spacing: 10,
            children: [
              TaSquareButton(
                background: Colors.white.withValues(alpha: 0.16),
                onTap: () => context.go('/home'),
                child: TaIcon(
                  TaIcons.arrowLeft,
                  size: 17,
                  mono: true,
                  color: t.headerInk,
                ),
              ),
              Expanded(child: _searchField(t, catLabel)),
              TaSquareButton(
                onTap: () {},
                background: Colors.white.withValues(alpha: 0.16),
                child: TaIcon(
                  TaIcons.sort,
                  size: 17,
                  mono: true,
                  color: t.headerInk,
                ),
              ),
            ],
          ),
        ),
        // ----- filtres (sur le fond, sous l'en-tête) -----
        const SizedBox(height: 14),
        _chipsScroll([
          TaChip(
            label: 'Tous',
            active: filter.cat == 'all',
            onTap: () => notifier.setCat('all'),
          ),
          for (final c in categories.take(6))
            TaChip(
              label: c.label,
              active: filter.cat == c.id,
              onTap: () => notifier.setCat(c.id),
              icon: TaIcon(
                c.icon,
                size: 13,
                mono: filter.cat == c.id,
                color: t.primaryInk,
              ),
            ),
        ]),
        const SizedBox(height: 8),
        _chipsScroll([
          for (final co in ['Toutes', ...communes.take(6)])
            TaChip(
              label: co,
              active: filter.commune == co,
              onTap: () => notifier.setCommune(co),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              icon: co == 'Toutes'
                  ? null
                  : TaIcon(
                      TaIcons.mapPin,
                      size: 12,
                      mono: filter.commune == co,
                      color: t.primaryInk,
                    ),
            ),
        ]),
      ],
    );
  }

  /// Faux champ de recherche affichant la catégorie active (carte blanche).
  Widget _searchField(TaTokens t, String catLabel) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(TaDims.rPill),
        boxShadow: t.shadowCard,
      ),
      child: Row(
        spacing: 8,
        children: [
          const TaIcon(TaIcons.search, size: 16),
          Expanded(
            child: Text(
              catLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: TaDims.fsSm,
                fontWeight: FontWeight.w600,
                color: t.text,
              ),
            ),
          ),
          TaIcon(TaIcons.close, size: 13, mono: true, color: t.text3),
        ],
      ),
    );
  }

  /// Rangée de chips débordant des marges (scroll horizontal pleine largeur).
  Widget _chipsScroll(List<Widget> chips) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: TaDims.pad),
      child: Row(spacing: 7, children: chips),
    );
  }
}

/// Carte artisan de la liste de résultats.
class _ArtisanCard extends StatelessWidget {
  const _ArtisanCard({required this.artisan});

  final Artisan artisan;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    final a = artisan;
    return TaCard(
      padding: const EdgeInsets.all(TaDims.pad),
      onTap: () => context.push('/artisan/${a.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 12,
            children: [
              TaAvatar(artisan: a, size: 54),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      spacing: 6,
                      children: [
                        Flexible(
                          child: Text(
                            a.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: TaDims.fs,
                              fontWeight: FontWeight.w800,
                              color: t.text,
                            ),
                          ),
                        ),
                        if (a.verified) const TaIcon(TaIcons.badge, size: 15),
                      ],
                    ),
                    const SizedBox(height: 1),
                    Text(a.metier, style: context.taSub),
                    const SizedBox(height: 5),
                    Row(
                      spacing: 5,
                      children: [
                        TaStars(note: a.note, size: 12),
                        Text(
                          _formatNote(a.note),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: t.text,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            '(${a.avis} avis)',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: t.text3,
                            ),
                          ),
                        ),
                        Text(
                          '·',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: t.text3,
                          ),
                        ),
                        Flexible(
                          child: Text(
                            '${a.jobs} chantiers',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
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
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: TaIcon(
                  TaIcons.chevronRight,
                  size: 16,
                  mono: true,
                  color: t.text3,
                ),
              ),
            ],
          ),
          const TaDivider(margin: EdgeInsets.only(top: 12, bottom: 10)),
          Row(
            spacing: 6,
            children: [
              // Le proto pose `flex-wrap: wrap` sur cette rangée.
              Expanded(
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    TaBadge.neutral(
                      context,
                      label: a.commune,
                      icon: TaIcons.mapPin,
                    ),
                    TaBadge.neutral(
                      context,
                      label: a.dispo,
                      icon: TaIcons.clock,
                    ),
                    if (a.featured) TaBadge.featured(context, small: true),
                  ],
                ),
              ),
              Text(
                'dès ${formatNumber(a.prix)} F',
                style: TextStyle(
                  fontSize: TaDims.fsSm,
                  fontWeight: FontWeight.w800,
                  color: t.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
