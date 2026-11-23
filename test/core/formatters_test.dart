import 'package:flutter_test/flutter_test.dart';
import 'package:shop_approval_app/core/formatters.dart';

void main() {
  test('formats today, yesterday and older times', () {
    final now = DateTime(2026, 11, 23, 15, 0);

    expect(
      formatRequestTime(DateTime(2026, 11, 23, 12, 29), now: now),
      'اليوم 12:29 م',
    );
    expect(
      formatRequestTime(DateTime(2026, 11, 22, 0, 5), now: now),
      'أمس 12:05 ص',
    );
    expect(
      formatRequestTime(DateTime(2026, 11, 20, 9, 0), now: now),
      '20/11/2026 9:00 ص',
    );
  });
}