import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/ta_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../providers/wallet_provider.dart';
import '../../shared/widgets/widgets.dart';

/// Ouvre la feuille de recharge du wallet.
Future<void> showRechargeSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => const _RechargeSheet(),
  );
}

/// Montants rapides proposés en chips.
const _montants = [1000, 2000, 5000, 10000, 25000];

/// Moyen de paiement sélectionnable.
class _Moyen {
  const _Moyen(this.icon, this.label, [this.sub]);

  final TaIcons icon;
  final String label;
  final String? sub;
}

const _moyens = [
  _Moyen(TaIcons.wallet, 'Orange Money'),
  _Moyen(TaIcons.phone, 'MTN MoMo'),
  _Moyen(TaIcons.send, 'Wave'),
  _Moyen(
    TaIcons.wrench,
    'En espèces — point de recharge agréé',
    'Agence Cocody à 1,2 km',
  ),
];

class _RechargeSheet extends ConsumerStatefulWidget {
  const _RechargeSheet();

  @override
  ConsumerState<_RechargeSheet> createState() => _RechargeSheetState();
}

class _RechargeSheetState extends ConsumerState<_RechargeSheet> {
  final _customCtrl = TextEditingController();
  int? _chip = 5000;
  int _moyen = 0;

  @override
  void dispose() {
    _customCtrl.dispose();
    super.dispose();
  }

  /// Montant effectif : la saisie libre prime sur la chip.
  int get _montant {
    final custom = _customCtrl.text.trim();
    if (custom.isNotEmpty) return int.tryParse(custom) ?? 0;
    return _chip ?? 0;
  }

  void _recharger() {
    ref.read(walletProvider.notifier).recharge(_montant, _moyens[_moyen].label);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    final montant = _montant;
    final bottomPad =
        20 +
        MediaQuery.viewInsetsOf(context).bottom +
        MediaQuery.paddingOf(context).bottom;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(TaDims.pad, 12, TaDims.pad, bottomPad),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      // Scrollable au besoin (clavier ouvert sur petit écran).
      child: SingleChildScrollView(child: _buildContent(context, t, montant)),
    );
  }

  Widget _buildContent(BuildContext context, TaTokens t, int montant) {
    return Column(
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
        const SizedBox(height: 14),
        Text('Recharger mon wallet', style: context.taH2),
        const SizedBox(height: 4),
        Text(
          'Choisissez un montant et un moyen de paiement',
          style: context.taSub,
        ),
        const SizedBox(height: 16),
        Text('MONTANT', style: context.taLabel),
        const SizedBox(height: 9),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: [
            for (final m in _montants)
              TaChip(
                label: '${formatNumber(m)} F',
                active: _customCtrl.text.trim().isEmpty && _chip == m,
                onTap: () => setState(() {
                  _chip = m;
                  _customCtrl.clear();
                }),
              ),
          ],
        ),
        const SizedBox(height: 9),
        TaInput(
          controller: _customCtrl,
          height: 46,
          hint: 'Autre montant',
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          // La saisie libre désélectionne les chips.
          onChanged: (_) => setState(() => _chip = null),
        ),
        const SizedBox(height: 16),
        Text('MOYEN DE PAIEMENT', style: context.taLabel),
        const SizedBox(height: 9),
        Column(
          spacing: 8,
          children: [
            for (var i = 0; i < _moyens.length; i++)
              _MoyenTile(
                moyen: _moyens[i],
                selected: _moyen == i,
                onTap: () => setState(() => _moyen = i),
              ),
          ],
        ),
        const SizedBox(height: 18),
        Opacity(
          opacity: montant > 0 ? 1 : 0.5,
          child: TaButton(
            label: 'Recharger ${formatNumber(montant)} F',
            expanded: true,
            onPressed: montant > 0 ? _recharger : null,
          ),
        ),
      ],
    );
  }
}

/// Option de paiement : icône, libellé (+ sous-titre), radio à droite.
class _MoyenTile extends StatelessWidget {
  const _MoyenTile({
    required this.moyen,
    required this.selected,
    required this.onTap,
  });

  final _Moyen moyen;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    return TaPressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: selected ? t.primarySoft : t.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? t.primary : t.border,
            width: 1.5,
          ),
        ),
        child: Row(
          spacing: 11,
          children: [
            TaIconBox(
              icon: moyen.icon,
              size: 34,
              radius: 10,
              iconSize: 16,
              background: t.surface2,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    moyen.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: TaDims.fsSm,
                      fontWeight: FontWeight.w700,
                      color: t.text,
                    ),
                  ),
                  if (moyen.sub != null)
                    Text(
                      moyen.sub!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.taSub.copyWith(fontSize: 11),
                    ),
                ],
              ),
            ),
            // Radio custom : rond 20, point central si sélectionné.
            Container(
              width: 20,
              height: 20,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? t.primary : t.borderStrong,
                  width: 2,
                ),
              ),
              child: selected
                  ? Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: t.primary,
                        shape: BoxShape.circle,
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
