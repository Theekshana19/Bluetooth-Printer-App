import 'package:bluetooth_printer_app/core/errors/printer_exception.dart';
import 'package:bluetooth_printer_app/features/printer/data/bt_status.dart';
import 'package:bluetooth_printer_app/features/printer/domain/entities/printer_device.dart' as app;

/// Stub remote datasource for web – Bluetooth printing is not supported.
class PrinterRemoteDatasource {
  Stream<app.PrinterDevice> discoverDevices() =>
      const Stream<app.PrinterDevice>.empty();

  Future<void> connect(app.PrinterDevice device) async {
    throw PrinterConnectionException(
        'Bluetooth printing is not supported on web. Use Android or iOS.');
  }

  Future<void> connectWithAutoReconnect(app.PrinterDevice device) async {
    throw PrinterConnectionException(
        'Bluetooth printing is not supported on web. Use Android or iOS.');
  }

  Future<void> disconnect() async {}

  Future<void> sendBytes(List<int> bytes) async {
    throw PrinterPrintException(
        'Bluetooth printing is not supported on web. Use Android or iOS.');
  }

  Stream<BtStatus> get bluetoothState => Stream<BtStatus>.value(BtStatus.none);
}
