import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_palette.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/ta_tokens.dart';
import '../../data/models/models.dart';
import '../../providers/data_providers.dart';
import '../../shared/widgets/widgets.dart';

/// Liste des conversations avec les artisans.
class MessagesScreen extends ConsumerWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.ta;
    final conversations = ref.watch(conversationsProvider);

    return TaStatusBar(
      forceLight: true,
      child: Scaffold(
        backgroundColor: t.bg,
        body: Column(
          children: [
            const _Header(),
            // ----- conversations (liste resserrée) -----
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(
                  TaDims.pad,
                  TaDims.pad,
                  TaDims.pad,
                  116,
                ),
                itemCount: conversations.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, i) =>
                    _ConversationCard(conversation: conversations[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// En-tête vert à bas arrondi : titre + bouton « Nouveau » (demande de devis).
class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    return Container(
      width: double.infinity,
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
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Messages',
                  style: TextStyle(
                    color: t.headerInk,
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.46,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Vos conversations avec les artisans',
                  style: TextStyle(
                    color: t.headerInk2,
                    fontSize: TaDims.fsSm,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          TaPressable(
            onTap: () => context.push('/devis'),
            child: Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(13),
                boxShadow: t.shadowPop,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 6,
                children: [
                  const TaIcon(TaIcons.plus, size: 16),
                  Text(
                    'Nouveau',
                    style: TextStyle(
                      color: AppPalette.green700,
                      fontSize: TaDims.fsSm,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Carte d'une conversation : avatar, nom, heure, dernier message, non-lus.
class _ConversationCard extends ConsumerWidget {
  const _ConversationCard({required this.conversation});

  final Conversation conversation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.ta;
    final artisan = ref.watch(artisanProvider(conversation.artisanId));
    final hasMessages = conversation.messages.isNotEmpty;
    final unread = conversation.unread > 0;

    return Opacity(
      opacity: hasMessages ? 1 : 0.8,
      child: TaCard(
        padding: const EdgeInsets.all(14),
        onTap: hasMessages
            ? () => context.push('/chat/${conversation.id}')
            : null,
        child: Row(
          spacing: 12,
          children: [
            TaAvatar(artisan: artisan, size: 48),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        artisan.name,
                        style: TextStyle(
                          fontSize: TaDims.fsSm,
                          fontWeight: FontWeight.w800,
                          color: t.text,
                        ),
                      ),
                      Text(
                        conversation.time,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: unread ? t.primary : t.text3,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    spacing: 8,
                    children: [
                      Expanded(
                        child: Text(
                          conversation.last,
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
                      if (unread) TaUnreadBadge(count: conversation.unread),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
