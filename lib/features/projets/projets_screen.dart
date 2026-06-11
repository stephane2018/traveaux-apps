import 'dart:math' as math;

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

/// Pastille de statut d'un projet (mappings partagés liste / détail).
TaBadge projetStatutBadge(BuildContext context, ProjetStatut statut) {
  final t = context.ta;
  return switch (statut) {
    ProjetStatut.enAttente => TaBadge(
      label: 'En attente',
      background: t.surface2,
      foreground: t.text2,
      icon: TaIcons.clock,
    ),
    ProjetStatut.devisRecus => TaBadge(
      label: 'Devis reçus',
      background: t.accentSoft,
      foreground: t.accentStrong,
      icon: TaIcons.doc,
    ),
    ProjetStatut.enCours => TaBadge(
      label: 'En cours',
      background: t.primarySoft,
      foreground: t.primary,
      icon: TaIcons.wrench,
    ),
    ProjetStatut.enValidation => TaBadge(
      label: 'En validation',
      background: t.surface2,
      foreground: t.text2,
      icon: TaIcons.shield,
    ),
    ProjetStatut.termine => TaBadge(
      label: 'Terminé',
      background: t.primary,
      foreground: t.primaryInk,
      icon: TaIcons.check,
    ),
  };
}

/// Onglet « Mes projets » : demandes du client et devis reçus.
class ProjetsScreen extends ConsumerWidget {
  const ProjetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.ta;
    final projets = ref.watch(projetsProvider);
    final allDevis = ref.watch(devisDocsProvider);

    // KPI orientés devis : reçus, acceptés, refusés (sur les projets client).
    final projetIds = projets.map((p) => p.id).toSet();
    final devis = allDevis
        .where((d) => projetIds.contains(d.projetId))
        .toList();
    final acceptes = devis.where((d) => d.statut == DevisStatut.accepte).length;
    final refuses = devis.where((d) => d.statut == DevisStatut.refuse).length;

