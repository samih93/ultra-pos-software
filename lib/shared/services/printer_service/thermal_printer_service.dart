import 'package:desktoppossystem/models/printer_model.dart';
import 'package:desktoppossystem/shared/services/printer_service/printer_service.dart';
import 'package:flutter/material.dart';
import 'package:thermal_printer_plus/thermal_printer.dart';

class ThermalPrinterService implements PrinterService {
  @override
  Stream<List<PrinterModel>> listenToPrinters() {
    final printersList = <PrinterModel>[];
    return PrinterManager.instance
        .discovery(type: PrinterType.usb)
        .map((device) {
      printersList.add(PrinterModel(modelName: device.name));
      return List<PrinterModel>.from(printersList);
    });
  }

  @override
  Future<bool> connectToPrinter(String printerName) async {
    try {
      return await PrinterManager.instance.connect(
        type: PrinterType.usb,
        model: UsbPrinterInput(name: printerName),
      );
    } catch (e) {
      debugPrint('Error connecting to USB printer: $e');
      return false;
    }
  }

  @override
  Future<void> printReceipt(List<int> bytes) async {
    try {
      await PrinterManager.instance.send(
        type: PrinterType.usb,
        bytes: bytes,
      );
    } catch (error) {
      debugPrint('Error printing: $error');
      rethrow;
    }
  }

  @override
  Future<void> disconnect() {
    throw UnimplementedError();
  }

  @override
  Future<void> openCashDrawer() {
    throw UnimplementedError();
  }
}
