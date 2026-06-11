import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/ta_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/models.dart';
import '../../providers/wallet_provider.dart';
import '../../shared/widgets/widgets.dart';
import 'recharge_sheet.dart';

/// Écran « Mon wallet » : solde, actions (recharge / paiement), historique.
class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(walletProvider);
    return TaStatusBar(
      forceLight: true,
      child: Scaffold(
        body: Column(
          children: [
            _WalletHeader(solde: wallet.solde),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  TaDims.pad,
                  TaDims.gap + 10,
                  TaDims.pad,
                  32,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: TaDims.gap,
                  children: [
                    const _InfoCard(),
                    const TaSectionHead(title: 'Historique'),
                    _TxList(transactions: wallet.transactions),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// En-tête dégradé vert : retour, titre, solde et actions.
class _WalletHeader extends StatelessWidget {
  const _WalletHeader({required this.solde});

  final int solde;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    final topPad = MediaQuery.paddingOf(context).top + 16;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(TaDims.pad, topPad, TaDims.pad, 24),
      decoration: BoxDecoration(
        gradient: t.headerGrad,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(26)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              TaSquareButton(
                onTap: () => context.pop(),
                background: const Color(0x24FFFFFF),
                child: const TaIcon(
                  TaIcons.arrowLeft,
                  size: 17,
                  mono: true,
                  color: Colors.white,
                ),
              ),
              Expanded(
                child: Text(
                  'Mon wallet',
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: t.headerInk,
                  ),
                ),
              ),
              // Icône miroir pour équilibrer le bouton retour.
              SizedBox(
                width: 38,
                height: 38,
                child: Center(
                  child: TaIcon(
                    TaIcons.wallet,
                    size: 20,
                    mono: true,
                    color: t.headerInk2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'SOLDE DISPONIBLE',
            style: context.taLabel.copyWith(color: t.headerInk2),
          ),
          Text(
            formatFcfa(solde),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.64,
              color: t.headerInk,
            ),
          ),
          Text(
            'Paiements clients, boosts et retraits',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: t.headerInk2,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            spacing: 10,
            children: [
              Expanded(
                child: TaButton(
                  label: 'Recharger',
                  leading: TaIcon(
                    TaIcons.plus,
                    size: 15,
                    mono: true,
                    color: TaButton.inkColor(context, TaButtonVariant.cta),
                  ),
                  onPressed: () => showRechargeSheet(context),
                ),
              ),
              const Expanded(child: _RetirerButton()),
            ],
          ),
        ],
      ),
    );
  }
}

/// Bouton « outline sur fond vert » : pill blanc translucide, encre blanche.
class _RetirerButton extends StatelessWidget {
  const _RetirerButton();

  @override
  Widget build(BuildContext context) {
    return TaPressable(
      onTap: () {},
      pressedScale: 0.98,
      child: Container(
        height: TaDims.btnHeight,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0x24FFFFFF),
          borderRadius: BorderRadius.circular(TaDims.rPill),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          spacing: 8,
          children: [
            TaIcon(TaIcons.logout, size: 15, mono: true, color: Colors.white),
            Flexible(
              child: Text(
                'Retirer',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: TaDims.fsSm,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Encart d'information sur les moyens de recharge.
class _InfoCard extends StatelessWidget {
  const _InfoCard();

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    return TaCard(
      padding: const EdgeInsets.all(14),
      color: t.primarySoft,
      border: false,
      shadow: false,
      child: Row(
        spacing: 10,
        children: [
          const TaIcon(TaIcons.shield, size: 18),
          Expanded(
            child: Text(
              'Recevez les paiements de vos clients, payez vos boosts '
              '« Mis en avant » et retirez vos gains via mobile money.',
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
    );
  }
}

/// Historique des transactions, dans une carte unique.
class _TxList extends StatelessWidget {
  const _TxList({required this.transactions});

  final List<WalletTx> transactions;

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) return const _EmptyState();
    return TaCard(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: TaDims.pad),
      child: Column(
        children: [
          for (var i = 0; i < transactions.length; i++) ...[
            if (i > 0) const TaDivider(),
            _TxRow(tx: transactions[i]),
          ],
        ],
      ),
    );
  }
}

/// Rangée de transaction : icône typée, libellé + date, montant signé.
class _TxRow extends StatelessWidget {
  const _TxRow({required this.tx});

  final WalletTx tx;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    final recharge = tx.type == WalletTxType.recharge;
    // Signe moins typographique (−) côté débit.
    final montant = recharge
        ? '+${formatNumber(tx.montant)} F'
        : '−${formatNumber(tx.montant.abs())} F';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        spacing: 12,
        children: [
          TaIconBox(
            icon: recharge ? TaIcons.plus : TaIcons.send,
            background: recharge ? t.primarySoft : t.accentSoft,
            mono: true,
            iconColor: recharge ? t.primary : t.accentStrong,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: TaDims.fsSm,
                    fontWeight: FontWeight.w700,
                    color: t.text,
                  ),
                ),
                Text(tx.date, style: context.taSub.copyWith(fontSize: 11.5)),
              ],
            ),
          ),
          Text(
            montant,
            style: TextStyle(
              fontSize: TaDims.fsSm,
              fontWeight: FontWeight.w800,
              color: recharge ? t.primary : t.text,
            ),
          ),
        ],
      ),
    );
  }
}

/// État vide de l'historique.
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        spacing: 8,
        children: [
          const Opacity(opacity: 0.5, child: TaIcon(TaIcons.wallet, size: 30)),
          Text(
            'Aucune transaction pour l’instant',
            textAlign: TextAlign.center,
            style: context.taSub,
          ),
        ],
      ),
    );
  }
}
