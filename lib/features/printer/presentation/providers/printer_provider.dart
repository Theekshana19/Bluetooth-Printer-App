import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:thermal_printer/thermal_printer.dart';

import '../../data/datasources/printer_local_datasource.dart';
import '../../data/datasources/printer_remote_datasource.dart';
import '../../data/repositories/printer_repository_impl.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/printer_device.dart';
import '../../domain/usecases/auto_reconnect_use_case.dart';
import '../../domain/usecases/connect_printer_use_case.dart';
import '../../domain/usecases/disconnect_printer_use_case.dart';
import '../../domain/usecases/print_receipt_use_case.dart';
import '../../domain/usecases/save_last_printer_use_case.dart';
import '../../domain/usecases/scan_devices_use_case.dart';
import '../../../core/utils/logger_util.dart';

/// Connection state for the printer.
enum PrinterConnectionState {
  disconnected,
  connecting,
  connected,
  printing,
  error,
}

/// State held by the printer notifier.
class PrinterState {
  const PrinterState({
    this.connectionState = PrinterConnectionState.disconnected,
    this.connectedDevice,
    this.lastDevice,
    this.errorMessage,
    this.devices = const [],
    this.isScanning = false,
  });

  final PrinterConnectionState connectionState;
  final PrinterDevice? connectedDevice;
  final PrinterDevice? lastDevice;
  final String? errorMessage;
  final List<PrinterDevice> devices;
  final bool isScanning;

  PrinterState copyWith({
    PrinterConnectionState? connectionState,
    PrinterDevice? connectedDevice,
    PrinterDevice? lastDevice,
    String? errorMessage,
    List<PrinterDevice>? devices,
    bool? isScanning,
  }) {
    return PrinterState(
      connectionState: connectionState ?? this.connectionState,
      connectedDevice: connectedDevice ?? this.connectedDevice,
      lastDevice: lastDevice ?? this.lastDevice,
      errorMessage: errorMessage,
      devices: devices ?? this.devices,
      isScanning: isScanning ?? this.isScanning,
    );
  }
}

/// Notifier for printer state and actions.
class PrinterNotifier extends StateNotifier<PrinterState> {
  PrinterNotifier(this._scanUseCase, this._connectUseCase, this._disconnectUseCase,
      this._printUseCase, this._saveLastPrinterUseCase, this._autoReconnectUseCase,
      this._repository)
    : super(const PrinterState()) {
    _listenToBluetoothState();
  }

  final ScanDevicesUseCase _scanUseCase;
  final ConnectPrinterUseCase _connectUseCase;
  final DisconnectPrinterUseCase _disconnectUseCase;
  final PrintReceiptUseCase _printUseCase;
  final SaveLastPrinterUseCase _saveLastPrinterUseCase;
  final AutoReconnectUseCase _autoReconnectUseCase;
  final PrinterRepositoryImpl _repository;

  StreamSubscription<BTStatus>? _btSubscription;

  void _listenToBluetoothState() {
    _btSubscription = _repository.watchBluetoothState().listen((status) {
      LoggerUtil.log('BTStatus: $status');
      if (status == BTStatus.none || status == BTStatus.stopScanning) {
        if (state.connectionState != PrinterConnectionState.connecting &&
            state.connectionState != PrinterConnectionState.printing) {
          state = state.copyWith(
            connectionState: PrinterConnectionState.disconnected,
            connectedDevice: null,
            errorMessage: null,
          );
        }
      } else if (status == BTStatus.connected) {
        state = state.copyWith(
          connectionState: PrinterConnectionState.connected,
          errorMessage: null,
        );
      }
    });
  }

  @override
  void dispose() {
    _btSubscription?.cancel();
    super.dispose();
  }

  Future<bool> requestPermissions() async {
    if (await Permission.bluetoothScan.isGranted &&
        await Permission.bluetoothConnect.isGranted) {
      return true;
    }
    final results = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();
    return results[Permission.bluetoothScan]?.isGranted == true &&
        results[Permission.bluetoothConnect]?.isGranted == true;
  }

  Future<void> loadLastDevice() async {
    final device = await _autoReconnectUseCase.getLastDevice();
    state = state.copyWith(lastDevice: device);
  }

  Future<void> scanDevices() async {
    if (!await requestPermissions()) {
      state = state.copyWith(errorMessage: 'Bluetooth permissions required');
      return;
    }
    state = state.copyWith(isScanning: true, devices: [], errorMessage: null);
    final devices = <PrinterDevice>[];
    final sub = _scanUseCase().listen(
      (d) {
        devices.add(d);
        state = state.copyWith(devices: List.from(devices));
      },
      onError: (e) {
        state = state.copyWith(
          isScanning: false,
          errorMessage: 'Scan failed: $e',
        );
      },
    );
    await Future.delayed(const Duration(seconds: 10));
    await sub.cancel();
    state = state.copyWith(isScanning: false);
  }

