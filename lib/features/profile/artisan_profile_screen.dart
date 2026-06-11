import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/ta_tokens.dart';
import '../../core/utils/formatters.dart';
import '../../data/models/models.dart';
import '../../providers/data_providers.dart';
import '../../shared/widgets/widgets.dart';

/// « 4.9 » mais « 5 » si la note est entière (comme le proto JS).
String _formatNote(double note) =>
    note == note.roundToDouble() ? note.toStringAsFixed(0) : note.toString();

enum _ProfileTab { realisations, avis, infos }

/// Profil public d'un artisan : cover verte, carte identité, onglets
/// Réalisations / Avis / Infos et barre CTA collée en bas.
class ArtisanProfileScreen extends ConsumerStatefulWidget {
  const ArtisanProfileScreen({super.key, required this.artisanId});

  final String artisanId;

  @override
  ConsumerState<ArtisanProfileScreen> createState() =>
      _ArtisanProfileScreenState();
}

class _ArtisanProfileScreenState extends ConsumerState<ArtisanProfileScreen> {
  _ProfileTab _tab = _ProfileTab.realisations;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    final a = ref.watch(artisanProvider(widget.artisanId));

    return TaStatusBar(
      forceLight: true,
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _cover(context, a),
                    Padding(
                      padding: const EdgeInsets.all(TaDims.pad),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _tabs(t),
                          Padding(
                            padding: const EdgeInsets.only(
                                top: TaDims.gap, bottom: 96),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              spacing: TaDims.gap,
                              children: switch (_tab) {
                                _ProfileTab.realisations =>
                                  _realisationsTab(context),
                                _ProfileTab.avis => _avisTab(context, a),
                                _ProfileTab.infos => _infosTab(context, a),
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _ctaBar(context, a),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Cover + carte identité ───

  /// Le « 58px » de padding du proto inclut la barre de statut → top + 10,
  /// soit 90 px de cover sous le padding (148 − 58 dans le proto).
  Widget _cover(BuildContext context, Artisan a) {
    final topInset = MediaQuery.paddingOf(context).top;
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            height: topInset + 100,
            decoration: BoxDecoration(gradient: context.ta.headerGrad),
          ),
        ),
        Column(
          children: [
            Padding(
              padding:
                  EdgeInsets.fromLTRB(TaDims.pad, topInset + 10, TaDims.pad, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _coverButton(TaIcons.arrowLeft, onTap: () => context.pop()),
                  _coverButton(TaIcons.send),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: TaDims.pad),
              child: _identityCard(context, a),
            ),
          ],
        ),
      ],
    );
  }

  Widget _coverButton(TaIcons icon, {VoidCallback? onTap}) {
    return TaSquareButton(
      onTap: onTap,
      background: const Color(0x29FFFFFF),
      child: TaIcon(icon, size: 17, mono: true, color: Colors.white),
    );
  }

