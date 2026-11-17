import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/values/my_color.dart';

/// Themed form field used by every form in the app.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
    this.maxLength,
    this.prefixText,
    this.suffixText,
    this.prefix,
    this.autofocus = false,
    this.capitalization = TextCapitalization.none,
    this.onChanged,
    this.onSubmitted,
    this.style,
    this.textAlign = TextAlign.start,
    this.autofillHints,
    this.emphasized = false,
  });

  final TextEditingController controller;
  final String? label;
  final String? hint;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final int? maxLength;
  final String? prefixText;
  final String? suffixText;
  final Widget? prefix;
  final bool autofocus;
  final TextCapitalization capitalization;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextStyle? style;
  final TextAlign textAlign;
  final Iterable<String>? autofillHints;

  /// Always-floating label on a dark outline (auth forms).
  final bool emphasized;

  static final _darkBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(8),
    borderSide: const BorderSide(color: MyColors.inputBorder),
  );

  /// Digits only, limited to [max] characters.
  static List<TextInputFormatter> digits(int max) => [
    FilteringTextInputFormatter.digitsOnly,
    LengthLimitingTextInputFormatter(max),
  ];

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      maxLength: maxLength,
      autofocus: autofocus,
      textCapitalization: capitalization,
      onChanged: onChanged,
      onFieldSubmitted: onSubmitted,
      style: style,
      textAlign: textAlign,
      autofillHints: autofillHints,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixText: prefixText,
        suffixText: suffixText,
        prefixIcon: prefix,
        counterText: '',
        // Auth style: label pinned on a dark outline.
        floatingLabelBehavior: emphasized ? FloatingLabelBehavior.always : null,
        enabledBorder: emphasized ? _darkBorder : null,
        focusedBorder: emphasized ? _darkBorder : null,
      ),
    );
  }
}
