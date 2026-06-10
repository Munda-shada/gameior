import 'package:flutter_test/flutter_test.dart';
import 'package:gameior/core/extensions/datetime_ext.dart';

void main() {
  group('DateTimeIST - toIST', () {
    test('converts UTC time to IST (UTC+5:30)', () {
      final utc = DateTime.utc(2026, 6, 10, 12, 0); // 12:00 PM UTC
      final ist = utc.toIST();
      expect(ist.hour, 17);
      expect(ist.minute, 30);
    });
  });

  group('DateTimeIST - toTimeString', () {
    test('formats AM times correctly', () {
      final time = DateTime.utc(2026, 6, 10, 3, 30); // 9:00 AM IST (3:30 AM UTC)
      expect(time.toTimeString(), '9:00 AM');
    });

    test('formats PM times correctly', () {
      final time = DateTime.utc(2026, 6, 10, 12, 0); // 5:30 PM IST (12:00 PM UTC)
      expect(time.toTimeString(), '5:30 PM');
    });

    test('formats midnight (12:00 AM) correctly', () {
      final time = DateTime.utc(2026, 6, 9, 18, 30); // 12:00 AM IST (18:30 UTC day before)
      expect(time.toTimeString(), '12:00 AM');
    });

    test('formats noon (12:00 PM) correctly', () {
      final time = DateTime.utc(2026, 6, 10, 6, 30); // 12:00 PM IST (6:30 AM UTC)
      expect(time.toTimeString(), '12:00 PM');
    });
  });

  group('DateTimeIST - toDateString', () {
    test('formats dates correctly in IST context', () {
      // Wed, June 10, 2026
      final date = DateTime.utc(2026, 6, 10, 10, 0); // IST: June 10, 3:30 PM
      expect(date.toDateString(), 'Wed 10 Jun');
    });
  });
}
