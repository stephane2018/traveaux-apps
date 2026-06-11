import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/app_strings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/ta_tokens.dart';
import '../../providers/settings_providers.dart';
import '../../shared/widgets/widgets.dart';

/// Écran « Compte » (5e onglet) : en-tête vert, réglages, passerelle pro.
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.ta;
    return TaStatusBar(
      forceLight: true,
      child: SingleChildScrollView(
        child: Column(
          children: [
            const _AccountHeader(),
            Padding(
              // 116 en bas : la tab bar flottante est gérée par le shell.
              padding: const EdgeInsets.fromLTRB(
                TaDims.pad,
                TaDims.pad,
                TaDims.pad,
                116,
              ),
              child: Column(
                spacing: TaDims.gap,
                children: [
                  const _SettingsCard(),
                  const _ArtisanCard(),
                  Text(
                    'TravauxAbidjan v1.0 · Fait à Abidjan',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: t.text3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// En-tête dégradé vert : avatar initiales + identité.
class _AccountHeader extends StatelessWidget {
  const _AccountHeader();

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    final topPad = MediaQuery.paddingOf(context).top + 16;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(TaDims.pad, topPad, TaDims.pad, 24),
      decoration: BoxDecoration(
        gradient: t.headerGrad,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(26)),
      ),
      child: Column(
        children: [
          Container(
            width: 74,
            height: 74,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: Color(0x29FFFFFF),
              shape: BoxShape.circle,
            ),
            child: const Text(
              'AK',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 26,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Awa Koné',
            style: TextStyle(
              color: t.headerInk,
              fontWeight: FontWeight.w800,
              fontSize: TaDims.fsLg,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '+225 07 09 45 12 88 · Cocody',
            style: TextStyle(
              color: t.headerInk2,
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Carte des réglages : langue, thème, rangées cliquables, déconnexion.
class _SettingsCard extends ConsumerWidget {
  const _SettingsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.ta;
    final lang = ref.watch(langProvider);
    final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;

    return TaCard(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: TaDims.pad),
      child: Column(
        children: [
          _SettingRow(
            icon: TaIcons.globe,
            label: 'Langue',
            trailing: TaSegmented<AppLang>(
              height: 24,
              options: const [
                TaSegmentOption(AppLang.fr, 'FR'),
                TaSegmentOption(AppLang.en, 'EN'),
              ],
              value: lang,
              onChanged: (v) => ref.read(langProvider.notifier).set(v),
            ),
          ),
          _SettingRow(
            icon: isDark ? TaIcons.moon : TaIcons.sun,
            label: 'Mode sombre',
            trailing: TaToggle(
              value: isDark,
              onChanged: (_) => ref.read(themeModeProvider.notifier).toggle(),
            ),
          ),
          const _SettingRow(
            icon: TaIcons.mapPin,
            label: 'Mes adresses',
            sub: 'Domicile — Angré 7e tranche',
            chevron: true,
          ),
          const _SettingRow(
            icon: TaIcons.bell,
            label: 'Notifications',
            sub: 'Devis, messages, rappels',
            chevron: true,
          ),
          const _SettingRow(
            icon: TaIcons.shield,
            label: 'Sécurité du compte',
            sub: 'Numéro vérifié',
            chevron: true,
          ),
          _SettingRow(
            icon: TaIcons.logout,
            label: 'Se déconnecter',
            labelColor: t.danger,
            last: true,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

/// Rangée de réglage : icône, label (+ sous-titre), action à droite.
class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.label,
    this.sub,
    this.trailing,
    this.chevron = false,
    this.labelColor,
    this.last = false,
    this.onTap,
  });

  final TaIcons icon;
  final String label;
  final String? sub;
  final Widget? trailing;
  final bool chevron;
  final Color? labelColor;
  final bool last;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    final row = Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: last
          ? null
          : BoxDecoration(
              border: Border(bottom: BorderSide(color: t.border)),
            ),
      child: Row(
        spacing: 12,
        children: [
          TaIconBox(icon: icon),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: TaDims.fsSm,
                    color: labelColor ?? t.text,
                  ),
                ),
                if (sub != null)
                  Text(sub!, style: context.taSub.copyWith(fontSize: 11.5)),
              ],
            ),
          ),
          ?trailing,
          if (chevron)
            TaIcon(TaIcons.chevronRight, size: 14, mono: true, color: t.text3),
        ],
      ),
    );
    if (!chevron && onTap == null) return row;
    return TaPressable(onTap: onTap ?? () {}, child: row);
  }
}

/// Passerelle « Vous êtes artisan ? » vers l'espace pro.
class _ArtisanCard extends StatelessWidget {
  const _ArtisanCard();

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    return TaCard(
      onTap: () => context.push('/pro'),
      padding: const EdgeInsets.all(TaDims.pad),
      // linear-gradient(120deg, primary-soft, surface)
      gradient: LinearGradient(
        begin: const Alignment(-0.87, -0.5),
        end: const Alignment(0.87, 0.5),
        colors: [t.primarySoft, t.surface],
      ),
      child: Row(
        spacing: 13,
        children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: t.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: TaIcon(
              TaIcons.wrench,
              size: 20,
              mono: true,
              color: t.primaryInk,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Vous êtes artisan ?',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: TaDims.fsSm,
                    color: t.text,
                  ),
                ),
                Text(
                  'Créez votre profil pro et recevez des demandes.',
                  style: context.taSub.copyWith(fontSize: 11.5),
                ),
              ],
            ),
          ),
          TaIcon(TaIcons.chevronRight, size: 15, mono: true, color: t.text3),
        ],
      ),
    );
  }
}
