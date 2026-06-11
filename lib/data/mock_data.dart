import 'package:flutter/material.dart';

import '../shared/widgets/ta_icon.dart';
import 'models/models.dart';

/// Données réalistes de démonstration (noms ivoiriens, communes d'Abidjan,
/// prix en F CFA) — miroir de data.js du design.
abstract final class MockData {
  static const categories = [
    TaCategory(
      id: 'plombier',
      label: 'Plomberie',
      icon: TaIcons.drop,
      count: 124,
    ),
    TaCategory(
      id: 'electricien',
      label: 'Électricité',
      icon: TaIcons.bolt,
      count: 98,
    ),
    TaCategory(
      id: 'macon',
      label: 'Maçonnerie',
      icon: TaIcons.brick,
      count: 156,
    ),
    TaCategory(
      id: 'peintre',
      label: 'Peinture',
      icon: TaIcons.paint,
      count: 87,
    ),
    TaCategory(
      id: 'menuisier',
      label: 'Menuiserie',
      icon: TaIcons.hammer,
      count: 64,
    ),
    TaCategory(
      id: 'climatisation',
      label: 'Climatisation',
      icon: TaIcons.snow,
      count: 52,
    ),
    TaCategory(
      id: 'jardinier',
      label: 'Jardinage',
      icon: TaIcons.leaf,
      count: 31,
    ),
    TaCategory(
      id: 'serrurier',
      label: 'Serrurerie',
      icon: TaIcons.key,
      count: 27,
    ),
  ];

  static const communes = [
    'Cocody',
    'Yopougon',
    'Marcory',
    'Plateau',
    'Abobo',
    'Treichville',
    'Koumassi',
    'Adjamé',
    'Port-Bouët',
    'Bingerville',
  ];

  static const artisans = [
    Artisan(
      id: 'a1',
      name: 'Konan Yao',
      metier: 'Plombier',
      cat: 'plombier',
      commune: 'Cocody',
      quartier: 'Angré 8e tranche',
      note: 4.9,
      avis: 127,
      jobs: 215,
      annees: 12,
      verified: true,
      featured: true,
      dispo: 'Disponible aujourd’hui',
      prix: 15000,
      c1: Color(0xFF1B7A3D),
      c2: Color(0xFF56B947),
      bio:
          'Spécialiste en installation sanitaire, détection de fuites et '
          'chauffe-eau. Intervention rapide sur tout Cocody et Bingerville.',
      skills: ['Fuites d’eau', 'Chauffe-eau', 'Sanitaires', 'Pompes'],
    ),
    Artisan(
      id: 'a2',
      name: 'Aminata Traoré',
      metier: 'Peintre décoratrice',
      cat: 'peintre',
      commune: 'Marcory',
      quartier: 'Zone 4',
      note: 4.8,
      avis: 94,
      jobs: 143,
      annees: 8,
      verified: true,
      featured: true,
      dispo: 'Dispo sous 48 h',
      prix: 25000,
      c1: Color(0xFFF28C28),
      c2: Color(0xFFF5A04C),
      bio:
          'Peinture intérieure et extérieure, enduits décoratifs, conseils '
          'couleurs. Devis détaillé avec échantillons.',
      skills: ['Peinture int.', 'Façades', 'Enduits déco', 'Étanchéité'],
    ),
    Artisan(
      id: 'a3',
      name: 'Ibrahim Diabaté',
      metier: 'Électricien bâtiment',
      cat: 'electricien',
      commune: 'Yopougon',
      quartier: 'Niangon Nord',
      note: 4.7,
      avis: 88,
      jobs: 176,
      annees: 10,
      verified: true,
      featured: false,
      dispo: 'Disponible aujourd’hui',
      prix: 10000,
      c1: Color(0xFF11502A),
      c2: Color(0xFF2E9A4F),
      bio:
          'Installation électrique complète, mise aux normes, dépannage 7j/7. '
          'Certifié CIE.',
      skills: ['Tableaux', 'Dépannage', 'Mise aux normes', 'Domotique'],
    ),
    Artisan(
      id: 'a4',
      name: 'Serge N’Guessan',
      metier: 'Maçon',
      cat: 'macon',
      commune: 'Abobo',
      quartier: 'Abobo Baoulé',
      note: 4.6,
      avis: 61,
      jobs: 89,
      annees: 15,
      verified: true,
      featured: false,
      dispo: 'Dispo sous 72 h',
      prix: 35000,
      c1: Color(0xFFDE7A12),
      c2: Color(0xFFF28C28),
      bio:
          'Gros œuvre, dalles, clôtures, carrelage. Équipe de 4 ouvriers '
          'qualifiés, matériel complet.',
      skills: ['Dalles', 'Clôtures', 'Carrelage', 'Fondations'],
    ),
    Artisan(
      id: 'a5',
      name: 'Fatou Koné',
      metier: 'Spécialiste climatisation',
      cat: 'climatisation',
      commune: 'Plateau',
      quartier: 'Avenue Chardy',
      note: 4.9,
      avis: 142,
      jobs: 230,
      annees: 9,
      verified: true,
      featured: true,
      dispo: 'Disponible aujourd’hui',
      prix: 20000,
      c1: Color(0xFF166236),
      c2: Color(0xFF56B947),
      bio:
          'Installation, entretien et recharge de climatiseurs split et '
          'gainables. Contrats d’entretien entreprises.',
      skills: ['Splits', 'Entretien', 'Recharge gaz', 'VRV'],
    ),
    Artisan(
      id: 'a6',
      name: 'Moussa Cissé',
      metier: 'Menuisier ébéniste',
      cat: 'menuisier',
      commune: 'Treichville',
      quartier: 'Avenue 16',
      note: 4.5,
      avis: 47,
      jobs: 72,
      annees: 18,
      verified: false,
      featured: false,
      dispo: 'Dispo sous 48 h',
      prix: 30000,
      c1: Color(0xFF0B3219),
      c2: Color(0xFF1B7A3D),
      bio:
          'Meubles sur mesure en bois massif : placards, cuisines, portes. '
          'Atelier à Treichville.',
      skills: ['Placards', 'Cuisines', 'Portes', 'Sur mesure'],
    ),
  ];