  Future<void> connect(PrinterDevice device) async {
    if (!await requestPermissions()) {
      state = state.copyWith(errorMessage: 'Bluetooth permissions required');
      return;
    }
    state = state.copyWith(
      connectionState: PrinterConnectionState.connecting,
      errorMessage: null,
    );
    try {
      await _connectUseCase(device);
      await _saveLastPrinterUseCase(device);
      state = state.copyWith(
        connectionState: PrinterConnectionState.connected,
        connectedDevice: device,
        lastDevice: device,
        errorMessage: null,
      );
    } catch (e) {
      LoggerUtil.log('Connect failed', e);
      state = state.copyWith(
        connectionState: PrinterConnectionState.error,
        errorMessage: 'Failed to connect: $e',
      );
    }
  }

  Future<void> disconnect() async {
    try {
      await _disconnectUseCase();
      state = state.copyWith(
        connectionState: PrinterConnectionState.disconnected,
        connectedDevice: null,
        errorMessage: null,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Disconnect failed: $e');
    }
  }

  Future<void> printReceipt(Order order) async {
    if (state.connectionState != PrinterConnectionState.connected) {
      state = state.copyWith(errorMessage: 'Not connected to printer');
      return;
    }
    state = state.copyWith(
      connectionState: PrinterConnectionState.printing,
      errorMessage: null,
    );
    try {
      await _printUseCase(order);
      state = state.copyWith(connectionState: PrinterConnectionState.connected);
    } catch (e) {
      LoggerUtil.log('Print failed', e);
      state = state.copyWith(
        connectionState: PrinterConnectionState.error,
        errorMessage: 'Print failed: $e',
      );
    }
  }

  Future<void> autoReconnect() async {
    final device = await _autoReconnectUseCase.getLastDevice();
    if (device == null) return;
    state = state.copyWith(
      connectionState: PrinterConnectionState.connecting,
      errorMessage: null,
    );
    try {
      await _autoReconnectUseCase.reconnect(device);
      state = state.copyWith(
        connectionState: PrinterConnectionState.connected,
        connectedDevice: device,
        lastDevice: device,
        errorMessage: null,
      );
    } catch (e) {
      LoggerUtil.log('Auto-reconnect failed', e);
      state = state.copyWith(
        connectionState: PrinterConnectionState.disconnected,
        connectedDevice: null,
        errorMessage: null,
      );
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}

/// Provider for SharedPreferences. Override in main() after init.
final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

/// Provider for the printer repository.
final printerRepositoryProvider = Provider<PrinterRepositoryImpl>((ref) {
  final prefsAsync = ref.watch(sharedPreferencesProvider);
  final prefs = prefsAsync.valueOrNull;
  if (prefs == null) {
    throw StateError('SharedPreferences not yet loaded');
  }
  return PrinterRepositoryImpl(
    remote: PrinterRemoteDatasource(),
    local: PrinterLocalDatasource(prefs),
  );
});

/// Provider for use cases (lazy, depend on repository).
final scanDevicesUseCaseProvider = Provider<ScanDevicesUseCase>((ref) {
  return ScanDevicesUseCase(ref.watch(printerRepositoryProvider));
});

final connectPrinterUseCaseProvider = Provider<ConnectPrinterUseCase>((ref) {
  return ConnectPrinterUseCase(ref.watch(printerRepositoryProvider));
});

final disconnectPrinterUseCaseProvider = Provider<DisconnectPrinterUseCase>((ref) {
  return DisconnectPrinterUseCase(ref.watch(printerRepositoryProvider));
});

final printReceiptUseCaseProvider = Provider<PrintReceiptUseCase>((ref) {
  return PrintReceiptUseCase(ref.watch(printerRepositoryProvider));
});

final saveLastPrinterUseCaseProvider = Provider<SaveLastPrinterUseCase>((ref) {
  return SaveLastPrinterUseCase(ref.watch(printerRepositoryProvider));
});

final autoReconnectUseCaseProvider = Provider<AutoReconnectUseCase>((ref) {
  return AutoReconnectUseCase(ref.watch(printerRepositoryProvider));
});

/// Provider for PrinterNotifier.
final printerNotifierProvider =
    StateNotifierProvider<PrinterNotifier, PrinterState>((ref) {
  final scan = ref.watch(scanDevicesUseCaseProvider);
  final connect = ref.watch(connectPrinterUseCaseProvider);
  final disconnect = ref.watch(disconnectPrinterUseCaseProvider);
  final printUc = ref.watch(printReceiptUseCaseProvider);
  final save = ref.watch(saveLastPrinterUseCaseProvider);
  final auto = ref.watch(autoReconnectUseCaseProvider);
  final repo = ref.watch(printerRepositoryProvider);
  return PrinterNotifier(scan, connect, disconnect, printUc, save, auto, repo);
});
