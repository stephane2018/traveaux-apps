import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Style de barre de statut du design : icônes claires sur les écrans à
/// en-tête vert ([forceLight]) ou en mode sombre, foncées sinon.
class TaStatusBar extends StatelessWidget {
  const TaStatusBar({super.key, required this.child, this.forceLight = false});

  final Widget child;
  final bool forceLight;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final light = forceLight || dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: light ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: child,
    );
  }
}
