import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/printer_provider.dart';

/// Card showing the current printer connection status.
class ConnectionStatusCard extends ConsumerWidget {
  const ConnectionStatusCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(printerNotifierProvider);

    final statusText = switch (state.connectionState) {
      PrinterConnectionState.disconnected => 'Disconnected',
      PrinterConnectionState.connecting => 'Connecting...',
      PrinterConnectionState.connected => 'Connected',
      PrinterConnectionState.printing => 'Printing...',
      PrinterConnectionState.error => 'Error',
    };

    final statusColor = switch (state.connectionState) {
      PrinterConnectionState.disconnected => Colors.grey,
      PrinterConnectionState.connecting => Colors.orange,
      PrinterConnectionState.connected => Colors.green,
      PrinterConnectionState.printing => Colors.blue,
      PrinterConnectionState.error => Colors.red,
    };

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  statusText,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            if (state.connectedDevice != null) ...[
              const SizedBox(height: 8),
              Text(
                '${state.connectedDevice!.name} (${state.connectedDevice!.typeLabel})',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
            if (state.lastDevice != null && state.connectedDevice == null) ...[
              const SizedBox(height: 8),
              Text(
                'Last: ${state.lastDevice!.name}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey,
                    ),
              ),
            ],
            if (state.errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                state.errorMessage!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.red,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
