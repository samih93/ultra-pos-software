import 'package:desktoppossystem/controller/auth_controller.dart';
import 'package:desktoppossystem/controller/setting_controller.dart';
import 'package:desktoppossystem/models/customers_model.dart';
import 'package:desktoppossystem/models/product_model.dart';
import 'package:desktoppossystem/models/receipt_model.dart';
import 'package:desktoppossystem/models/reports/end_of_day_model.dart';
import 'package:desktoppossystem/models/restaurant_stock_model.dart';
import 'package:desktoppossystem/models/view_model/profit_report_model.dart';
import 'package:desktoppossystem/repositories/products/product_repository.dart';
import 'package:desktoppossystem/repositories/settings_repository/settings_repository.dart';
import 'package:desktoppossystem/screens/settings/components/sections/owner_section/owner_query_screen/owner_query_screen.dart';
import 'package:desktoppossystem/shared/constances/auth_role.dart';
import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final globalControllerProvider = ChangeNotifierProvider<GlobalController>((
  ref,
) {
  return GlobalController(ref);
});

class GlobalController extends ChangeNotifier {
  final Ref ref;
  GlobalController(this.ref);
  RequestState openDailySaleExcelRequestState = RequestState.success;
  Future openDailySalesInExcel(
    List<ProductModel> products,
    EndOfDayModel endOfDayModel,
  ) async {
    openDailySaleExcelRequestState = RequestState.loading;
    notifyListeners();

    try {
      await generateDailyReport(products, endOfDayModel);
      openDailySaleExcelRequestState = RequestState.success;
      notifyListeners();
    } catch (e) {
      openDailySaleExcelRequestState = RequestState.error;
      notifyListeners();
    }
  }

  RequestState openProductHistoryRequestState = RequestState.success;
  int downloadProductHistoryId = 0;

  Future openProductHistoryInExcel({required int productId}) async {
    downloadProductHistoryId = productId;
    openProductHistoryRequestState = RequestState.loading;
    notifyListeners();

    try {
      final response = await ref
          .read(productProviderRepository)
          .fetchProductHistory(productId: productId);
      response.fold((l) {}, (r) async {
        if (r.isEmpty) {
          ToastUtils.showToast(
            message: "No history found",
            type: RequestState.loading,
          );
          openProductHistoryRequestState = RequestState.success;
          notifyListeners();
          return;
        }
        await generateProductHistoryReport(r, ref);
        openProductHistoryRequestState = RequestState.success;
        notifyListeners();
      });
    } catch (e) {
      openProductHistoryRequestState = RequestState.error;
      notifyListeners();
    }
  }

  Future executeQuery(String query) async {
    final response = await ref
        .read(settingProviderRepository)
        .executeQuery(query);
    response.fold(
      (l) {
        ref.read(errorResultProvider.notifier).state = l.message.toString();
      },
      (r) {
        ref.read(queryResultProvider.notifier).state = r;
      },
    );
    notifyListeners();
  }

  RequestState openInvoiceAsPdfRequestState = RequestState.success;
  Future openInvoiceAsPdf(
    ReceiptModel receipt,
    List<ProductModel> products, {
    bool? isQuotation,
  }) async {
    try {
      openInvoiceAsPdfRequestState = RequestState.loading;
      notifyListeners();
      await generateInvoiceAsPdf(
        isQuotation: isQuotation,
        settingModel: ref.read(settingControllerProvider).settingModel,
        receipt: receipt,
        products: products,
      );
      openInvoiceAsPdfRequestState = RequestState.success;
      notifyListeners();
    } catch (e) {
      openInvoiceAsPdfRequestState = RequestState.error;
      notifyListeners();
    }
  }

  RequestState downloadProfitReportRequestState = RequestState.success;
  Future downloadProfitReport(ProfitReportModel model) async {
    downloadProfitReportRequestState = RequestState.loading;
    notifyListeners();

    try {
      await generateProfitReportAsPdf(model);
      downloadProfitReportRequestState = RequestState.success;
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
      downloadProfitReportRequestState = RequestState.error;
      notifyListeners();
    }
  }

