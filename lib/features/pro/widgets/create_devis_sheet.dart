import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/ta_tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../data/models/models.dart';
import '../../../providers/projets_provider.dart';
import '../../../shared/widgets/widgets.dart';

/// Ouvre le formulaire de création d'un devis structuré pour [demande].
Future<void> showCreateDevisSheet(
  BuildContext context, {
  required Demande demande,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    useSafeArea: true,
    builder: (ctx) => _CreateDevisSheet(demande: demande),
  );
}

/// Paire de contrôleurs d'une ligne clé/valeur du devis.
class _LigneCtrls {
  _LigneCtrls()
    : label = TextEditingController(),
      valeur = TextEditingController();

  final TextEditingController label;
  final TextEditingController valeur;

  void dispose() {
    label.dispose();
    valeur.dispose();
  }
}

class _CreateDevisSheet extends ConsumerStatefulWidget {
  const _CreateDevisSheet({required this.demande});

  final Demande demande;

  @override
  ConsumerState<_CreateDevisSheet> createState() => _CreateDevisSheetState();
}

class _CreateDevisSheetState extends ConsumerState<_CreateDevisSheet> {
  final _titreCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  // 2 lignes vides au départ.
  final List<_LigneCtrls> _lignes = [_LigneCtrls(), _LigneCtrls()];

  @override
  void dispose() {
    _titreCtrl.dispose();
    _descCtrl.dispose();
    for (final l in _lignes) {
      l.dispose();
    }
    super.dispose();
  }

  /// Somme des valeurs numériques (même logique que DevisLigne.montant).
  int get _total => _lignes.fold(
    0,
    (sum, l) =>
        sum +
        (DevisLigne(label: l.label.text, valeur: l.valeur.text).montant ?? 0),
  );

  bool get _canSend =>
      _titreCtrl.text.trim().isNotEmpty &&
      _lignes.any((l) => l.label.text.trim().isNotEmpty);

  void _send() {
    final lignes = [
      for (final l in _lignes)
        if (l.label.text.trim().isNotEmpty)
          DevisLigne(label: l.label.text.trim(), valeur: l.valeur.text.trim()),
    ];
    ref
        .read(devisDocsProvider.notifier)
        .addDevis(
          projetId: widget.demande.id,
          artisanId: 'a1',
          titre: _titreCtrl.text.trim(),
          description: _descCtrl.text.trim(),
          lignes: lignes,
        );

    final t = context.ta;
    // Le messenger est capturé avant le pop (context du sheet démonté après).
    final messenger = ScaffoldMessenger.of(context);
    Navigator.pop(context);
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: t.primary,
        shape: const StadiumBorder(),
        margin: const EdgeInsets.all(20),
        content: Text(
          'Devis envoyé à ${widget.demande.client}',
          style: TextStyle(fontWeight: FontWeight.w700, color: t.primaryInk),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    final media = MediaQuery.of(context);
    final demande = widget.demande;

    // Collé en bas, largeur limitée sur tablette.
    return Center(
      heightFactor: 1,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 560,
          maxHeight: media.size.height * 0.9,
        ),
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
                Text('Créer un devis', style: context.taH2),
                const SizedBox(height: 3),
                Text(
                  'Pour ${demande.client} · ${demande.projet}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.taSub,
                ),
                const SizedBox(height: 16),
                Text('TITRE DU DEVIS', style: context.taLabel),
                const SizedBox(height: 8),
                TaInput(
                  controller: _titreCtrl,
                  hint: 'Ex. : Réparation fuite + remplacement siphon',
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 14),
                Text('DESCRIPTION', style: context.taLabel),
                const SizedBox(height: 8),
                TaInput(
                  controller: _descCtrl,
                  maxLines: 3,
                  hint: 'Délais, garantie, conditions…',
                ),
                const SizedBox(height: 16),
                Text('DÉTAIL DU DEVIS', style: context.taLabel),
                const SizedBox(height: 8),
                Text(
                  'Ajoutez des lignes : les valeurs numériques '
                  's’additionnent automatiquement.',
                  style: context.taSub.copyWith(fontSize: 11.5),
                ),
                const SizedBox(height: 8),
                Column(
                  spacing: 8,
                  children: [
                    for (var i = 0; i < _lignes.length; i++)
                      _LigneRow(
                        ctrls: _lignes[i],
                        canDelete: _lignes.length > 1,
                        onChanged: () => setState(() {}),
                        onDelete: () => setState(() {
                          // Dispose différé : le champ référence encore les
                          // controllers jusqu'au rebuild.
                          final retiree = _lignes.removeAt(i);
                          WidgetsBinding.instance.addPostFrameCallback(
                            (_) => retiree.dispose(),
                          );
                        }),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                TaButton(
                  label: 'Ajouter une ligne',
                  variant: TaButtonVariant.outline,
                  small: true,
                  onPressed: () => setState(() => _lignes.add(_LigneCtrls())),
                  leading: TaIcon(
                    TaIcons.plus,
                    size: 13,
                    mono: true,
                    color: TaButton.inkColor(context, TaButtonVariant.outline),
                  ),
                ),
                const SizedBox(height: 12),
                // Total automatique des lignes numériques.
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: t.primarySoft,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: t.primary,
                        ),
                      ),
                      const Spacer(),
                      Flexible(
                        child: Text(
                          formatFcfa(_total),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: t.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Opacity(
                  opacity: _canSend ? 1 : 0.5,
                  child: TaButton(
                    label: 'Envoyer le devis',
                    expanded: true,
                    onPressed: _canSend ? _send : null,
                    leading: TaIcon(
                      TaIcons.send,
                      size: 16,
                      mono: true,
                      color: TaButton.inkColor(context, TaButtonVariant.cta),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Ligne clé/valeur éditable, avec suppression si plusieurs lignes.
class _LigneRow extends StatelessWidget {
  const _LigneRow({
    required this.ctrls,
    required this.canDelete,
    required this.onChanged,
    required this.onDelete,
  });

  final _LigneCtrls ctrls;
  final bool canDelete;
  final VoidCallback onChanged;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    return Row(
      spacing: 8,
      children: [
        Expanded(
          flex: 3,
          child: TaInput(
            controller: ctrls.label,
            height: 46,
            hint: 'Libellé (ex. : Main d’œuvre)',
            onChanged: (_) => onChanged(),
          ),
        ),
        Expanded(
          flex: 2,
          child: TaInput(
            controller: ctrls.valeur,
            height: 46,
            hint: 'Valeur',
            onChanged: (_) => onChanged(),
          ),
        ),
        if (canDelete)
          TaPressable(
            onTap: onDelete,
            child: Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: t.surface2,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TaIcon(
                TaIcons.close,
                size: 14,
                mono: true,
                color: t.text3,
              ),
            ),
          ),
      ],
    );
  }
}
