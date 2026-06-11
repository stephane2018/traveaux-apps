import '../../shared/widgets/widgets.dart';

/// Pages de l'espace artisan.
enum ProPage { dash, demandes, messages, realisations, profil }

/// Entrée de navigation (sidebar tablette / barre d'onglets mobile).
class ProNavItem {
  const ProNavItem(
    this.page,
    this.icon,
    this.label, {
    String? shortLabel,
    this.badge,
  }) : shortLabel = shortLabel ?? label;

  final ProPage page;
  final TaIcons icon;
  final String label;

  /// Libellé compact pour la barre d'onglets mobile.
  final String shortLabel;
  final int? badge;
}

const proNavItems = [
  ProNavItem(
    ProPage.dash,
    TaIcons.grid,
    'Tableau de bord',
    shortLabel: 'Tableau',
  ),
  ProNavItem(ProPage.demandes, TaIcons.doc, 'Demandes', badge: 2),
  ProNavItem(ProPage.messages, TaIcons.chat, 'Messages', badge: 3),
  ProNavItem(
    ProPage.realisations,
    TaIcons.image,
    'Réalisations',
    shortLabel: 'Photos',
  ),
  ProNavItem(ProPage.profil, TaIcons.user, 'Mon profil', shortLabel: 'Profil'),
];
