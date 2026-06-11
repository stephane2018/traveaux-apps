import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/ta_tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/models.dart';
import '../../../providers/data_providers.dart';
import '../../../providers/projets_provider.dart';
import '../../../shared/widgets/widgets.dart';

/// Ouvre le détail d'un devis en bottom sheet (max 80 % · footer fixe).
Future<void> showDevisDetailSheet(
  BuildContext context, {
  required String devisId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _DevisDetailSheet(devisId: devisId),
  );
}

class _DevisDetailSheet extends ConsumerStatefulWidget {
  const _DevisDetailSheet({required this.devisId});

  final String devisId;

  @override
  ConsumerState<_DevisDetailSheet> createState() => _DevisDetailSheetState();
}

class _DevisDetailSheetState extends ConsumerState<_DevisDetailSheet> {
  /// Bascule sur l'étape « réserver l'intervention » après « J'accepte ».
  bool _booking = false;
  DateTime? _rdvDate;
  String _creneau = 'Matin';

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    final docs = ref.watch(devisDocsProvider);
    DevisDoc? devis;
    for (final d in docs) {
      if (d.id == widget.devisId) devis = d;
    }
    if (devis == null) return const SizedBox.shrink();
    final d = devis;
    final artisan = ref.watch(artisanProvider(d.artisanId));
    final bottomPad = MediaQuery.paddingOf(context).bottom;

    return ConstrainedBox(
      // Le sheet peut occuper jusqu'à 80 % de la hauteur d'écran.
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.8,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: t.bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            // ----- poignée -----
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: t.surface3,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            // ----- contenu scrollable -----
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  TaDims.pad,
                  14,
                  TaDims.pad,
                  16,
                ),
                child: _booking
                    ? _BookingBody(
                        artisan: artisan,
                        date: _rdvDate,
                        creneau: _creneau,
                        onPickDate: (date) => setState(() => _rdvDate = date),
                        onPickCreneau: (c) => setState(() => _creneau = c),
                      )
                    : _DevisBody(devis: d, artisan: artisan),
              ),
            ),
            // ----- footer fixe (boutons collés en bas) -----
            _Footer(
              devis: d,
              booking: _booking,
              canConfirm: _rdvDate != null,
              bottomInset: bottomPad,
              onAccepterTap: () => setState(() {
                _booking = true;
                _rdvDate ??= _firstSlot();
              }),
              onRefuser: () =>
                  ref.read(devisDocsProvider.notifier).refuser(d.id),
              onConfirmRdv: () {
                final label = '${formatDateLongFr(_rdvDate!)} · $_creneau';
                ref.read(devisDocsProvider.notifier).accepter(d.id, rdv: label);
                setState(() => _booking = false);
              },
              onCancelBooking: () => setState(() => _booking = false),
            ),
          ],
        ),
      ),
    );
  }

  /// Premier créneau proposé : demain.
  static DateTime _firstSlot() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
  }
}

/// Corps « détail du devis » : artisan, lignes, total, rendez-vous éventuel.
class _DevisBody extends StatelessWidget {
  const _DevisBody({required this.devis, required this.artisan});

