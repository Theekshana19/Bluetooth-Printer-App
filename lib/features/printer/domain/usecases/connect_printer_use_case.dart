import '../entities/printer_device.dart';
import '../repositories/printer_repository.dart';

/// Use case for connecting to a printer.
class ConnectPrinterUseCase {
  ConnectPrinterUseCase(this._repository);

  final PrinterRepository _repository;

  Future<void> call(PrinterDevice device) => _repository.connect(device);
}
