import 'package:flutter/material.dart';

import '../../../core/theme/ta_tokens.dart';
import '../../../data/models/models.dart';
import '../../../shared/widgets/widgets.dart';

/// Pastille de statut d'une demande de devis.
class ProStatutBadge extends StatelessWidget {
  const ProStatutBadge({super.key, required this.statut});

  final DemandeStatut statut;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    final (label, bg, fg) = switch (statut) {
      DemandeStatut.nouvelle => ('Nouvelle', t.accentSoft, t.accentStrong),
      DemandeStatut.devisEnvoye => ('Devis envoyé', t.primarySoft, t.primary),
      DemandeStatut.acceptee => ('Acceptée', t.primary, t.primaryInk),
    };
    return TaBadge(label: label, background: bg, foreground: fg);
  }
}