    return TaStatusBar(
      forceLight: true,
      child: Scaffold(
        backgroundColor: t.bg,
        body: Column(
          children: [
            _Header(
              recus: devis.length,
              acceptes: acceptes,
              refuses: refuses,
              showKpi: projets.isNotEmpty,
            ),
            Expanded(
              child: projets.isEmpty
                  ? const _EmptyProjets()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        TaDims.pad,
                        TaDims.pad,
                        TaDims.pad,
                        116,
                      ),
                      itemCount: projets.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: TaDims.gap),
                      itemBuilder: (context, i) =>
                          _ProjetCard(projet: projets[i]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

/// En-tête vert à bas arrondi : titre, bouton « + » et bandeau KPI.
class _Header extends StatelessWidget {
  const _Header({
    required this.recus,
    required this.acceptes,
    required this.refuses,
    required this.showKpi,
  });

  final int recus;
  final int acceptes;
  final int refuses;
  final bool showKpi;

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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mes projets',
                      style: TextStyle(
                        color: t.headerInk,
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.46,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Suivez vos demandes et les devis reçus',
                      style: TextStyle(
                        color: t.headerInk2,
                        fontSize: TaDims.fsSm,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _AddButton(),
            ],
          ),
          if (showKpi) ...[
            const SizedBox(height: 16),
            _KpiStrip(recus: recus, acceptes: acceptes, refuses: refuses),
          ],
        ],
      ),
    );
  }
}

/// Bouton « + » de l'en-tête : nouveau projet (demande de devis).
class _AddButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TaPressable(
      onTap: () => context.push('/devis'),
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(13),
          boxShadow: context.ta.shadowPop,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            const TaIcon(TaIcons.plus, size: 16),
            Text(
              'Nouveau',
              style: TextStyle(
                color: AppPalette.green700,
                fontSize: TaDims.fsSm,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bandeau KPI translucide sur l'en-tête vert : devis reçus / acceptés /
/// refusés, avec dots de statut.
class _KpiStrip extends StatelessWidget {
  const _KpiStrip({
    required this.recus,
    required this.acceptes,
    required this.refuses,
  });

  final int recus;
  final int acceptes;
  final int refuses;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    return TaPressable(
      onTap: () => context.push('/mes-devis'),
      child: Container(
        padding: const EdgeInsets.fromLTRB(4, 12, 4, 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: _KpiItem(value: recus, label: 'Devis reçus'),
                  ),
                  const _KpiDivider(),
                  Expanded(
                    child: _KpiItem(
                      value: acceptes,
                      label: 'Acceptés',
                      dot: AppPalette.lime500,
                    ),
                  ),
                  const _KpiDivider(),
                  Expanded(
                    child: _KpiItem(
                      value: refuses,
                      label: 'Refusés',
                      dot: _refuseDot,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Container(height: 1, color: Colors.white.withValues(alpha: 0.12)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 4,
              children: [
                Text(
                  'Voir tous les devis',
                  style: TextStyle(
                    color: t.headerInk2,
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TaIcon(
                  TaIcons.chevronRight,
                  size: 12,
                  mono: true,
                  color: t.headerInk2,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Corail clair, lisible sur le dégradé vert (statut « refusé »).
  static const _refuseDot = Color(0xFFF2A9A0);
}

class _KpiDivider extends StatelessWidget {
  const _KpiDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      margin: const EdgeInsets.symmetric(vertical: 2),
      color: Colors.white.withValues(alpha: 0.18),
    );
  }
}

/// Une statistique : grand nombre blanc + libellé discret (dot de statut).
class _KpiItem extends StatelessWidget {
  const _KpiItem({required this.value, required this.label, this.dot});

  final int value;
  final String label;
  final Color? dot;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$value',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.42,
            height: 1,
            color: t.headerInk,
          ),
        ),
        const SizedBox(height: 5),
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
            Flexible(
              child: Text(
                label.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: t.headerInk2,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.6,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Carte projet détaillée : en-tête, description, méta (urgence/budget),
/// progression et résumé des devis reçus.
class _ProjetCard extends ConsumerWidget {
  const _ProjetCard({required this.projet});

  final Projet projet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.ta;
    final p = projet;
    final devis = ref.watch(devisForProjetProvider(p.id));
    final categories = ref.watch(categoriesProvider);

    var icon = TaIcons.doc;
    var catLabel = 'Travaux';
    for (final c in categories) {
      if (c.id == p.cat) {
        icon = c.icon;
        catLabel = c.label;
      }
    }

    final urgent = p.urgence.startsWith('Urgent');
    final minDevis = devis.isEmpty
        ? null
        : devis.map((d) => d.total).reduce(math.min);

    return TaCard(
      padding: const EdgeInsets.all(TaDims.pad),
      onTap: () => context.push('/projet/${p.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ---- en-tête : catégorie, titre, statut ----
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 11,
            children: [
              TaIconBox(
                icon: icon,
                size: 44,
                radius: 13,
                iconSize: 20,
                background: t.primarySoft,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.titre,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: TaDims.fs,
                        fontWeight: FontWeight.w800,
                        color: t.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '$catLabel · ${p.commune} · ${p.date}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.taSub.copyWith(fontSize: 11.5),
                    ),
                  ],
                ),
              ),
              projetStatutBadge(context, p.statut),
            ],
          ),
          const SizedBox(height: 12),
          // ---- description ----
          Text(
            p.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.taSub.copyWith(height: 1.5, color: t.text2),
          ),
          const SizedBox(height: 12),
          // ---- méta : urgence + budget ----
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              TaBadge(
                label: p.urgence,
                icon: TaIcons.clock,
                background: urgent ? t.accentSoft : t.surface2,
                foreground: urgent ? t.accentStrong : t.text2,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _ProjetProgress(statut: p.statut),
          const TaDivider(margin: EdgeInsets.only(top: 12, bottom: 10)),
          // ---- pied : devis reçus + meilleur prix ----
          Row(
            spacing: 6,
            children: [
              TaIcon(
                TaIcons.doc,
                size: 13,
                mono: devis.isEmpty,
                color: t.text3,
              ),
              Flexible(
                child: Text(
                  devis.isEmpty
                      ? 'Aucun devis pour l’instant'
                      : '${devis.length} devis reçu${devis.length > 1 ? 's' : ''}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: devis.isEmpty ? t.text3 : t.text2,
                  ),
                ),
              ),
              const Spacer(),
              if (minDevis != null) ...[
                Text(
                  'dès ${formatNumber(minDevis)} F',
                  style: TextStyle(
                    fontSize: TaDims.fsSm,
                    fontWeight: FontWeight.w800,
                    color: t.primary,
                  ),
                ),
                const SizedBox(width: 6),
              ],
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
}

/// Barre de progression du projet selon son statut (4 étapes).
class _ProjetProgress extends StatelessWidget {
  const _ProjetProgress({required this.statut});

  final ProjetStatut statut;

  static const _steps = ['Demande', 'Devis', 'En cours', 'Validation', 'Fini'];

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    final reached = switch (statut) {
      ProjetStatut.enAttente => 1,
      ProjetStatut.devisRecus => 2,
      ProjetStatut.enCours => 3,
      ProjetStatut.enValidation => 4,
      ProjetStatut.termine => 5,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          spacing: 4,
          children: [
            for (var i = 0; i < _steps.length; i++)
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: i < reached ? t.primary : t.surface3,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Étape ${math.min(reached, 4)}/4 · ${_steps[reached - 1]}',
          style: context.taSub.copyWith(fontSize: 10.5, color: t.text3),
        ),
      ],
    );
  }
}

/// État vide : aucune demande de devis pour le moment.
class _EmptyProjets extends StatelessWidget {
  const _EmptyProjets();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const TaIconBox(
            icon: TaIcons.doc,
            size: 76,
            radius: 28,
            iconSize: 34,
          ),
          const SizedBox(height: 14),
          Text('Aucun projet', style: context.taH2),
          const SizedBox(height: 6),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 280),
            child: Text(
              'Décrivez votre besoin et recevez jusqu’à 3 devis gratuits.',
              textAlign: TextAlign.center,
              style: context.taSub,
            ),
          ),
          const SizedBox(height: 16),
          TaButton(
            label: 'Nouveau projet',
            small: true,
            onPressed: () => context.push('/devis'),
          ),
        ],
      ),
    );
  }
}
