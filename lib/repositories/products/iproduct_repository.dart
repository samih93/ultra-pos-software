import 'package:desktoppossystem/models/expense_model.dart';
import 'package:desktoppossystem/models/invoice_details_model.dart';
import 'package:desktoppossystem/models/notification_model.dart';
import 'package:desktoppossystem/models/reports/product_history_model.dart';
import 'package:desktoppossystem/models/tracked_related_product.dart';
import 'package:desktoppossystem/models/product_model.dart';
import 'package:desktoppossystem/models/reports/sales_product_model.dart';
import 'package:desktoppossystem/models/reports/total_cost_price_model.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/type_def.dart';

abstract class IProductRepository {
  FutureEither<List<ProductModel>> fetchWeightedProducts();
  FutureEither<List<ProductModel>> getAllProducts({
    int? limit,
    int? offset,
    int? categoryId,
    bool? isStock,
    bool? isDeleted,
  });
  FutureEither<List<ProductModel>> getAllStockGroupedByCategory({
    int? categoryId,
  });
  FutureEither<List<ProductModel>> getProductsByCategoryId(
    int categoryId, {
    int? offset,
    int? limit,
  });
  FutureEither<ProductStatsModel> fetchProductsStats({int? categoryId});

  FutureEither<ProductModel> addProduct(
    ProductModel p,
    List<TrackedRelatedProductModel> trackedRelatedProductModel,
  );
  FutureEitherVoid updateProductCost({
    required double cost,
    required int productId,
  });
  FutureEitherVoid addBulkProducts(List<ProductModel> products);
  FutureEither<ProductModel> updateProduct(
    ProductModel p,
    List<TrackedRelatedProductModel> trackedRelatedProductModel,
  );
  FutureEither deleteProduct(int productId);
  FutureEither<ProductModel> restoreProduct(int productId);

  Future<ProductModel?> getProductByBarcode(String barcode);
  Future<ProductModel?> getProduct(int id);
  Future<ProductModel?> fetchProductByPlu(int plu);
  FutureEither increasedecreaseProductQty({
    required List<ProductModel> products,
    required bool isForDescrease,
  });

  Future<List<ProductModel>> getMostSellingProductByType({
    DashboardFilterEnum? view,
    int? limit,
    String? date,
    int? shiftId,
    bool? isForReports,
    bool? isForStaff,
  });

  Future<List<ProductModel>> getMostProfitableProducts({
    DashboardFilterEnum? view,
  });

  FutureEither<List<ProductModel>> fetchMostSellingProductByCustomer({
    required int customerId,
  });

  FutureEither<List<ExpenseModel>> getExpensesByType({
    DashboardFilterEnum? view,
    int? limit,
    String? date,
    int? shiftId,
  });

  Future<List<ProductModel>> searchByNameOrBarcode(
    String query, {
    int? categoryId,
    bool? isTracked,
    bool? isForBarcode,
    bool? isDeleted,
  });
  // used for restaurant stock
  FutureEither<List<ProductModel>> searchForAProductOrASandwich(String query);

  Future<List<SalesProductModel>> getProfitPerProduct({
    String? date,
    ReportInterval? view,
  });

  FutureEither<List<TrackedRelatedProductModel>> fetchRelatedTrackedByProductId(
    int productId,
  );
  FutureEither addRelatedTrackedProductsList(
    List<TrackedRelatedProductModel> list,
  );

  FutureEither removeRelatedTrackedProductsList(int productId);

  FutureEither<List<ProductModel>> fetchAllSandwichesWithIngredients();

  FutureEitherVoid updateStockByInvoiceDetails(
    PurchaseDetailsModel invoiceDetails,
  );

  FutureEither setAllProductsAsActive();

  // for notifications
  FutureEither<int> fetchProductsCount();
  FutureEither<int> fetchMarketNotificationCounts(int nbOfMonths);
  FutureEither<List<NotificationModel>> fetchMarketLowStockList();
  FutureEither<List<NotificationModel>> fetchMarketOutOfStockProducts();
  FutureEither<List<NotificationModel>> fetchMarketExpiryDateProducts(
    int nbOfMonths,
  );

  FutureEitherVoid reOrderProducts({required List<ProductModel> products});

  FutureEither<List<ProductHistoryModel>> fetchProductHistory({
    required int productId,
  });

  FutureEither<List<ProductModel>> fetchQuickSelectionProducts();
  FutureEitherVoid addQuickSelectionProduct(int productId);
  FutureEitherVoid removeQuickSelectionProduct(int productId);
  FutureEitherVoid reorderQuickSelectionProducts(List<ProductModel> products);

  FutureEither<List<ProductModel>> fetchProductsForBackupToCloud();
}
