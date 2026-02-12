import 'dart:async';
import 'dart:io';

import 'package:bluetooth_printer_app/core/constants/app_constants.dart';
import 'package:bluetooth_printer_app/core/errors/printer_exception.dart';
import 'package:bluetooth_printer_app/core/utils/logger_util.dart';
import 'package:bluetooth_printer_app/features/printer/data/bt_status.dart';
import 'package:bluetooth_printer_app/features/printer/domain/entities/printer_device.dart' as app;
import 'package:thermal_printer/thermal_printer.dart';
import '../models/printer_device_model.dart';

BtStatus _toBtStatus(BTStatus s) {
  switch (s) {
    case BTStatus.none:
      return BtStatus.none;
    case BTStatus.stopScanning:
      return BtStatus.stopScanning;
    case BTStatus.connected:
      return BtStatus.connected;
    case BTStatus.scanning:
      return BtStatus.scanning;
    default:
      return BtStatus.none;
  }
}

/// Remote datasource for printer operations via thermal_printer (mobile only).
class PrinterRemoteDatasource {
  PrinterRemoteDatasource() : _manager = PrinterManager.instance;

  final PrinterManager _manager;

  Stream<app.PrinterDevice> discoverDevices() {
    LoggerUtil.log('Starting device discovery');

    if (Platform.isIOS) {
      return _manager.discovery(type: PrinterType.bluetooth, isBle: true).map<app.PrinterDevice>(
            (d) => PrinterDeviceModel.fromPrinterDevice(d, isBle: true),
          );
    }

    final seen = <String>{};
    late StreamSubscription sub1, sub2;
    final ctrl = StreamController<app.PrinterDevice>.broadcast(
      onCancel: () {
        sub1.cancel();
        sub2.cancel();
      },
    );

    void addDevice(app.PrinterDevice d) {
      final key = '${d.address}_${d.isBle}';
      if (!seen.contains(key)) {
        seen.add(key);
        ctrl.add(d);
      }
    }

    sub1 = _manager.discovery(type: PrinterType.bluetooth, isBle: true).listen(
          (d) => addDevice(PrinterDeviceModel.fromPrinterDevice(d, isBle: true)),
        );
    sub2 = _manager.discovery(type: PrinterType.bluetooth, isBle: false).listen(
          (d) => addDevice(PrinterDeviceModel.fromPrinterDevice(d, isBle: false)),
        );

    return ctrl.stream;
  }

  Future<void> connect(app.PrinterDevice device) async {
    LoggerUtil.log('Connecting to ${device.name} (${device.address})');

    final input = BluetoothPrinterInput(
      address: device.address,
      name: device.name,
      isBle: device.isBle,
      autoConnect: false,
    );

    try {
      final success = await _manager.connect(
        type: PrinterType.bluetooth,
        model: input,
      ).timeout(AppConstants.connectTimeout);

      if (!success) {
        throw PrinterConnectionException('Connection failed');
      }
      LoggerUtil.log('Connected successfully');
    } on TimeoutException {
      throw PrinterConnectionException('Connection timed out after ${AppConstants.connectTimeout.inSeconds}s');
    } catch (e, st) {
      LoggerUtil.log('Connect error', e, st);
      throw PrinterConnectionException('Failed to connect: $e', e);
    }
  }

  Future<void> connectWithAutoReconnect(app.PrinterDevice device) async {
    LoggerUtil.log('Connecting (auto-reconnect) to ${device.name}');

    final input = BluetoothPrinterInput(
      address: device.address,
      name: device.name,
      isBle: device.isBle,
      autoConnect: true,
    );

    final success = await _manager.connect(
      type: PrinterType.bluetooth,
      model: input,
    ).timeout(AppConstants.connectTimeout);

    if (!success) {
      throw PrinterConnectionException('Auto-reconnect failed');
    }
  }

  Future<void> disconnect() async {
    LoggerUtil.log('Disconnecting');
    await _manager.disconnect(type: PrinterType.bluetooth);
  }

  Future<void> sendBytes(List<int> bytes) async {
    LoggerUtil.log('Sending ${bytes.length} bytes to printer');

    final success = await _manager.send(
      type: PrinterType.bluetooth,
      bytes: bytes,
    );

    if (!success) {
      throw PrinterPrintException('Failed to send print data');
    }
    LoggerUtil.log('Print data sent successfully');
  }

  Stream<BtStatus> get bluetoothState =>
      _manager.stateBluetooth.map(_toBtStatus);
}
