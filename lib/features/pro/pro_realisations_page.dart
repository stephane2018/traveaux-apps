import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/ta_tokens.dart';
import '../../data/models/models.dart';
import '../../providers/data_providers.dart';
import '../../shared/widgets/widgets.dart';
import 'widgets/add_realisation_sheet.dart';

/// Page « Réalisations » de l'espace artisan : galerie avant/après.
class ProRealisationsPage extends ConsumerWidget {
  const ProRealisationsPage({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final realisations = ref.watch(realisationsProvider);
    final columns = compact ? 2 : 3;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!compact) ...[
          _Header(count: realisations.length),
          const SizedBox(height: 18),
        ],
        // ----- carte d'ajout -----
        const _AddCard(),
        const SizedBox(height: TaDims.gap),
        // ----- grille des réalisations -----
        for (var i = 0; i < realisations.length; i += columns) ...[
          if (i > 0) const SizedBox(height: TaDims.gap),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var j = i; j < i + columns; j++) ...[
                if (j > i) const SizedBox(width: TaDims.gap),
                Expanded(
                  child: j < realisations.length
                      ? _RealisationCard(realisation: realisations[j], index: j)
                      : const SizedBox.shrink(),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

/// Titre + CTA (tablette).
class _Header extends StatelessWidget {
  const _Header({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mes réalisations',
                style: context.taH1.copyWith(fontSize: 24),
              ),
              const SizedBox(height: 3),
              Text(
                '$count chantiers · vos photos avant/après rassurent les clients',
                style: context.taSub,
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        TaButton(
          label: 'Ajouter',
          variant: TaButtonVariant.primary,
          height: 42,
          fontSize: TaDims.fsSm,
          onPressed: () => showAddRealisationSheet(context),
          leading: TaIcon(
            TaIcons.plus,
            size: 15,
            mono: true,
            color: TaButton.inkColor(context, TaButtonVariant.primary),
          ),
        ),
      ],
    );
  }
}

/// Carte « Ajouter une réalisation » (placeholder dashed).
class _AddCard extends StatelessWidget {
  const _AddCard();

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    return TaCard(
      onTap: () => showAddRealisationSheet(context),
      color: t.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        child: Row(
          spacing: 14,
          children: [
            TaIconBox(
              icon: TaIcons.camera,
              size: 46,
              radius: 15,
              iconSize: 22,
              background: t.primarySoft,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ajouter une réalisation',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: TaDims.fs,
                      color: t.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Photos avant / après, type de travaux et durée.',
                    style: context.taSub,
                  ),
                ],
              ),
            ),
            TaIcon(TaIcons.plus, size: 18, mono: true, color: t.primary),
          ],
        ),
      ),
    );
  }
}

/// Carte d'une réalisation : avant/après + infos.
class _RealisationCard extends StatelessWidget {
  const _RealisationCard({required this.realisation, required this.index});

  final Realisation realisation;
  final int index;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    final p = realisation;
    return TaCard(
      onTap: () => context.push('/pro/realisation/${realisation.id}'),
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TaBeforeAfter(height: 96),
          const SizedBox(height: 10),
          Text(
            p.titre,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: TaDims.fsSm,
              color: t.text,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            p.type,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: context.taSub.copyWith(fontSize: 11.5),
          ),
          const SizedBox(height: 8),
          TaBadge.neutral(context, label: p.duree, icon: TaIcons.clock),
        ],
      ),
    );
  }
}
