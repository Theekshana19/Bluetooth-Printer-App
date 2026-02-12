import '../../domain/entities/printer_device.dart';
import '../../domain/repositories/printer_repository.dart';
import '../datasources/printer_local_datasource.dart';
import '../datasources/printer_remote_datasource.dart';

/// Implementation of [PrinterRepository].
class PrinterRepositoryImpl implements PrinterRepository {
  PrinterRepositoryImpl({
    required PrinterRemoteDatasource remote,
    required PrinterLocalDatasource local,
  })  : _remote = remote,
        _local = local;

  final PrinterRemoteDatasource _remote;
  final PrinterLocalDatasource _local;

  @override
  Stream<PrinterDevice> discoverDevices() => _remote.discoverDevices();

  @override
  Future<void> connect(PrinterDevice device) => _remote.connect(device);

  @override
  Future<void> connectWithAutoReconnect(PrinterDevice device) =>
      _remote.connectWithAutoReconnect(device);

  @override
  Future<void> disconnect() => _remote.disconnect();

  @override
  Future<void> sendPrintBytes(List<int> bytes) => _remote.sendBytes(bytes);

  @override
  Future<PrinterDevice?> getLastConnectedDevice() => _local.getLastPrinter();

  @override
  Future<void> saveLastConnectedDevice(PrinterDevice device) =>
      _local.saveLastPrinter(device);

  @override
  Stream<dynamic> watchBluetoothState() => _remote.bluetoothState;
}
