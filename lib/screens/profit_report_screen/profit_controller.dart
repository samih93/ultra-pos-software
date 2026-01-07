import 'package:collection/collection.dart';
import 'package:desktoppossystem/controller/category_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/button_model.dart';
import 'package:desktoppossystem/models/expense_model.dart';
import 'package:desktoppossystem/models/reports/sales_by_category_model.dart';
import 'package:desktoppossystem/models/reports/sales_product_model.dart';
import 'package:desktoppossystem/models/reports/subscribtion_state_model.dart';
import 'package:desktoppossystem/models/reports/waste_by_stock_model.dart';
import 'package:desktoppossystem/repositories/expenses/expenses_repository.dart';
import 'package:desktoppossystem/repositories/products/iproduct_repository.dart';
import 'package:desktoppossystem/repositories/products/product_repository.dart';
import 'package:desktoppossystem/repositories/subscription/subscription_repository.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/shared/constances/app_constances.dart';
import 'package:desktoppossystem/shared/default%20components/default_price_text.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:desktoppossystem/shared/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

import '../../models/reports/restaurant_stock_usage_model.dart';
import '../../repositories/restaurant_stock/restaurant_stock_repository.dart';

final profitControllerProvider = ChangeNotifierProvider<ProfitController>((
  ref,
) {
  return ProfitController(
    ref: ref,
    expensesRepository: ref.read(expenseProviderRepository),
    productRepositoy: ref.read(productProviderRepository),
    restaurantStockRepository: ref.read(restaurantProviderRepository),
    subscriptionRepository: ref.read(subscriptionRepositoryProvider),
  );
});

class ProfitController extends ChangeNotifier {
  final Ref _ref;
  final IProductRepository _productRepositoy;
  final IRestaurantStockRepository _restaurantStockRepository;
  final IExpensesRepository _expensesRepository;
  final ISubscriptionRepository _subscriptionRepository;

  ProfitController({
    required Ref ref,
    required IProductRepository productRepositoy,
    required IExpensesRepository expensesRepository,
    required IRestaurantStockRepository restaurantStockRepository,
    required ISubscriptionRepository subscriptionRepository,
  }) : _ref = ref,
       _productRepositoy = productRepositoy,
       _expensesRepository = expensesRepository,
       _restaurantStockRepository = restaurantStockRepository,
       _subscriptionRepository = subscriptionRepository;

  List<SalesProductModel> salesProductList = [];
  List<SalesByCategoryModel> salesByCategoryList = [];
  List<SalesProductModel> originalsalesProductList = [];
  DateTime profitReportDate = DateTime.now();

  Future getProfitReport({String? date, ReportInterval? view}) async {
    salesProductList = [];

    _productRepositoy
        .getProfitPerProduct(date: date, view: view)
        .then((value) {
          salesProductList = value;
          originalsalesProductList = salesProductList;
        })
        .catchError((error) {
          debugPrint(error.toString());
        });
  }

  bool isDescending = false;
  SortType selectedSortType = SortType.profit;

  sortSalesOrderByProfitDescending() {
    isDescending = !isDescending;
    selectedSortType = SortType.profit;
    if (isDescending) {
      salesProductList.sort((a, b) => b.profit.compareTo(a.profit));
    } else {
      salesProductList.sort((a, b) => a.profit.compareTo(b.profit));
    }
    notifyListeners();
  }

  sortSalesOrderByQty() {
    isDescending = !isDescending;
    selectedSortType = SortType.qty;
    if (isDescending) {
      salesProductList.sort((a, b) => b.qty.compareTo(a.qty));
    } else {
      salesProductList.sort((a, b) => a.qty.compareTo(b.qty));
    }
    notifyListeners();
  }

  void groupSalesByCategory() {
    salesByCategoryList = [];
    Map<int, List<SalesProductModel>> groupedByCategory = groupBy(
      salesProductList,
      (SalesProductModel product) => product.categoryId!,
    );
    // Iterate through each group to calculate totals
    groupedByCategory.forEach((categoryId, products) {
      double totalCost = 0;
      double paidCost = 0;
      double profit = 0;
      String categoryName = 'Unknown Category';

      // Sum up the totals for each product in the category
      for (var product in products) {
        totalCost += product.totalCost;
        paidCost += product.paidCost;
        profit += product.profit;
        categoryName = _ref
            .read(categoryControllerProvider)
            .categoryNameById(categoryId);
      }

      // Create a SalesByCategoryModel instance with the aggregated data
      SalesByCategoryModel categoryData = SalesByCategoryModel(
        categoryId: categoryId,
        name: categoryName,
        totalCost: totalCost,
        paidCost: paidCost,
        profit: profit,
      );

      salesByCategoryList.add(categoryData);
      salesByCategoryList.sort((a, b) => b.profit.compareTo(a.profit));
    });
  }

