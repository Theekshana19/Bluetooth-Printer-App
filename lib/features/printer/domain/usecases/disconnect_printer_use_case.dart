import '../repositories/printer_repository.dart';

/// Use case for disconnecting from the printer.
class DisconnectPrinterUseCase {
  DisconnectPrinterUseCase(this._repository);

  final PrinterRepository _repository;

  Future<void> call() => _repository.disconnect();
}
