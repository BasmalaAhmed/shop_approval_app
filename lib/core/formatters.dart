String formatPiastres(int piastres, {String currency = 'ج.م'}) {
  final isNegative = piastres < 0;
  final absolute = piastres.abs();
  final pounds = absolute ~/ 100;
  final remainder = absolute % 100;

  final groupedPounds = pounds.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ',',
  );

  final sign = isNegative ? '-' : '';
  return '$sign$groupedPounds.${remainder.toString().padLeft(2, '0')} $currency';
}

/// Short, display-only version of a decision id (the full id is what the API uses).
String shortDecisionId(String decisionId) {
  final short = decisionId.length > 8 ? decisionId.substring(0, 8) : decisionId;
  return 'DEC-${short.toUpperCase()}';
}