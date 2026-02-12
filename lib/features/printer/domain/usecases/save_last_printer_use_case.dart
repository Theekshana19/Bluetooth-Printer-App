import '../entities/printer_device.dart';
import '../repositories/printer_repository.dart';

/// Use case for saving the last connected printer.
class SaveLastPrinterUseCase {
  SaveLastPrinterUseCase(this._repository);

  final PrinterRepository _repository;

  Future<void> call(PrinterDevice device) =>
      _repository.saveLastConnectedDevice(device);
}
