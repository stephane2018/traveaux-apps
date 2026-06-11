import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/ta_tokens.dart';
import '../../../providers/data_providers.dart';
import '../../../shared/widgets/widgets.dart';

/// Ouvre la feuille « Nouvelle réalisation » (publication d'un chantier).
Future<void> showAddRealisationSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const _AddRealisationSheet(),
  );
}

/// Choix figés du formulaire de réalisation.
const _types = [
  'Rénovation complète',
  'Installation',
  'Réparation',
  'Construction neuve',
  'Entretien',
];
const _durees = [
  '1 jour',
  '2-3 jours',
  '1 semaine',
  '2-3 semaines',
  'Plus d’1 mois',
];

class _AddRealisationSheet extends ConsumerStatefulWidget {
  const _AddRealisationSheet();

  @override
  ConsumerState<_AddRealisationSheet> createState() =>
      _AddRealisationSheetState();
}

class _AddRealisationSheetState extends ConsumerState<_AddRealisationSheet> {
  final _titreCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  String _type = _types.first;
  String _duree = _durees.first;
  String _commune = '';
  bool _canPublish = false;

  @override
  void initState() {
    super.initState();
    // Active le CTA dès qu'un titre est saisi.
    _titreCtrl.addListener(() {
      final ok = _titreCtrl.text.trim().isNotEmpty;
      if (ok != _canPublish) setState(() => _canPublish = ok);
    });
  }

  @override
  void dispose() {
    _titreCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _publish() {
    ref
        .read(realisationsProvider.notifier)
        .add(
          titre: _titreCtrl.text.trim(),
          type: _type,
          duree: _duree,
          commune: _commune,
          description: _descCtrl.text.trim(),
        );
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: context.ta.primary,
        content: const Text('Réalisation publiée'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    final media = MediaQuery.of(context);
    final communes = ref.watch(communesProvider);
    if (_commune.isEmpty && communes.isNotEmpty) _commune = communes.first;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: media.size.height * 0.85),
      child: Container(
        decoration: BoxDecoration(
          color: t.bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          20 + media.viewInsets.bottom + media.padding.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Poignée.
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
              Text('Nouvelle réalisation', style: context.taH2),
              const SizedBox(height: 4),
              Text(
                'Présentez un chantier réussi à vos futurs clients',
                style: context.taSub,
              ),
              const SizedBox(height: 18),

              // ----- photos avant / après -----
              Text('PHOTOS AVANT / APRÈS', style: context.taLabel),
              const SizedBox(height: 10),
              const TaBeforeAfter(height: 120),
              const SizedBox(height: 10),
              Row(
                spacing: 10,
                children: [
                  Expanded(
                    child: TaPhoto(height: 64, icon: TaIcons.camera, tone: 1),
                  ),
                  Expanded(
                    child: TaPhoto(height: 64, icon: TaIcons.camera, tone: 2),
                  ),
                  Expanded(child: _AddTile(onTap: () {})),
                ],
              ),
              const SizedBox(height: 18),

              // ----- titre -----
              Text('TITRE', style: context.taLabel),
              const SizedBox(height: 8),
              TaInput(
                controller: _titreCtrl,
                hint: 'Ex. : Rénovation salle de bain',
              ),
              const SizedBox(height: 18),

              // ----- type de travaux -----
              Text('TYPE DE TRAVAUX', style: context.taLabel),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final type in _types)
                    TaChip(
                      label: type,
                      active: _type == type,
                      onTap: () => setState(() => _type = type),
                    ),
                ],
              ),
              const SizedBox(height: 18),

              // ----- commune -----
              Text('COMMUNE', style: context.taLabel),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in communes.take(8))
                    TaChip(
                      label: c,
                      active: _commune == c,
                      onTap: () => setState(() => _commune = c),
                    ),
                ],
              ),
              const SizedBox(height: 18),

              // ----- durée -----
              Text('DURÉE', style: context.taLabel),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final d in _durees)
                    TaChip(
                      label: d,
                      active: _duree == d,
                      onTap: () => setState(() => _duree = d),
                    ),
                ],
              ),
              const SizedBox(height: 18),

              // ----- description -----
              Text('DESCRIPTION', style: context.taLabel),
              const SizedBox(height: 8),
              TaInput(
                controller: _descCtrl,
                maxLines: 3,
                hint: 'Décrivez le chantier, les matériaux, le résultat…',
              ),
              const SizedBox(height: 20),

              // ----- CTA -----
              Opacity(
                opacity: _canPublish ? 1 : 0.5,
                child: TaButton(
                  label: 'Publier la réalisation',
                  expanded: true,
                  onPressed: _canPublish ? _publish : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Case d'ajout pointillée (placeholder « + »).
class _AddTile extends StatelessWidget {
  const _AddTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 64,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: BorderRadius.circular(TaDims.rCard - 6),
          border: Border.all(color: t.borderStrong),
        ),
        child: TaIcon(TaIcons.plus, size: 18, mono: true, color: t.text3),
      ),
    );
  }
}
