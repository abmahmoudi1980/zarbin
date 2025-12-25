import 'package:flutter_test/flutter_test.dart';
import 'package:zarbin/utils/persian_formatter.dart';

void main() {
  test('formats an ISO8601 timestamp with +03:30 offset to local Jalali time', () {
    // This test assumes the developer's machine is set to Asia/Tehran (+03:30).
    final dt = DateTime.parse('2025-12-25T11:39:29+03:30');
    final formatted = PersianFormatter.formatDateTime(dt);

    // Expect the Persian time '11:39' -> '۱۱:۳۹' to appear in the formatted string
    expect(formatted.contains('۱۱:۳۹'), isTrue);
  });
}
