import 'dart:typed_data';

import 'package:desktoppossystem/models/customers_model.dart';
import 'package:desktoppossystem/models/printer_model.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';

import '../../models/reports/end_of_day_model.dart';

abstract class IPrinterRepository {
  Stream<List<PrinterModel>> listenToPrinters();
  Future<bool> connectToPrinter(String printerName);
  Future printReceipt(List<int> value);

  Future<List<int>> buildReceiptTicket(
      {required List<Uint8List> images,
      required double originalTotalForeign,
      required double totalForeign,
      required double dolarRate,
      bool? dontOpenCash,
      String? receiptNumber,
      String? tableNumber,
      int? invoiceNumber,
      required bool printReceiptInLebanon,
      required bool printReceiptInDolar,
      CustomerModel? customerModel,
      bool? isHasDiscount,
      bool? isQuotaion,
      String? receiptDate,
      String? receiptDiscount // used if all products same discount
      });
  Future<List<int>> buildRestaurantStockTicket({
    required List<Uint8List> images,
  });
  Future<List<int>> buildOrderTicket(PageSize pageSize, List<Uint8List> images,
      int receiptNumber, String tableNumber, String orderedBy);
  Future<List<int>> buildEndOfDayTicket(
      PageSize pageSize, EndOfDayModel endOfDayModel);

  Future<PrinterModel?> getCurrentPrinterSettings();
  Future<PrinterModel> updateCurrentPrinterSettings(PrinterModel printermodel);
  Future<PrinterModel> addPrinterSettings(PrinterModel printermodel);

  Future openCashDrawer(PrinterModel printermodel);
}
