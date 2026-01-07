import 'dart:io';
import 'package:desktoppossystem/models/printer_model.dart';
import 'package:desktoppossystem/shared/services/printer_service/printer_service.dart';
import 'package:flutter/material.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:permission_handler/permission_handler.dart';

/// Bluetooth Printer Service for Android devices
class BluetoothPrinterService implements PrinterService {
  /// Request Bluetooth permissions on Android
  Future<bool> _requestBluetoothPermissions() async {
    if (!Platform.isAndroid) return true;

    try {
      // Check if permission is already granted
      final bool isGranted =
          await PrintBluetoothThermal.isPermissionBluetoothGranted;

      if (!isGranted) {
        // Request Bluetooth permissions
        final Map<Permission, PermissionStatus> statuses = await [
          Permission.bluetoothScan,
          Permission.bluetoothConnect,
        ].request();

        final bool allGranted = statuses.values.every(
          (status) => status.isGranted,
        );

        if (!allGranted) {
          debugPrint(
            'Bluetooth permissions not granted. Please enable in settings.',
          );
          return false;
        }
      }

      // Check if Bluetooth is enabled
      final bool bluetoothEnabled =
          await PrintBluetoothThermal.bluetoothEnabled;
      if (!bluetoothEnabled) {
        debugPrint('Bluetooth is not enabled. Please enable Bluetooth.');
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('Error requesting Bluetooth permissions: $e');
      return false;
    }
  }

  @override
  Stream<List<PrinterModel>> listenToPrinters() async* {
    if (!Platform.isAndroid) {
      yield <PrinterModel>[];
      return;
    }

    // Request permissions first
    final hasPermissions = await _requestBluetoothPermissions();
    if (!hasPermissions) {
      debugPrint('Bluetooth permissions denied');
      yield <PrinterModel>[];
      return;
    }

    try {
      final List<BluetoothInfo> devices =
          await PrintBluetoothThermal.pairedBluetooths;
      yield devices
          .map((device) => PrinterModel(modelName: device.name))
          .toList();
    } catch (e) {
      debugPrint('Bluetooth scan error: $e');
      yield <PrinterModel>[];
    }
  }

  @override
  Future<bool> connectToPrinter(String printerName) async {
    if (!Platform.isAndroid) return false;

    try {
      // Check if printer name is valid
      if (printerName.isEmpty) {
        debugPrint('Bluetooth connect error: Printer name is empty');
        return false;
      }

      final List<BluetoothInfo> devices =
          await PrintBluetoothThermal.pairedBluetooths;

      debugPrint('Available paired Bluetooth devices:');
      for (var device in devices) {
        debugPrint('  - ${device.name} (${device.macAdress})');
      }
      debugPrint('Attempting to connect to: $printerName');

      final device = devices.firstWhere(
        (d) => d.name == printerName,
        orElse: () => throw Exception('Printer "$printerName" not found'),
      );

      // Check if already connected
      final bool isConnected = await PrintBluetoothThermal.connectionStatus;
      if (isConnected) {
        debugPrint('Disconnecting from previous printer...');
        await PrintBluetoothThermal.disconnect;
      }

      // Connect to device using MAC address
      final bool connected = await PrintBluetoothThermal.connect(
        macPrinterAddress: device.macAdress,
      );

      if (connected) {
        debugPrint('Connected to Bluetooth printer: $printerName');
      } else {
        debugPrint('Failed to connect to Bluetooth printer: $printerName');
      }

      return connected;
    } catch (e) {
      debugPrint('Bluetooth connect error: $e');
      return false;
    }
  }

  @override
  Future<void> printReceipt(List<int> bytes) async {
    if (!Platform.isAndroid) return;

    try {
      final bool isConnected = await PrintBluetoothThermal.connectionStatus;
      if (!isConnected) {
        throw Exception('Printer not connected');
      }

      await PrintBluetoothThermal.writeBytes(bytes);
      debugPrint('Printed ${bytes.length} bytes via Bluetooth');
    } catch (e) {
      debugPrint('Bluetooth print error: $e');
      rethrow;
    }
  }

  @override
  Future<void> openCashDrawer() async {}

  @override
  Future<void> disconnect() async {
    if (!Platform.isAndroid) return;

    try {
      await PrintBluetoothThermal.disconnect;
      debugPrint('Disconnected from Bluetooth printer');
    } catch (e) {
      debugPrint('Bluetooth disconnect error: $e');
    }
  }
}
