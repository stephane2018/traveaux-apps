import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/ta_tokens.dart';
import '../../data/models/models.dart';
import '../../providers/pro_messages_provider.dart';
import '../../shared/widgets/widgets.dart';

/// Page « Messages » de l'espace artisan : conversations avec les clients.
/// Rendue dans le shell (qui fournit scroll + padding).
class ProMessagesPage extends ConsumerWidget {
  const ProMessagesPage({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final conversations = ref.watch(proConversationsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!compact) ...[
          // Sur tablette, le titre est rendu ici (pas d'en-tête vert).
          Text('Messages', style: context.taH1.copyWith(fontSize: 24)),
          const SizedBox(height: 3),
          Text(
            'Échangez avec vos clients pour préciser leurs travaux',
            style: context.taSub,
          ),
          const SizedBox(height: 18),
        ],
        for (var i = 0; i < conversations.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          _ConversationCard(conversation: conversations[i]),
        ],
      ],
    );
  }
}

/// Aperçu d'une conversation : avatar, nom, projet, dernier message.
class _ConversationCard extends StatelessWidget {
  const _ConversationCard({required this.conversation});

  final ProConversation conversation;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    final c = conversation;
    final unread = c.unread > 0;

    return TaCard(
      onTap: () => context.push('/pro/chat/${c.id}'),
      padding: const EdgeInsets.all(14),
      child: Row(
        spacing: 12,
        children: [
          TaClientAvatar(name: c.client, size: 48),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        c.client,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: t.text,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      c.time,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: unread ? t.primary : t.text3,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  c.projet,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.taSub.copyWith(fontSize: 11.5),
                ),
                const SizedBox(height: 4),
                Row(
                  spacing: 8,
                  children: [
                    Expanded(
                      child: Text(
                        c.last,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.taSub.copyWith(
                          fontWeight: unread
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: unread ? t.text : t.text2,
                        ),
                      ),
                    ),
                    if (unread) TaUnreadBadge(count: c.unread),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
