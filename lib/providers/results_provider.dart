import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/models.dart';
import 'data_providers.dart';

/// Filtres de l'écran Résultats (métier + commune).
@immutable
class ResultsFilter {
  const ResultsFilter({this.cat = 'all', this.commune = 'Toutes'});

  final String cat;
  final String commune;

  ResultsFilter copyWith({String? cat, String? commune}) =>
      ResultsFilter(cat: cat ?? this.cat, commune: commune ?? this.commune);
}

class ResultsFilterNotifier extends Notifier<ResultsFilter> {
  @override
  ResultsFilter build() => const ResultsFilter();

  void setCat(String cat) => state = state.copyWith(cat: cat);

  void setCommune(String commune) => state = state.copyWith(commune: commune);

  void reset({String cat = 'all'}) => state = ResultsFilter(cat: cat);
}

final resultsFilterProvider =
    NotifierProvider<ResultsFilterNotifier, ResultsFilter>(
      ResultsFilterNotifier.new,
    );

/// Artisans filtrés, « Mis en avant » d'abord.
final filteredArtisansProvider = Provider<List<Artisan>>((ref) {
  final filter = ref.watch(resultsFilterProvider);
  final artisans = ref.watch(artisansProvider);
  final list =
      artisans
          .where((a) => filter.cat == 'all' || a.cat == filter.cat)
          .where(
            (a) => filter.commune == 'Toutes' || a.commune == filter.commune,
          )
          .toList()
        ..sort((a, b) => (b.featured ? 1 : 0) - (a.featured ? 1 : 0));
  return list;
});
