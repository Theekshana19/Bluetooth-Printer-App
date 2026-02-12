/// Application-wide constants.
class AppConstants {
  AppConstants._();

  static const String lastPrinterAddressKey = 'last_printer_address';
  static const String lastPrinterNameKey = 'last_printer_name';
  static const String lastPrinterIsBleKey = 'last_printer_is_ble';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration scanTimeout = Duration(seconds: 10);

  static const String shopName = 'Sample Shop';
  static const String shopAddress = '123 Main Street, City, Country';
}
