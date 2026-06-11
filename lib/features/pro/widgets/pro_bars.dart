import 'package:flutter/material.dart';

import '../../../core/theme/ta_tokens.dart';

/// Graphique barres des vues hebdomadaires : la 5e barre (vendredi) est mise
/// en avant en orange avec son étiquette « N vues ».
class ProBars extends StatelessWidget {
  const ProBars({super.key, required this.data, required this.jours});

  final List<int> data;
  final List<String> jours;

  static const _highlightIndex = 4;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    final max = data.reduce((a, b) => a > b ? a : b);
    return SizedBox(
      height: 120,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        spacing: 10,
        children: [
          for (var i = 0; i < data.length; i++)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: 6,
                children: [
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: double.infinity,
                        height: data[i] / max * 96,
                        decoration: BoxDecoration(
                          color: i == _highlightIndex
                              ? t.accent
                              : t.primarySoft,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(7),
                            bottom: Radius.circular(3),
                          ),
                        ),
                      ),
                      if (i == _highlightIndex)
                        Positioned(
                          top: -22,
                          left: -30,
                          right: -30,
                          child: Center(
                            child: Text(
                              '${data[i]} vues',
                              maxLines: 1,
                              softWrap: false,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: t.accentStrong,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  Text(
                    jours[i],
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: t.text3,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
