import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/mock_data.dart';
import '../data/models/models.dart';

/// Conversations de l'artisan avec ses clients (mutable : envoi + lecture).
class ProConversationsNotifier extends Notifier<List<ProConversation>> {
  @override
  List<ProConversation> build() => MockData.proConversations;

  /// Marque une conversation comme lue (remet le compteur à zéro).
  void markRead(String id) {
    state = [
      for (final c in state)
        if (c.id == id && c.unread > 0) c.copyWith(unread: 0) else c,
    ];
  }

  /// L'artisan envoie un message texte au client.
  void sendMessage(String id, String text) {
    final now = DateTime.now();
    final time =
        '${now.hour.toString().padLeft(2, '0')}:'
        '${now.minute.toString().padLeft(2, '0')}';
    state = [
      for (final c in state)
        if (c.id == id)
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

final proConversationsProvider =
    NotifierProvider<ProConversationsNotifier, List<ProConversation>>(
      ProConversationsNotifier.new,
    );

final proConversationProvider = Provider.family<ProConversation?, String>((
  ref,
  id,
) {
  for (final c in ref.watch(proConversationsProvider)) {
    if (c.id == id) return c;
  }
  return null;
});

/// Total des messages non lus côté artisan.
final proUnreadProvider = Provider<int>(
  (ref) => ref
      .watch(proConversationsProvider)
      .fold(0, (sum, c) => sum + c.unread),
);