  /// Carte identité chevauchant la cover, avatar remontant de 44 px.
  Widget _identityCard(BuildContext context, Artisan a) {
    final t = context.ta;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        SizedBox(
          width: double.infinity,
          child: TaCard(
            padding: const EdgeInsets.all(TaDims.pad),
            child: Column(
              children: [
                // Espace sous l'avatar chevauchant (86 − 44) + marginTop 8.
                const SizedBox(height: 50),
                Text(
                  a.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: t.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${a.metier} · ${a.commune}, ${a.quartier}',
                  textAlign: TextAlign.center,
                  style: context.taSub,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    if (a.verified) TaBadge.verified(context),
                    if (a.featured) TaBadge.featured(context),
                    TaBadge.neutral(context,
                        label: a.dispo, icon: TaIcons.clock),
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(top: 14),
                  padding: const EdgeInsets.only(top: 12, bottom: 2),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: t.border)),
                  ),
                  child: Row(
                    children: [
                      _stat(t, _formatNote(a.note), 'Note', star: true),
                      _stat(t, '${a.avis}', 'Avis', divider: true),
                      _stat(t, '${a.annees} ans', 'Expérience', divider: true),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: -24,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: t.surface,
                // 36 % du cadre (76 + 2 × 5).
                borderRadius: BorderRadius.circular(86 * 0.36),
              ),
              child: TaAvatar(artisan: a, size: 76),
            ),
          ),
        ),
      ],
    );
  }

  Widget _stat(
    TaTokens t,
    String value,
    String label, {
    bool star = false,
    bool divider = false,
  }) {
    return Expanded(
      child: Container(
        decoration: divider
            ? BoxDecoration(border: Border(left: BorderSide(color: t.border)))
            : null,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 4,
              children: [
                if (star) const TaIcon(TaIcons.star, size: 14),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: t.text,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(label.toUpperCase(), style: context.taLabel),
          ],
        ),
      ),
    );
  }

  // ─── Onglets ───

  Widget _tabs(TaTokens t) {
    return TaSegmented<_ProfileTab>(
      expand: true,
      value: _tab,
      onChanged: (tab) => setState(() => _tab = tab),
      options: const [
        TaSegmentOption(_ProfileTab.realisations, 'Réalisations'),
        TaSegmentOption(_ProfileTab.avis, 'Avis'),
        TaSegmentOption(_ProfileTab.infos, 'Infos'),
      ],
      background: t.surface2,
      activeBackground: t.surface,
      activeForeground: t.text,
      foreground: t.text2,
      height: 36,
      fontSize: TaDims.fsSm,
      padding: const EdgeInsets.all(4),
      gap: 4,
      activeShadow: true,
    );
  }

  // ─── Réalisations ───

  List<Widget> _realisationsTab(BuildContext context) {
    final realisations = ref.watch(realisationsProvider);
    return [
      const TaBeforeAfter(height: 112),
      for (final (i, p) in realisations.indexed)
        _RealisationCard(realisation: p, tone: i + 1),
    ];
  }

  // ─── Avis ───

  List<Widget> _avisTab(BuildContext context, Artisan a) {
    final avis = ref.watch(avisProvider);
    return [
      _ratingSummaryCard(context, a),
      for (final r in avis) _ReviewCard(review: r),
    ];
  }

  Widget _ratingSummaryCard(BuildContext context, Artisan a) {
    final t = context.ta;
    const percents = [88, 9, 2, 1, 0];
    return TaCard(
      padding: const EdgeInsets.all(TaDims.pad),
      child: Row(
        spacing: 16,
        children: [
          Column(
            children: [
              Text(
                _formatNote(a.note),
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  height: 1,
                  color: t.text,
                ),
              ),
              TaStars(note: a.note, size: 12),
              const SizedBox(height: 3),
              Text('${a.avis} avis', style: context.taSub),
            ],
          ),
          Expanded(
            child: Column(
              spacing: 4,
              children: [
                for (final (i, pct) in percents.indexed)
                  Row(
                    spacing: 7,
                    children: [
                      SizedBox(
                        width: 8,
                        child: Text(
                          '${5 - i}',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: t.text3,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          height: 5,
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            color: t.surface2,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: FractionallySizedBox(
                            widthFactor: pct / 100,
                            child: Container(
                              decoration: BoxDecoration(
                                color: t.star,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Infos ───

  List<Widget> _infosTab(BuildContext context, Artisan a) {
    final t = context.ta;
    return [
      TaCard(
        padding: const EdgeInsets.all(TaDims.pad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('À PROPOS', style: context.taLabel),
            const SizedBox(height: 7),
            Text(
              a.bio,
              style: TextStyle(
                fontSize: TaDims.fsSm,
                fontWeight: FontWeight.w500,
                height: 1.6,
                color: t.text2,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 14, bottom: 8),
              child: Text('COMPÉTENCES', style: context.taLabel),
            ),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final s in a.skills)
                  TaChip(
                    label: s,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                  ),
              ],
            ),
          ],
        ),
      ),
      TaCard(
        padding: const EdgeInsets.all(TaDims.pad),
        child: Column(
          spacing: 12,
          children: [
            _infoRow(context, TaIcons.mapPin, 'Zone d’intervention',
                '${a.commune}, ${a.quartier} et environs'),
            _infoRow(context, TaIcons.clock, 'Horaires',
                'Lun – Sam · 7 h 30 – 18 h 30'),
            _infoRow(context, TaIcons.wallet, 'Tarif de déplacement',
                'À partir de ${formatNumber(a.prix)} F CFA'),
            _infoRow(
              context,
              TaIcons.shield,
              'Identité vérifiée',
              a.verified
                  ? 'CNI + selfie vérifiés par TravauxAbidjan'
                  : 'Vérification en cours',
            ),
          ],
        ),
      ),
    ];
  }

  Widget _infoRow(
      BuildContext context, TaIcons icon, String title, String sub) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 12,
      children: [
        TaIconBox(icon: icon),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: TaDims.fsSm,
                  fontWeight: FontWeight.w700,
                  color: context.ta.text,
                ),
              ),
              const SizedBox(height: 1),
              Text(sub, style: context.taSub),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Barre CTA ───

  Widget _ctaBar(BuildContext context, Artisan a) {
    return TaBottomCtaBar(
      child: Row(
        spacing: 10,
        children: [
          const _SoftIconButton(icon: TaIcons.phone),
          _SoftIconButton(
            icon: TaIcons.chat,
            onTap: () => context.push('/chat/c1'),
          ),
          Expanded(
            child: TaButton(
              label: 'Demander un devis',
              expanded: true,
              leading: TaIcon(
                TaIcons.doc,
                size: 17,
                mono: true,
                color: TaButton.inkColor(context, TaButtonVariant.cta),
              ),
              onPressed: () => context.push('/devis?cat=${a.cat}'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Bouton `.ta-btn.soft` carré 50×50 (appel, message).
class _SoftIconButton extends StatelessWidget {
  const _SoftIconButton({required this.icon, this.onTap});

  final TaIcons icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TaPressable(
      onTap: onTap,
      pressedScale: 0.98,
      child: Container(
        width: 50,
        height: 50,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: context.ta.primarySoft,
          borderRadius: BorderRadius.circular(TaDims.rPill),
        ),
        child: TaIcon(icon, size: 20),
      ),
    );
  }
}

/// Carte d'une réalisation : vignette 64×56 + titre/type + durée.
class _RealisationCard extends StatelessWidget {
  const _RealisationCard({required this.realisation, required this.tone});

  final Realisation realisation;
  final int tone;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    return TaCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        spacing: 12,
        children: [
          SizedBox(
            width: 64,
            child: TaPhoto(height: 56, tone: tone, radius: 12),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  realisation.titre,
                  style: TextStyle(
                    fontSize: TaDims.fsSm,
                    fontWeight: FontWeight.w700,
                    color: t.text,
                  ),
                ),
                const SizedBox(height: 1),
                Text(realisation.type, style: context.taSub),
              ],
            ),
          ),
          TaBadge.neutral(context,
              label: realisation.duree, icon: TaIcons.clock),
        ],
      ),
    );
  }
}

/// Carte d'un avis client.
class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    final r = review;
    return TaCard(
      padding: const EdgeInsets.all(TaDims.pad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            spacing: 10,
            children: [
              TaClientAvatar(name: r.name, size: 36),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.name,
                      style: TextStyle(
                        fontSize: TaDims.fsSm,
                        fontWeight: FontWeight.w700,
                        color: t.text,
                      ),
                    ),
                    Text(
                      '${r.commune} · ${r.date}',
                      style: context.taSub.copyWith(fontSize: 11),
                    ),
                  ],
                ),
              ),
              TaStars(note: r.note, size: 11),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            r.text,
            style: TextStyle(
              fontSize: TaDims.fsSm,
              fontWeight: FontWeight.w500,
              height: 1.55,
              color: t.text,
            ),
          ),
          const SizedBox(height: 9),
          TaBadge(
            label: r.projet,
            background: t.primarySoft,
            foreground: t.primary,
            icon: TaIcons.check,
          ),
        ],
      ),
    );
  }
}
