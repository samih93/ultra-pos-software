// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:desktoppossystem/models/expense_model.dart';
import 'package:desktoppossystem/models/reports/restaurant_stock_usage_model.dart';
import 'package:desktoppossystem/models/reports/sales_product_model.dart';
import 'package:desktoppossystem/models/reports/subscribtion_state_model.dart';
import 'package:desktoppossystem/models/reports/waste_by_stock_model.dart';

class ProfitReportModel {
  final List<SalesProductModel> products;
  final double totalCost;
  final double totalPaid;
  final double profit;
  final String header;
  List<ExpenseModel> expenses;
  final double totalExpenses;
  final double? restaurantCost;
  List<RestaurantStockUsageModel>? stockUsageList;
  List<WasteByStockModel>? wasteList;
  final double totalSubscriptionIncome;
  final List<SubscribtionStateModel> subscriptionsStats;
  final double? totalWaste;

  ProfitReportModel({
    required this.products,
    required this.totalCost,
    required this.totalPaid,
    required this.profit,
    required this.expenses,
    required this.totalExpenses,
    required this.header,
    this.restaurantCost,
    this.stockUsageList,
    this.wasteList,
    this.subscriptionsStats = const [],
    this.totalSubscriptionIncome = 0,
    this.totalWaste,
  });
}
