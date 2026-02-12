import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../receipt/receipt_generator.dart';
import '../providers/printer_provider.dart';
import '../widgets/connection_status_card.dart';
import 'device_list_screen.dart';
import 'receipt_preview_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(printerNotifierProvider.notifier).loadLastDevice();
      ref.read(printerNotifierProvider.notifier).autoReconnect();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(printerNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bluetooth Printer'),
        centerTitle: true,
        actions: [
          if (state.connectionState == PrinterConnectionState.connected)
            IconButton(
              icon: const Icon(Icons.link_off),
              onPressed: () =>
                  ref.read(printerNotifierProvider.notifier).disconnect(),
              tooltip: 'Disconnect',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ConnectionStatusCard(),
            const SizedBox(height: 24),
            if (state.errorMessage != null) ...[
              Row(
                children: [
                  Expanded(
                    child: Text(
                      state.errorMessage!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        ref.read(printerNotifierProvider.notifier).clearError(),
                    child: const Text('Dismiss'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            FilledButton.icon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const DeviceListScreen(),
                ),
              ),
              icon: const Icon(Icons.search),
              label: const Text('Scan & Connect'),
            ),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ReceiptPreviewScreen(),
                ),
              ),
              icon: const Icon(Icons.receipt_long),
              label: const Text('Receipt Preview & Print'),
            ),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: state.connectionState == PrinterConnectionState.connected
                  ? () async {
                      final order = ReceiptGenerator.createMockOrder();
                      await ref.read(printerNotifierProvider.notifier).printReceipt(order);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Test print sent')),
                        );
                      }
                    }
                  : null,
              icon: const Icon(Icons.print),
              label: const Text('Test Print'),
            ),
            const SizedBox(height: 24),
            if (Platform.isIOS)
              Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    'iOS supports BLE printers only. Classic Bluetooth printers require Wi-Fi/AirPrint or a BLE-capable model.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
