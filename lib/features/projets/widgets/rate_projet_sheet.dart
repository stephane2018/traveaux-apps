import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/ta_tokens.dart';
import '../../../providers/data_providers.dart';
import '../../../providers/projets_provider.dart';
import '../../../shared/widgets/widgets.dart';

/// Bottom sheet : le client confirme la bonne réalisation et note l'artisan.
Future<void> showRateProjetSheet(
  BuildContext context, {
  required String projetId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _RateProjetSheet(projetId: projetId),
  );
}

class _RateProjetSheet extends ConsumerStatefulWidget {
  const _RateProjetSheet({required this.projetId});

  final String projetId;

  @override
  ConsumerState<_RateProjetSheet> createState() => _RateProjetSheetState();
}

class _RateProjetSheetState extends ConsumerState<_RateProjetSheet> {
  int _note = 0;
  final _comment = TextEditingController();

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  void _submit() {
    if (_note == 0) return;
    ref
        .read(projetsProvider.notifier)
        .confirmByClient(
          widget.projetId,
          note: _note,
          comment: _comment.text.trim().isEmpty ? null : _comment.text.trim(),
        );
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: context.ta.primary,
        margin: const EdgeInsets.all(TaDims.pad),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TaDims.rPill),
        ),
        content: Text(
          'Merci ! Votre évaluation a été enregistrée.',
          style: TextStyle(
            color: context.ta.primaryInk,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    final projet = ref.watch(projetProvider(widget.projetId));
    final devis = ref.watch(devisAccepteProvider(widget.projetId));
    final artisan = devis == null
        ? null
        : ref.watch(artisanProvider(devis.artisanId));
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final safeBottom = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        padding: EdgeInsets.fromLTRB(
          TaDims.pad,
          12,
          TaDims.pad,
          20 + safeBottom,
        ),
        decoration: BoxDecoration(
          color: t.bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: t.surface3,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Travaux terminés ?', style: context.taH2),
            const SizedBox(height: 4),
            Text(
              artisan != null
                  ? 'Confirmez la bonne réalisation et notez ${artisan.name}.'
                  : 'Confirmez la bonne réalisation et notez l’artisan.',
              style: context.taSub.copyWith(height: 1.5),
            ),
            const SizedBox(height: 18),
            // ----- étoiles sélectionnables -----
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 1; i <= 5; i++)
                    GestureDetector(
                      onTap: () => setState(() => _note = i),
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: TaIcon(
                          TaIcons.star,
                          size: 38,
                          mono: i > _note,
                          color: t.borderStrong,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 6),
            Center(
              child: Text(
                _noteLabel(_note),
                style: TextStyle(
                  fontSize: TaDims.fsSm,
                  fontWeight: FontWeight.w700,
                  color: _note == 0 ? t.text3 : t.primary,
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text('UN COMMENTAIRE ? (FACULTATIF)', style: context.taLabel),
            const SizedBox(height: 9),
            TaInput(
              controller: _comment,
              maxLines: 3,
              hint: 'Ponctualité, qualité du travail, propreté…',
            ),
            const SizedBox(height: 12),
            TaCard(
              color: t.primarySoft,
              border: false,
              shadow: false,
              padding: const EdgeInsets.all(12),
              child: Row(
                spacing: 10,
                children: [
                  const TaIcon(TaIcons.shield, size: 18),
                  Expanded(
                    child: Text(
                      'Le paiement sera libéré à l’artisan après validation '
                      'par l’administration.',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        height: 1.45,
                        color: t.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Opacity(
              opacity: _note == 0 ? 0.5 : 1,
              child: TaButton(
                label: 'Confirmer & noter',
                expanded: true,
                onPressed: _note == 0 ? null : _submit,
                leading: TaIcon(
                  TaIcons.check,
                  size: 16,
                  mono: true,
                  color: TaButton.inkColor(context, TaButtonVariant.cta),
                ),
              ),
            ),
            // Réserve l'espace si jamais le projet disparaît.
            if (projet == null) const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }

  static String _noteLabel(int n) => switch (n) {
    0 => 'Touchez les étoiles pour noter',
    1 => 'Très insuffisant',
    2 => 'Insuffisant',
    3 => 'Correct',
    4 => 'Très bien',
    _ => 'Excellent !',
  };
}
