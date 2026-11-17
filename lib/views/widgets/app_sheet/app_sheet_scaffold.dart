import 'package:flutter/material.dart';

/// Standard sheet layout: [X | centred title] header, divider, body, optional sticky footer.
/// Sizes to content (up to the presenter's max height) unless [expand] is true.
class AppSheetScaffold extends StatelessWidget {
  const AppSheetScaffold({
    super.key,
    required this.body,
    this.title,
    this.footer,
    this.onClose,
    this.bodyPadding = const EdgeInsets.fromLTRB(24, 20, 24, 20),
    this.scrollable = true,
    this.expand = false,
  });

  final String? title;
  final Widget body;

  /// Pinned under the body (e.g. primary action); stays visible above the keyboard.
  final Widget? footer;

  /// Defaults to `Navigator.pop`.
  final VoidCallback? onClose;
  final EdgeInsets bodyPadding;

  /// Set false when [body] scrolls itself or needs a fixed size (maps, lists).
  final bool scrollable;

  /// Fill the available sheet height (footer sits at the bottom).
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final content = Padding(padding: bodyPadding, child: body);
    final scrolled = scrollable ? SingleChildScrollView(child: content) : content;
    return Column(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      children: [
        SizedBox(
          height: 56,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  tooltip: 'Close',
                  onPressed: onClose ?? () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, size: 22),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 56),
                child: Text(
                  title ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        expand ? Expanded(child: scrolled) : Flexible(child: scrolled),
        if (footer != null) ...[
          const Divider(height: 1),
          Padding(padding: const EdgeInsets.fromLTRB(24, 16, 24, 16), child: footer),
        ],
      ],
    );
  }
}
