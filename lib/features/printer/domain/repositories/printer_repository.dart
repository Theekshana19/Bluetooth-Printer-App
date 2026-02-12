import '../entities/printer_device.dart';

/// Repository interface for printer operations.
abstract class PrinterRepository {
  Stream<PrinterDevice> discoverDevices();

  Future<void> connect(PrinterDevice device);

  Future<void> connectWithAutoReconnect(PrinterDevice device);

  Future<void> disconnect();

  Future<void> sendPrintBytes(List<int> bytes);

  Future<PrinterDevice?> getLastConnectedDevice();

  Future<void> saveLastConnectedDevice(PrinterDevice device);

  Stream<dynamic> watchBluetoothState();
}
