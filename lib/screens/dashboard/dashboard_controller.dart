import 'package:desktoppossystem/models/button_model.dart';
import 'package:desktoppossystem/models/customers_model.dart';
import 'package:desktoppossystem/models/expense_model.dart';
import 'package:desktoppossystem/models/product_model.dart';
import 'package:desktoppossystem/models/receipts_count_by_view_model.dart';
import 'package:desktoppossystem/models/reports/daily_sale_model.dart';
import 'package:desktoppossystem/models/reports/restaurant_stock_usage_model.dart';
import 'package:desktoppossystem/models/reports/revenue_vs_purchases_model.dart';
import 'package:desktoppossystem/models/reports/sales_product_model.dart';
import 'package:desktoppossystem/repositories/customers/customer_repository.dart';
import 'package:desktoppossystem/repositories/products/iproduct_repository.dart';
import 'package:desktoppossystem/repositories/products/product_repository.dart';
import 'package:desktoppossystem/repositories/receipts/receiptrepository.dart';
import 'package:desktoppossystem/repositories/restaurant_stock/restaurant_stock_repository.dart';
import 'package:desktoppossystem/repositories/users/user_reposiotry.dart';
import 'package:desktoppossystem/screens/dashboard/components/overview_dashboard.dart';
import 'package:desktoppossystem/screens/dashboard/components/sales_by_vew_pie_diagram.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/shared/constances/app_constances.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dashboardControllerProvider =
    ChangeNotifierProvider<DashboardController>((ref) {
  return DashboardController(
    ref: ref,
    productRepository: ref.read(productProviderRepository),
  );
});

final usersCountProvider = FutureProvider<int>((ref) async {
  var users = await ref.read(userProviderRepository).getAllUsers();
  return users.length;
});

final most10SellingProductsProvider =
    FutureProvider.autoDispose<List<ProductModel>>((ref) async {
  final filter = ref.watch(selectedDashboardViewProvider);
  final mostSellingProducts = await ref
      .read(productProviderRepository)
      .getMostSellingProductByType(view: filter);
  int index = 0;
  for (var element in mostSellingProducts) {
    element.categoryColor = AppConstance.colorsForCharts[index];
    index++;
  }
  return mostSellingProducts;
});

final most15ProfitableProductsProvider =
    FutureProvider.autoDispose<List<ProductModel>>((ref) async {
  final filter = ref.watch(selectedDashboardViewProvider);
  final mostProfitableProducts = await ref
      .read(productProviderRepository)
      .getMostProfitableProducts(view: filter);
  int index = 0;
  for (var element in mostProfitableProducts) {
    element.categoryColor = AppConstance.colorsForCharts[index];
    index++;
  }
  return mostProfitableProducts;
});

final futureExpensesProvider =
    FutureProvider.autoDispose<List<ExpenseModel>>((ref) async {
  final filter = ref.watch(selectedDashboardViewProvider);

  final expensesRes =
      await ref.read(productProviderRepository).getExpensesByType(view: filter);

  return expensesRes.fold((l) {
    throw Exception(l.message);
  }, (r) {
    final expenses = r;
    int index = 0;
    for (var element in expenses) {
      element.expenseColor = AppConstance.colorsForCharts[index];
      index++;
      if (index == AppConstance.colorsForCharts.length - 1) index = 0;
    }
    return expenses;
  });
});

final futureSalesProvider =
    FutureProvider.autoDispose<List<DailySalesModel>>((ref) async {
  final filter = ref.watch(selectedDashboardViewProvider);
  List<String> months = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec"
  ];

  final resposne =
      await ref.read(receiptProviderRepository).getSalesByType(view: filter);
  if (filter == DashboardFilterEnum.thisYear ||
      filter == DashboardFilterEnum.lastYear) {
    for (var element in resposne) {
      element.day = months[int.parse(element.day) - 1];
    }
  }
  return resposne;
});

final futureStockUsageProvider =
    FutureProvider.autoDispose<List<RestaurantStockUsageModel>>((ref) async {
  final filter = ref.watch(selectedDashboardViewProvider);

  final response = await ref
      .read(restaurantProviderRepository)
      .fetchStockUsageReportByView(view: filter);

  return response.fold((l) {
    throw Exception(l.message);
  }, (r) => r);
});

