import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/ta_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/models.dart';
import '../../providers/pro_messages_provider.dart';
import '../../shared/widgets/widgets.dart';

/// Conversation artisan ↔ client : fil de messages + composer.
/// Côté pro : `MessageAuthor.me` = l'artisan, `them` = le client.
class ProChatScreen extends ConsumerStatefulWidget {
  const ProChatScreen({super.key, required this.conversationId});

  final String conversationId;

  @override
  ConsumerState<ProChatScreen> createState() => _ProChatScreenState();
}

class _ProChatScreenState extends ConsumerState<ProChatScreen> {
  @override
  void initState() {
    super.initState();
    // Marque comme lu après le build (mutation interdite pendant le build).
    Future.microtask(
      () => ref
          .read(proConversationsProvider.notifier)
          .markRead(widget.conversationId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final conversation = ref.watch(
      proConversationProvider(widget.conversationId),
    );
    if (conversation == null) {
      return TaStatusBar(
        child: Scaffold(
          body: Center(
            child: Text('Conversation introuvable', style: context.taSub),
          ),
        ),
      );
    }

    final t = context.ta;
    // Largeur utile du fil (écran - padding horizontal) pour les bulles.
    final bodyWidth = MediaQuery.sizeOf(context).width - 2 * TaDims.pad;
    // Fil inversé : index 0 = message le plus récent, pillule de date en fin.
    final items = conversation.messages.reversed.toList();

    return TaStatusBar(
      child: Scaffold(
        backgroundColor: t.bg,
        body: Column(
          children: [
            _ChatHeader(client: conversation.client),
            Expanded(
              // `reverse` ancre le fil en bas : dernier message toujours
              // visible, y compris à l'ouverture du clavier et à l'envoi.
              child: ListView.separated(
                reverse: true,
                padding: const EdgeInsets.all(TaDims.pad),
                itemCount: items.length + 1,
                separatorBuilder: (_, _) => const SizedBox(height: 9),
                itemBuilder: (context, index) {
                  if (index == items.length) {
                    return const _DayPill(label: 'Aujourd’hui');
                  }
                  final m = items[index];
                  return switch (m.type) {
                    MessageType.devis => _DevisMessage(
                      message: m,
                      maxWidth: bodyWidth * 0.85,
                    ),
                    MessageType.photo => _PhotoMessage(
                      message: m,
                      width: bodyWidth * 0.58,
                    ),
                    MessageType.text => _TextBubble(
                      message: m,
                      maxWidth: bodyWidth * 0.78,
                    ),
                  };
                },
              ),
            ),
            _Composer(conversationId: widget.conversationId),
          ],
        ),
      ),
    );
  }
}

/// En-tête : retour, avatar client, nom + statut « En ligne », appel.
class _ChatHeader extends StatelessWidget {
  const _ChatHeader({required this.client});

  final String client;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    final topPad = MediaQuery.paddingOf(context).top;

    return Container(
      padding: EdgeInsets.fromLTRB(TaDims.pad, topPad + 12, TaDims.pad, 12),
      decoration: BoxDecoration(
        color: t.surface,
        border: Border(bottom: BorderSide(color: t.border)),
      ),
      child: Row(
        spacing: 11,
        children: [
          TaSquareButton(
            size: 36,
            radius: 11,
            background: t.surface,
            borderColor: t.borderStrong,
            onTap: () => context.pop(),
            child: TaIcon(
              TaIcons.arrowLeft,
              size: 16,
              mono: true,
              color: t.text,
            ),
          ),
          TaClientAvatar(name: client, size: 40),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  client,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: t.text,
                  ),
                ),
                Row(
                  spacing: 4,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: t.primary,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    Text(
                      'En ligne',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: t.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          TaSquareButton(
            size: 36,
            radius: 11,
            background: t.primarySoft,
            child: const TaIcon(TaIcons.phone, size: 16),
          ),
        ],
      ),
    );
  }
}

/// Pillule de date centrée (« Aujourd'hui »).
class _DayPill extends StatelessWidget {
  const _DayPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    return Align(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: t.surface2,
          borderRadius: BorderRadius.circular(TaDims.rPill),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            color: t.text3,
          ),
        ),
      ),
    );
  }
}

