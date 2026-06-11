import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/account/account_screen.dart';
import '../features/devis/devis_screen.dart';
import '../features/home/home_screen.dart';
import '../features/messages/chat_screen.dart';
import '../features/messages/messages_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/profile/artisan_profile_screen.dart';
import '../features/projets/projet_detail_screen.dart';
import '../features/projets/mes_devis_screen.dart';
import '../features/projets/projets_screen.dart';
import '../features/pro/notifications_screen.dart';
import '../features/pro/pro_chat_screen.dart';
import '../features/pro/pro_shell.dart';
import '../features/pro/profil_edit_screen.dart';
import '../features/pro/realisation_detail_screen.dart';
import '../features/results/results_screen.dart';
import '../features/splash/splash_screen.dart';
import '../features/wallet/wallet_screen.dart';
import 'main_shell.dart';
import 'ta_page.dart';

/// Routeur fourni via Riverpod : une instance par scope (testable, jetable).
final appRouterProvider = Provider<GoRouter>((ref) {
  final router = createAppRouter();
  ref.onDispose(router.dispose);
  return router;
});

GoRouter createAppRouter() {
  final rootNavigatorKey = GlobalKey<NavigatorState>();
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (context, state) =>
            fadePage(state: state, child: const OnboardingScreen()),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                pageBuilder: (context, state) =>
                    taPage(state: state, child: const HomeScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/results',
                pageBuilder: (context, state) => taPage(
                  state: state,
                  child: ResultsScreen(
                    initialCat: state.uri.queryParameters['cat'],
                  ),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/projets',
                pageBuilder: (context, state) =>
                    taPage(state: state, child: const ProjetsScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/messages',
                pageBuilder: (context, state) =>
                    taPage(state: state, child: const MessagesScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/account',
                pageBuilder: (context, state) =>
                    taPage(state: state, child: const AccountScreen()),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/devis',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => taPage(
          state: state,
          child: DevisScreen(initialCat: state.uri.queryParameters['cat']),
        ),
      ),
      GoRoute(
        path: '/projet/:id',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => taPage(
          state: state,
          child: ProjetDetailScreen(projetId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/mes-devis',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) =>
            taPage(state: state, child: const MesDevisScreen()),
      ),
      GoRoute(
        path: '/wallet',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) =>
            taPage(state: state, child: const WalletScreen()),
      ),
      GoRoute(
        path: '/artisan/:id',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => taPage(
          state: state,
          child: ArtisanProfileScreen(artisanId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/chat/:id',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => taPage(
          state: state,
          child: ChatScreen(conversationId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/pro',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) =>
            taPage(state: state, child: const ProShell()),
      ),
      GoRoute(
        path: '/pro/chat/:id',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => taPage(
          state: state,
          child: ProChatScreen(conversationId: state.pathParameters['id']!),
        ),
      ),
      GoRoute(
        path: '/pro/realisation/:id',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => taPage(
          state: state,
          child: RealisationDetailScreen(
            realisationId: state.pathParameters['id']!,
          ),
        ),
      ),
      GoRoute(
        path: '/pro/profil/edit',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) =>
            taPage(state: state, child: const ProfilEditScreen()),
      ),
      GoRoute(
        path: '/pro/notifications',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) =>
            taPage(state: state, child: const NotificationsScreen()),
      ),
    ],
  );
}
