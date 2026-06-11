import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/ta_tokens.dart';
import '../../data/models/models.dart';
import '../../providers/data_providers.dart';
import '../../shared/widgets/widgets.dart';

/// Page « Messages » de l'espace artisan : conversations avec les clients.
class ProMessagesPage extends ConsumerWidget {
  const ProMessagesPage({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final demandes = ref.watch(demandesProvider);
    // Conversations dérivées des demandes clients (un fil par client).
    final threads = [for (final d in demandes) _thread(d)];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!compact) ...[
          Text('Messages', style: context.taH1.copyWith(fontSize: 24)),
          const SizedBox(height: 3),
          Text(
            'Échangez avec vos clients pour préciser leurs travaux',
            style: context.taSub,
          ),
          const SizedBox(height: 18),
        ],
        for (var i = 0; i < threads.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          _ThreadCard(thread: threads[i]),
        ],
      ],
    );
  }

  /// Construit un fil d'aperçu depuis une demande (préview selon le statut).
  _Thread _thread(Demande d) {
    final (String last, bool unread) = switch (d.statut) {
      DemandeStatut.nouvelle => ('Nouvelle demande · répondez sous 24 h', true),
      DemandeStatut.devisEnvoye => ('Vous avez envoyé un devis', false),
      DemandeStatut.acceptee => (
        'Devis accepté · planifiez l’intervention',
        false,
      ),
    };
    return _Thread(
      client: d.client,
      projet: d.projet,
      last: last,
      time: d.date,
      unread: unread,
    );
  }
}

/// Fil de conversation (vue artisan).
class _Thread {
  const _Thread({
    required this.client,
    required this.projet,
    required this.last,
    required this.time,
    required this.unread,
  });

  final String client;
  final String projet;
  final String last;
  final String time;
  final bool unread;
}

class _ThreadCard extends StatelessWidget {
  const _ThreadCard({required this.thread});

  final _Thread thread;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    final c = thread;
    return TaCard(
      onTap: () {},
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
                          fontSize: TaDims.fsSm,
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
                        color: c.unread ? t.primary : t.text3,
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
                          fontWeight: c.unread
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: c.unread ? t.text : t.text2,
                        ),
                      ),
                    ),
                    if (c.unread)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: t.accent,
                          shape: BoxShape.circle,
                        ),
                      ),
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
