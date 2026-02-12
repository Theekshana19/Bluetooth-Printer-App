import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'features/printer/presentation/providers/printer_provider.dart';
import 'features/printer/presentation/screens/home_screen.dart';

class BluetoothPrinterApp extends ConsumerWidget {
  const BluetoothPrinterApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prefsAsync = ref.watch(sharedPreferencesProvider);

    return MaterialApp(
      title: 'Bluetooth Printer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: prefsAsync.when(
        data: (_) => const HomeScreen(),
        loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Scaffold(
          body: Center(child: Text('Error: $e')),
        ),
      ),
    );
  }
}
