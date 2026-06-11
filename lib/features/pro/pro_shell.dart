import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_palette.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../core/theme/ta_tokens.dart';
import '../../providers/data_providers.dart';
import '../../providers/pro_messages_provider.dart';
import '../../providers/wallet_provider.dart';
import '../../shared/widgets/widgets.dart';
import 'pro_dashboard_page.dart';
import 'pro_demandes_page.dart';
import 'pro_nav.dart';
import 'pro_messages_page.dart';
import 'pro_profil_page.dart';
import 'pro_realisations_page.dart';
import 'widgets/pro_featured_card.dart';
import 'widgets/pro_sidebar.dart';

/// Espace artisan adaptatif : sidebar + contenu sur tablette
/// (shortestSide ≥ 600), en-tête + barre d'onglets sur téléphone.
class ProShell extends ConsumerStatefulWidget {
  const ProShell({super.key});

  @override
  ConsumerState<ProShell> createState() => _ProShellState();
}

class _ProShellState extends ConsumerState<ProShell> {
  ProPage _page = ProPage.dash;

  void _go(ProPage page) => setState(() => _page = page);

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.sizeOf(context).shortestSide >= 600;
    return isTablet ? _tabletLayout(context) : _mobileLayout(context);
  }

  // ───── Tablette : sidebar + contenu ─────
  Widget _tabletLayout(BuildContext context) {
    final t = context.ta;
    return TaStatusBar(
      child: Scaffold(
        backgroundColor: t.bg,
        body: SafeArea(
          bottom: false,
          child: Row(
            children: [
              ProSidebar(
                page: _page,
                onSelect: _go,
                onLogout: () => context.pop(),
              ),
              Expanded(child: _content(context, mobile: false)),
            ],
          ),
        ),
      ),
    );
  }

  // ───── Mobile : en-tête vert + contenu + barre d'onglets ─────
  Widget _mobileLayout(BuildContext context) {
    final t = context.ta;
    final unread = ref.watch(proUnreadProvider);
    return TaStatusBar(
      forceLight: true,
      child: Scaffold(
        backgroundColor: t.bg,
        body: Stack(
          children: [
            Positioned.fill(
              child: Column(
                children: [
                  _MobileProHeader(page: _page, onLogout: () => context.pop()),
                  Expanded(child: _content(context, mobile: true)),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: TaTabBar(
                currentIndex: _page.index,
                onTap: (index) => _go(ProPage.values[index]),
                items: [
                  for (final item in proNavItems)
                    TaTabItem(
                      icon: item.icon,
                      label: item.shortLabel,
                      showDot: item.page == ProPage.messages
                          ? unread > 0
                          : (item.badge ?? 0) > 0,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(BuildContext context, {required bool mobile}) {
    // Mobile : le contenu défile sous la barre d'onglets floutée (116).
    final pad = mobile ? TaDims.pad : 26.0;
    final bottomPad = mobile
        ? 116.0
        : 26 + MediaQuery.paddingOf(context).bottom;

    switch (_page) {
      case ProPage.dash:
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(pad, pad, pad, bottomPad),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ProDashboardPage(
                compact: mobile,
                onOpenDemandes: () => _go(ProPage.demandes),
              ),
              // Sur mobile la carte « mise en avant » (sidebar) descend ici.
              if (mobile) ...[
                const SizedBox(height: TaDims.gap),
                const ProFeaturedCard(),
              ],
            ],
          ),
        );
      case ProPage.demandes:
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(pad, pad, pad, bottomPad),
          child: ProDemandesPage(compact: mobile),
        );
      case ProPage.messages:
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(pad, pad, pad, bottomPad),
          child: ProMessagesPage(compact: mobile),
        );
      case ProPage.realisations:
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(pad, pad, pad, bottomPad),
          child: ProRealisationsPage(compact: mobile),
        );
      case ProPage.profil:
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(pad, pad, pad, bottomPad),
          child: ProProfilPage(compact: mobile),
        );
    }
  }
}

/// En-tête mobile de l'espace artisan : dégradé vert arrondi (même langage
/// que les écrans client), marque, actions et salutation contextuelle.
class _MobileProHeader extends ConsumerWidget {
  const _MobileProHeader({required this.page, required this.onLogout});

  final ProPage page;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.ta;
    final me = ref.watch(artisansProvider).first;
    final isDash = page == ProPage.dash;

    return Container(
      padding: EdgeInsets.fromLTRB(
        TaDims.pad,
        MediaQuery.paddingOf(context).top + 16,
        TaDims.pad,
        18,
      ),
      decoration: BoxDecoration(
        gradient: t.headerGrad,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(26)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 9,
            children: [
              const TaLogo(size: 28),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FittedBox(
                      fit: BoxFit.scaleDown,
                      child: TaWordmark(size: 15, light: true),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'ESPACE ARTISAN',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.taLabel.copyWith(
                        fontSize: 9.5,
                        letterSpacing: 0.76,
                        color: AppPalette.orange300,
                      ),
                    ),
                  ],
                ),
              ),
              const _WalletPill(),
              _HeaderAction(
                onTap: () => context.push('/pro/notifications'),
                showDot: true,
                child: TaIcon(
                  TaIcons.bell,
                  size: 18,
                  mono: true,
                  color: t.headerInk,
                ),
              ),
              _HeaderAction(
                onTap: onLogout,
                child: TaIcon(
                  TaIcons.logout,
                  size: 17,
                  mono: true,
                  color: t.headerInk,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            isDash
                ? 'Bonjour M. ${me.name.split(' ').first}'
                : proNavItems.firstWhere((i) => i.page == page).label,
            style: TextStyle(
              color: t.headerInk,
              fontSize: 23,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.46,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            isDash
                ? 'Mardi 10 juin · 2 nouvelles demandes vous attendent'
                : '${me.metier} · ${me.commune}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: t.headerInk2,
              fontSize: TaDims.fsSm,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Pastille « solde wallet » de l'en-tête pro mobile → page Wallet.
class _WalletPill extends ConsumerWidget {
  const _WalletPill();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final solde = ref.watch(walletProvider).solde;
    return TaPressable(
      onTap: () => context.push('/wallet'),
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 11),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          spacing: 6,
          children: [
            const TaIcon(
              TaIcons.wallet,
              size: 15,
              mono: true,
              color: Colors.white,
            ),
            Text(
              '${formatNumber(solde)} F',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Bouton d'action de l'en-tête vert (cloche, déconnexion).
class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.child,
    required this.onTap,
    this.showDot = false,
  });

  final Widget child;
  final VoidCallback onTap;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    return TaPressable(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            Center(child: child),
            if (showDot)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: t.accent,
                    border: Border.all(color: AppPalette.green700, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