final futureSalesByUserProvider =
    FutureProvider.autoDispose<List<SalesByUserModel>>((ref) async {
  final filter = ref.watch(selectedDashboardViewProvider);

  return await ref
      .read(receiptProviderRepository)
      .fetchSalesByUserAndType(view: filter);
});

final futureTop10Customers =
    FutureProvider.autoDispose<List<CustomerModel>>((ref) async {
  final filter = ref.watch(selectedDashboardViewProvider);

  final response =
      await ref.read(customerProviderRepository).fetchTop10Customers(filter);
  return response.fold((l) {
    return [];
  }, (r) => r);
});

final futureHourlyCustomersProvider =
    FutureProvider.autoDispose<List<CustomersCountByViewModel>>((ref) async {
  final filter = ref.watch(selectedDashboardViewProvider);

  return await ref
      .read(receiptProviderRepository)
      .fetchNbOfCustomersByViewHourly(view: filter);
});

final futureNbOfReceipts = FutureProvider.autoDispose<int>((ref) async {
  final filter = ref.watch(selectedDashboardViewProvider);
  final response = await ref
      .read(receiptProviderRepository)
      .fetchNbOfReceiptsByType(view: filter);
  return response;
});

final futureDeliveryReceiptsCounts =
    FutureProvider.autoDispose<Map<String, int>>((ref) async {
  final filter = ref.watch(selectedDashboardViewProvider);
  final response = await ref
      .read(receiptProviderRepository)
      .fetchDeliveryReceiptsCountByType(view: filter);
  return response.fold((l) => throw Exception(l.message), (r) => r);
});

final futureRevenueVsPurchasesProvider =
    FutureProvider.autoDispose<List<RevenueVsPurchasesVsExpensesModel>>(
        (ref) async {
  final filter = ref.watch(selectedDashboardViewProvider);
  final isWorkWithIngredients =
      ref.watch(mainControllerProvider).isWorkWithIngredients;

  return await ref.read(receiptProviderRepository).fetchRevenueVsPurchases(
        view: filter,
      );
});

class DashboardController extends ChangeNotifier {
  final Ref _ref;
  final IProductRepository _productRepository;

  DashboardController({
    required Ref ref,
    required IProductRepository productRepository,
  })  : _ref = ref,
        _productRepository = productRepository;

  //! list of button needed to filter dashboard
  List<DashboardButtonModel> buttons = [
    DashboardButtonModel(false,
        dashboardFilterEnum: DashboardFilterEnum.lastYear),
    DashboardButtonModel(false,
        dashboardFilterEnum: DashboardFilterEnum.lastMonth),
    DashboardButtonModel(false,
        dashboardFilterEnum: DashboardFilterEnum.yesterday),
    DashboardButtonModel(true, dashboardFilterEnum: DashboardFilterEnum.today),
    DashboardButtonModel(false,
        dashboardFilterEnum: DashboardFilterEnum.thisWeek),
    DashboardButtonModel(false,
        dashboardFilterEnum: DashboardFilterEnum.thisMonth),
    DashboardButtonModel(false,
        dashboardFilterEnum: DashboardFilterEnum.thisYear),
  ];

  onchangeView(DashboardFilterEnum filter) {
    _ref.read(selectedDashboardViewProvider.notifier).state = filter;
    _ref.refresh(most10SellingProductsProvider);
    _ref.refresh(most15ProfitableProductsProvider);
    _ref.refresh(futureTop10Customers);
    _ref.refresh(futureExpensesProvider);
    _ref.refresh(futureSalesProvider);
    _ref.refresh(futureStockUsageProvider);
    _ref.refresh(futureSalesByUserProvider);
    _ref.refresh(futureHourlyCustomersProvider);
    _ref.refresh(futureNbOfReceipts);
    _ref.refresh(futureRevenueVsPurchasesProvider);
    if (filter == DashboardFilterEnum.today) {
      _ref.read(isZoneSalesProvider.notifier).state = false;
    }

    //notifyListeners();
  }

  RequestState getProfitByProductRequestState = RequestState.success;
  List<SalesProductModel> profitList = [];

  Future getProfitByProduct({String? date}) async {
    getProfitByProductRequestState = RequestState.loading;
    notifyListeners();
    await _productRepository.getProfitPerProduct(date: date).then((value) {
      profitList = value;
      getProfitByProductRequestState = RequestState.success;
      notifyListeners();
    }).catchError((error) {
      getProfitByProductRequestState = RequestState.error;
      notifyListeners();
    });
  }
}
