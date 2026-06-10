import 'package:flutter_test/flutter_test.dart';
import 'package:gameior/core/extensions/int_ext.dart';

void main() {
  group('PaiseExt - toRupees', () {
    test('formats whole rupees correctly without decimal', () {
      expect(50000.toRupees(), '₹500');
      expect(100.toRupees(), '₹1');
      expect(0.toRupees(), '₹0');
    });

    test('formats fractional rupees correctly with 2 decimal places', () {
      expect(50050.toRupees(), '₹500.50');
      expect(125.toRupees(), '₹1.25');
      expect(99.toRupees(), '₹0.99');
    });
  });

  group('perHeadPaise', () {
    test('divides cost evenly when divisible', () {
      expect(perHeadPaise(30000, 3), 10000);
    });

    test('rounds up using ceil division when not evenly divisible', () {
      // ₹1001 (100100 paise) split among 3 players -> 33367 paise (₹333.67) each
      expect(perHeadPaise(100100, 3), 33367);
    });
  });
}
