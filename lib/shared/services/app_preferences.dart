import 'dart:convert';
import 'dart:io';

import 'package:desktoppossystem/models/section_printer_model.dart';
import 'package:desktoppossystem/shared/config/secure_config.dart';
import 'package:desktoppossystem/shared/services/file_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppPreferences {
  static late SharedPreferences sharedPreferences;

  static Future init() async {
    try {
      sharedPreferences = await SharedPreferences.getInstance();
      if (Platform.isWindows) {
        await FileLogger().log('AppPreferences initialized', level: 'INFO');
      }
    } catch (e) {
      // SharedPreferences is corrupted, clear and recreate
      if (Platform.isWindows) {
        await FileLogger().log(
          'AppPreferences corrupted, clearing and recreating: $e',
          level: 'WARN',
        );
      }
      debugPrint('AppPreferences corrupted: $e');

      try {
        // Clear the corrupted preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        // Reinitialize
        sharedPreferences = await SharedPreferences.getInstance();

        if (Platform.isWindows) {
          await FileLogger().log(
            'AppPreferences recreated successfully',
            level: 'INFO',
          );
        }
      } catch (retryError) {
        if (Platform.isWindows) {
          await FileLogger().log(
            'FATAL: Cannot recreate AppPreferences: $retryError',
            level: 'ERROR',
          );
        }
        debugPrint('FATAL: Cannot recreate AppPreferences: $retryError');
        rethrow;
      }
    }
  }

  Future setTheme({required String key, required dynamic value}) async {
    await sharedPreferences.setBool(key, value);
  }

  bool? getThem({required String key}) {
    return sharedPreferences.getBool(key);
  }

  Future<bool> saveData({required String key, required dynamic value}) async {
    if (value is String) return await sharedPreferences.setString(key, value);
    if (value is int) return await sharedPreferences.setInt(key, value);
    if (value is bool) return await sharedPreferences.setBool(key, value);
    if (value is double) return await sharedPreferences.setDouble(key, value);

    return await sharedPreferences.setDouble(key, value);
  }

  getData({required String key}) {
    return sharedPreferences.get(key);
  }

  bool getBool({required String key, bool defaultValue = false}) {
    final value = sharedPreferences.get(key);
    if (value == null) return defaultValue;

    // Handle cases where boolean might be stored as int (0/1)
    if (value is bool) return value;

    return defaultValue;
  }

  bool getSecureBool({required String key, bool defaultValue = false}) {
    final value = sharedPreferences.get(key);
    if (value == null) return defaultValue;

    // Handle cases where boolean might be stored as String
    if (value is String) {
      if (value == SecureConfig.trueKey) return true;
      if (value == SecureConfig.falseKey) return false;
    }

    return defaultValue;
  }

  int getInt({required String key, int defaultValue = 0}) {
    final value = sharedPreferences.get(key);
    if (value == null) return defaultValue;
    if (value is int) return value;
    return defaultValue;
  }

  Future<bool> removeDatabykey({required String key}) async {
    return await sharedPreferences.remove(key);
  }

  Future<bool> clearSharedPreference() async {
    return await sharedPreferences.clear();
  }

  Future<void> saveSectionPrinters(List<SectionPrinterModel> printers) async {
    final list = printers.map((e) => e.toMap()).toList();
    await sharedPreferences.setString("sectionPrinters", json.encode(list));
  }

  List<SectionPrinterModel> getSectionPrinters() {
    final jsonString = sharedPreferences.getString("sectionPrinters");
    if (jsonString == null) return [];
    try {
      final list = json.decode(jsonString) as List;
      return list.map((e) => SectionPrinterModel.fromMap(e)).toList();
    } catch (e) {
      return [];
    }
  }

  Future removeSectionPrinter(String printerName) async {
    var oldPrinters = getSectionPrinters();
    oldPrinters.removeWhere((element) => element.printerName == printerName);
    await sharedPreferences.setString(
      'sectionPrinters',
      jsonEncode([...oldPrinters.map((e) => e.toMap())]),
    );
  }
  // Future addExpenseType(String expenseType) async {
  //   // Get SharedPreferences

  //   // Get the current list of expense types
  //   String? expenseTypeList = await getData(key: "expenseTypes");

  //   // Initialize a list to hold expense types
  //   List<String> expenseTypes =
  //       expenseTypeList != null ? expenseTypeList.split(',') : [];

  //   // Add the new expense type if it's not already in the list
  //   if (!expenseTypes.contains(expenseType)) {
  //     expenseTypes.add(expenseType);
  //   }

  //   // Convert the list back to a comma-separated string
  //   String updatedExpenseTypeList = expenseTypes.join(',');

  //   // Store the updated list in SharedPreferences
  //   await saveData(key: 'expenseTypes', value: updatedExpenseTypeList);
  // }

  // Future<List<String>> getExpenseTypes() async {
  //   // Obtain a reference to SharedPreferences

  //   // Retrieve the expense types as a single string
  //   String? expenseTypeList = await getData(key: 'expenseTypes');

  //   // Convert the comma-separated string into a list of expense types
  //   return expenseTypeList != null ? expenseTypeList.split(',') : [];
  // }

  // Future<void> removeExpenseType(String expenseType) async {
  //   // Obtain a reference to SharedPreferences

  //   // Retrieve the current list of expense types
  //   String? expenseTypeList = await getData(key: 'expenseTypes');

  //   // Convert the list to a list of strings
  //   List<String> expenseTypes =
  //       expenseTypeList != null ? expenseTypeList.split(',') : [];

  //   // Remove the specified expense type from the list
  //   expenseTypes.remove(expenseType);

  //   // Convert the updated list back to a comma-separated string
  //   String updatedExpenseTypeList = expenseTypes.join(',');

  //   // Store the updated list in SharedPreferences
  //   await saveData(key: 'expenseTypes', value: updatedExpenseTypeList);
  // }
}