/// Message « devis proposé » : aligné selon l'auteur (artisan = droite).
class _DevisMessage extends StatelessWidget {
  const _DevisMessage({required this.message, required this.maxWidth});

  final ChatMessage message;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    final mine = message.from == MessageAuthor.me;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: TaCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                spacing: 8,
                children: [
                  TaIconBox(
                    icon: TaIcons.doc,
                    size: 34,
                    radius: 10,
                    iconSize: 16,
                    background: t.accentSoft,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DEVIS PROPOSÉ',
                          style: context.taLabel.copyWith(
                            color: t.accentStrong,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          message.titre ?? '',
                          style: TextStyle(
                            fontSize: TaDims.fsSm,
                            fontWeight: FontWeight.w700,
                            color: t.text,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10, bottom: 2),
                child: Text(
                  formatFcfa(message.montant ?? 0),
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: t.text,
                  ),
                ),
              ),
              Text(message.delai ?? '', style: context.taSub),
            ],
          ),
        ),
      ),
    );
  }
}

/// Message photo (placeholder stylisé), aligné selon l'auteur.
class _PhotoMessage extends StatelessWidget {
  const _PhotoMessage({required this.message, required this.width});

  final ChatMessage message;
  final double width;

  @override
  Widget build(BuildContext context) {
    final mine = message.from == MessageAuthor.me;
    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: SizedBox(
        width: width,
        child: const TaPhoto(
          height: 120,
          tone: 2,
          icon: TaIcons.camera,
          label: 'Photo',
        ),
      ),
    );
  }
}

/// Bulle de texte : verte à droite (artisan), surface à gauche (client).
class _TextBubble extends StatelessWidget {
  const _TextBubble({required this.message, required this.maxWidth});

  final ChatMessage message;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    final mine = message.from == MessageAuthor.me;
    final ink = mine ? t.primaryInk : t.text;

    return Align(
      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: mine ? t.primary : t.surface,
            border: mine ? null : Border.all(color: t.border),
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(TaDims.rCard),
              topRight: const Radius.circular(TaDims.rCard),
              bottomRight: Radius.circular(mine ? 6 : TaDims.rCard),
              bottomLeft: Radius.circular(mine ? TaDims.rCard : 6),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                message.text,
                style: TextStyle(
                  fontSize: TaDims.fsSm,
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                  color: ink,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text(
                  message.time,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: ink.withValues(alpha: 0.65),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Barre de saisie : photo, champ texte, envoi.
class _Composer extends ConsumerStatefulWidget {
  const _Composer({required this.conversationId});

  final String conversationId;

  @override
  ConsumerState<_Composer> createState() => _ComposerState();
}

class _ComposerState extends ConsumerState<_Composer> {
  final _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final hasText = _controller.text.trim().isNotEmpty;
      if (hasText != _hasText) setState(() => _hasText = hasText);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    ref
        .read(proConversationsProvider.notifier)
        .sendMessage(widget.conversationId, text);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    // Clavier ouvert → padding compact, sinon zone du geste système (30 min).
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;
    final bottomPad = keyboardOpen ? 10.0 : math.max(30.0, bottomInset + 10);

    return Container(
      padding: EdgeInsets.fromLTRB(TaDims.pad, 10, TaDims.pad, bottomPad),
      decoration: BoxDecoration(
        color: t.surface,
        border: Border(top: BorderSide(color: t.border)),
      ),
      child: Row(
        spacing: 9,
        children: [
          TaSquareButton(
            size: 42,
            radius: 13,
            background: t.surface2,
            child: const TaIcon(TaIcons.camera, size: 19),
          ),
          Expanded(
            child: TaInput(
              controller: _controller,
              height: 42,
              hint: 'Écrire un message…',
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _send(),
            ),
          ),
          AnimatedOpacity(
            duration: const Duration(milliseconds: 150),
            opacity: _hasText ? 1 : 0.55,
            child: TaSquareButton(
              size: 42,
              radius: 13,
              background: t.primary,
              onTap: _send,
              child: TaIcon(
                TaIcons.send,
                size: 18,
                mono: true,
                color: t.primaryInk,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
