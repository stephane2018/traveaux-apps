import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/ta_tokens.dart';
import '../../data/models/models.dart';
import '../../providers/data_providers.dart';
import '../../shared/widgets/widgets.dart';

/// Détail plein écran d'une réalisation (galerie avant/après + infos).
class RealisationDetailScreen extends ConsumerWidget {
  const RealisationDetailScreen({super.key, required this.realisationId});

  final String realisationId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = ref.watch(realisationProvider(realisationId));

    if (r == null) {
      return const Scaffold(
        body: Center(child: Text('Réalisation introuvable')),
      );
    }

    return TaStatusBar(
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(realisation: r),
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
                      const TaBeforeAfter(height: 180),
                      // Vignettes complémentaires.
                      Row(
                        spacing: 10,
                        children: [
                          Expanded(child: TaPhoto(height: 80, tone: 0)),
                          Expanded(child: TaPhoto(height: 80, tone: 1)),
                          Expanded(child: TaPhoto(height: 80, tone: 2)),
                        ],
                      ),
                      _DescriptionCard(realisation: r),
                      _InfosCard(realisation: r),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// En-tête : retour + titre/sous-titre + bouton édition.
class _Header extends StatelessWidget {
  const _Header({required this.realisation});

  final Realisation realisation;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    final top = MediaQuery.of(context).padding.top;
    return Container(
      decoration: BoxDecoration(
        color: t.surface,
        border: Border(bottom: BorderSide(color: t.border)),
      ),
      padding: EdgeInsets.fromLTRB(TaDims.pad, top + 16, TaDims.pad, 12),
      child: Row(
        spacing: 12,
        children: [
          TaSquareButton.back(context, onTap: () => Navigator.pop(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  realisation.titre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: t.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${realisation.type} · ${realisation.commune}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.taSub.copyWith(fontSize: 12),
                ),
              ],
            ),
          ),
          // Bouton édition (sans effet pour le moment).
          TaSquareButton(
            onTap: () {},
            background: t.surface,
            borderColor: t.borderStrong,
            child: TaIcon(
              TaIcons.settings,
              size: 17,
              mono: true,
              color: t.text,
            ),
          ),
        ],
      ),
    );
  }
}

/// Carte description.
class _DescriptionCard extends StatelessWidget {
  const _DescriptionCard({required this.realisation});

  final Realisation realisation;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    return TaCard(
      padding: const EdgeInsets.all(TaDims.pad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DESCRIPTION', style: context.taLabel),
          const SizedBox(height: 10),
          Text(
            realisation.description.isEmpty
                ? 'Aucune description fournie.'
                : realisation.description,
            style: TextStyle(
              fontSize: TaDims.fsSm,
              fontWeight: FontWeight.w500,
              height: 1.6,
              color: t.text2,
            ),
          ),
        ],
      ),
    );
  }
}

/// Carte infos clés (type, durée, commune).
class _InfosCard extends StatelessWidget {
  const _InfosCard({required this.realisation});

  final Realisation realisation;

  @override
  Widget build(BuildContext context) {
    final rows = [
      (TaIcons.doc, 'Type', realisation.type),
      (TaIcons.clock, 'Durée', realisation.duree),
      (TaIcons.mapPin, 'Commune', realisation.commune),
    ];
    return TaCard(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: TaDims.pad),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const TaDivider(),
            _InfoRow(icon: rows[i].$1, label: rows[i].$2, value: rows[i].$3),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
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
              value.isEmpty ? '—' : value,
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
