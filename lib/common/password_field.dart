import 'package:flutter/material.dart';

import 'theme.dart';

/// Hidden password field, with an eye to check what was typed.
class PasswordField extends StatefulWidget {
  const PasswordField({
    super.key,
    required this.controller,
    required this.label,
    this.focusNode,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final FocusNode? focusNode;
  final FormFieldValidator<String>? validator;

  @override
  State<PasswordField> createState() => _PasswordFieldState();
}

class _PasswordFieldState extends State<PasswordField> {
  var _visible = false;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      obscureText: !_visible,
      autocorrect: false,
      enableSuggestions: false,
      validator: widget.validator,
      style: AppText.rowTitle.copyWith(fontSize: 16),
      decoration: InputDecoration(
        labelText: widget.label,
        suffixIcon: IconButton(
          tooltip: _visible
              ? 'Masquer le mot de passe'
              : 'Afficher le mot de passe',
          color: AppColors.textSecondary,
          icon: Icon(
            _visible
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
          ),
          onPressed: () => setState(() => _visible = !_visible),
        ),
      ),
    );
  }
}
