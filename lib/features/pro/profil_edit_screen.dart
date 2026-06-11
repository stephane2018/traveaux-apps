import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../core/theme/ta_tokens.dart';
import '../../providers/data_providers.dart';
import '../../shared/widgets/widgets.dart';

/// Options de disponibilité proposées (apostrophes typographiques).
const _dispoOptions = [
  'Disponible aujourd’hui',
  'Dispo sous 48 h',
  'Dispo sous 72 h',
];

/// Édition plein écran du profil artisan.
class ProfilEditScreen extends ConsumerStatefulWidget {
  const ProfilEditScreen({super.key});

  @override
  ConsumerState<ProfilEditScreen> createState() => _ProfilEditScreenState();
}

class _ProfilEditScreenState extends ConsumerState<ProfilEditScreen> {
  late final TextEditingController _name;
  late final TextEditingController _metier;
  late final TextEditingController _quartier;
  late final TextEditingController _bio;
  late final TextEditingController _prix;
  final _skillCtrl = TextEditingController();

  // État local des champs à sélection.
  late String _commune;
  late String _dispo;
  late List<String> _skills;

  @override
  void initState() {
    super.initState();
    final me = ref.read(proProfileProvider);
    _name = TextEditingController(text: me.name);
    _metier = TextEditingController(text: me.metier);
    _quartier = TextEditingController(text: me.quartier);
    _bio = TextEditingController(text: me.bio);
    _prix = TextEditingController(text: '${me.prix}');
    _commune = me.commune;
    _dispo = me.dispo;
    _skills = List.of(me.skills);
  }

  @override
  void dispose() {
    _name.dispose();
    _metier.dispose();
    _quartier.dispose();
    _bio.dispose();
    _prix.dispose();
    _skillCtrl.dispose();
    super.dispose();
  }

  void _addSkill() {
    final value = _skillCtrl.text.trim();
    if (value.isEmpty || _skills.contains(value)) return;
    setState(() {
      _skills = [..._skills, value];
      _skillCtrl.clear();
    });
  }

  void _removeSkill(String skill) {
    setState(() => _skills = _skills.where((s) => s != skill).toList());
  }

  void _save() {
    final me = ref.read(proProfileProvider);
    final updated = me.copyWith(
      name: _name.text.trim(),
      metier: _metier.text.trim(),
      commune: _commune,
      quartier: _quartier.text.trim(),
      dispo: _dispo,
      prix: int.tryParse(_prix.text) ?? me.prix,
      bio: _bio.text.trim(),
      skills: _skills,
    );
    ref.read(proProfileProvider.notifier).update(updated);
    context.pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: context.ta.primary,
        content: const Text('Profil mis à jour'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(proProfileProvider);
    final communes = ref.watch(communesProvider).take(8).toList();

    return TaStatusBar(
      child: Scaffold(
        body: Column(
          children: [
            _header(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  TaDims.pad,
                  TaDims.pad,
                  TaDims.pad,
                  110,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  spacing: TaDims.gap + 4,
                  children: [
                    // Avatar + changer la photo.
                    Column(
                      children: [
                        TaAvatar(artisan: me, size: 76),
                        const SizedBox(height: 12),
                        TaButton(
                          label: 'Changer la photo',
                          variant: TaButtonVariant.soft,
                          small: true,
                          leading: TaIcon(
                            TaIcons.camera,
                            size: 14,
                            mono: true,
                            color: TaButton.inkColor(
                              context,
                              TaButtonVariant.soft,
                            ),
                          ),
                          onPressed: () {},
                        ),
                      ],
                    ),
                    _field('NOM', TaInput(controller: _name)),
                    _field('MÉTIER', TaInput(controller: _metier)),
                    _field(
                      'COMMUNE',
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final c in communes)
                            TaChip(
                              label: c,
                              active: c == _commune,
                              onTap: () => setState(() => _commune = c),
                            ),
                        ],
                      ),
                    ),
                    _field('QUARTIER', TaInput(controller: _quartier)),
                    _field(
                      'DISPONIBILITÉ',
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final d in _dispoOptions)
                            TaChip(
                              label: d,
                              active: d == _dispo,
                              onTap: () => setState(() => _dispo = d),
                            ),
                        ],
                      ),
                    ),
                    _field(
                      'TARIF DE DÉPLACEMENT (F CFA)',
                      TaInput(
                        controller: _prix,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                      ),
                    ),
                    _field('À PROPOS', TaInput(controller: _bio, maxLines: 4)),
                    _field('COMPÉTENCES', _skillsEditor(context)),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: TaBottomCtaBar(
          child: TaButton(
            label: 'Enregistrer',
            expanded: true,
            onPressed: _save,
          ),
        ),
      ),
    );
  }

  // ─── En-tête ───

  Widget _header(BuildContext context) {
    final t = context.ta;
    final topInset = MediaQuery.paddingOf(context).top;
    return Container(
      padding: EdgeInsets.fromLTRB(TaDims.pad, topInset + 16, TaDims.pad, 16),
      decoration: BoxDecoration(
        color: t.surface,
        border: Border(bottom: BorderSide(color: t.border)),
      ),
      child: Row(
        spacing: 12,
        children: [
          TaSquareButton.back(context, onTap: () => context.pop()),
          Text(
            'Modifier le profil',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: t.text,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Éditeur de compétences ───

  Widget _skillsEditor(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (_skills.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final s in _skills)
                  _RemovableSkill(label: s, onRemove: () => _removeSkill(s)),
              ],
            ),
          ),
        Row(
          spacing: 8,
          children: [
            Expanded(
              child: TaInput(
                controller: _skillCtrl,
                hint: 'Ajouter une compétence',
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _addSkill(),
              ),
            ),
            TaButton(
              label: 'Ajouter',
              variant: TaButtonVariant.outline,
              small: true,
              onPressed: _addSkill,
            ),
          ],
        ),
      ],
    );
  }

  /// Libellé + contenu, gap standard.
  Widget _field(String label, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label, style: context.taLabel),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

/// Chip de compétence avec croix de suppression.
class _RemovableSkill extends StatelessWidget {
  const _RemovableSkill({required this.label, required this.onRemove});

  final String label;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 6, 8, 6),
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(TaDims.rPill),
        border: Border.all(color: t.borderStrong),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 6,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: TaDims.fsSm,
              fontWeight: FontWeight.w600,
              color: t.text2,
            ),
          ),
          GestureDetector(
            onTap: onRemove,
            child: TaIcon(TaIcons.close, size: 13, mono: true, color: t.text3),
          ),
        ],
      ),
    );
  }
}