  final DevisDoc devis;
  final Artisan artisan;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    final d = devis;
    final accepte = d.statut == DevisStatut.accepte;
    final refuse = d.statut == DevisStatut.refuse;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          spacing: 11,
          children: [
            TaAvatar(artisan: artisan, size: 48),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    spacing: 5,
                    children: [
                      Flexible(
                        child: Text(
                          artisan.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: t.text,
                          ),
                        ),
                      ),
                      if (artisan.verified)
                        const TaIcon(TaIcons.badge, size: 14),
                    ],
                  ),
                  Text(
                    artisan.metier,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.taSub,
                  ),
                ],
              ),
            ),
            if (accepte)
              TaBadge(
                label: 'Accepté',
                background: t.primary,
                foreground: t.primaryInk,
                icon: TaIcons.check,
              )
            else if (refuse)
              TaBadge(
                label: 'Refusé',
                background: t.surface2,
                foreground: t.danger,
                icon: TaIcons.close,
              ),
          ],
        ),
        const SizedBox(height: 14),
        Text(d.titre, style: context.taH2),
        const SizedBox(height: 4),
        Text(d.description, style: context.taSub.copyWith(height: 1.55)),
        // ----- rendez-vous réservé -----
        if (accepte && d.rdv != null) ...[
          const SizedBox(height: 12),
          TaCard(
            color: t.primarySoft,
            border: false,
            shadow: false,
            padding: const EdgeInsets.all(12),
            child: Row(
              spacing: 10,
              children: [
                TaIconBox(
                  icon: TaIcons.calendar,
                  size: 34,
                  radius: 10,
                  iconSize: 16,
                  background: t.surface,
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Intervention prévue',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: t.primary,
                        ),
                      ),
                      Text(
                        d.rdv!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: TaDims.fsSm,
                          fontWeight: FontWeight.w800,
                          color: t.text,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        // ----- lignes du devis -----
        const SizedBox(height: 14),
        TaCard(
          padding: const EdgeInsets.symmetric(
            horizontal: TaDims.pad,
            vertical: 6,
          ),
          child: Column(
            children: [
              for (var i = 0; i < d.lignes.length; i++) ...[
                if (i > 0) const TaDivider(),
                _LigneRow(ligne: d.lignes[i]),
              ],
            ],
          ),
        ),
        // ----- total -----
        const SizedBox(height: 10),
        TaCard(
          color: t.primarySoft,
          border: false,
          shadow: false,
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Text(
                'Total',
                style: TextStyle(
                  fontSize: TaDims.fsSm,
                  fontWeight: FontWeight.w800,
                  color: t.primary,
                ),
              ),
              const Spacer(),
              Text(
                formatFcfa(d.total),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: t.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Corps « réserver l'intervention » : choix de la date et du créneau.
class _BookingBody extends StatelessWidget {
  const _BookingBody({
    required this.artisan,
    required this.date,
    required this.creneau,
    required this.onPickDate,
    required this.onPickCreneau,
  });

  final Artisan artisan;
  final DateTime? date;
  final String creneau;
  final ValueChanged<DateTime> onPickDate;
  final ValueChanged<String> onPickCreneau;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    final today = DateTime.now();
    final start = DateTime(today.year, today.month, today.day);
    // 14 prochains jours, à partir de demain.
    final days = [for (var i = 1; i <= 14; i++) start.add(Duration(days: i))];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Réserver l’intervention', style: context.taH2),
        const SizedBox(height: 4),
        Text(
          'Choisissez la date des travaux avec ${artisan.name}.',
          style: context.taSub.copyWith(height: 1.5),
        ),
        const SizedBox(height: 16),
        const _SectionLabel('DATE D’INTERVENTION'),
        const SizedBox(height: 10),
        SizedBox(
          height: 78,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: days.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final day = days[i];
              final selected =
                  date != null &&
                  day.year == date!.year &&
                  day.month == date!.month &&
                  day.day == date!.day;
              return _DateCard(
                day: day,
                selected: selected,
                onTap: () => onPickDate(day),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        const _SectionLabel('CRÉNEAU'),
        const SizedBox(height: 10),
        Row(
          spacing: 8,
          children: [
            for (final c in const ['Matin', 'Après-midi'])
              Expanded(
                child: _CreneauChip(
                  label: c,
                  selected: creneau == c,
                  onTap: () => onPickCreneau(c),
                ),
              ),
          ],
        ),
        const SizedBox(height: 14),
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
                  'L’artisan confirmera le rendez-vous. Vous pourrez le '
                  'replanifier depuis Messages.',
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

/// Carte d'un jour sélectionnable (réservation).
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
        width: 60,
        padding: const EdgeInsets.symmetric(vertical: 10),
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
                fontSize: 19,
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

/// Choix de créneau (Matin / Après-midi).
class _CreneauChip extends StatelessWidget {
  const _CreneauChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? t.primarySoft : t.surface,
          borderRadius: BorderRadius.circular(TaDims.rPill),
          border: Border.all(
            color: selected ? t.primary : t.borderStrong,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: TaDims.fsSm,
            fontWeight: FontWeight.w700,
            color: selected ? t.primary : t.text2,
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Text(text, style: context.taLabel);
}

/// Footer fixe : actions selon le statut / l'étape de réservation.
class _Footer extends StatelessWidget {
  const _Footer({
    required this.devis,
    required this.booking,
    required this.canConfirm,
    required this.bottomInset,
    required this.onAccepterTap,
    required this.onRefuser,
    required this.onConfirmRdv,
    required this.onCancelBooking,
  });

  final DevisDoc devis;
  final bool booking;
  final bool canConfirm;
  final double bottomInset;
  final VoidCallback onAccepterTap;
  final VoidCallback onRefuser;
  final VoidCallback onConfirmRdv;
  final VoidCallback onCancelBooking;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
        TaDims.pad,
        12,
        TaDims.pad,
        16 + bottomInset,
      ),
      decoration: BoxDecoration(
        color: t.surface,
        border: Border(top: BorderSide(color: t.border)),
      ),
      child: _content(context, t),
    );
  }

  Widget _content(BuildContext context, TaTokens t) {
    // Étape de réservation : annuler / confirmer.
    if (booking) {
      return Row(
        spacing: 8,
        children: [
          Expanded(
            child: TaButton(
              label: 'Retour',
              variant: TaButtonVariant.outline,
              onPressed: onCancelBooking,
            ),
          ),
          Expanded(
            flex: 2,
            child: Opacity(
              opacity: canConfirm ? 1 : 0.5,
              child: TaButton(
                label: 'Confirmer le rendez-vous',
                variant: TaButtonVariant.primary,
                onPressed: canConfirm ? onConfirmRdv : null,
                leading: TaIcon(
                  TaIcons.calendar,
                  size: 15,
                  mono: true,
                  color: TaButton.inkColor(context, TaButtonVariant.primary),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return switch (devis.statut) {
      DevisStatut.propose => Row(
        spacing: 8,
        children: [
          Expanded(
            child: TaButton(
              label: 'Refuser',
              variant: TaButtonVariant.outline,
              onPressed: onRefuser,
            ),
          ),
          Expanded(
            child: TaButton(
              label: 'J’accepte',
              variant: TaButtonVariant.primary,
              onPressed: onAccepterTap,
              leading: TaIcon(
                TaIcons.check,
                size: 15,
                mono: true,
                color: TaButton.inkColor(context, TaButtonVariant.primary),
              ),
            ),
          ),
        ],
      ),
      DevisStatut.accepte => Row(
        spacing: 8,
        children: [
          TaIcon(TaIcons.check, size: 18, mono: true, color: t.primary),
          Expanded(
            child: Text(
              devis.rdv != null ? 'Accepté · ${devis.rdv}' : 'Devis accepté',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: TaDims.fsSm,
                fontWeight: FontWeight.w800,
                color: t.primary,
              ),
            ),
          ),
        ],
      ),
      DevisStatut.refuse => Row(
        spacing: 8,
        children: [
          TaIcon(TaIcons.close, size: 18, mono: true, color: t.text3),
          Text(
            'Devis refusé',
            style: TextStyle(
              fontSize: TaDims.fsSm,
              fontWeight: FontWeight.w800,
              color: t.text3,
            ),
          ),
        ],
      ),
    };
  }
}

/// Rangée label/valeur d'une ligne de devis.
class _LigneRow extends StatelessWidget {
  const _LigneRow({required this.ligne});

  final DevisLigne ligne;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    final montant = ligne.montant;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        spacing: 10,
        children: [
          Expanded(
            child: Text(
              ligne.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: t.text2,
              ),
            ),
          ),
          Text(
            montant != null ? '${formatNumber(montant)} F' : ligne.valeur,
            style: TextStyle(
              fontSize: montant != null ? TaDims.fsSm : 12.5,
              fontWeight: montant != null ? FontWeight.w800 : FontWeight.w700,
              color: t.text,
            ),
          ),
        ],
      ),
    );
  }
}
