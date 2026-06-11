import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/ta_tokens.dart';
import '../../providers/settings_providers.dart';
import '../../shared/widgets/widgets.dart';

/// Logo Google multicolore (recopié du design).
const _googleLogoSvg = '''
<svg viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg">
  <path d="M21.6 12.2c0-.7-.1-1.4-.2-2H12v3.9h5.4a4.6 4.6 0 0 1-2 3v2.5h3.2c1.9-1.7 3-4.3 3-7.4Z" fill="#4285F4"/>
  <path d="M12 22c2.7 0 5-.9 6.6-2.4l-3.2-2.5c-.9.6-2 1-3.4 1-2.6 0-4.8-1.8-5.6-4.1H3.1v2.6A10 10 0 0 0 12 22Z" fill="#34A853"/>
  <path d="M6.4 14a6 6 0 0 1 0-3.8V7.6H3.1a10 10 0 0 0 0 9l3.3-2.6Z" fill="#FBBC05"/>
  <path d="M12 6.1c1.5 0 2.8.5 3.8 1.5L18.7 5A10 10 0 0 0 3.1 7.6L6.4 10c.8-2.3 3-3.9 5.6-3.9Z" fill="#EA4335"/>
</svg>
''';

/// Onboarding / connexion : marque sur dégradé vert + carte de connexion.
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.ta;
    final strings = ref.watch(stringsProvider);

    return TaStatusBar(
      forceLight: true,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(gradient: t.headerGrad),
          child: Column(
            children: [
              // ----- haut : marque -----
              Expanded(
                // Scrollable pour rester robuste sur petites hauteurs,
                // centré comme le design sinon.
                child: LayoutBuilder(
                  builder: (context, constraints) => SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          spacing: 18,
                          children: [
                            Container(
                              padding: const EdgeInsets.fromLTRB(
                                24,
                                22,
                                24,
                                16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(32),
                                boxShadow: t.shadowPop,
                              ),
                              child: const TaLogo(size: 64),
                            ),
                            const TaWordmark(size: 28, light: true),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 280),
                              child: Text(
                                strings.onboardingTagline,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: t.headerInk2,
                                  fontSize: TaDims.fs,
                                  fontWeight: FontWeight.w500,
                                  height: 1.5,
                                ),
                              ),
                            ),
                            const _LangSwitch(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // ----- bas : carte connexion -----
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(
                  TaDims.pad,
                  TaDims.pad + 8,
                  TaDims.pad,
                  // Clavier ouvert → padding compact pour garder le champ
                  // et le bouton visibles.
                  MediaQuery.viewInsetsOf(context).bottom > 0 ? 16 : 110,
                ),
                decoration: BoxDecoration(
                  color: t.bg,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: TaDims.gap,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        strings.signInTitle,
                        textAlign: TextAlign.center,
                        style: context.taH2,
                      ),
                    ),
                    _PhoneField(hint: strings.phoneHint),
                    TaButton(
                      label: strings.continueLabel,
                      expanded: true,
                      onPressed: () => context.go('/home'),
                      trailing: TaIcon(
                        TaIcons.arrowRight,
                        size: 17,
                        mono: true,
                        color: TaButton.inkColor(context, TaButtonVariant.cta),
                      ),
                    ),
                    Row(
                      spacing: 12,
                      children: [
                        const Expanded(child: TaDivider()),
                        Text(strings.or, style: context.taSub),
                        const Expanded(child: TaDivider()),
                      ],
                    ),
                    TaButton(
                      label: strings.continueWithGoogle,
                      variant: TaButtonVariant.outline,
                      height: 46,
                      expanded: true,
                      onPressed: () => context.go('/home'),
                      leading: SvgPicture.string(
                        _googleLogoSvg,
                        width: 17,
                        height: 17,
                      ),
                    ),
                    TaButton(
                      label: strings.imACraftsman,
                      variant: TaButtonVariant.ghost,
                      height: 40,
                      fontSize: TaDims.fsSm,
                      expanded: true,
                      onPressed: () => context.push('/pro'),
                      leading: const TaIcon(TaIcons.wrench, size: 15),
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

/// Sélecteur de langue pill Français / English.
class _LangSwitch extends ConsumerWidget {
  const _LangSwitch();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.ta;
    final lang = ref.watch(langProvider);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(TaDims.rPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 4,
        children: [
          for (final (code, label) in const [
            (AppLang.fr, 'Français'),
            (AppLang.en, 'English'),
          ])
            GestureDetector(
              onTap: () => ref.read(langProvider.notifier).set(code),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: lang == code ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(TaDims.rPill),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: lang == code ? AppPalette.green700 : t.headerInk2,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Champ téléphone composé : préfixe « +225 » + séparateur + saisie,
/// clavier numérique, formatage automatique « 07 09 45 12 88 » et
/// bordure verte animée au focus (style `.ta-input` du design).
class _PhoneField extends StatefulWidget {
  const _PhoneField({required this.hint});

  final String hint;

  @override
  State<_PhoneField> createState() => _PhoneFieldState();
}

class _PhoneFieldState extends State<_PhoneField> {
  final _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus != _focused) {
        setState(() => _focused = _focusNode.hasFocus);
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    return GestureDetector(
      // Toute la surface du champ donne le focus.
      onTap: _focusNode.requestFocus,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: TaDims.inputHeight,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: BorderRadius.circular(TaDims.rPill),
          border: Border.all(
            color: _focused ? t.primary : t.borderStrong,
            width: 1.5,
          ),
        ),
        child: Row(
          spacing: 12,
          children: [
            Text(
              '+225',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: t.text2,
                fontSize: TaDims.fs,
              ),
            ),
            Container(width: 1, height: 22, color: t.borderStrong),
            Expanded(
              child: TextField(
                focusNode: _focusNode,
                keyboardType: TextInputType.phone,
                inputFormatters: [_IvorianPhoneFormatter()],
                cursorColor: t.primary,
                style: TextStyle(
                  fontSize: TaDims.fs,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                  color: t.text,
                ),
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: widget.hint,
                  hintStyle: TextStyle(
                    fontSize: TaDims.fs,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                    color: t.text3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Regroupe les chiffres par paires (numéros ivoiriens à 10 chiffres).
class _IvorianPhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text
        .replaceAll(RegExp(r'\D'), '')
        .characters
        .take(10)
        .toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i.isEven) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final text = buffer.toString();
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
