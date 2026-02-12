import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../receipt/receipt_generator.dart';
import '../providers/printer_provider.dart';

class ReceiptPreviewScreen extends ConsumerWidget {
  const ReceiptPreviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final order = ReceiptGenerator.createMockOrder();
    final preview = ReceiptGenerator.generateReceiptPreview(order);
    final state = ref.watch(printerNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt Preview'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SelectableText(
                  preview,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: FilledButton.icon(
              onPressed: state.connectionState == PrinterConnectionState.connected
                  ? () async {
                      await ref
                          .read(printerNotifierProvider.notifier)
                          .printReceipt(order);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Print sent')),
                        );
                      }
                    }
                  : null,
              icon: const Icon(Icons.print),
              label: Text(
                state.connectionState == PrinterConnectionState.connected
                    ? 'Print'
                    : 'Connect a printer first',
              ),
              style: FilledButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
