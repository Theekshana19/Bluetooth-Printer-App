import '../entities/printer_device.dart';
import '../repositories/printer_repository.dart';

/// Use case for auto-reconnecting to the last printer.
class AutoReconnectUseCase {
  AutoReconnectUseCase(this._repository);

  final PrinterRepository _repository;

  Future<PrinterDevice?> getLastDevice() => _repository.getLastConnectedDevice();

  Future<void> reconnect(PrinterDevice device) =>
      _repository.connectWithAutoReconnect(device);
}
