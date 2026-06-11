enum AppLang { fr, en }

/// Chaînes localisées FR/EN — le design ne traduit que l'onboarding,
/// le reste de l'app est en français.
class AppStrings {
  const AppStrings._(this.lang);

  final AppLang lang;

  static const _fr = AppStrings._(AppLang.fr);
  static const _en = AppStrings._(AppLang.en);

  factory AppStrings.of(AppLang lang) => lang == AppLang.fr ? _fr : _en;

  bool get isFr => lang == AppLang.fr;

  String get onboardingTagline => isFr
      ? 'Trouvez un artisan de confiance près de chez vous, partout à Abidjan.'
      : 'Find a trusted craftsman near you, anywhere in Abidjan.';

  String get signInTitle =>
      isFr ? 'Connexion ou inscription' : 'Sign in or sign up';

  String get phoneHint => '07 XX XX XX XX';

  String get continueLabel => isFr ? 'Continuer' : 'Continue';

  String get or => isFr ? 'ou' : 'or';

  String get continueWithGoogle =>
      isFr ? 'Continuer avec Google' : 'Continue with Google';

  String get imACraftsman => isFr
      ? 'Je suis artisan — créer mon profil pro'
      : 'I’m a craftsman — create my pro profile';
}
