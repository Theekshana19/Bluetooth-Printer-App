import '../../../../receipt/receipt_generator.dart';
import '../entities/order.dart';
import '../repositories/printer_repository.dart';

/// Use case for printing a receipt.
class PrintReceiptUseCase {
  PrintReceiptUseCase(this._repository);

  final PrinterRepository _repository;

  Future<void> call(Order order) async {
    final bytes = await ReceiptGenerator.generateReceiptBytes(order);
    await _repository.sendPrintBytes(bytes);
  }
}
