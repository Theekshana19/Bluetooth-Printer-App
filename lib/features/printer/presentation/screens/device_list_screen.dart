import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/printer_device.dart';
import '../providers/printer_provider.dart';
import '../widgets/printer_device_tile.dart';

class DeviceListScreen extends ConsumerStatefulWidget {
  const DeviceListScreen({super.key});

  @override
  ConsumerState<DeviceListScreen> createState() => _DeviceListScreenState();
}

class _DeviceListScreenState extends ConsumerState<DeviceListScreen> {
  PrinterDevice? _connectingDevice;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(printerNotifierProvider.notifier).scanDevices();
    });
  }

  Future<void> _connect(PrinterDevice device) async {
    setState(() => _connectingDevice = device);
    try {
      await ref.read(printerNotifierProvider.notifier).connect(device);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _connectingDevice = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(printerNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Printers'),
      ),
      body: Column(
        children: [
          if (Platform.isIOS)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: Colors.blue.shade50,
              child: Text(
                'iOS supports BLE printers only. Classic-only printers require Wi-Fi/AirPrint or a BLE model.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          if (state.isScanning)
            const LinearProgressIndicator(),
          Expanded(
            child: state.devices.isEmpty && !state.isScanning
                ? Center(
                    child: Text(
                      'No printers found. Ensure Bluetooth is on and printer is discoverable.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  )
                : ListView.builder(
                    itemCount: state.devices.length,
                    itemBuilder: (context, i) {
                      final device = state.devices[i];
                      return PrinterDeviceTile(
                        device: device,
                        onConnect: () => _connect(device),
                        isConnecting: _connectingDevice == device,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
