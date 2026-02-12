import '../entities/printer_device.dart';
import '../repositories/printer_repository.dart';

/// Use case for scanning nearby Bluetooth printers.
class ScanDevicesUseCase {
  ScanDevicesUseCase(this._repository);

  final PrinterRepository _repository;

  Stream<PrinterDevice> call() => _repository.discoverDevices();
}
