import 'package:flutter/material.dart';

import '../../domain/entities/printer_device.dart';

/// List tile for a discovered printer device.
class PrinterDeviceTile extends StatelessWidget {
  const PrinterDeviceTile({
    super.key,
    required this.device,
    required this.onConnect,
    this.isConnecting = false,
  });

  final PrinterDevice device;
  final VoidCallback onConnect;
  final bool isConnecting;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        Icons.print,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(device.name.isNotEmpty ? device.name : 'Unknown Printer'),
      subtitle: Text('${device.address} • ${device.typeLabel}'),
      trailing: FilledButton(
        onPressed: isConnecting ? null : onConnect,
        child: isConnecting
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Connect'),
      ),
    );
  }
}
