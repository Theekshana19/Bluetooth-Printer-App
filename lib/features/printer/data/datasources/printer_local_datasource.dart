import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/constants/app_constants.dart';
import '../../domain/entities/printer_device.dart';

/// Local datasource for persisting last connected printer.
class PrinterLocalDatasource {
  PrinterLocalDatasource(this._prefs);

  final SharedPreferences _prefs;

  Future<void> saveLastPrinter(PrinterDevice device) async {
    await _prefs.setString(AppConstants.lastPrinterAddressKey, device.address);
    await _prefs.setString(AppConstants.lastPrinterNameKey, device.name);
    await _prefs.setBool(AppConstants.lastPrinterIsBleKey, device.isBle);
  }

  Future<PrinterDevice?> getLastPrinter() async {
    final address = _prefs.getString(AppConstants.lastPrinterAddressKey);
    final name = _prefs.getString(AppConstants.lastPrinterNameKey);
    final isBle = _prefs.getBool(AppConstants.lastPrinterIsBleKey);

    if (address == null || address.isEmpty) return null;

    return PrinterDevice(
      name: name ?? 'Unknown',
      address: address,
      isBle: isBle ?? true,
    );
  }

  Future<void> clearLastPrinter() async {
    await _prefs.remove(AppConstants.lastPrinterAddressKey);
    await _prefs.remove(AppConstants.lastPrinterNameKey);
    await _prefs.remove(AppConstants.lastPrinterIsBleKey);
  }
}