  RequestState openRestaurantInExcelRequestState = RequestState.success;
  Future openRestaurantStockInExcel(List<RestaurantStockModel> stock) async {
    openRestaurantInExcelRequestState = RequestState.loading;
    notifyListeners();

    try {
      await generateRestaurantStockExcel(stock, ref);
      openRestaurantInExcelRequestState = RequestState.success;
      notifyListeners();
    } catch (e) {
      openRestaurantInExcelRequestState = RequestState.error;
      notifyListeners();
    }
  }

  RequestState openStockInExcelRequestState = RequestState.success;
  Future openStockInExcel(List<ProductModel> products) async {
    openStockInExcelRequestState = RequestState.loading;
    notifyListeners();

    try {
      await generateStockExcel(products);
      openStockInExcelRequestState = RequestState.success;
      notifyListeners();
    } catch (e) {
      openStockInExcelRequestState = RequestState.error;
      notifyListeners();
    }
  }

  Future openWeightedStockInExcel() async {
    openStockInExcelRequestState = RequestState.loading;
    notifyListeners();

    try {
      final response = await ref
          .read(productProviderRepository)
          .fetchWeightedProducts();
      response.fold(
        (l) {
          openStockInExcelRequestState = RequestState.error;
          notifyListeners();
        },
        (r) async {
          if (r.isEmpty) {
            ToastUtils.showToast(
              message: "No weighted products found",
              type: RequestState.loading,
            );
            openStockInExcelRequestState = RequestState.success;
            notifyListeners();
            return;
          }
          try {
            await generateWeightedStock(r);
            ToastUtils.showToast(
              message: "Downloaded successfully",
              type: RequestState.success,
            );
            openStockInExcelRequestState = RequestState.success;
            notifyListeners();
          } catch (e) {
            ToastUtils.showToast(
              message: "Download failed",
              type: RequestState.error,
            );
            openStockInExcelRequestState = RequestState.error;
            notifyListeners();
          }
        },
      );
    } catch (e) {
      openStockInExcelRequestState = RequestState.error;
      notifyListeners();
    }
  }

  Future openItemsWithCostInExcel(List<ProductModel> products) async {
    try {
      await generateExcelItemsWithCost(
        products,
        isSuperAdmin:
            ref.read(currentUserProvider)?.role?.name ==
            AuthRole.superAdminRole,
      );
    } catch (e) {}
  }

  Future openItemsWithIngredientsInExcel(List<ProductModel> products) async {
    try {
      await generateExcelItemsWithIngredients(
        products,
        isSuperAdmin:
            ref.read(currentUserProvider)?.role?.name ==
            AuthRole.superAdminRole,
      );
    } catch (e) {}
  }

  RequestState openCustomersInExcelRequestState = RequestState.success;
  Future openCustomersInExcel(List<CustomerModel> customers) async {
    openCustomersInExcelRequestState = RequestState.loading;
    notifyListeners();

    try {
      await generateCustomersExcel(customers);
      openCustomersInExcelRequestState = RequestState.success;
      notifyListeners();
    } catch (e) {
      openCustomersInExcelRequestState = RequestState.error;
      notifyListeners();
    }
  }

  RequestState generateImportRequestState = RequestState.success;
  Future generateImportExcelTemplate() async {
    generateImportRequestState = RequestState.loading;
    notifyListeners();
    await generateImportProductTemplate();
    generateImportRequestState = RequestState.success;
    notifyListeners();
  }

  RequestState generateCustomerExcelRequestState = RequestState.success;
  Future generateCustomerExcelTemplate() async {
    generateCustomerExcelRequestState = RequestState.loading;
    notifyListeners();
    await generateCustomersImportTemplate();
    generateCustomerExcelRequestState = RequestState.success;
    notifyListeners();
  }
}
