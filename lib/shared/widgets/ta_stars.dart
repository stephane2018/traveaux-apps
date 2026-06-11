import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/ta_tokens.dart';

const _starPath =
    'm12 2.6 2.8 5.8 6.3.9-4.6 4.4 1.1 6.3L12 17l-5.6 3 1.1-6.3L2.9 9.3l6.3-.9L12 2.6Z';

/// Rangée de 5 étoiles de notation.
class TaStars extends StatelessWidget {
  const TaStars({super.key, required this.note, this.size = 13});

  final double note;
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    String hex(Color c) =>
        '#${c.toARGB32().toRadixString(16).padLeft(8, '0').substring(2)}';
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 1.5,
      children: [
        for (var i = 1; i <= 5; i++)
          SvgPicture.string(
            '<svg viewBox="0 0 24 24"><path d="$_starPath" '
            'fill="${hex(i <= note.round() ? t.star : t.borderStrong)}"/></svg>',
            width: size,
            height: size,
          ),
      ],
    );
  }
}
