import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/data_providers.dart';
import '../shared/widgets/widgets.dart';

/// Shell principal : 5 onglets (la création de demande est une route
/// poussée, ouverte via le FAB des projets ou le « + » de l'accueil).
/// Le changement d'onglet rejoue la transition `ta-screen-anim` (14 px).
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
    value: 1,
  );

  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0.035, 0),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.ease));

  int _lastIndex = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  StatefulNavigationShell get navigationShell => widget.navigationShell;

  @override
  Widget build(BuildContext context) {
    final hasUnread = ref.watch(unreadCountProvider) > 0;

    if (navigationShell.currentIndex != _lastIndex) {
      _lastIndex = navigationShell.currentIndex;
      if (!MediaQuery.disableAnimationsOf(context)) {
        _controller.forward(from: 0);
      }
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          Positioned.fill(
            child: SlideTransition(position: _slide, child: navigationShell),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: TaTabBar(
              currentIndex: navigationShell.currentIndex,
              onTap: (index) => navigationShell.goBranch(
                index,
                initialLocation: index == navigationShell.currentIndex,
              ),
              items: [
                const TaTabItem(icon: TaIcons.home, label: 'Accueil'),
                const TaTabItem(icon: TaIcons.search, label: 'Recherche'),
                const TaTabItem(icon: TaIcons.doc, label: 'Projets'),
                TaTabItem(
                  icon: TaIcons.chat,
                  label: 'Messages',
                  showDot: hasUnread,
                ),
                const TaTabItem(icon: TaIcons.user, label: 'Profil'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
