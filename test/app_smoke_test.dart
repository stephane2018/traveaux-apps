import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travaux_abidjan/app.dart';
import 'package:travaux_abidjan/shared/widgets/widgets.dart';

void main() {
  Future<void> pumpApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1206, 2622); // ~402×874 logiques
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const ProviderScope(child: TravauxAbidjanApp()));
    // Splash : laisse passer le minuteur de redirection (1,6 s) puis settle.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  }

  testWidgets('splash puis onboarding', (tester) async {
    tester.view.physicalSize = const Size(1206, 2622);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const ProviderScope(child: TravauxAbidjanApp()));
    await tester.pump();

    // Splash visible d'abord.
    expect(find.text('Fait à Abidjan'), findsOneWidget);

    // Puis redirection automatique vers l'onboarding.
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
    expect(find.text('Connexion ou inscription'), findsOneWidget);
    expect(find.text('Continuer avec Google'), findsOneWidget);
  });

  testWidgets('onboarding → accueil → onglets', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();

    // Accueil
    expect(find.text('Bonjour Awa,'), findsOneWidget);
    expect(find.text('Catégories'), findsOneWidget);

    // Onglet Messages
    await tester.tap(find.text('Messages').first);
    await tester.pumpAndSettle();
    expect(find.text('Vos conversations avec les artisans'), findsOneWidget);

    // Onglet Profil (compte)
    await tester.tap(find.text('Profil').first);
    await tester.pumpAndSettle();
    expect(find.text('Awa Koné'), findsOneWidget);
    expect(find.text('Mode sombre'), findsOneWidget);
  });

  testWidgets('bascule du mode sombre depuis le compte', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Profil').first);
    await tester.pumpAndSettle();

    await tester.tap(find.byType(TaToggle));
    await tester.pumpAndSettle();

    final context = tester.element(find.text('Mode sombre'));
    expect(Theme.of(context).brightness, Brightness.dark);
  });

  testWidgets('chat : envoi d\'un message depuis le composer', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Messages').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Konan Yao'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextField),
      'Parfait, à demain 9 h !',
    );
    await tester.tap(find.byType(TaIcon).last); // bouton envoyer
    await tester.pumpAndSettle();

    expect(find.text('Parfait, à demain 9 h !'), findsOneWidget);

    // L'aperçu de la liste des conversations est mis à jour.
    await tester.tap(find.byType(TaSquareButton).first); // retour custom
    await tester.pumpAndSettle();
    expect(find.text('Parfait, à demain 9 h !'), findsOneWidget);
  });

  testWidgets('recherche : filtres et profil artisan', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Recherche').first);
    await tester.pumpAndSettle();
    expect(find.textContaining('triés par pertinence'), findsOneWidget);

    // Ouvre le premier artisan mis en avant (Konan Yao en tête de liste)
    await tester.tap(find.text('Konan Yao').first);
    await tester.pumpAndSettle();
    expect(find.text('Demander un devis'), findsOneWidget);
  });

  testWidgets('wallet artisan : solde dans l\'espace pro et recharge',
      (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Je suis artisan — créer mon profil pro'));
    await tester.pumpAndSettle();

    // Solde dans l'en-tête pro mobile ; absent côté client.
    expect(find.text('48 500 F'), findsOneWidget);

    // Page wallet.
    await tester.tap(find.text('48 500 F'));
    await tester.pumpAndSettle();
    expect(find.text('Mon wallet'), findsOneWidget);
    expect(find.text('Historique'), findsOneWidget);

    // Recharge via la bottom sheet (chip 5 000 F présélectionnée).
    await tester.tap(find.text('Recharger'));
    await tester.pumpAndSettle();
    expect(find.text('Recharger mon wallet'), findsOneWidget);
    await tester.tap(find.text('Recharger 5 000 F'));
    await tester.pumpAndSettle();

    // Solde mis à jour.
    expect(find.textContaining('53 500'), findsWidgets);
  });

  testWidgets('wallet absent de l\'accueil client', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();
    expect(find.text('Bonjour Awa,'), findsOneWidget);
    expect(find.byWidgetPredicate(
      (w) => w is TaIcon && w.icon == TaIcons.wallet,
    ), findsNothing);
  });

  testWidgets('projets : KPI devis dans l\'en-tête', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Projets').first);
    await tester.pumpAndSettle();

    // Bandeau KPI : 3 devis reçus (q1, q2, q3), 1 refusé d'emblée.
    expect(find.text('DEVIS REÇUS'), findsOneWidget);
    expect(find.text('ACCEPTÉS'), findsOneWidget);
    expect(find.text('REFUSÉS'), findsOneWidget);
  });

  testWidgets('projets : liste, détail et acceptation d\'un devis',
      (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();

    // Onglet Projets.
    await tester.tap(find.text('Projets').first);
    await tester.pumpAndSettle();
    expect(find.text('Mes projets'), findsOneWidget);
    expect(find.text('Fuite sous évier de cuisine'), findsOneWidget);

    // Détail du projet + devis reçus.
    await tester.tap(find.text('Fuite sous évier de cuisine'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Devis reçus ('), findsOneWidget);
    expect(find.text('18 000 F CFA'), findsOneWidget);

    // Ouvre le devis → bottom sheet (apostrophe typographique du design).
    await tester.tap(find.text('Voir le devis'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('J’accepte'));
    await tester.pumpAndSettle();

    // Étape réservation : un créneau par défaut est pré-sélectionné.
    expect(find.text('Réserver l’intervention'), findsOneWidget);
    await tester.tap(find.text('Confirmer le rendez-vous'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Accepté'), findsWidgets);
  });

  testWidgets('mes devis : page dédiée avec 2 onglets', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Projets').first);
    await tester.pumpAndSettle();

    // Accès depuis le bandeau KPI.
    await tester.tap(find.text('Voir tous les devis'));
    await tester.pumpAndSettle();
    expect(find.text('Mes devis'), findsOneWidget);
    expect(find.textContaining('Reçus ('), findsOneWidget);
    expect(find.textContaining('Traités ('), findsOneWidget);

    // L'onglet « Traités » montre le devis refusé seedé.
    await tester.tap(find.textContaining('Traités ('));
    await tester.pumpAndSettle();
    expect(find.text('Refusé'), findsWidgets);
  });

  testWidgets('artisan : créer un devis, visible côté client',
      (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Je suis artisan — créer mon profil pro'));
    await tester.pumpAndSettle();

    // Page demandes → bottom sheet de création sur la 1re demande (d1).
    await tester.tap(find.text('Demandes').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Envoyer un devis').first);
    await tester.pumpAndSettle();
    expect(find.text('Créer un devis'), findsOneWidget);

    // Titre + 2 lignes (numérique + texte) → total sommé.
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'Remplacement robinet');
    await tester.enterText(fields.at(2), 'Main d\'œuvre');
    await tester.enterText(fields.at(3), '12000');
    await tester.enterText(fields.at(4), 'Robinet laiton');
    await tester.enterText(fields.at(5), '8000');
    await tester.pumpAndSettle();
    expect(find.text('20 000 F CFA'), findsOneWidget);

    await tester.tap(find.text('Envoyer le devis'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Devis envoyé à'), findsOneWidget);
    // Laisse la SnackBar de confirmation disparaître.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();

    // Côté client : le projet d1 a maintenant 2 devis.
    // Déconnexion → retour onboarding → entrée client → onglet Projets.
    await tester.tap(find.byWidgetPredicate(
      (w) => w is TaIcon && w.icon == TaIcons.logout,
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continuer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Projets').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fuite sous évier de cuisine'));
    await tester.pumpAndSettle();
    expect(find.text('Remplacement robinet'), findsOneWidget);
    expect(find.text('20 000 F CFA'), findsOneWidget);
  });

  testWidgets('espace artisan : layout mobile sur téléphone', (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Je suis artisan — créer mon profil pro'));
    await tester.pumpAndSettle();

    // Layout mobile : barre d'onglets pro, pas de sidebar.
    expect(find.text('Tableau'), findsOneWidget);
    expect(find.text('Bonjour M. Konan'), findsOneWidget);
    expect(find.text('Tableau de bord'), findsNothing);

    await tester.tap(find.text('Demandes').last);
    await tester.pumpAndSettle();
    // Titre dans l'en-tête vert + compteur dans le contenu.
    expect(find.textContaining('demandes · 2 nouvelles'), findsOneWidget);
  });

  testWidgets('espace artisan : pages profil / photos / messages remplies',
      (tester) async {
    await pumpApp(tester);
    await tester.tap(find.text('Je suis artisan — créer mon profil pro'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Profil').last);
    await tester.pumpAndSettle();
    expect(find.text('Modifier le profil'), findsOneWidget);
    expect(find.text('COMPÉTENCES'), findsOneWidget);

    await tester.tap(find.text('Photos').last);
    await tester.pumpAndSettle();
    expect(find.text('Ajouter une réalisation'), findsOneWidget);
    expect(find.text('Salle de bain — Riviera 3'), findsOneWidget);

    await tester.tap(find.text('Messages').last);
    await tester.pumpAndSettle();
    expect(find.text('Adjoua Bamba'), findsWidgets);
  });

  testWidgets('espace artisan : sidebar sur tablette', (tester) async {
    tester.view.physicalSize = const Size(2360, 1708); // ~1180×854 logiques
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const ProviderScope(child: TravauxAbidjanApp()));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Je suis artisan — créer mon profil pro'));
    await tester.pumpAndSettle();

    // Sidebar visible avec libellés longs et carte « mise en avant ».
    expect(find.text('Tableau de bord'), findsOneWidget);
    expect(find.text('Profil mis en avant'), findsOneWidget);
    expect(find.text('Bonjour M. Konan'), findsOneWidget);
  });
}
