import 'package:intl/intl.dart';

final _money = NumberFormat('#,##0');

String rs(num value) => 'Rs ${_money.format(value)}';

String km(double value) => value < 1 ? '${(value * 1000).round()} m' : '${value.toStringAsFixed(1)} km';

String dateTime(DateTime? d) => d == null ? '' : DateFormat('d MMM, h:mm a').format(d);

String feeText(int fee) => fee == 0 ? 'Free delivery' : '${rs(fee)} delivery';

/// 1.0 → "1", 2.5 → "2.5"
String trimNum(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

/// 03001234567 / 3001234567 / +923001234567 → +923001234567, or null if invalid.
String? normalizePkPhone(String input) {
  var digits = input.replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.startsWith('92')) digits = digits.substring(2);
  if (digits.startsWith('0')) digits = digits.substring(1);
  if (digits.length != 10 || !digits.startsWith('3')) return null;
  return '+92$digits';
}

/// +923001234567 → 03001234567 (for editable fields).
String localPhone(String phone) => phone.replaceFirst('+92', '0');