  static const avis = [
    Review(
      id: 'r1',
      name: 'Adjoua Bamba',
      commune: 'Cocody',
      note: 5,
      date: 'Il y a 3 jours',
      text:
          'Très professionnel. Il a réparé la fuite sous mon évier en moins '
          'd’une heure et a tout laissé propre. Je recommande !',
      projet: 'Réparation fuite cuisine',
    ),
    Review(
      id: 'r2',
      name: 'Éric Kouamé',
      commune: 'Bingerville',
      note: 5,
      date: 'Il y a 1 semaine',
      text:
          'Installation complète de 3 chauffe-eau dans notre résidence. '
          'Travail soigné, prix respecté, délai tenu.',
      projet: 'Installation chauffe-eau ×3',
    ),
    Review(
      id: 'r3',
      name: 'Mariam Ouattara',
      commune: 'Cocody',
      note: 4,
      date: 'Il y a 2 semaines',
      text:
          'Bon travail sur la salle de bain. Petit retard le premier jour '
          'mais il a prévenu à l’avance.',
      projet: 'Rénovation salle de bain',
    ),
  ];

  static const realisations = [
    Realisation(
      id: 'p1',
      titre: 'Salle de bain — Riviera 3',
      type: 'Rénovation complète',
      duree: '5 jours',
    ),
    Realisation(
      id: 'p2',
      titre: 'Chauffe-eau — Angré',
      type: 'Installation',
      duree: '1 jour',
    ),
    Realisation(
      id: 'p3',
      titre: 'Plomberie villa — Bingerville',
      type: 'Construction neuve',
      duree: '3 semaines',
    ),
    Realisation(
      id: 'p4',
      titre: 'Fuite encastrée — II Plateaux',
      type: 'Détection + réparation',
      duree: '2 jours',
    ),
  ];

