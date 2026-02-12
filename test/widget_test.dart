import 'package:bluetooth_printer_app/receipt/receipt_generator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ReceiptGenerator creates mock order with 5 items', () {
    final order = ReceiptGenerator.createMockOrder();
    expect(order.items.length, 5);
    expect(order.shopName, 'Sample Shop');
  });

  test('ReceiptGenerator generates preview text', () {
    final order = ReceiptGenerator.createMockOrder();
    final preview = ReceiptGenerator.generateReceiptPreview(order);
    expect(preview, contains('Sample Shop'));
    expect(preview, contains('Thank you'));
  });
}
