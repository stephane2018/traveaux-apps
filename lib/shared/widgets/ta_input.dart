import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/ta_tokens.dart';

/// Champ de saisie `.ta-input` : pill (ou arrondi 24 en multiligne),
/// liseré 1.5, focus vert animé.
///
/// Champ « composé » : le conteneur porte la décoration et le `TextField`
/// interne est nu — la hauteur demandée est respectée au pixel et le texte
/// est parfaitement centré, quelle que soit [height].
class TaInput extends StatefulWidget {
  const TaInput({
    super.key,
    this.controller,
    this.hint,
    this.initialValue,
    this.readOnly = false,
    this.maxLines = 1,
    this.height,
    this.contentPadding,
    this.prefix,
    this.keyboardType,
    this.inputFormatters,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
  }) : assert(
          controller == null || initialValue == null,
          'Fournir controller OU initialValue, pas les deux.',
        );

  final TextEditingController? controller;
  final String? hint;
  final String? initialValue;
  final bool readOnly;
  final int maxLines;

  /// Hauteur exacte du champ (single-line uniquement, 50 par défaut).
  final double? height;

  final EdgeInsetsGeometry? contentPadding;

  /// Préfixe toujours visible (indicatif téléphonique…), aligné sur la
  /// ligne de saisie.
  final Widget? prefix;

  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;

  @override
  State<TaInput> createState() => _TaInputState();
}

class _TaInputState extends State<TaInput> {
  final _focusNode = FocusNode();
  TextEditingController? _ownController;
  bool _focused = false;

  TextEditingController? get _effectiveController =>
      widget.controller ??
      (widget.initialValue != null
          ? _ownController ??= TextEditingController(text: widget.initialValue)
          : null);

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
    _ownController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.ta;
    final multiline = widget.maxLines > 1;

    final field = TextField(
      controller: _effectiveController,
      focusNode: _focusNode,
      readOnly: widget.readOnly,
      maxLines: widget.maxLines,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      textInputAction: widget.textInputAction,
      cursorColor: t.primary,
      style: TextStyle(
        fontSize: TaDims.fs,
        fontWeight: FontWeight.w500,
        height: multiline ? 1.5 : null,
        color: t.text,
      ),
      decoration: InputDecoration(
        isCollapsed: true,
        border: InputBorder.none,
        hintText: widget.hint,
        hintStyle: TextStyle(
          fontSize: TaDims.fs,
          fontWeight: FontWeight.w500,
          color: t.text3,
        ),
      ),
    );

    return GestureDetector(
      // Toute la surface du champ donne le focus.
      onTap: widget.readOnly ? null : _focusNode.requestFocus,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: multiline ? null : (widget.height ?? TaDims.inputHeight),
        padding: widget.contentPadding ??
            (multiline
                ? const EdgeInsets.symmetric(horizontal: 16, vertical: 14)
                : const EdgeInsets.symmetric(horizontal: 16)),
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius:
              BorderRadius.circular(multiline ? TaDims.rCard : TaDims.rPill),
          border: Border.all(
            color: _focused ? t.primary : t.borderStrong,
            width: 1.5,
          ),
        ),
        child: multiline
            ? field
            : Row(
                spacing: 10,
                children: [
                  if (widget.prefix != null) widget.prefix!,
                  Expanded(child: field),
                ],
              ),
      ),
    );
  }
}
