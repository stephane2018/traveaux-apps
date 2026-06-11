import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_palette.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/ta_tokens.dart';
import '../../data/models/models.dart';
import '../../providers/data_providers.dart';
import '../../shared/widgets/widgets.dart';

/// Accueil client : en-tête vert + recherche, catégories, artisans mis en
/// avant, CTA devis et « Comment ça marche ».
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final featured = ref.watch(featuredArtisansProvider);

    return TaStatusBar(
      forceLight: true,
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // En-tête fixe (salutation + recherche) : seul le contenu défile.
            const _HomeHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(0, TaDims.gap + 6, 0, 116),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: TaDims.gap + 10,
                  children: [
                    _hPad(_CategoriesSection(categories: categories)),
                    _FeaturedSection(featured: featured),
                    _hPad(const _DevisCta()),
                    _hPad(const _HowItWorks()),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _hPad(Widget child) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: TaDims.pad),
    child: child,
  );
}

// ─── En-tête vert avec barre de recherche à cheval ───
//
// Le dégradé s'arrête 24 px au-dessus du bas du widget : la barre de
// recherche, posée en fin de colonne, chevauche ainsi l'en-tête (28 px sur
// le vert, 24 px sur le fond) tout en restant dans les bornes de hit-test.
class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    return Stack(
      children: [
        Positioned.fill(
          bottom: 24,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: t.headerGrad,
              borderRadius: const BorderRadius.vertical(
                bottom: Radius.circular(26),
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            TaDims.pad,
            MediaQuery.paddingOf(context).top + 16,
            TaDims.pad,
            0,
          ),
          child: _headerContent(t, context),
        ),
      ],
    );
  }

  Widget _headerContent(TaTokens t, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: Row(
            spacing: 8,
            children: [
              const TaLogo(size: 30),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: TaWordmark(size: 17, light: true),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Row(
                        spacing: 3,
                        children: [
                          TaIcon(
                            TaIcons.mapPin,
                            size: 11,
                            mono: true,
                            color: t.headerInk2,
                          ),
                          Flexible(
                            child: Text(
                              'Abidjan, Côte d’Ivoire',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: t.headerInk2,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const _PlusButton(),
              const _BellButton(),
            ],
          ),
        ),
        Text(
          'Bonjour Awa,',
          style: TextStyle(
            color: t.headerInk,
            fontSize: 23,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.46,
            height: 1.2,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 3),
          child: Text(
            'Quel travail faut-il faire aujourd’hui ?',
            style: TextStyle(
              color: t.headerInk2,
              fontSize: TaDims.fs,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        // Barre de recherche à cheval (le vert s'arrête 24 px plus haut).
        const Padding(padding: EdgeInsets.only(top: 16), child: _SearchBar()),
      ],
    );
  }
}

/// Bouton « + » de l'en-tête : nouvelle demande de devis (projet).
class _PlusButton extends StatelessWidget {
  const _PlusButton();

  @override
  Widget build(BuildContext context) {
    return TaPressable(
      onTap: () => context.push('/devis'),
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(13),
        ),
        child: const TaIcon(
          TaIcons.plus,
          size: 17,
          mono: true,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _BellButton extends StatelessWidget {
  const _BellButton();

  @override
  Widget build(BuildContext context) {
    return TaPressable(
      onTap: () => context.go('/messages'),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Stack(
          children: [
            const Center(
              child: TaIcon(
                TaIcons.bell,
                size: 19,
                mono: true,
                color: Colors.white,
              ),
            ),
            Positioned(
              top: 8,
              right: 9,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppPalette.orange400,
                  border: Border.all(color: AppPalette.green700, width: 1.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    return SizedBox(
      height: 52,
      child: TaCard(
        onTap: () => context.go('/results'),
        popShadow: true,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          spacing: 10,
          children: [
            const TaIcon(TaIcons.search, size: 20),
            Expanded(
              child: Text(
                'Plombier, électricien, peintre…',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: t.text3,
                  fontSize: TaDims.fs,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: t.accent,
                borderRadius: BorderRadius.circular(TaDims.rPill),
              ),
              child: TaIcon(
                TaIcons.filter,
                size: 16,
                mono: true,
                color: t.accentInk,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Catégories : grille 4 colonnes ───
class _CategoriesSection extends StatelessWidget {
  const _CategoriesSection({required this.categories});

  final List<TaCategory> categories;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TaSectionHead(
          title: 'Catégories',
          action: 'Tout voir',
          onAction: () => context.go('/results'),
        ),
        Column(
          spacing: TaDims.gap,
          children: [
            for (var i = 0; i < categories.length; i += 4)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: TaDims.gap,
                children: [
                  for (var j = i; j < i + 4; j++)
                    Expanded(
                      child: j < categories.length
                          ? _CategoryItem(category: categories[j])
                          : const SizedBox.shrink(),
                    ),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({required this.category});

  final TaCategory category;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    return TaPressable(
      onTap: () => context.go('/results?cat=${category.id}'),
      child: Column(
        spacing: 6,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: TaCard(
              radius: TaDims.rCard - 2,
              child: Center(child: TaIcon(category.icon, size: 26)),
            ),
          ),
          Text(
            category.label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: t.text2,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Artisans mis en avant : scroll horizontal débordant ───
class _FeaturedSection extends StatelessWidget {
  const _FeaturedSection({required this.featured});

  final List<Artisan> featured;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: TaDims.pad),
          child: TaSectionHead(
            title: 'Artisans mis en avant',
            action: 'Tout voir',
            onAction: () => context.go('/results'),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(TaDims.pad, 2, TaDims.pad, 8),
          child: Row(
            spacing: TaDims.gap,
            children: [for (final a in featured) _FeaturedCard(artisan: a)],
          ),
        ),
      ],
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.artisan});

  final Artisan artisan;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 172),
      child: TaCard(
        onTap: () => context.push('/artisan/${artisan.id}'),
        padding: const EdgeInsets.all(TaDims.pad),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            TaAvatar(artisan: artisan, size: 56),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 4,
                  children: [
                    Text(
                      artisan.name,
                      style: TextStyle(
                        fontSize: TaDims.fsSm,
                        fontWeight: FontWeight.w800,
                        color: t.text,
                      ),
                    ),
                    if (artisan.verified) const TaIcon(TaIcons.badge, size: 13),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    artisan.metier,
                    textAlign: TextAlign.center,
                    style: context.taSub,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 5,
              children: [
                TaStars(note: artisan.note, size: 11),
                Text(
                  '${artisan.note}',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: t.text,
                  ),
                ),
                Text(
                  '(${artisan.avis})',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: t.text3,
                  ),
                ),
              ],
            ),
            TaBadge.featured(context, small: true),
          ],
        ),
      ),
    );
  }
}

// ─── Carte CTA devis ───
class _DevisCta extends StatelessWidget {
  const _DevisCta();

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    return TaCard(
      padding: const EdgeInsets.all(TaDims.pad),
      // linear-gradient(120deg, accent-soft, surface)
      gradient: LinearGradient(
        begin: const Alignment(-0.87, -0.5),
        end: const Alignment(0.87, 0.5),
        colors: [t.accentSoft, t.surface],
      ),
      child: Row(
        spacing: 14,
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: t.accent,
              borderRadius: BorderRadius.circular(15),
            ),
            child: TaIcon(
              TaIcons.doc,
              size: 22,
              mono: true,
              color: t.accentInk,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Un projet en tête ?',
                  style: TextStyle(
                    fontSize: TaDims.fs,
                    fontWeight: FontWeight.w800,
                    color: t.text,
                  ),
                ),
                Text(
                  'Décrivez-le, recevez jusqu’à 3 devis gratuits.',
                  style: context.taSub,
                ),
              ],
            ),
          ),
          TaButton(
            label: 'Devis',
            small: true,
            onPressed: () => context.push('/devis'),
          ),
        ],
      ),
    );
  }
}

// ─── Comment ça marche ───
class _HowItWorks extends StatelessWidget {
  const _HowItWorks();

  static const _steps = [
    (
      TaIcons.search,
      'Décrivez votre besoin',
      'Catégorie, commune, photos du chantier.',
    ),
    (
      TaIcons.chat,
      'Recevez des devis',
      'Jusqu’à 3 artisans vérifiés vous répondent.',
    ),
    (
      TaIcons.shield,
      'Choisissez en confiance',
      'Avis clients réels et profils vérifiés.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const TaSectionHead(title: 'Comment ça marche'),
        TaCard(
          padding: const EdgeInsets.all(TaDims.pad),
          child: Column(
            spacing: 14,
            children: [
              for (final (i, step) in _steps.indexed)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 12,
                  children: [
                    TaIconBox(
                      icon: step.$1,
                      size: 38,
                      radius: 12,
                      iconSize: 18,
                      background: t.primarySoft,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${i + 1}. ${step.$2}',
                            style: TextStyle(
                              fontSize: TaDims.fsSm,
                              fontWeight: FontWeight.w700,
                              color: t.text,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 1),
                            child: Text(step.$3, style: context.taSub),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}
