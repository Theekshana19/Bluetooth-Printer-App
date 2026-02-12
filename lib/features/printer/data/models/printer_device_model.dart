import 'package:thermal_printer/thermal_printer.dart' as tp;
import '../../domain/entities/printer_device.dart';

/// Adapter from thermal_printer's PrinterDevice to our domain entity.
class PrinterDeviceModel {
  PrinterDeviceModel._();

  static PrinterDevice fromPrinterDevice(tp.PrinterDevice device, {required bool isBle}) {
    return PrinterDevice(
      name: device.name,
      address: device.address ?? '',
      isBle: isBle,
    );
  }
}
