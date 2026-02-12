/// Bluetooth status for connection state.
/// Mirrors thermal_printer's BTStatus for platform-agnostic use.
enum BtStatus {
  none,
  stopScanning,
  connected,
  scanning,
}
