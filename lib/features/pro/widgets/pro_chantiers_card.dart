import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/ta_tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/models.dart';
import '../../../providers/projets_provider.dart';
import '../../../shared/widgets/widgets.dart';

/// Carte « Chantiers en cours » de l'artisan : marquer terminé, voir la note
/// du client et le paiement en attente de validation.
class ProChantiersCard extends ConsumerWidget {
  const ProChantiersCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.ta;
    final chantiers = ref.watch(chantiersProvider);
    final enAttente = ref.watch(paiementEnAttenteProvider);
    if (chantiers.isEmpty) return const SizedBox.shrink();

    return TaCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Chantiers en cours',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: t.text,
                  ),
                ),
              ),
              Text(
                '${chantiers.length}',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: t.text3,
                ),
              ),
            ],
          ),
          // Bandeau paiement en attente.
          if (enAttente > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: t.accentSoft,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                spacing: 10,
                children: [
                  TaIconBox(
                    icon: TaIcons.wallet,
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
                          'Paiement en attente',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: t.accentStrong,
                          ),
                        ),
                        Text(
                          formatFcfa(enAttente),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: TaDims.fs,
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
          const SizedBox(height: 6),
          for (final c in chantiers) ...[
            const TaDivider(margin: EdgeInsets.symmetric(vertical: 10)),
            _ChantierRow(chantier: c),
          ],
        ],
      ),
    );
  }
}

class _ChantierRow extends ConsumerWidget {
  const _ChantierRow({required this.chantier});

  final Chantier chantier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.ta;
    final p = chantier.projet;
    final montant = chantier.devis.total;
    final enValidation = p.statut == ProjetStatut.enValidation;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          spacing: 11,
          children: [
            TaIconBox(
              icon: TaIcons.wrench,
              size: 40,
              radius: 12,
              iconSize: 18,
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
                      fontWeight: FontWeight.w800,
                      fontSize: TaDims.fsSm,
                      color: t.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${p.commune} · ${formatFcfa(montant)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.taSub.copyWith(fontSize: 11.5),
                  ),
                ],
              ),
            ),
            _statutBadge(context, p),
          ],
        ),
        // Avis du client.
        if (p.clientConfirmed) ...[
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(11),
            decoration: BoxDecoration(
              color: t.surface2,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: 8,
                  children: [
                    Text(
                      'Avis du client',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: t.text2,
                      ),
                    ),
                    const Spacer(),
                    TaStars(note: p.clientNote!.toDouble(), size: 13),
                  ],
                ),
                if (p.clientComment != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    '« ${p.clientComment!} »',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      height: 1.45,
                      fontStyle: FontStyle.italic,
                      color: t.text2,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: 10),
        // Action / état.
        if (enValidation)
          Row(
            spacing: 8,
            children: [
              TaIcon(TaIcons.shield, size: 16, mono: true, color: t.text3),
              Expanded(
                child: Text(
                  'En attente de validation par l’administration',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: t.text2,
                  ),
                ),
              ),
            ],
          )
        else if (p.statut == ProjetStatut.termine)
          Row(
            spacing: 8,
            children: [
              TaIcon(TaIcons.check, size: 16, mono: true, color: t.primary),
              Text(
                'Terminé · payé',
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: t.primary,
                ),
              ),
            ],
          )
        else if (!p.artisanDone)
          TaButton(
            label: 'Marquer le travail terminé',
            variant: TaButtonVariant.primary,
            small: true,
            expanded: true,
            onPressed: () => ref
                .read(projetsProvider.notifier)
                .markArtisanDone(p.id, preuves: kDefaultPreuves),
            leading: TaIcon(
              TaIcons.check,
              size: 14,
              mono: true,
              color: TaButton.inkColor(context, TaButtonVariant.primary),
            ),
          )
        else
          Row(
            spacing: 8,
            children: [
              TaIcon(TaIcons.clock, size: 16, mono: true, color: t.text3),
              Expanded(
                child: Text(
                  'Terminé de votre côté · en attente du client',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: t.text2,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _statutBadge(BuildContext context, Projet p) {
    final t = context.ta;
    if (p.statut == ProjetStatut.enValidation) {
      return TaBadge(
        label: 'Validation',
        background: t.surface2,
        foreground: t.text2,
        icon: TaIcons.shield,
      );
    }
    if (p.statut == ProjetStatut.termine) {
      return TaBadge(
        label: 'Terminé',
        background: t.primary,
        foreground: t.primaryInk,
        icon: TaIcons.check,
      );
    }
    return TaBadge(
      label: 'En cours',
      background: t.primarySoft,
      foreground: t.primary,
      icon: TaIcons.wrench,
    );
  }
}
