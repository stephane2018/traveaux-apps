import 'package:flutter/material.dart';

import '../../shared/widgets/ta_icon.dart';

@immutable
class TaCategory {
  const TaCategory({
    required this.id,
    required this.label,
    required this.icon,
    required this.count,
  });

  final String id;
  final String label;
  final TaIcons icon;
  final int count;
}

@immutable
class Artisan {
  const Artisan({
    required this.id,
    required this.name,
    required this.metier,
    required this.cat,
    required this.commune,
    required this.quartier,
    required this.note,
    required this.avis,
    required this.jobs,
    required this.annees,
    required this.verified,
    required this.featured,
    required this.dispo,
    required this.prix,
    required this.c1,
    required this.c2,
    required this.bio,
    required this.skills,
  });

  final String id;
  final String name;
  final String metier;
  final String cat;
  final String commune;
  final String quartier;
  final double note;
  final int avis;
  final int jobs;
  final int annees;
  final bool verified;
  final bool featured;
  final String dispo;
  final int prix;
  final Color c1;
  final Color c2;
  final String bio;
  final List<String> skills;

  String get initials => name.split(' ').map((w) => w[0]).take(2).join();

  Artisan copyWith({
    String? name,
    String? metier,
    String? commune,
    String? quartier,
    String? dispo,
    int? prix,
    String? bio,
    List<String>? skills,
  }) {
    return Artisan(
      id: id,
      name: name ?? this.name,
      metier: metier ?? this.metier,
      cat: cat,
      commune: commune ?? this.commune,
      quartier: quartier ?? this.quartier,
      note: note,
      avis: avis,
      jobs: jobs,
      annees: annees,
      verified: verified,
      featured: featured,
      dispo: dispo ?? this.dispo,
      prix: prix ?? this.prix,
      c1: c1,
      c2: c2,
      bio: bio ?? this.bio,
      skills: skills ?? this.skills,
    );
  }
}

@immutable
class Review {
  const Review({
    required this.id,
    required this.name,
    required this.commune,
    required this.note,
    required this.date,
    required this.text,
    required this.projet,
  });

  final String id;
  final String name;
  final String commune;
  final double note;
  final String date;
  final String text;
  final String projet;
}

@immutable
class Realisation {
  const Realisation({
    required this.id,
    required this.titre,
    required this.type,
    required this.duree,
    this.description = '',
    this.commune = '',
  });

  final String id;
  final String titre;
  final String type;
  final String duree;
  final String description;
  final String commune;
}

enum MessageAuthor { me, them }

enum MessageType { text, photo, devis }

@immutable
class ChatMessage {
  const ChatMessage({
    required this.from,
    required this.time,
    this.type = MessageType.text,
    this.text = '',
    this.titre,
    this.montant,
    this.delai,
  });

  final MessageAuthor from;
  final MessageType type;
  final String text;
  final String time;

  /// Champs spécifiques aux messages de type devis.
  final String? titre;
  final int? montant;
  final String? delai;
}

@immutable
class Conversation {
  const Conversation({
    required this.id,
    required this.artisanId,
    required this.unread,
    required this.last,
    required this.time,
    this.messages = const [],
  });

  final String id;
  final String artisanId;
  final int unread;
  final String last;
  final String time;
  final List<ChatMessage> messages;

  Conversation copyWith({
    int? unread,
    String? last,
    String? time,
    List<ChatMessage>? messages,
  }) {
    return Conversation(
      id: id,
      artisanId: artisanId,
      unread: unread ?? this.unread,
      last: last ?? this.last,
      time: time ?? this.time,
      messages: messages ?? this.messages,
    );
  }
}

/// Conversation côté artisan (avec un client). « me » = l'artisan.
@immutable
class ProConversation {
  const ProConversation({
    required this.id,
    required this.client,
    required this.projet,
    required this.last,
    required this.time,
    required this.unread,
    this.messages = const [],
  });

  final String id;
  final String client;
  final String projet;
  final String last;
  final String time;
  final int unread;
  final List<ChatMessage> messages;

  ProConversation copyWith({
    String? last,
    String? time,
    int? unread,
    List<ChatMessage>? messages,
  }) {
    return ProConversation(
      id: id,
      client: client,
      projet: projet,
      last: last ?? this.last,
      time: time ?? this.time,
      unread: unread ?? this.unread,
      messages: messages ?? this.messages,
    );
  }
}

@immutable
class ProStats {
  const ProStats({
    required this.vues,
    required this.vuesDelta,
    required this.demandes,
    required this.demandesDelta,
    required this.noteMoy,
    required this.revenus,
    required this.revenusDelta,
  });