  List<ExpenseModel> expensesList = [];
  getExpensesByView({String? date, ReportInterval? view}) async {
    expensesList = [];

    final expensesRes = await _expensesRepository.getExpensesForProfitReport(
      date: date,
      view: view,
    );
    expensesRes.fold(
      (l) {
        debugPrint(l.message.toString());
      },
      (r) {
        expensesList = r;
        expensesList.sort((a, b) => b.expenseAmount.compareTo(a.expenseAmount));
      },
    );
  }

  List<WasteByStockModel> wasteList = [];
  Future fetchWasteByView({String? date, ReportInterval? view}) async {
    wasteList = [];

    final expensesRes = await _restaurantStockRepository.fetchWastesByView(
      date: date,
      view: view,
    );
    expensesRes.fold(
      (l) {
        debugPrint(l.message.toString());
      },
      (r) {
        wasteList = r;
        wasteList.sort((a, b) => b.totalPrice.compareTo(a.totalPrice));
      },
    );
  }

  List<SubscribtionStateModel> subscriptionStatsList = [];
  Future fetchSubscriptionStats({String? date, ReportInterval? view}) async {
    subscriptionStatsList = [];

    final result = await _subscriptionRepository.fetchSubscriptionStatsByView(
      date: date,
      view: view,
    );
    result.fold(
      (l) {
        debugPrint(l.message.toString());
      },
      (r) {
        subscriptionStatsList = r;
      },
    );
  }

  double totalExpenses = 0;
  void generateTotalExpenses() {
    totalExpenses = 0;
    for (var element in expensesList) {
      totalExpenses += element.expenseAmount;
    }
  }

  double totalSubscriptionIncome = 0;
  void generateTotalSubscriptionIncome() {
    totalSubscriptionIncome = 0;
    for (var element in subscriptionStatsList) {
      totalSubscriptionIncome += element.totalPaid;
    }
  }

  double totalWaste = 0;
  void generateTotalWaste() {
    totalWaste = 0;
    for (var element in wasteList) {
      totalWaste += element.totalPrice;
    }
  }

  double totalPaid = 0;
  double totalCost = 0;
  double totalCostWithIngredient = 0;
  double totalProfit = 0;

  double get totalRealCost =>
      _ref.read(mainControllerProvider).isWorkWithIngredients
      ? restaurantTotalCost
      : totalCost;

  double get finalProfit {
    // Total revenue from sandwiches that include ingredients
    double salesWithIngredients = totalCostWithIngredient;

    // The total cost of the ingredients used in the sold sandwiches
    double ingredientCost = restaurantTotalCost;

    double waste = _ref.read(mainControllerProvider).isWorkWithIngredients
        ? totalWaste
        : 0;

    // Calculate subscription total income
    double subscriptionIncome = totalSubscriptionIncome;

    // Calculate the profit by subtracting ingredient cost from sales revenue and adding subscription income
    return totalProfit +
        (salesWithIngredients - ingredientCost) -
        totalExpenses -
        waste +
        subscriptionIncome;
  }

  /// **Generates the Correct Costs for Sales, Profit, and Ingredients**
  void generateTotalProfit() {
    totalPaid = 0;
    totalCost = 0;
    totalCostWithIngredient = 0;
    totalProfit = 0;

    for (var element in salesProductList) {
      totalPaid += element.paidCost;
      totalCost += element.totalCost;
      totalProfit += element.profit;

      // If the business works with ingredients, check ingredient-related costs
      if (_ref.read(mainControllerProvider).isWorkWithIngredients) {
        if (element.isHasIngredients == true) {
          // Sandwich includes all ingredients -> Count towards totalCostWithIngredient
          totalCostWithIngredient += element.totalCost;
        }
      }
    }
  }

  onSearchInProfit(String query) {
    List<String> keywords = query.toUpperCase().split(" ");

    if (query.trim() == '') {
      salesProductList = originalsalesProductList;
    } else {
      salesProductList = searchProfits(originalsalesProductList, keywords);
    }
    if (query.trim() == '') {
      stockUsageList = originalstockUsageList;
    } else {
      stockUsageList = searchInRestaurantStock(
        originalstockUsageList,
        keywords,
      );
    }

    notifyListeners();
  }

