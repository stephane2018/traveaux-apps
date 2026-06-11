import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_data.dart';
import '../data/models/models.dart';

/// Wallet du client : solde + historique, recharge locale (mock API).
class WalletNotifier extends Notifier<WalletState> {
  int _txCounter = 100;

  @override
  WalletState build() => MockData.wallet;

  /// Crédite le wallet ([moyen] : Orange Money, Wave, artisan partenaire…).
  void recharge(int montant, String moyen) {
    if (montant <= 0) return;
    state = state.copyWith(
      solde: state.solde + montant,
      transactions: [
        WalletTx(
          id: 'w${_txCounter++}',
          label: 'Recharge — $moyen',
          montant: montant,
          date: 'À l’instant',
          type: WalletTxType.recharge,
        ),
        ...state.transactions,
      ],
    );
  }
}

final walletProvider = NotifierProvider<WalletNotifier, WalletState>(
  WalletNotifier.new,
);
