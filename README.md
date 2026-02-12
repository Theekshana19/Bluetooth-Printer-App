# Bluetooth Receipt Printer App

A Flutter app for testing Bluetooth receipt printers on Android and iOS. Supports ESC/POS thermal printers via Bluetooth Classic (Android) and BLE (both platforms).

## Features

- **Scan & list nearby printers**: Android uses both Classic SPP and BLE; iOS uses BLE only
- **Connect/disconnect** to a selected printer
- **Print receipts** (ESC/POS) with shop name, address, date/time, items table, totals, payment, thank-you message, and paper cut
- **Receipt preview screen** with text preview and Print button
- **Test Print** button on home screen (prints immediately when connected)
- **Auto-reconnect** to last connected device on app open
- **iOS notice**: Shows message when printer is Classic-only (requires Wi-Fi/AirPrint or BLE model)

## Prerequisites

- Flutter stable (3.x) with null-safety
- Android Studio or Xcode
- Physical device (Bluetooth does not work in simulators/emulators)
- ESC/POS thermal printer (Bluetooth Classic and/or BLE)

## Setup

### 1. Clone and install

```bash
cd Bluetooth-Printer-App
flutter pub get
```

### 2. Generate platform files (if needed)

If the project was created manually, run:

```bash
flutter create .
```

This populates missing Android/iOS platform files (launcher icons, gradle wrapper, etc.).

### 3. Android

- **minSdkVersion**: 21 (already set in `android/app/build.gradle`)
- **Permissions**: Declared in `AndroidManifest.xml`:
  - `BLUETOOTH`, `BLUETOOTH_ADMIN` (legacy, maxSdk 30)
  - `BLUETOOTH_SCAN`, `BLUETOOTH_CONNECT` (Android 12+)
  - `ACCESS_FINE_LOCATION`, `ACCESS_COARSE_LOCATION` (for older BLE scan)

The app requests these at runtime before scanning/connecting.

### 4. iOS

- **Info.plist** already includes:
  - `NSBluetoothAlwaysUsageDescription`
  - `NSBluetoothPeripheralUsageDescription`
  - `UIBackgroundModes` with `bluetooth-central`

For `permission_handler`, add to `ios/Podfile` (inside `post_install`):

```ruby
config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
  '$(inherited)',
  'PERMISSION_BLUETOOTH=1',
]
```

Then run:

```bash
cd ios && pod install && cd ..
```

## Running the app

### Android

```bash
flutter run
```

Use a physical device; enable Bluetooth and grant permissions when prompted.

### iOS

```bash
flutter run
```

Use a physical iPhone/iPad; Bluetooth must be on. iOS only supports BLE printers.

## Testing with a printer

1. **Pair first**: Pair the printer in system Bluetooth settings (Android) or ensure it is discoverable (iOS).
2. **Power on**: Turn the printer on and ensure it is in discoverable mode.
3. **Open app**: Launch the app and tap **Scan & Connect**.
4. **Select device**: Choose your printer from the list (labeled Classic or BLE on Android).
5. **Connect**: Tap Connect; the home screen should show "Connected".
6. **Test print**: Tap **Test Print** to print a sample receipt, or open **Receipt Preview & Print** to see the preview and print.

### Common ESC/POS printer models

- RPP02N, RPP02N Pro (BLE)
- Many POS thermal printers with Bluetooth (Classic or BLE)
- Check your printer manual for Bluetooth mode (Classic vs BLE)

## Troubleshooting

### No devices found

- **Android**: Ensure Bluetooth is on, Location is on (required for BLE scan on older Android), and the printer is discoverable. Pair the printer in system settings first.
- **iOS**: Ensure Bluetooth is on. Only BLE printers appear. Classic-only printers will not show up.
- **Both**: Move closer to the printer; ensure it is not connected to another device.

### Connection fails

- **Timeout**: Printer may be off or out of range. Try again with the printer nearby.
- **Android Classic**: Some printers need to be paired in system settings before connecting from the app.
- **iOS**: If you see "iOS doesn't support this printer type", the printer is Classic-only. Use Wi-Fi/AirPrint or a BLE-capable model.

### Print fails or garbled output

- Verify the printer supports ESC/POS.
- Try a different paper width (app uses 80mm; some printers use 58mm).
- Check cable/power if printing stops midway.

### Permission denied

- **Android**: Grant Bluetooth and Location when prompted. On Android 12+, Bluetooth Scan and Connect are required.
- **iOS**: Allow Bluetooth when the system dialog appears.

### Driver / compatibility

- The app sends raw ESC/POS bytes. No special drivers are needed.
- If the printer uses a different command set (e.g. TSPL, CPCL), it may not print correctly.

## Project structure

```
lib/
├── main.dart
├── app.dart
├── core/           # Constants, errors, logging
├── features/printer/
│   ├── data/       # Datasources, models, repository impl
│   ├── domain/     # Entities, repository interface, use cases
│   └── presentation/
│       ├── providers/
│       ├── screens/
│       └── widgets/
└── receipt/        # ReceiptGenerator (ESC/POS bytes + preview)
```

## Dependencies

- `thermal_printer`: Bluetooth Classic + BLE, send raw bytes
- `esc_pos_utils_plus`: ESC/POS command generation
- `permission_handler`: Runtime permissions
- `shared_preferences`: Store last printer for auto-reconnect
- `flutter_riverpod`: State management

## License

MIT
# Bluetooth-Printer-App