  static const conversations = [
    Conversation(
      id: 'c1',
      artisanId: 'a1',
      unread: 2,
      last: 'Je peux passer demain à 9 h pour voir la fuite.',
      time: '14:32',
      messages: [
        ChatMessage(
          from: MessageAuthor.me,
          time: '13:05',
          text:
              'Bonjour M. Konan, j’ai une fuite sous l’évier de la '
              'cuisine à Angré 7e tranche.',
        ),
        ChatMessage(
          from: MessageAuthor.them,
          time: '13:18',
          text:
              'Bonjour ! Merci pour votre demande. Pouvez-vous m’envoyer '
              'une photo de la fuite ?',
        ),
        ChatMessage(
          from: MessageAuthor.me,
          time: '13:24',
          type: MessageType.photo,
          text: 'Photo de la fuite',
        ),
        ChatMessage(
          from: MessageAuthor.them,
          time: '14:02',
          type: MessageType.devis,
          titre: 'Réparation fuite + remplacement siphon',
          montant: 18000,
          delai: 'Intervention : demain matin',
        ),
        ChatMessage(
          from: MessageAuthor.them,
          time: '14:32',
          text: 'Je peux passer demain à 9 h pour voir la fuite.',
        ),
      ],
    ),
    Conversation(
      id: 'c2',
      artisanId: 'a2',
      unread: 0,
      last: 'Parfait, je prépare les échantillons de couleurs.',
      time: 'Hier',
    ),
    Conversation(
      id: 'c3',
      artisanId: 'a5',
      unread: 0,
      last: 'L’entretien des 2 splits est terminé ✓',
      time: 'Lun.',
    ),
  ];

  // ----- espace artisan (tablette) -----
  static const pro = ProData(
    name: 'Konan Yao',
    metier: 'Plombier',
    commune: 'Cocody',
    stats: ProStats(
      vues: 1284,
      vuesDelta: '+18 %',
      demandes: 23,
      demandesDelta: '+5',
      noteMoy: 4.9,
      revenus: '485 000',
      revenusDelta: '+12 %',
    ),
    semaine: [42, 65, 51, 78, 92, 60, 84],
    jours: ['L', 'M', 'M', 'J', 'V', 'S', 'D'],
  );

  static const demandes = [
    Demande(
      id: 'd1',
      client: 'Adjoua Bamba',
      commune: 'Cocody — Angré',
      projet: 'Fuite sous évier de cuisine',
      budget: '15 000 – 25 000 F',
      urgence: 'Urgent',
      date: 'Il y a 25 min',
      statut: DemandeStatut.nouvelle,
    ),
    Demande(
      id: 'd2',
      client: 'Éric Kouamé',
      commune: 'Bingerville',
      projet: 'Installation de 2 chauffe-eau 50 L',
      budget: '120 000 – 180 000 F',
      urgence: 'Cette semaine',
      date: 'Il y a 2 h',
      statut: DemandeStatut.nouvelle,
    ),
    Demande(
      id: 'd3',
      client: 'Mariam Ouattara',
      commune: 'Cocody — Riviera',
      projet: 'Rénovation plomberie salle de bain',
      budget: '250 000 – 400 000 F',
      urgence: 'Ce mois-ci',
      date: 'Hier',
      statut: DemandeStatut.devisEnvoye,
    ),
    Demande(
      id: 'd4',
      client: 'Jean-Marc Kouassi',
      commune: 'Marcory — Zone 4',
      projet: 'Pompe surpresseur en panne',
      budget: 'À discuter',
      urgence: 'Urgent',
      date: 'Hier',
      statut: DemandeStatut.devisEnvoye,
    ),
    Demande(
      id: 'd5',
      client: 'Salimata Doumbia',
      commune: 'Plateau',
      projet: 'Entretien plomberie bureaux (contrat)',
      budget: '80 000 F / mois',
      urgence: 'Planifié',
      date: 'Il y a 3 jours',
      statut: DemandeStatut.acceptee,
    ),
  ];

  // ----- wallet (espace artisan) -----
  static const wallet = WalletState(
    solde: 48500,
    transactions: [
      WalletTx(
        id: 'w4',
        label: 'Paiement reçu — Adjoua Bamba',
        montant: 18000,
        date: 'Hier · 18:24',
        type: WalletTxType.recharge,
      ),
      WalletTx(
        id: 'w3',
        label: 'Boost « Mis en avant » (7 j)',
        montant: -5000,
        date: 'Lun. · 09:10',
        type: WalletTxType.paiement,
      ),
      WalletTx(
        id: 'w2',
        label: 'Recharge — Orange Money',
        montant: 25000,
        date: '5 juin · 11:02',
        type: WalletTxType.recharge,
      ),
      WalletTx(
        id: 'w1',
        label: 'Retrait — Orange Money',
        montant: -20000,
        date: '2 juin · 16:45',
        type: WalletTxType.paiement,
      ),
    ],
  );

