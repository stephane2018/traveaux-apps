import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/ta_tokens.dart';
import '../../../data/models/models.dart';
import '../../../providers/data_providers.dart';
import '../../../shared/widgets/widgets.dart';

/// « 4.9 » mais « 5 » si la note est entière.
String _formatNote(double note) =>
    note == note.roundToDouble() ? note.toStringAsFixed(0) : note.toString();

/// Affiche l'aperçu du profil tel que les clients le voient (bottom sheet).
Future<void> showPublicPreviewSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _PublicPreviewSheet(),
  );
}

/// Contenu du bottom sheet : reproduit la carte vue côté client.
class _PublicPreviewSheet extends ConsumerWidget {
  const _PublicPreviewSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.ta;
    final me = ref.watch(proProfileProvider);
    final maxHeight = MediaQuery.sizeOf(context).height * 0.85;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Container(
        decoration: BoxDecoration(
          color: t.bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _header(context),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  TaDims.pad,
                  0,
                  TaDims.pad,
                  TaDims.pad + 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _miniCover(context, me),
                    const SizedBox(height: TaDims.gap),
                    _aboutCard(context, me),
                    const SizedBox(height: TaDims.gap),
                    _skillsCard(context, me),
                    const SizedBox(height: TaDims.gap),
                    Text(
                      'C’est ainsi que les clients voient votre profil.',
                      textAlign: TextAlign.center,
                      style: context.taSub,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Barre supérieure : poignée + libellé + fermer ───

  Widget _header(BuildContext context) {
    final t = context.ta;
    return Padding(
      padding: const EdgeInsets.fromLTRB(TaDims.pad, 10, TaDims.pad, 8),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: t.borderStrong,
              borderRadius: BorderRadius.circular(TaDims.rPill),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const SizedBox(width: 38),
              Expanded(
                child: Text(
                  'APERÇU CLIENT',
                  textAlign: TextAlign.center,
                  style: context.taLabel,
                ),
              ),
              TaSquareButton(
                onTap: () => Navigator.pop(context),
                background: t.surface,
                borderColor: t.borderStrong,
                child: TaIcon(
                  TaIcons.close,
                  size: 17,
                  mono: true,
                  color: t.text,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Mini-cover + carte identité chevauchante ───

  Widget _miniCover(BuildContext context, Artisan a) {
    final t = context.ta;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Bande verte arrondie en fond.
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 88,
            decoration: BoxDecoration(
              gradient: t.headerGrad,
              borderRadius: BorderRadius.circular(TaDims.rCard),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 52),
          child: _identityCard(context, a),
        ),
      ],
    );
  }

  /// Carte identité chevauchant la mini-cover (avatar remontant).
  Widget _identityCard(BuildContext context, Artisan a) {
    final t = context.ta;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          width: double.infinity,
          child: TaCard(
            padding: const EdgeInsets.all(TaDims.pad),
            child: Column(
              children: [
                // Espace sous l'avatar chevauchant.
                const SizedBox(height: 50),
                Text(
                  a.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: t.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${a.metier} · ${a.commune}, ${a.quartier}',
                  textAlign: TextAlign.center,
                  style: context.taSub,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (a.verified) TaBadge.verified(context),
                    TaBadge.neutral(
                      context,
                      label: a.dispo,
                      icon: TaIcons.clock,
                    ),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(top: 14),
                  padding: const EdgeInsets.only(top: 12, bottom: 2),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: t.border)),
                  ),
                  child: Row(
                    children: [
                      _stat(context, _formatNote(a.note), 'Note', star: true),
                      _stat(context, '${a.avis}', 'Avis', divider: true),
                      _stat(
                        context,
                        '${a.annees} ans',
                        'Expérience',
                        divider: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Avatar dans son cadre surface, chevauchant la cover.
        Positioned(
          top: -24,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: t.surface,
                borderRadius: BorderRadius.circular(86 * 0.36),
              ),
              child: TaAvatar(artisan: a, size: 76),
            ),
          ),
        ),
      ],
    );
  }

  Widget _stat(
    BuildContext context,
    String value,
    String label, {
    bool star = false,
    bool divider = false,
  }) {
    final t = context.ta;
    return Expanded(
      child: Container(
        decoration: divider
            ? BoxDecoration(
                border: Border(left: BorderSide(color: t.border)),
              )
            : null,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
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
            const SizedBox(height: 2),
            Text(label.toUpperCase(), style: context.taLabel),
          ],
        ),
      ),
    );
  }

  // ─── Sections ───

  Widget _aboutCard(BuildContext context, Artisan a) {
    final t = context.ta;
    return TaCard(
      padding: const EdgeInsets.all(TaDims.pad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('À PROPOS', style: context.taLabel),
          const SizedBox(height: 7),
          Text(
            a.bio,
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

  Widget _skillsCard(BuildContext context, Artisan a) {
    return TaCard(
      padding: const EdgeInsets.all(TaDims.pad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('COMPÉTENCES', style: context.taLabel),
          const SizedBox(height: 9),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final s in a.skills)
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
