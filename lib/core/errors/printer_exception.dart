/// Base exception for printer-related errors.
class PrinterException implements Exception {
  PrinterException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => 'PrinterException: $message${cause != null ? ' (cause: $cause)' : ''}';
}

/// Thrown when connection fails.
class PrinterConnectionException extends PrinterException {
  PrinterConnectionException(super.message, [super.cause]);
}

/// Thrown when printing fails.
class PrinterPrintException extends PrinterException {
  PrinterPrintException(super.message, [super.cause]);
}
