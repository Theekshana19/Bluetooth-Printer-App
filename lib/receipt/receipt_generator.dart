import 'dart:typed_data';

import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import '../core/constants/app_constants.dart';
import '../features/printer/domain/entities/order.dart';

/// Generates ESC/POS receipt bytes from an order.
class ReceiptGenerator {
  ReceiptGenerator._();

  /// Generates receipt bytes for printing.
  static Future<Uint8List> generateReceiptBytes(Order order) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    final List<int> bytes = [];

    bytes.addAll(
      generator.text(
        order.shopName,
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
        ),
        linesAfter: 1,
      ),
    );
    bytes.addAll(
      generator.text(
        order.shopAddress,
        styles: const PosStyles(align: PosAlign.center),
        linesAfter: 1,
      ),
    );
    bytes.addAll(
      generator.text(
        _formatDateTime(order.dateTime),
        styles: const PosStyles(align: PosAlign.center),
        linesAfter: 1,
      ),
    );
    bytes.addAll(generator.hr(linesAfter: 1));

    bytes.addAll(
      generator.row(
        [
          PosColumn(text: 'QTY', width: 2, styles: const PosStyles(bold: true)),
          PosColumn(text: 'ITEM', width: 5, styles: const PosStyles(bold: true)),
          PosColumn(text: 'PRICE', width: 2, styles: const PosStyles(bold: true)),
          PosColumn(text: 'TOTAL', width: 3, styles: const PosStyles(bold: true)),
        ],
      ),
    );
    bytes.addAll(generator.hr(linesAfter: 1));

    for (final item in order.items) {
      bytes.addAll(
        generator.row(
          [
            PosColumn(text: '${item.quantity}', width: 2),
            PosColumn(text: item.name, width: 5),
            PosColumn(text: '\$${item.unitPrice.toStringAsFixed(2)}', width: 2),
            PosColumn(text: '\$${item.total.toStringAsFixed(2)}', width: 3),
          ],
        ),
      );
    }

    bytes.addAll(generator.hr(linesAfter: 1));
    bytes.addAll(
      generator.row(
        [
          PosColumn(text: 'Subtotal:', width: 8),
          PosColumn(
            text: '\$${order.subtotal.toStringAsFixed(2)}',
            width: 4,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ],
      ),
    );
    bytes.addAll(
      generator.row(
        [
          PosColumn(text: 'Discount:', width: 8),
          PosColumn(
            text: '-\$${order.discount.toStringAsFixed(2)}',
            width: 4,
            styles: const PosStyles(align: PosAlign.right),
          ),
        ],
      ),
    );
    bytes.addAll(
      generator.row(
        [
          PosColumn(text: 'Total:', width: 8, styles: const PosStyles(bold: true)),
          PosColumn(
            text: '\$${order.total.toStringAsFixed(2)}',
            width: 4,
            styles: const PosStyles(align: PosAlign.right, bold: true),
          ),
        ],
      ),
    );
    bytes.addAll(generator.hr(linesAfter: 1));
    bytes.addAll(
      generator.text(
        'Payment: ${order.paymentMethod}',
        styles: const PosStyles(align: PosAlign.center),
        linesAfter: 1,
      ),
    );
    bytes.addAll(generator.feed(1));
    bytes.addAll(
      generator.text(
        'Thank you for your purchase!',
        styles: const PosStyles(align: PosAlign.center, bold: true),
        linesAfter: 2,
      ),
    );
    bytes.addAll(generator.cut());

    return Uint8List.fromList(bytes);
  }

  /// Mock order for testing (5 items).
  static Order createMockOrder() {
    final items = [
      const OrderItem(quantity: 2, name: 'Coffee', unitPrice: 4.50),
      const OrderItem(quantity: 1, name: 'Croissant', unitPrice: 3.25),
      const OrderItem(quantity: 3, name: 'Muffin', unitPrice: 2.99),
      const OrderItem(quantity: 1, name: 'Orange Juice', unitPrice: 5.00),
      const OrderItem(quantity: 2, name: 'Bagel', unitPrice: 3.50),
    ];
    final subtotal = items.fold<double>(0, (s, i) => s + i.total);
    const discount = 2.00;
    return Order(
      shopName: AppConstants.shopName,
      shopAddress: AppConstants.shopAddress,
      items: items,
      subtotal: subtotal,
      discount: discount,
      paymentMethod: 'Card',
      dateTime: DateTime.now(),
    );
  }

  /// Generates a text preview of the receipt (for Receipt Preview screen).
  static String generateReceiptPreview(Order order) {
    final buffer = StringBuffer();
    buffer.writeln(order.shopName.toUpperCase());
    buffer.writeln(order.shopAddress);
    buffer.writeln(_formatDateTime(order.dateTime));
    buffer.writeln('-' * 32);
    buffer.writeln('QTY   ITEM              PRICE   TOTAL');
    buffer.writeln('-' * 32);
    for (final item in order.items) {
      final qty = item.quantity.toString().padLeft(3);
      final name = item.name.padRight(16);
      final price = '\$${item.unitPrice.toStringAsFixed(2)}'.padLeft(7);
      final total = '\$${item.total.toStringAsFixed(2)}'.padLeft(7);
      buffer.writeln('$qty   $name $price $total');
    }
    buffer.writeln('-' * 32);
    buffer.writeln('Subtotal:                    \$${order.subtotal.toStringAsFixed(2)}');
    buffer.writeln('Discount:                    -\$${order.discount.toStringAsFixed(2)}');
    buffer.writeln('Total:                       \$${order.total.toStringAsFixed(2)}');
    buffer.writeln('-' * 32);
    buffer.writeln('Payment: ${order.paymentMethod}');
    buffer.writeln();
    buffer.writeln('Thank you for your purchase!');
    return buffer.toString();
  }

  static String _formatDateTime(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
