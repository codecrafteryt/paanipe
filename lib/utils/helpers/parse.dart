/// Safe Firestore value parsing (tolerates int / double / numeric string).
double toDouble(Object? v, [double fallback = 0]) => switch (v) {
  num n => n.toDouble(),
  String s => double.tryParse(s) ?? fallback,
  _ => fallback,
};

int toInt(Object? v, [int fallback = 0]) => switch (v) {
  num n => n.round(),
  String s => num.tryParse(s)?.round() ?? fallback,
  _ => fallback,
};

String toStr(Object? v) => v?.toString() ?? '';