  // ----- projets (client) — les ids partagés avec les demandes lient
  // les devis créés côté artisan aux projets du client -----
  static const projets = [
    Projet(
      id: 'd1',
      titre: 'Fuite sous évier de cuisine',
      description:
          'Fuite d’eau sous l’évier de la cuisine, le placard '
          'commence à gonfler. Besoin d’une intervention rapide.',
      cat: 'plombier',
      commune: 'Cocody',
      urgence: 'Urgent (24 h)',
      budget: '15 000 – 25 000 F',
      date: 'Aujourd’hui',
      statut: ProjetStatut.devisRecus,
    ),
    Projet(
      id: 'd3',
      titre: 'Rénovation plomberie salle de bain',
      description:
          'Remplacement complet de la tuyauterie, pose d’une douche '
          'italienne et d’un double lavabo. Carrelage déjà acheté.',
      cat: 'plombier',
      commune: 'Cocody',
      urgence: 'Ce mois-ci',
      budget: '250 000 – 400 000 F',
      date: 'Hier',
      statut: ProjetStatut.devisRecus,
    ),
    Projet(
      id: 'p3',
      titre: 'Peinture du salon et du couloir',
      description:
          'Rafraîchir le salon (4 m × 5 m) et le couloir en blanc '
          'cassé, plafonds compris. Conseils couleurs bienvenus.',
      cat: 'peintre',
      commune: 'Cocody',
      urgence: 'Je planifie',
      budget: '50 000 – 150 000 F',
      date: 'Il y a 3 jours',
      statut: ProjetStatut.enAttente,
    ),
  ];

  static const devisDocs = [
    DevisDoc(
      id: 'q1',
      projetId: 'd1',
      artisanId: 'a1',
      titre: 'Réparation fuite + remplacement siphon',
      description:
          'Intervention demain matin. Main d’œuvre et pièces '
          'incluses, garantie 3 mois sur la réparation.',
      lignes: [
        DevisLigne(label: 'Main d’œuvre', valeur: '10 000'),
        DevisLigne(label: 'Siphon PVC + joints', valeur: '5 000'),
        DevisLigne(label: 'Déplacement', valeur: '3 000'),
        DevisLigne(label: 'Délai', valeur: 'Demain matin'),
        DevisLigne(label: 'Garantie', valeur: '3 mois'),
      ],
      date: 'Aujourd’hui · 14:02',
    ),
    DevisDoc(
      id: 'q2',
      projetId: 'd3',
      artisanId: 'a1',
      titre: 'Rénovation complète plomberie SDB',
      description:
          'Dépose de l’existant, tuyauterie PPR, pose douche '
          'italienne et double vasque. Durée estimée : 5 jours.',
      lignes: [
        DevisLigne(label: 'Main d’œuvre (5 j)', valeur: '180 000'),
        DevisLigne(label: 'Tuyauterie + raccords', valeur: '85 000'),
        DevisLigne(label: 'Receveur + bonde douche', valeur: '45 000'),
        DevisLigne(label: 'Évacuation déchets', valeur: '15 000'),
        DevisLigne(label: 'Début des travaux', valeur: 'Lundi prochain'),
      ],
      date: 'Hier · 17:40',
    ),
    DevisDoc(
      id: 'q3',
      projetId: 'd3',
      artisanId: 'a3',
      titre: 'Rénovation SDB — offre éco',
      description:
          'Prestation réduite, sans pose de douche italienne. '
          'Matériaux d’entrée de gamme.',
      lignes: [
        DevisLigne(label: 'Main d’œuvre (4 j)', valeur: '140 000'),
        DevisLigne(label: 'Tuyauterie standard', valeur: '60 000'),
        DevisLigne(label: 'Robinetterie', valeur: '35 000'),
      ],
      date: 'Hier · 19:05',
      statut: DevisStatut.refuse,
    ),
  ];

  static Artisan artisanById(String id) =>
      artisans.firstWhere((a) => a.id == id, orElse: () => artisans.first);

  static TaCategory? categoryById(String id) {
    for (final c in categories) {
      if (c.id == id) return c;
    }
    return null;
  }
}
