import 'package:desktoppossystem/models/printer_model.dart';

abstract class PrinterService {
  /// Listen to available printers
  Stream<List<PrinterModel>> listenToPrinters();

  /// Connect to a specific printer
  Future<bool> connectToPrinter(String printerName);

  /// Print receipt bytes
  Future<void> printReceipt(List<int> bytes);

  /// Open cash drawer (if supported)
  Future<void> openCashDrawer();

  /// Disconnect from printer
  Future<void> disconnect();
}
