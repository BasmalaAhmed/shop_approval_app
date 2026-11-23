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

String shortDecisionId(String decisionId) {
  final short = decisionId.length > 8 ? decisionId.substring(0, 8) : decisionId;
  return 'DEC-${short.toUpperCase()}';
}

String formatRequestTime(DateTime time, {DateTime? now}) {
  final reference = now ?? DateTime.now();
  final today = DateTime.utc(reference.year, reference.month, reference.day);
  final day = DateTime.utc(time.year, time.month, time.day);
  final daysAgo = today.difference(day).inDays;

  final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
  final minutes = time.minute.toString().padLeft(2, '0');
  final period = time.hour < 12 ? 'ص' : 'م';
  final clock = '$hour:$minutes $period';

  if (daysAgo == 0) return 'اليوم $clock';
  if (daysAgo == 1) return 'أمس $clock';

  final dd = time.day.toString().padLeft(2, '0');
  final mm = time.month.toString().padLeft(2, '0');
  return '$dd/$mm/${time.year} $clock';
}
