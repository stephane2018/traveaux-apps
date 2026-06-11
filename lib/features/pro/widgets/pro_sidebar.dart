import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/theme/ta_tokens.dart';
import '../../../providers/data_providers.dart';
import '../../../providers/wallet_provider.dart';
import '../../../shared/widgets/widgets.dart';
import '../pro_nav.dart';
import 'pro_featured_card.dart';

/// Barre latérale de l'espace artisan : marque, navigation, carte « mise en
/// avant » et profil connecté. Scrollable si la hauteur manque (téléphone).
class ProSidebar extends ConsumerWidget {
  const ProSidebar({
    super.key,
    required this.page,
    required this.onSelect,
    required this.onLogout,
  });

  final ProPage page;
  final ValueChanged<ProPage> onSelect;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.ta;
    final me = ref.watch(artisansProvider).first;

    return Container(
      width: 248,
      decoration: BoxDecoration(
        color: t.surface,
        border: Border(right: BorderSide(color: t.border)),
      ),
      padding: const EdgeInsets.fromLTRB(14, 22, 14, 18),
      child: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _SidebarBrand(),
                  Column(
                    spacing: 4,
                    children: [
                      for (final item in proNavItems)
                        _NavButton(
                          item: item,
                          active: page == item.page,
                          onTap: () => onSelect(item.page),
                        ),
                    ],
                  ),
                  const Spacer(),
                  const _WalletCard(),
                  const ProFeaturedCard(margin: EdgeInsets.only(bottom: 14)),
                  Container(
                    padding: const EdgeInsets.fromLTRB(8, 12, 8, 0),
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: t.border)),
                    ),
                    child: Row(
                      spacing: 10,
                      children: [
                        TaAvatar(artisan: me, size: 38, showMetier: false),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                spacing: 4,
                                children: [
                                  Flexible(
                                    child: Text(
                                      me.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12.5,
                                        color: t.text,
                                      ),
                                    ),
                                  ),
                                  const TaIcon(TaIcons.badge, size: 12),
                                ],
                              ),
                              Text(
                                '${me.metier} · ${me.commune}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.taSub.copyWith(fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: onLogout,
                          child: TaIcon(
                            TaIcons.logout,
                            size: 17,
                            mono: true,
                            color: t.text3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Accès au wallet artisan : solde + lien vers la page dédiée.
class _WalletCard extends ConsumerWidget {
  const _WalletCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.ta;
    final solde = ref.watch(walletProvider).solde;
    return TaPressable(
      onTap: () => context.push('/wallet'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: t.surface2,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          spacing: 10,
          children: [
            TaIconBox(
              icon: TaIcons.wallet,
              size: 34,
              radius: 10,
              iconSize: 16,
              background: t.primarySoft,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Wallet',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: t.text2,
                    ),
                  ),
                  Text(
                    '${formatNumber(solde)} F',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: t.text,
                    ),
                  ),
                ],
              ),
            ),
            TaIcon(TaIcons.chevronRight, size: 13, mono: true, color: t.text3),
          ],
        ),
      ),
    );
  }
}

/// Logo + wordmark + mention « Espace artisan ».
class _SidebarBrand extends StatelessWidget {
  const _SidebarBrand();

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 24),
      child: Row(
        spacing: 10,
        children: [
          const TaLogo(size: 32),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: TaWordmark(size: 16),
                ),
                const SizedBox(height: 2),
                Text(
                  'ESPACE ARTISAN',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.taLabel.copyWith(
                    fontSize: 9.5,
                    letterSpacing: 0.76,
                    color: t.accentStrong,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Item de navigation : pill, duotone si actif, badge non lu.
class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.active,
    required this.onTap,
  });

  final ProNavItem item;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    return TaPressable(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        decoration: BoxDecoration(
          color: active ? t.primarySoft : Colors.transparent,
          borderRadius: BorderRadius.circular(TaDims.rPill),
        ),
        child: Row(
          spacing: 11,
          children: [
            TaIcon(item.icon, size: 19, mono: !active, color: t.text3),
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: TaDims.fsSm,
                  fontWeight: FontWeight.w700,
                  color: active ? t.primary : t.text2,
                ),
              ),
            ),
            if (item.badge != null) TaUnreadBadge(count: item.badge!),
          ],
        ),
      ),
    );
  }
}
