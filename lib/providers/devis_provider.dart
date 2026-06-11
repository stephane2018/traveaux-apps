import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Description pré-remplie de la démo (texte du prototype).
const kDefaultDevisDescription =
    'Fuite d’eau sous l’évier de la cuisine, le placard commence à '
    'gonfler. Besoin d’une intervention rapide.';

/// Mode de planification d'un travail non urgent : une date précise ou une
/// durée (travail vaste qui s'étend dans le temps).
enum PlanifMode { date, periode }

/// État du formulaire de demande de devis (3 étapes).
@immutable
class DevisForm {
  const DevisForm({
    this.step = 0,
    this.cat = 'plombier',
    this.commune = 'Cocody',
    this.urgence = 'Cette semaine',
    this.budget = '15 000 – 50 000 F',
    this.description = kDefaultDevisDescription,
    this.planifMode = PlanifMode.date,
    this.planifDate,
    this.planifPeriode,
  });

  final int step;
  final String cat;
  final String commune;
  final String urgence;
  final String budget;
  final String description;

  final PlanifMode planifMode;

  /// Date précise choisie (mode date).
  final DateTime? planifDate;

  /// Durée estimée choisie (mode période).
  final String? planifPeriode;

  /// Vrai si l'urgence sélectionnée n'est pas « Urgent ».
  bool get isPlanifiable => !urgence.startsWith('Urgent');

  DevisForm copyWith({
    int? step,
    String? cat,
    String? commune,
    String? urgence,
    String? budget,
    String? description,
    PlanifMode? planifMode,
    DateTime? planifDate,
    String? planifPeriode,
  }) {
    return DevisForm(
      step: step ?? this.step,
      cat: cat ?? this.cat,
      commune: commune ?? this.commune,
      urgence: urgence ?? this.urgence,
      budget: budget ?? this.budget,
      description: description ?? this.description,
      planifMode: planifMode ?? this.planifMode,
      planifDate: planifDate ?? this.planifDate,
      planifPeriode: planifPeriode ?? this.planifPeriode,
    );
  }
}

class DevisFormNotifier extends Notifier<DevisForm> {
  @override
  DevisForm build() => const DevisForm();

  void start({String? cat}) => state = DevisForm(cat: cat ?? state.cat);

  void next() => state = state.copyWith(step: state.step + 1);

  void back() => state = state.copyWith(step: state.step - 1);

  void setCat(String cat) => state = state.copyWith(cat: cat);

  void setCommune(String commune) => state = state.copyWith(commune: commune);

  void setUrgence(String urgence) => state = state.copyWith(urgence: urgence);

  void setBudget(String budget) => state = state.copyWith(budget: budget);

  void setDescription(String description) =>
      state = state.copyWith(description: description);

  void setPlanifMode(PlanifMode mode) =>
      state = state.copyWith(planifMode: mode);

  void setPlanifDate(DateTime date) => state = state.copyWith(planifDate: date);

  void setPlanifPeriode(String periode) =>
      state = state.copyWith(planifPeriode: periode);

  void reset() => state = const DevisForm();
}

final devisFormProvider =
    NotifierProvider<DevisFormNotifier, DevisForm>(DevisFormNotifier.new);
