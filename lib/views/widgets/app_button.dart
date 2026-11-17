import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../utils/values/my_color.dart';

/// filled = brand pill · outlined = grey-border pill · social = outlined with a
/// left-pinned logo (Google…) · danger = red outline.
enum ButtonVariant { filled, outlined, social, danger }

/// Full-width stadium button. Loading shows wave dots and keeps the enabled look.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.leading,
    this.variant = ButtonVariant.filled,
  });

  final String label;

  /// Null disables the button (grey fill, grey text).
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  /// Logo pinned to the left edge (social variant).
  final Widget? leading;
  final ButtonVariant variant;

  static const _danger = Color(0xFFDC2626);
  static const _height = 48.0;

  @override
  Widget build(BuildContext context) {
    final filled = variant == ButtonVariant.filled;
    final enabled = onPressed != null || isLoading;
    final fg = switch (variant) {
      ButtonVariant.filled => enabled ? Colors.white : MyColors.disabledText,
      ButtonVariant.danger => _danger,
      _ => Colors.black,
    };
    final style = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size.fromHeight(_height)),
      shape: const WidgetStatePropertyAll(StadiumBorder()),
      elevation: const WidgetStatePropertyAll(0),
      backgroundColor: WidgetStatePropertyAll(
        filled ? (enabled ? MyColors.brand : MyColors.disabledFill) : Colors.white,
      ),
      foregroundColor: WidgetStatePropertyAll(fg),
      side: WidgetStatePropertyAll(
        filled
            ? BorderSide.none
            : BorderSide(color: variant == ButtonVariant.danger ? _danger : MyColors.subtleBorder),
      ),
      // From the theme so the app font (Georgia) is kept.
      textStyle: WidgetStatePropertyAll(
        Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 15, fontWeight: FontWeight.w600),
      ),
      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 16)),
    );

    return TextButton(
      style: style,
      onPressed: isLoading ? () {} : onPressed,
      child: isLoading
          ? LoadingAnimationWidget.waveDots(color: filled ? Colors.white : MyColors.brand, size: 26)
          : _label(fg),
    );
  }

  Widget _label(Color fg) {
    final text = Text(
      label,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(color: fg),
    );
    final logo = leading;
    if (logo != null) {
      return Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox.square(dimension: 20, child: logo),
          ),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 28), child: text),
        ],
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[Icon(icon, size: 20, color: fg), const SizedBox(width: 8)],
        Flexible(child: text),
      ],
    );
  }
}
