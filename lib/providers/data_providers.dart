import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_data.dart';
import '../data/models/models.dart';

/// Couche données — providers prêts à être remplacés par une vraie API.
final categoriesProvider = Provider<List<TaCategory>>(
  (ref) => MockData.categories,
);

final communesProvider = Provider<List<String>>((ref) => MockData.communes);

final artisansProvider = Provider<List<Artisan>>((ref) => MockData.artisans);

final featuredArtisansProvider = Provider<List<Artisan>>(
  (ref) => ref.watch(artisansProvider).where((a) => a.featured).toList(),
);

final artisanProvider = Provider.family<Artisan, String>(
  (ref, id) => MockData.artisanById(id),
);

final avisProvider = Provider<List<Review>>((ref) => MockData.avis);

/// Réalisations — mutable (ajout local depuis l'espace artisan).
class RealisationsNotifier extends Notifier<List<Realisation>> {
  int _counter = 100;

  @override
  List<Realisation> build() => MockData.realisations;

  void add({
    required String titre,
    required String type,
    required String duree,
    required String commune,
    required String description,
  }) {
    state = [
      Realisation(
        id: 'p${_counter++}',
        titre: titre,
        type: type,
        duree: duree,
        commune: commune,
        description: description,
      ),
      ...state,
    ];
  }
}

final realisationsProvider =
    NotifierProvider<RealisationsNotifier, List<Realisation>>(
      RealisationsNotifier.new,
    );

final realisationProvider = Provider.family<Realisation?, String>((ref, id) {
  for (final r in ref.watch(realisationsProvider)) {
    if (r.id == id) return r;
  }
  return null;
});

/// Profil artisan connecté — mutable (édition locale).
class ProProfileNotifier extends Notifier<Artisan> {
  @override
  Artisan build() => MockData.artisans.first;

  void update(Artisan artisan) => state = artisan;
}

final proProfileProvider = NotifierProvider<ProProfileNotifier, Artisan>(
  ProProfileNotifier.new,
);

/// Conversations — mutable pour l'envoi local de messages (en attendant l'API).
class ConversationsNotifier extends Notifier<List<Conversation>> {
  @override
  List<Conversation> build() => MockData.conversations;

  /// Ajoute un message « moi » au fil et met à jour l'aperçu de la liste.
  void sendMessage(String conversationId, String text) {
    final now = TimeOfDay.now();
    final time =
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}';
    state = [
      for (final c in state)
        if (c.id == conversationId)
          c.copyWith(
            last: text,
            time: time,
            messages: [
              ...c.messages,
              ChatMessage(from: MessageAuthor.me, text: text, time: time),
            ],
          )
        else
          c,
    ];
  }
}

final conversationsProvider =
    NotifierProvider<ConversationsNotifier, List<Conversation>>(
      ConversationsNotifier.new,
    );

final conversationProvider = Provider.family<Conversation?, String>((ref, id) {
  for (final c in ref.watch(conversationsProvider)) {
    if (c.id == id) return c;
  }
  return null;
});

final unreadCountProvider = Provider<int>(
  (ref) => ref.watch(conversationsProvider).fold(0, (sum, c) => sum + c.unread),
);

final proDataProvider = Provider<ProData>((ref) => MockData.pro);

final demandesProvider = Provider<List<Demande>>((ref) => MockData.demandes);
