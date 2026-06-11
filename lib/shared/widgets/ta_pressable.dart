import 'package:flutter/material.dart';

/// Effet « ta-press » du design : léger rétrécissement à l'appui.
class TaPressable extends StatefulWidget {
  const TaPressable({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.985,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;

  @override
  State<TaPressable> createState() => _TaPressableState();
}

class _TaPressableState extends State<TaPressable> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1,
        duration: const Duration(milliseconds: 120),
        child: widget.child,
      ),
    );
  }
}
