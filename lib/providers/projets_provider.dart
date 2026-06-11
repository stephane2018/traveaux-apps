import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_data.dart';
import '../data/models/models.dart';

/// Projets du client. Les ids partagés avec les demandes côté artisan
/// lient les devis créés par l'artisan aux projets du client.
class ProjetsNotifier extends Notifier<List<Projet>> {
  int _counter = 10;

  @override
  List<Projet> build() => MockData.projets;

  /// Crée un projet depuis le formulaire de demande de devis.
  void addProjet({
    required String titre,
    required String description,
    required String cat,
    required String commune,
    required String urgence,
    required String budget,
  }) {
    state = [
      Projet(
        id: 'p${_counter++}',
        titre: titre,
        description: description,
        cat: cat,
        commune: commune,
        urgence: urgence,
        budget: budget,
        date: 'À l’instant',
        statut: ProjetStatut.enAttente,
      ),
      ...state,
    ];
  }

  void setStatut(String id, ProjetStatut statut) {
    state = [
      for (final p in state)
        if (p.id == id) p.copyWith(statut: statut) else p,
    ];
  }

  /// Le client confirme la bonne réalisation et note l'artisan.
  /// Si l'artisan a déjà marqué terminé → passe en validation admin.
  void confirmByClient(String id, {required int note, String? comment}) {
    state = [
      for (final p in state)
        if (p.id == id)
          p.copyWith(
            clientNote: note,
            clientComment: comment,
            statut: p.artisanDone ? ProjetStatut.enValidation : p.statut,
          )
        else
          p,
    ];
  }

  /// L'artisan marque le travail comme terminé.
  /// Si le client a déjà confirmé → passe en validation admin.
  void markArtisanDone(String id) {
    state = [
      for (final p in state)
        if (p.id == id)
          p.copyWith(
            artisanDone: true,
            statut: p.clientConfirmed ? ProjetStatut.enValidation : p.statut,
          )
        else
          p,
    ];
  }
}

final projetsProvider = NotifierProvider<ProjetsNotifier, List<Projet>>(
  ProjetsNotifier.new,
);

final projetProvider = Provider.family<Projet?, String>((ref, id) {
  for (final p in ref.watch(projetsProvider)) {
    if (p.id == id) return p;
  }
  return null;
});

/// Devis structurés (créés côté artisan, lus côté client).
class DevisDocsNotifier extends Notifier<List<DevisDoc>> {
  int _counter = 10;

  @override
  List<DevisDoc> build() => MockData.devisDocs;

  /// L'artisan envoie un devis sur une demande/projet.
  void addDevis({
    required String projetId,
    required String artisanId,
    required String titre,
    required String description,
    required List<DevisLigne> lignes,
  }) {
    state = [
      DevisDoc(
        id: 'q${_counter++}',
        projetId: projetId,
        artisanId: artisanId,
        titre: titre,
        description: description,
        lignes: lignes,
        date: 'À l’instant',
      ),
      ...state,
    ];
    // Le projet client correspondant passe en « devis reçus ».
    final projets = ref.read(projetsProvider);
    if (projets.any((p) => p.id == projetId)) {
      ref
          .read(projetsProvider.notifier)
          .setStatut(projetId, ProjetStatut.devisRecus);
    }
  }

  /// Le client accepte un devis et réserve la date d'intervention [rdv] :
  /// le projet passe « en cours ».
  void accepter(String devisId, {String? rdv}) {
    state = [
      for (final d in state)
        if (d.id == devisId)
          d.copyWith(statut: DevisStatut.accepte, rdv: rdv)
        else
          d,
    ];
    final devis = state.firstWhere((d) => d.id == devisId);
    ref
        .read(projetsProvider.notifier)
        .setStatut(devis.projetId, ProjetStatut.enCours);
  }

  /// Le client refuse un devis (sans incidence sur le statut du projet).
  void refuser(String devisId) {
    state = [
      for (final d in state)
        if (d.id == devisId) d.copyWith(statut: DevisStatut.refuse) else d,
    ];
  }
}

final devisDocsProvider = NotifierProvider<DevisDocsNotifier, List<DevisDoc>>(
  DevisDocsNotifier.new,
);

/// Devis d'un projet donné, plus récents d'abord.
final devisForProjetProvider = Provider.family<List<DevisDoc>, String>(
  (ref, projetId) => ref
      .watch(devisDocsProvider)
      .where((d) => d.projetId == projetId)
      .toList(),
);

/// Devis accepté d'un projet (le chantier de l'artisan), s'il existe.
final devisAccepteProvider = Provider.family<DevisDoc?, String>((
  ref,
  projetId,
) {
  for (final d in ref.watch(devisDocsProvider)) {
    if (d.projetId == projetId && d.statut == DevisStatut.accepte) return d;
  }
  return null;
});

/// Chantier de l'artisan : un projet dont le devis a été accepté.
@immutable
class Chantier {
  const Chantier({required this.projet, required this.devis});

  final Projet projet;
  final DevisDoc devis;
}

/// Chantiers de l'artisan (projets avec devis accepté), non terminés d'abord.
final chantiersProvider = Provider<List<Chantier>>((ref) {
  final projets = ref.watch(projetsProvider);
  final accepte = ref
      .watch(devisDocsProvider)
      .where((d) => d.statut == DevisStatut.accepte);
  final byId = {for (final p in projets) p.id: p};
  return [
    for (final d in accepte)
      if (byId[d.projetId] case final p?) Chantier(projet: p, devis: d),
  ]..sort((a, b) => a.projet.statut == ProjetStatut.termine ? 1 : 0);
});

/// Total des paiements en attente (chantiers en validation admin).
final paiementEnAttenteProvider = Provider<int>((ref) {
  return ref
      .watch(chantiersProvider)
      .where((c) => c.projet.statut == ProjetStatut.enValidation)
      .fold(0, (sum, c) => sum + c.devis.total);
});
