import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/ta_tokens.dart';
import '../../shared/widgets/widgets.dart';

/// Type d'une notification d'artisan (pilote l'icône et la couleur du bloc).
enum _NotifKind { demande, devis, avis, paiement, boost, visites }

/// Donnée statique d'une notification.
@immutable
class _Notif {
  const _Notif({
    required this.kind,
    required this.titre,
    required this.detail,
    required this.heure,
    this.unread = false,
  });

  final _NotifKind kind;
  final String titre;
  final String detail;
  final String heure;
  final bool unread;
}

/// Notifications de l'espace artisan (route poussée plein écran).
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  // Aujourd'hui : nouvelles demandes (non lues).
  static const _aujourdhui = [
    _Notif(
      kind: _NotifKind.demande,
      titre: 'Nouvelle demande de devis',
      detail: 'Adjoua Bamba · Fuite sous évier',
      heure: 'Il y a 25 min',
      unread: true,
    ),
    _Notif(
      kind: _NotifKind.demande,
      titre: 'Nouvelle demande',
      detail: 'Éric Kouamé · Installation chauffe-eau',
      heure: 'Il y a 2 h',
      unread: true,
    ),
  ];

  // Cette semaine : activité récente.
  static const _semaine = [
    _Notif(
      kind: _NotifKind.devis,
      titre: 'Devis accepté',
      detail: 'Salimata Doumbia a accepté votre devis',
      heure: 'Il y a 5 h',
    ),
    _Notif(
      kind: _NotifKind.avis,
      titre: 'Nouvel avis 5★',
      detail: 'Adjoua Bamba vous a noté',
      heure: 'Hier',
    ),
    _Notif(
      kind: _NotifKind.paiement,
      titre: 'Paiement reçu',
      detail: '+18 000 F CFA de Adjoua Bamba',
      heure: 'Hier',
    ),
    _Notif(
      kind: _NotifKind.boost,
      titre: 'Boost actif',
      detail: 'Votre profil est mis en avant jusqu’au 24 juin',
      heure: 'Lun.',
    ),
    _Notif(
      kind: _NotifKind.visites,
      titre: 'Pic de visites',
      detail: '+18 % de vues cette semaine',
      heure: 'Lun.',
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.ta;
    return TaStatusBar(
      forceLight: true,
      child: Scaffold(
        backgroundColor: t.bg,
        body: Column(
          children: [
            const _NotifHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  TaDims.pad,
                  TaDims.pad,
                  TaDims.pad,
                  40,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TaSectionHead(title: 'Aujourd’hui'),
                    const SizedBox(height: 11),
                    for (final n in _aujourdhui) ...[
                      _NotifCard(notif: n),
                      const SizedBox(height: TaDims.gap),
                    ],
                    const SizedBox(height: 6),
                    const TaSectionHead(title: 'Cette semaine'),
                    const SizedBox(height: 11),
                    for (var i = 0; i < _semaine.length; i++) ...[
                      _NotifCard(notif: _semaine[i]),
                      if (i < _semaine.length - 1)
                        const SizedBox(height: TaDims.gap),
                    ],
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

/// En-tête vert dégradé à bas arrondi 26.
class _NotifHeader extends StatelessWidget {
  const _NotifHeader();

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
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
      child: Row(
        spacing: 12,
        children: [
          // Bouton retour blanc translucide.
          TaSquareButton(
            onTap: () => context.pop(),
            background: Colors.white.withValues(alpha: 0.16),
            child: TaIcon(
              TaIcons.arrowLeft,
              size: 16,
              mono: true,
              color: t.headerInk,
            ),
          ),
          Expanded(
            child: Text(
              'Notifications',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.38,
                color: t.headerInk,
              ),
            ),
          ),
          // Action « Tout lire » (sans effet).
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {},
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(TaDims.rPill),
              ),
              child: Text(
                'Tout lire',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: t.headerInk,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Carte d'une notification : icône, texte, heure, point si non lue.
class _NotifCard extends StatelessWidget {
  const _NotifCard({required this.notif});

  final _Notif notif;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    final (icon, bg) = _style(t);
    return TaCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 12,
        children: [
          TaIconBox(icon: icon, size: 38, background: bg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notif.titre,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: t.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  notif.detail,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: context.taSub.copyWith(fontSize: 12),
                ),
                const SizedBox(height: 5),
                Text(
                  notif.heure,
                  style: context.taSub.copyWith(fontSize: 11, color: t.text3),
                ),
              ],
            ),
          ),
          // Point orange si non lue.
          if (notif.unread)
            Container(
              margin: const EdgeInsets.only(top: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: t.accent,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ),
    );
  }

  /// Icône + fond du bloc selon le type.
  (TaIcons, Color) _style(TaTokens t) => switch (notif.kind) {
    _NotifKind.demande => (TaIcons.doc, t.accentSoft),
    _NotifKind.devis => (TaIcons.check, t.primarySoft),
    _NotifKind.avis => (TaIcons.star, t.primarySoft),
    _NotifKind.paiement => (TaIcons.wallet, t.primarySoft),
    _NotifKind.boost => (TaIcons.crown, t.accentSoft),
    _NotifKind.visites => (TaIcons.eye, t.primarySoft),
  };
}
