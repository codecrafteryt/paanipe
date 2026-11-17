import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/values/my_color.dart';

/// Row of single-digit boxes backed by one invisible text field
/// (keeps paste / SMS-email autofill / backspace working natively).
class OtpCodeField extends StatelessWidget {
  const OtpCodeField({super.key, required this.controller, this.length = 6, this.onCompleted});

  final TextEditingController controller;
  final int length;
  final ValueChanged<String>? onCompleted;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (_, value, _) => Row(
            children: [
              for (var i = 0; i < length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _Box(
                    digit: i < value.text.length ? value.text[i] : '',
                    active: i == value.text.length,
                  ),
                ),
              ],
            ],
          ),
        ),
        Positioned.fill(
          child: Opacity(
            opacity: 0,
            child: TextField(
              controller: controller,
              autofocus: true,
              keyboardType: TextInputType.number,
              autofillHints: const [AutofillHints.oneTimeCode],
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(length),
              ],
              showCursor: false,
              enableInteractiveSelection: false,
              decoration: const InputDecoration.collapsed(hintText: ''),
              onChanged: (v) => v.length == length ? onCompleted?.call(v) : null,
            ),
          ),
        ),
      ],
    );
  }
}

class _Box extends StatelessWidget {
  const _Box({required this.digit, required this.active});

  final String digit;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: active ? MyColors.inputBorder : MyColors.subtleBorder),
        ),
        child: Center(
          child: Text(digit, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}