  final int vues;
  final String vuesDelta;
  final int demandes;
  final String demandesDelta;
  final double noteMoy;
  final String revenus;
  final String revenusDelta;
}

@immutable
class ProData {
  const ProData({
    required this.name,
    required this.metier,
    required this.commune,
    required this.stats,
    required this.semaine,
    required this.jours,
  });

  final String name;
  final String metier;
  final String commune;
  final ProStats stats;
  final List<int> semaine;
  final List<String> jours;
}

enum DemandeStatut { nouvelle, devisEnvoye, acceptee }

// ─── Wallet ───

enum WalletTxType { recharge, paiement }

@immutable
class WalletTx {
  const WalletTx({
    required this.id,
    required this.label,
    required this.montant,
    required this.date,
    required this.type,
  });

  final String id;
  final String label;

  /// Positif = crédit (recharge), négatif = débit (paiement).
  final int montant;
  final String date;
  final WalletTxType type;
}

@immutable
class WalletState {
  const WalletState({required this.solde, required this.transactions});

  final int solde;
  final List<WalletTx> transactions;

  WalletState copyWith({int? solde, List<WalletTx>? transactions}) {
    return WalletState(
      solde: solde ?? this.solde,
      transactions: transactions ?? this.transactions,
    );
  }
}

// ─── Projets (côté client) & devis structurés ───

enum ProjetStatut { enAttente, devisRecus, enCours, enValidation, termine }

@immutable
class Projet {
  const Projet({
    required this.id,
    required this.titre,
    required this.description,
    required this.cat,
    required this.commune,
    required this.urgence,
    required this.budget,
    required this.date,
    required this.statut,
    this.artisanDone = false,
    this.clientNote,
    this.clientComment,
  });

  final String id;
  final String titre;
  final String description;
  final String cat;
  final String commune;
  final String urgence;
  final String budget;
  final String date;
  final ProjetStatut statut;

  /// L'artisan a marqué le travail comme terminé.
  final bool artisanDone;

  /// Note (1-5) et commentaire laissés par le client à la réception.
  final int? clientNote;
  final String? clientComment;

  /// Le client a confirmé la bonne réalisation (et noté).
  bool get clientConfirmed => clientNote != null;

  Projet copyWith({
    ProjetStatut? statut,
    bool? artisanDone,
    int? clientNote,
    String? clientComment,
  }) {
    return Projet(
      id: id,
      titre: titre,
      description: description,
      cat: cat,
      commune: commune,
      urgence: urgence,
      budget: budget,
      date: date,
      statut: statut ?? this.statut,
      artisanDone: artisanDone ?? this.artisanDone,
      clientNote: clientNote ?? this.clientNote,
      clientComment: clientComment ?? this.clientComment,
    );
  }
}

/// Ligne clé/valeur d'un devis. Si la valeur est numérique, elle entre
/// dans le total.
@immutable
class DevisLigne {
  const DevisLigne({required this.label, required this.valeur});

  final String label;
  final String valeur;

  /// Montant numérique de la ligne (espaces ignorés), sinon null.
  int? get montant {
    final digits = valeur.replaceAll(RegExp(r'[\s  ]'), '');
    return RegExp(r'^\d+$').hasMatch(digits) ? int.parse(digits) : null;
  }
}

enum DevisStatut { propose, accepte, refuse }

/// Devis structuré envoyé par un artisan sur un projet/demande.
@immutable
class DevisDoc {
  const DevisDoc({
    required this.id,
    required this.projetId,
    required this.artisanId,
    required this.titre,
    required this.description,
    required this.lignes,
    required this.date,
    this.statut = DevisStatut.propose,
    this.rdv,
  });

  final String id;
  final String projetId;
  final String artisanId;
  final String titre;
  final String description;
  final List<DevisLigne> lignes;
  final String date;
  final DevisStatut statut;

  /// Rendez-vous d'intervention réservé à l'acceptation (libellé daté).
  final String? rdv;

  /// Somme des lignes numériques.
  int get total => lignes.fold(0, (sum, l) => sum + (l.montant ?? 0));

  DevisDoc copyWith({DevisStatut? statut, String? rdv}) {
    return DevisDoc(
      id: id,
      projetId: projetId,
      artisanId: artisanId,
      titre: titre,
      description: description,
      lignes: lignes,
      date: date,
      statut: statut ?? this.statut,
      rdv: rdv ?? this.rdv,
    );
  }
}

@immutable
class Demande {
  const Demande({
    required this.id,
    required this.client,
    required this.commune,
    required this.projet,
    required this.budget,
    required this.urgence,
    required this.date,
    required this.statut,
  });

  final String id;
  final String client;
  final String commune;
  final String projet;
  final String budget;
  final String urgence;
  final String date;
  final DemandeStatut statut;
}
