import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/ta_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/models.dart';
import '../../providers/data_providers.dart';
import '../../shared/widgets/widgets.dart';

/// Page « Mon profil » de l'espace artisan : fiche publique éditable.
class ProProfilPage extends ConsumerWidget {
  const ProProfilPage({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(artisansProvider).first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!compact) ...[
          Text('Mon profil', style: context.taH1.copyWith(fontSize: 24)),
          const SizedBox(height: 3),
          Text('Voici comment les clients vous voient', style: context.taSub),
          const SizedBox(height: 18),
        ],
        _IdentityCard(me: me),
        const SizedBox(height: TaDims.gap),
        _StatsCard(me: me),
        const SizedBox(height: TaDims.gap),
        _AboutCard(me: me),
        const SizedBox(height: TaDims.gap),
        _InfosCard(me: me),
      ],
    );
  }
}

/// Carte identité : avatar, nom, métier, disponibilité, bouton modifier.
class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.me});

  final Artisan me;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    return TaCard(
      padding: const EdgeInsets.all(TaDims.pad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 14,
            children: [
              TaAvatar(artisan: me, size: 64),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      spacing: 5,
                      children: [
                        Flexible(
                          child: Text(
                            me.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: TaDims.fsLg,
                              fontWeight: FontWeight.w800,
                              color: t.text,
                            ),
                          ),
                        ),
                        if (me.verified) const TaIcon(TaIcons.badge, size: 15),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${me.metier} · ${me.commune}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.taSub,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (me.verified) TaBadge.verified(context),
                        TaBadge.neutral(
                          context,
                          label: me.dispo,
                          icon: TaIcons.clock,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            spacing: 8,
            children: [
              Expanded(
                child: TaButton(
                  label: 'Modifier le profil',
                  variant: TaButtonVariant.primary,
                  small: true,
                  onPressed: () {},
                  leading: TaIcon(
                    TaIcons.settings,
                    size: 14,
                    mono: true,
                    color: TaButton.inkColor(context, TaButtonVariant.primary),
                  ),
                ),
              ),
              Expanded(
                child: TaButton(
                  label: 'Aperçu public',
                  variant: TaButtonVariant.outline,
                  small: true,
                  onPressed: () {},
                  leading: const TaIcon(TaIcons.eye, size: 14),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Carte des statistiques publiques (note, avis, chantiers, expérience).
class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.me});

  final Artisan me;

  @override
  Widget build(BuildContext context) {
    return TaCard(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _Stat(value: '${me.note}', label: 'Note', star: true),
            ),
            const _VDivider(),
            Expanded(
              child: _Stat(value: '${me.avis}', label: 'Avis'),
            ),
            const _VDivider(),
            Expanded(
              child: _Stat(value: '${me.jobs}', label: 'Chantiers'),
            ),
            const _VDivider(),
            Expanded(
              child: _Stat(value: '${me.annees} ans', label: 'Expérience'),
            ),
          ],
        ),
      ),
    );
  }
}

class _VDivider extends StatelessWidget {
  const _VDivider();

  @override
  Widget build(BuildContext context) => const TaDivider(
    vertical: true,
    margin: EdgeInsets.symmetric(vertical: 4),
  );
}

class _Stat extends StatelessWidget {
  const _Stat({required this.value, required this.label, this.star = false});

  final String value;
  final String label;
  final bool star;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            spacing: 4,
            children: [
              if (star) const TaIcon(TaIcons.star, size: 14),
              Text(
                value,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: t.text,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: context.taLabel,
        ),
      ],
    );
  }
}

/// Carte « À propos » + compétences.
class _AboutCard extends StatelessWidget {
  const _AboutCard({required this.me});

  final Artisan me;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    return TaCard(
      padding: const EdgeInsets.all(TaDims.pad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('À PROPOS', style: context.taLabel)),
              TaIcon(TaIcons.settings, size: 15, mono: true, color: t.text3),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            me.bio,
            style: TextStyle(
              fontSize: TaDims.fsSm,
              fontWeight: FontWeight.w500,
              height: 1.6,
              color: t.text2,
            ),
          ),
          const SizedBox(height: 14),
          Text('COMPÉTENCES', style: context.taLabel),
          const SizedBox(height: 9),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final s in me.skills)
                TaChip(
                  label: s,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Carte infos : zone, horaires, tarif, vérification.
class _InfosCard extends StatelessWidget {
  const _InfosCard({required this.me});

  final Artisan me;

  @override
  Widget build(BuildContext context) {
    final rows = [
      (
        TaIcons.mapPin,
        'Zone d’intervention',
        '${me.commune}, ${me.quartier} et environs',
      ),
      (TaIcons.clock, 'Horaires', 'Lun – Sam · 7 h 30 – 18 h 30'),
      (
        TaIcons.wallet,
        'Tarif de déplacement',
        'À partir de ${formatNumber(me.prix)} F CFA',
      ),
      (
        TaIcons.shield,
        'Identité vérifiée',
        me.verified
            ? 'CNI + selfie vérifiés par TravauxAbidjan'
            : 'Vérification en cours',
      ),
    ];

    return TaCard(
      padding: const EdgeInsets.all(TaDims.pad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          for (final (icon, title, sub) in rows)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 12,
              children: [
                TaIconBox(icon: icon, iconSize: 17),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: TaDims.fsSm,
                          fontWeight: FontWeight.w700,
                          color: context.ta.text,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Text(sub, style: context.taSub),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
