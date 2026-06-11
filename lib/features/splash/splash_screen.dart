import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/ta_tokens.dart';
import '../../shared/widgets/widgets.dart';

/// Écran de démarrage : logo et marque animés sur le dégradé vert,
/// puis redirection vers l'onboarding.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );

  late final Animation<double> _logoScale = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, 0.7, curve: Curves.easeOutBack),
  );

  late final Animation<double> _fadeIn = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.25, 1, curve: Curves.easeOut),
  );

  Timer? _exitTimer;

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _exitTimer = Timer(const Duration(milliseconds: 1600), () {
      if (mounted) context.go('/onboarding');
    });
  }

  @override
  void dispose() {
    _exitTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    return TaStatusBar(
      forceLight: true,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(gradient: t.headerGrad),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _logoScale,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 22, 24, 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                    boxShadow: t.shadowPop,
                  ),
                  child: const TaLogo(size: 64),
                ),
              ),
              const SizedBox(height: 18),
              FadeTransition(
                opacity: _fadeIn,
                child: Column(
                  children: [
                    const TaWordmark(size: 28, light: true),
                    const SizedBox(height: 10),
                    Text(
                      'Fait à Abidjan',
                      style: TextStyle(
                        color: t.headerInk2,
                        fontSize: TaDims.fsSm,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