  List<SalesProductModel> searchProfits(
    List<SalesProductModel> profits,
    List<String> keywords,
  ) {
    return profits.where((profit) {
      String upperName = profit.name!.toUpperCase();
      String upperBarcode = profit.barcode!.toUpperCase();
      return keywords.every(
        (part) => upperName.contains(part) || upperBarcode.contains(part),
      );
    }).toList();
  }

  onchangeCurrentSelectedDate(DateTime date) {
    profitReportDate = date;
    notifyListeners();
  }

  ReportInterval get selectedView => buttons
      .where((element) => element.isselected == true)
      .first
      .reportInterval;

  int selectedYear = DateTime.now().year;

  List<ProfitButtonModel> buttons = [
    ProfitButtonModel(true, reportInterval: ReportInterval.daily),
    ProfitButtonModel(false, reportInterval: ReportInterval.monthly),
    ProfitButtonModel(false, reportInterval: ReportInterval.yearly),
  ];
  ReportInterval selectedReportInterval = ReportInterval.daily;
  onchangeView(ReportInterval view, BuildContext context) {
    selectedReportInterval = view;
    for (var element in buttons) {
      if (element.reportInterval == view) {
        element.isselected = true;
      } else {
        element.isselected = false;
      }
    }
    switch (view) {
      case ReportInterval.daily:
        showDatePicker(
          context: context,
          initialDate: profitReportDate,
          firstDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
          lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
        ).then((value) {
          var tdate = value?.toString().split(' ');
          if (tdate != null) {
            //! get receipts by date
            profitReportDate = DateTime.parse(tdate[0]);
            onChangeProfitReport(
              date: profitReportDate.toString(),
              view: ReportInterval.daily,
            );
          }
        });
        break;
      case ReportInterval.monthly:
        showMonthPicker(
          context: context,
          firstDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
          lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
          initialDate: profitReportDate,
        ).then((date) {
          if (date != null) {
            profitReportDate = date;
            onChangeProfitReport(
              date: profitReportDate.toString(),
              view: ReportInterval.monthly,
            );
          }
        });

        break;
      case ReportInterval.yearly:
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: DefaultTextView(
              textAlign: TextAlign.center,
              fontSize: 16,
              text: S.of(context).selectYear,
            ),
            content: SizedBox(
              height: 300,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    kGap5,
                    ...years.map((e) {
                      return ListTile(
                        trailing: selectedYear == years[years.indexOf(e)]
                            ? Icon(
                                Icons.check_circle,
                                color: context.primaryColor,
                              )
                            : kEmptyWidget,
                        title: DefaultTextView(text: e.toString()),
                        onTap: () async {
                          selectedYear = years[years.indexOf(e)];
                          profitReportDate = DateTime(selectedYear);
                          onChangeProfitReport(
                            date: profitReportDate.toString(),
                            view: ReportInterval.yearly,
                          );

                          context.pop();
                        },
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        );
    }
  }

  final List<int> years = [
    ...List.generate(6, (index) => DateTime.now().year - index),
  ];

  String get displaySelectedViewAndDate {
    ReportInterval view = selectedView;
    String res = "";
    switch (view) {
      case ReportInterval.daily:
        res =
            "${ReportInterval.daily.localizedName(globalAppContext)} - ${DateFormat('dd-MM-yyyy').format(profitReportDate)}";
      case ReportInterval.monthly:
        res =
            "${ReportInterval.monthly.localizedName(globalAppContext)} - ${DateFormat.yMMM().format(profitReportDate)}";
      case ReportInterval.yearly:
        res =
            "${ReportInterval.yearly.localizedName(globalAppContext)} - ${profitReportDate.year}";
    }
    return res;
  }

  // Restaurant stock

  List<RestaurantStockUsageModel> stockUsageList = [];
  List<RestaurantStockUsageModel> originalstockUsageList = [];

  Future<List<RestaurantStockUsageModel>> fetchStockUsageReport({
    String? date,
    ReportInterval? view,
  }) async {
    stockUsageList = [];
    originalstockUsageList = [];
    final response = await _restaurantStockRepository.fetchStockUsageReport(
      date: date,
      view: view,
    );
    await response.fold<Future>(
      (l) async {
        debugPrint(l.message.toString());
      },
      (r) async {
        stockUsageList = r;
        originalstockUsageList = r;
      },
    );
    return stockUsageList;
  }

  double restaurantTotalCost = 0;
  double packagingTotalCost = 0;
  generateStockTotalCost() {
    restaurantTotalCost = 0;
    packagingTotalCost = 0;
    for (var element in stockUsageList) {
      restaurantTotalCost += element.totalPrice!;
      if (element.forPackaging == true) {
        packagingTotalCost += element.totalPrice!;
      }
    }
  }

  List<RestaurantStockUsageModel> searchInRestaurantStock(
    List<RestaurantStockUsageModel> profits,
    List<String> keywords,
  ) {
    return profits.where((profit) {
      String upperName = profit.name.toUpperCase();
      return keywords.every((part) => upperName.contains(part));
    }).toList();
  }

  // Function to call all necessary methods in the correct order
  Future<void> calculateProfitReport() async {
    // Fetch and calculate stock usage, expenses, and total profit
    generateStockTotalCost();
    generateTotalExpenses();
    generateTotalWaste();
    generateTotalProfit();
    generateTotalSubscriptionIncome();
  }

  RequestState profitReportRequestState = RequestState.success;

  void onChangeProfitReport({String? date, ReportInterval? view}) async {
    //! only if i am on dashboard and then open drawer and press dashboard again
    if (view == ReportInterval.daily && date == null) {
      profitReportDate = DateTime.now();
      selectedReportInterval = view!;
      for (var element in buttons) {
        if (element.reportInterval == view) {
          element.isselected = true;
        } else {
          element.isselected = false;
        }
      }
    }
    profitReportRequestState = RequestState.loading;
    notifyListeners();
    final mainController = _ref.read(mainControllerProvider);

    // Show a loading indicator while fetching the data.
    // You can handle this with a loading state if needed.

    try {
      // Check condition and fetch stock usage report.
      if (mainController.isWorkWithIngredients) {
        await fetchStockUsageReport(date: date, view: view);
      }

      // Build list of futures to wait for
      List<Future<void>> futures = [
        getProfitReport(date: date, view: view),
        getExpensesByView(date: date, view: view),
        fetchWasteByView(date: date, view: view),
      ];

      // Add subscription stats fetch if subscription is activated
      if (mainController.subscriptionActivated) {
        futures.add(fetchSubscriptionStats(date: date, view: view));
      }

      // Wait for all futures to complete
      await Future.wait<void>(futures);
      groupSalesByCategory();
      _ref.read(restaurantProviderRepository).fetchWastesByView(view: view);

      // Recalculate everything after fetching the reports
      await calculateProfitReport();
      profitReportRequestState = RequestState.success;
      notifyListeners();
    } catch (e) {
      // Handle any errors here.
      profitReportRequestState = RequestState.error;
      notifyListeners();
    }
  }

  Future showExpensesHistoryById(
    ExpenseModel expenseModel,
    BuildContext context,
  ) async {
    final response = await _ref
        .read(expenseProviderRepository)
        .fetchExpensesByIdForProfitReport(
          date: profitReportDate.toString().split(" ").first,
          expenseId: expenseModel.id,
          view: selectedReportInterval,
        );
    response.fold(
      (l) => ToastUtils.showToast(message: l.message, type: RequestState.error),
      (r) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              scrollable: true,
              title: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DefaultTextView(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      text: expenseModel.expensePurpose.validateString(),
                    ),
                    kGap10,
                    AppPriceText(
                      fontSize: 18,
                      text: expenseModel.expenseAmount
                          .formatDouble()
                          .toString(),
                      unit: AppConstance.primaryCurrency.currencyLocalization(),
                    ),
                  ],
                ),
              ),
              content: SizedBox(
                width: 300,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Loop through the data and build the rows
                    ...r.map(
                      (e) => Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: DefaultTextView(
                                  text: DateTime.parse(
                                    e.expensePurpose,
                                  ).formatDateTime12Hours(),
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              AppPriceText(
                                color: Colors.red, // Set red color for expenses
                                text: e.expenseAmount.formatDouble().toString(),
                                unit:
                                    '${AppConstance.primaryCurrency.currencyLocalization()}', // Assume primary currency is USD
                              ),
                            ],
                          ),
                          // Divider between rows for better separation
                          Divider(color: Colors.grey.shade400, thickness: 1),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
