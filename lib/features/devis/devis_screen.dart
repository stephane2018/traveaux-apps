import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/ta_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../data/mock_data.dart';
import '../../data/models/models.dart';
import '../../providers/data_providers.dart';
import '../../providers/devis_provider.dart';
import '../../providers/projets_provider.dart';
import '../../shared/widgets/widgets.dart';

/// Écran « Demande de devis » : formulaire en 3 étapes (Projet, Détails, Envoyé).
class DevisScreen extends ConsumerStatefulWidget {
  const DevisScreen({super.key, this.initialCat});

  final String? initialCat;

  @override
  ConsumerState<DevisScreen> createState() => _DevisScreenState();
}

class _DevisScreenState extends ConsumerState<DevisScreen> {
  static const _steps = ['Projet', 'Détails', 'Envoyé'];

  @override
  void initState() {
    super.initState();
    _seedCat();
  }

  @override
  void didUpdateWidget(DevisScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCat != oldWidget.initialCat) _seedCat();
  }

  /// Formulaire neuf à chaque ouverture, catégorie pré-sélectionnée si
  /// fournie. Différé : Riverpod interdit la mutation pendant le build.
  void _seedCat() {
    Future.microtask(() {
      if (!mounted) return;
      final notifier = ref.read(devisFormProvider.notifier);
      notifier.reset();
      if (widget.initialCat != null) notifier.start(cat: widget.initialCat);
    });
  }

  void _onBack(DevisForm form) {
    if (form.step > 0 && form.step < 2) {
      ref.read(devisFormProvider.notifier).back();
    } else {
      context.pop();
    }
  }

  /// « Envoyer ma demande » : crée le projet côté client puis passe à
  /// l'écran de confirmation.
  void _onNext(DevisForm form) {
    final notifier = ref.read(devisFormProvider.notifier);
    if (form.step == 1) {
      final cat = MockData.categoryById(form.cat);
      ref
          .read(projetsProvider.notifier)
          .addProjet(
            titre: '${cat?.label ?? 'Travaux'} — ${form.commune}',
            description: form.description,
            cat: form.cat,
            commune: form.commune,
            urgence: planningLabel(form),
            budget: form.budget,
          );
    }
    notifier.next();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    final form = ref.watch(devisFormProvider);
    final topPad = MediaQuery.paddingOf(context).top;

    return TaStatusBar(
      child: Scaffold(
        body: Stack(
          children: [
            Column(
              children: [
                // ----- en-tête : retour, titre, stepper -----
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(
                    TaDims.pad,
                    topPad + 16,
                    TaDims.pad,
                    14,
                  ),
                  decoration: BoxDecoration(
                    color: t.surface,
                    border: Border(bottom: BorderSide(color: t.border)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        spacing: 10,
                        children: [
                          TaSquareButton(
                            onTap: () => _onBack(form),
                            background: t.surface,
                            borderColor: t.borderStrong,
                            child: TaIcon(
                              form.step == 2
                                  ? TaIcons.close
                                  : TaIcons.arrowLeft,
                              size: 17,
                              mono: true,
                              color: t.text,
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Quel est votre projet ?',
                                  style: context.taH2,
                                ),
                                Text(
                                  'Gratuit · jusqu’à 3 devis sous 24 h',
                                  style: context.taSub,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Row(
                        spacing: 6,
                        children: [
                          for (final (i, label) in _steps.indexed)
                            Expanded(
                              child: _StepperSegment(
                                label: '${i + 1}. $label',
                                active: i <= form.step,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                // ----- corps de l'étape -----
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      TaDims.pad,
                      TaDims.pad,
                      TaDims.pad,
                      130,
                    ),
                    child: switch (form.step) {
                      0 => _StepProjet(form: form),
                      1 => _StepDetails(form: form),
                      _ => _StepEnvoye(form: form),
                    },
                  ),
                ),
              ],
            ),
            // ----- barre CTA -----
            if (form.step < 2)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: TaBottomCtaBar(
                  child: TaButton(
                    label: form.step == 0 ? 'Continuer' : 'Envoyer ma demande',
                    expanded: true,
                    trailing: TaIcon(
                      TaIcons.arrowRight,
                      size: 17,
                      mono: true,
                      color: TaButton.inkColor(context, TaButtonVariant.cta),
                    ),
                    onPressed: () => _onNext(form),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Segment du stepper : barre animée + numéro d'étape.
class _StepperSegment extends StatelessWidget {
  const _StepperSegment({required this.label, required this.active});

  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 5,
          decoration: BoxDecoration(
            color: active ? t.primary : t.surface3,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: active ? t.primary : t.text3,
          ),
        ),
      ],
    );
  }
}

/// Libellé de champ `.ta-label` (capitales).
class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Text(text.toUpperCase(), style: context.taLabel),
    );
  }
}

// ─── Étape 0 : Projet ───
class _StepProjet extends ConsumerWidget {
  const _StepProjet({required this.form});

  final DevisForm form;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.ta;
    final categories = ref.watch(categoriesProvider);
    final notifier = ref.read(devisFormProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: TaDims.gap + 4,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _FieldLabel('Type de travaux'),
            Column(
              spacing: 9,
              children: [
                for (var i = 0; i < categories.length; i += 2)
                  Row(
                    spacing: 9,
                    children: [
                      Expanded(
                        child: _CategoryButton(
                          category: categories[i],
                          selected: form.cat == categories[i].id,
                          onTap: () => notifier.setCat(categories[i].id),
                        ),
                      ),
                      Expanded(
                        child: i + 1 < categories.length
                            ? _CategoryButton(
                                category: categories[i + 1],
                                selected: form.cat == categories[i + 1].id,
                                onTap: () =>
                                    notifier.setCat(categories[i + 1].id),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ],
                  ),
              ],
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _FieldLabel('Décrivez le travail à faire'),
            TaInput(
              maxLines: 4,
              initialValue: kDefaultDevisDescription,
              onChanged: ref.read(devisFormProvider.notifier).setDescription,
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 9),
              child: Text.rich(
                TextSpan(
                  style: context.taLabel,
                  children: [
                    const TextSpan(text: 'PHOTOS DU CHANTIER '),
                    TextSpan(
                      text: '(recommandé)',
                      style: context.taLabel.copyWith(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              spacing: 9,
              children: [
                const Expanded(
                  child: TaPhoto(height: 86, tone: 1, icon: TaIcons.camera),
                ),
                const Expanded(
                  child: TaPhoto(height: 86, tone: 2, icon: TaIcons.camera),
                ),
                Expanded(
                  child: SizedBox(
                    height: 86,
                    child: CustomPaint(
                      painter: _DashedRRectPainter(color: t.borderStrong),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        spacing: 4,
                        children: [
                          TaIcon(
                            TaIcons.plus,
                            size: 17,
                            mono: true,
                            color: t.text3,
                          ),
                          Text(
                            'Ajouter',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: t.text3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

/// Bouton de sélection de catégorie (grille 2 colonnes).
class _CategoryButton extends StatelessWidget {
  const _CategoryButton({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final TaCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? t.primarySoft : t.surface,
          borderRadius: BorderRadius.circular(TaDims.rCard - 4),
          border: Border.all(
            color: selected ? t.primary : t.border,
            width: 1.5,
          ),
        ),
        child: Row(
          spacing: 9,
          children: [
            TaIcon(category.icon, size: 19),
            Expanded(
              child: Text(
                category.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: TaDims.fsSm,
                  fontWeight: FontWeight.w700,
                  color: selected ? t.primary : t.text2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bordure pointillée (case « Ajouter » une photo).
class _DashedRRectPainter extends CustomPainter {
  const _DashedRRectPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          (Offset.zero & size).deflate(1),
          const Radius.circular(TaDims.rCard - 6),
        ),
      );
    const dash = 6.0;
    const space = 5.0;
    for (final metric in path.computeMetrics()) {
      var d = 0.0;
      while (d < metric.length) {
        canvas.drawPath(metric.extractPath(d, d + dash), paint);
        d += dash + space;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedRRectPainter oldDelegate) =>
      oldDelegate.color != color;
}

// ─── Étape 1 : Détails ───
class _StepDetails extends ConsumerWidget {
  const _StepDetails({required this.form});

  final DevisForm form;

  static const _urgences = [
    (label: 'Urgent (24 h)', icon: TaIcons.bolt, urgent: true),
    (label: 'Cette semaine', icon: TaIcons.calendar, urgent: false),
    (label: 'Ce mois-ci', icon: TaIcons.calendar, urgent: false),
    (label: 'Je planifie', icon: TaIcons.clock, urgent: false),
  ];

  static const _budgets = [
    'Moins de 15 000 F',
    '15 000 – 50 000 F',
    '50 000 – 150 000 F',
    'Plus de 150 000 F',
    'Je ne sais pas',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.ta;
    final communes = ref.watch(communesProvider).take(8);
    final notifier = ref.read(devisFormProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: TaDims.gap + 4,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _FieldLabel('Commune'),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                for (final co in communes)
                  TaChip(
                    label: co,
                    active: form.commune == co,
                    onTap: () => notifier.setCommune(co),
                  ),
              ],
            ),
          ],
        ),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _FieldLabel('Quartier / repère'),
            TaInput(
              maxLines: 3,
              initialValue:
                  'Angré 7e tranche, près de la pharmacie Saint-Viateur. '
                  'Portail bleu, 2e étage. Sonner à l’interphone « Koné ».',
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _FieldLabel('C’est urgent ?'),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                for (final u in _urgences)
                  _UrgenceChip(
                    label: u.label,
                    icon: u.icon,
                    urgent: u.urgent,
                    active: form.urgence == u.label,
                    onTap: () => notifier.setUrgence(u.label),
                  ),
              ],
            ),
            // ----- planification (si non urgent) -----
            if (form.isPlanifiable) _PlanifBlock(form: form),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _FieldLabel('Budget estimé'),
            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                for (final b in _budgets)
                  TaChip(
                    label: b,
                    active: form.budget == b,
                    onTap: () => notifier.setBudget(b),
                  ),
              ],
            ),
          ],
        ),

        TaCard(
          padding: const EdgeInsets.all(12),
          color: t.primarySoft,
          border: false,
          shadow: false,
          child: Row(
            spacing: 10,
            children: [
              const TaIcon(TaIcons.shield, size: 18),
              Expanded(
                child: Text(
                  'Votre numéro reste privé jusqu’à ce que vous acceptiez '
                  'un devis.',
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
      ],
    );
  }
}

/// Libellé d'urgence enrichi de la planification, pour le projet créé.
/// « Cette semaine · le 18 juin » ou « Je planifie · 3 à 4 semaines ».
String planningLabel(DevisForm form) {
  if (!form.isPlanifiable) return form.urgence;
  if (form.planifMode == PlanifMode.periode) {
    return form.planifPeriode != null
        ? '${form.urgence} · ${form.planifPeriode}'
        : form.urgence;
  }
  return form.planifDate != null
      ? '${form.urgence} · le ${form.planifDate!.day} '
            '${monthShortFr(form.planifDate!)}'
      : form.urgence;
}

/// Chip d'urgence avec icône ; « Urgent » prend la couleur danger active.
class _UrgenceChip extends StatelessWidget {
  const _UrgenceChip({
    required this.label,
    required this.icon,
    required this.urgent,
    required this.active,
    required this.onTap,
  });

  final String label;
  final TaIcons icon;
  final bool urgent;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    // Urgent actif : rouge ; autre actif : vert ; inactif : surface.
    final bg = active
        ? (urgent ? t.danger : t.primary)
        : (urgent ? t.accentSoft : t.surface);
    final fg = active ? Colors.white : (urgent ? t.danger : t.text2);
    final border = active
        ? (urgent ? t.danger : t.primary)
        : (urgent ? t.danger.withValues(alpha: 0.3) : t.borderStrong);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(TaDims.rPill),
          border: Border.all(color: border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 6,
          children: [
            TaIcon(icon, size: 14, mono: true, color: fg),
            Text(
              label,
              style: TextStyle(
                fontSize: TaDims.fsSm,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bloc de planification d'un travail non urgent : date précise ou période.
class _PlanifBlock extends ConsumerWidget {
  const _PlanifBlock({required this.form});

  final DevisForm form;

  static const _periodes = [
    'Moins d’1 semaine',
    '1 à 2 semaines',
    '3 à 4 semaines',
    'Plus d’1 mois',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.ta;
    final notifier = ref.read(devisFormProvider.notifier);
    final dateMode = form.planifMode == PlanifMode.date;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: TaCard(
        color: t.surface,
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sélecteur date / période.
            TaSegmented<PlanifMode>(
              value: form.planifMode,
              expand: true,
              activeShadow: true,
              background: t.surface2,
              activeBackground: t.surface,
              activeForeground: t.text,
              height: 36,
              fontSize: TaDims.fsSm,
              onChanged: notifier.setPlanifMode,
              options: const [
                TaSegmentOption(PlanifMode.date, 'Une date'),
                TaSegmentOption(PlanifMode.periode, 'Une période'),
              ],
            ),
            const SizedBox(height: 14),
            if (dateMode) ...[
              Text('Quel jour ?', style: context.taLabel),
              const SizedBox(height: 10),
              _DatePicker(
                selected: form.planifDate,
                onPick: notifier.setPlanifDate,
              ),
            ] else ...[
              Row(
                spacing: 6,
                children: [
                  Text('DURÉE ESTIMÉE', style: context.taLabel),
                  Text(
                    '· travail vaste',
                    style: context.taLabel.copyWith(
                      letterSpacing: 0,
                      color: t.text3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 7,
                runSpacing: 7,
                children: [
                  for (final p in _periodes)
                    TaChip(
                      label: p,
                      active: form.planifPeriode == p,
                      onTap: () => notifier.setPlanifPeriode(p),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Sélecteur de date horizontal (21 prochains jours, à partir de demain).
class _DatePicker extends StatelessWidget {
  const _DatePicker({required this.selected, required this.onPick});

  final DateTime? selected;
  final ValueChanged<DateTime> onPick;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    final days = [for (var i = 1; i <= 21; i++) start.add(Duration(days: i))];

    return SizedBox(
      height: 76,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final day = days[i];
          final on =
              selected != null &&
              day.year == selected!.year &&
              day.month == selected!.month &&
              day.day == selected!.day;
          return _DateCard(day: day, selected: on, onTap: () => onPick(day));
        },
      ),
    );
  }
}

/// Carte d'un jour sélectionnable.
class _DateCard extends StatelessWidget {
  const _DateCard({
    required this.day,
    required this.selected,
    required this.onTap,
  });

  final DateTime day;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 58,
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: selected ? t.primary : t.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? t.primary : t.borderStrong,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              weekdayShortFr(day),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: selected ? t.primaryInk : t.text3,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              '${day.day}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                height: 1,
                color: selected ? t.primaryInk : t.text,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              monthShortFr(day),
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: selected ? t.primaryInk : t.text3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Étape 2 : Envoyé ───
class _StepEnvoye extends ConsumerWidget {
  const _StepEnvoye({required this.form});

  final DevisForm form;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.ta;
    final catLabel = _categoryLabel(ref.watch(categoriesProvider), form.cat);

    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Column(
        spacing: 14,
        children: [
          Container(
            width: 84,
            height: 84,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: t.primarySoft,
              borderRadius: BorderRadius.circular(84 * 0.38),
            ),
            child: TaIcon(
              TaIcons.check,
              size: 40,
              mono: true,
              color: t.primary,
            ),
          ),
          Text(
            'Demande envoyée !',
            style: context.taH1.copyWith(fontSize: 22, letterSpacing: -0.44),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 270),
            child: Text.rich(
              TextSpan(
                style: context.taSub,
                children: [
                  const TextSpan(text: '3 artisans '),
                  TextSpan(
                    text: catLabel,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  TextSpan(
                    text:
                        ' à ${form.commune} ont reçu votre demande. '
                        'Premier devis attendu sous 2 h.',
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: TaCard(
              padding: const EdgeInsets.all(TaDims.pad),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 10,
                children: [
                  Text('RÉCAPITULATIF', style: context.taLabel),
                  _recapRow(context, 'Catégorie', catLabel),
                  _recapRow(
                    context,
                    'Lieu',
                    '${form.commune}, Angré 7e tranche',
                  ),
                  _recapRow(context, 'Urgence', form.urgence),
                  _recapRow(context, 'Budget', form.budget),
                ],
              ),
            ),
          ),
          TaButton(
            label: 'Suivre dans Messages',
            variant: TaButtonVariant.soft,
            expanded: true,
            leading: const TaIcon(TaIcons.chat, size: 17),
            onPressed: () {
              ref.read(devisFormProvider.notifier).reset();
              context.go('/messages');
            },
          ),
        ],
      ),
    );
  }

  Widget _recapRow(BuildContext context, String label, String value) {
    final t = context.ta;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: TaDims.fsSm,
            fontWeight: FontWeight.w600,
            color: t.text2,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: TaDims.fsSm,
            fontWeight: FontWeight.w700,
            color: t.text,
          ),
        ),
      ],
    );
  }
}

/// Libellé d'une catégorie par id.
String _categoryLabel(List<TaCategory> categories, String id) {
  for (final c in categories) {
    if (c.id == id) return c.label;
  }
  return id;
}
