import 'dart:typed_data';

import 'package:desktoppossystem/models/reports/end_of_shift_employee_model.dart';
import 'package:desktoppossystem/models/expense_model.dart';
import 'package:desktoppossystem/models/restaurant_stock_model.dart';
import 'package:desktoppossystem/models/reports/restaurant_stock_usage_model.dart';

class EndOfDayModel {
  List<Uint8List> imageData;
  double salesPrimary;
  double salesSecondary;
  double depositDolar;
  double depositLebanese;
  double withdrawDolar;
  double withdrawLebanese;
  double withdrawDolarFromCash;
  double withdrawLebaneseFromCash;
  double totalPrimary;
  double totalPendingAmount;
  int totalPendingReceipts;
  double totalCollectedPending;
  double totalRefunds;
  double totalPurchasesPrimary;
  double totalPurchasesSecondary;
  double? totalSubscriptions;
  String date;
  int nbCustomers;
  //print report
  String? employeeName;
  List<ExpenseModel>? expenses;
  List<RestaurantStockUsageModel>? stockUsage = [];
  List<RestaurantStockModel>? stockItems = [];
  EndOfShiftEmployeeModel? endOfShiftEmployeeModel;

  EndOfDayModel({
    required this.date,
    required this.nbCustomers,
    this.employeeName,
    required this.salesPrimary,
    required this.salesSecondary,
    required this.totalPrimary,
    required this.imageData,
    required this.depositDolar,
    required this.depositLebanese,
    required this.withdrawDolar,
    required this.withdrawLebanese,
    required this.withdrawDolarFromCash,
    required this.withdrawLebaneseFromCash,
    required this.totalPendingAmount,
    required this.totalPendingReceipts,
    required this.totalCollectedPending,
    required this.totalRefunds,
    required this.totalPurchasesPrimary,
    required this.totalPurchasesSecondary,
    this.totalSubscriptions,
    this.expenses = const [],
    this.endOfShiftEmployeeModel,
    this.stockUsage,
    this.stockItems,
  });
}
