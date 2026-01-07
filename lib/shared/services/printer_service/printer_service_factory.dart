import 'dart:io';
import 'package:desktoppossystem/shared/services/printer_service/printer_service.dart';
import 'package:desktoppossystem/shared/services/printer_service/thermal_printer_service.dart';
import 'package:desktoppossystem/shared/services/printer_service/bluetooth_printer_service.dart';

class PrinterServiceFactory {
  static PrinterService getPrinterService() {
    if (Platform.isWindows) {
      // Desktop platforms use USB/Thermal printer
      return ThermalPrinterService();
    } else if (Platform.isAndroid || Platform.isIOS) {
      // Mobile platforms use Bluetooth printer
      return BluetoothPrinterService();
    } else {
      throw UnsupportedError('Platform not supported for printing');
    }
  }
}
