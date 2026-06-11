import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/l10n/app_strings.dart';

/// Thème clair/sombre (design : light par défaut).
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.light;

  void toggle() =>
      state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;

  void set(ThemeMode mode) => state = mode;
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

/// Langue de l'interface (FR par défaut).
class LangNotifier extends Notifier<AppLang> {
  @override
  AppLang build() => AppLang.fr;

  void set(AppLang lang) => state = lang;
}

final langProvider = NotifierProvider<LangNotifier, AppLang>(LangNotifier.new);

final stringsProvider = Provider<AppStrings>(
  (ref) => AppStrings.of(ref.watch(langProvider)),
);
