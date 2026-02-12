/// Domain entity representing a Bluetooth printer device.
class PrinterDevice {
  const PrinterDevice({
    required this.name,
    required this.address,
    required this.isBle,
  });

  final String name;
  final String address;
  final bool isBle;

  String get typeLabel => isBle ? 'BLE' : 'Classic';
}
