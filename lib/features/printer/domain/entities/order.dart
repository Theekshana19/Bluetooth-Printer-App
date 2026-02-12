/// Domain entity for order/receipt data.
class OrderItem {
  const OrderItem({
    required this.quantity,
    required this.name,
    required this.unitPrice,
  });

  final int quantity;
  final String name;
  final double unitPrice;

  double get total => quantity * unitPrice;
}

/// Order model for receipt generation.
class Order {
  const Order({
    required this.shopName,
    required this.shopAddress,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.paymentMethod,
    required this.dateTime,
  });

  final String shopName;
  final String shopAddress;
  final List<OrderItem> items;
  final double subtotal;
  final double discount;
  final String paymentMethod;
  final DateTime dateTime;

  double get total => subtotal - discount;
}
