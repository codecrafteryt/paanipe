import 'package:flutter/material.dart';

import '../../utils/values/my_color.dart';

/// Airbnb-style counter: an outlined "Add" pill that becomes ( − ) qty ( + ).
class QtyStepper extends StatelessWidget {
  const QtyStepper({super.key, required this.qty, required this.onAdd, required this.onRemove});

  final int qty;

  /// Null disables adding (closed store / out of stock).
  final VoidCallback? onAdd;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      transitionBuilder: (child, a) => FadeTransition(
        opacity: a,
        child: ScaleTransition(scale: Tween(begin: 0.9, end: 1.0).animate(a), child: child),
      ),
      child: qty == 0 ? _addPill() : _counter(),
    );
  }

  Widget _addPill() {
    final enabled = onAdd != null;
    return OutlinedButton(
      key: const ValueKey('add'),
      onPressed: onAdd,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(72, 36),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        foregroundColor: Colors.black,
        backgroundColor: Colors.white,
        side: BorderSide(color: enabled ? Colors.black : MyColors.subtleBorder),
        shape: const StadiumBorder(),
      ),
      child: const Text('Add', style: TextStyle(fontWeight: FontWeight.w600)),
    );
  }

  Widget _counter() {
    return Row(
      key: const ValueKey('counter'),
      mainAxisSize: MainAxisSize.min,
      children: [
        _CircleIcon(icon: qty == 1 ? Icons.delete_outline : Icons.remove, onTap: onRemove),
        SizedBox(
          width: 32,
          child: Text(
            '$qty',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
        _CircleIcon(icon: Icons.add, onTap: onAdd),
      ],
    );
  }
}

class _CircleIcon extends StatelessWidget {
  const _CircleIcon({required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return Material(
      color: Colors.white,
      shape: CircleBorder(side: BorderSide(color: enabled ? MyColors.textSecondary : MyColors.subtleBorder)),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: SizedBox.square(
          dimension: 32,
          child: Icon(icon, size: 16, color: enabled ? Colors.black87 : MyColors.subtleBorder),
        ),
      ),
    );
  }
}
