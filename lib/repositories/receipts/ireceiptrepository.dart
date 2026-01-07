import 'package:desktoppossystem/models/customers_model.dart';
import 'package:desktoppossystem/models/notification_model.dart';
import 'package:desktoppossystem/models/receipts_count_by_view_model.dart';
import 'package:desktoppossystem/models/reports/daily_sale_model.dart';
import 'package:desktoppossystem/models/reports/revenue_vs_purchases_model.dart';
import 'package:desktoppossystem/models/details_receipt.dart';
import 'package:desktoppossystem/models/financial_transaction_model.dart';
import 'package:desktoppossystem/models/receipt_model.dart';
import 'package:desktoppossystem/models/shift_model.dart';
import 'package:desktoppossystem/models/user_model.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/type_def.dart';

abstract class IReceiptRepository {
  Future<int> addReceipt(ReceiptModel receiptModel);

  Future<void> addDetailsReceipt(
      {required List<DetailsReceipt> detailsReceipt,
      required OrderType orderType});
  Future<ReceiptModel?> getReceiptById(int id);
  Future updateReceiptPrice(int id, double newprice, double lebanesePrice);

  Future<List<ReceiptModel>> getReceiptsByDayWithPagination({
    required String date,
    required int userId,
    required String role,
    required int limit,
    required int offset,
    int? filterUserId,
  });
  FutureEither<ReceiptTotals> getReceiptTotalsByDay({
    required String date,
    required int userId,
    required String role,
    int? filterUserId, // optional: admin's selected user id filter
  });

  FutureEither<ReceiptTotals> getReceiptTotalsByShift({
    required int userId,
    required String role,
    int? filterUserId, // optional: admin's selected user id filter
    int? shiftId, // shift ID (if null, use max shift)
  });
  Future<List<DetailsReceipt>> getDetailsReceiptById(int id);

  Future<List<DailySalesModel>> getSalesByType({DashboardFilterEnum? view});
  // sales by user , day => name of user
  Future<List<SalesByUserModel>> fetchSalesByUserAndType(
      {DashboardFilterEnum? view});

  Future refundItems(List<DetailsReceipt> products);
  FutureEitherVoid deleteReceipt(int receiptId);

  Future<int> fetchNbOfReceiptsByType({DashboardFilterEnum? view});
  FutureEither<Map<String, int>> fetchDeliveryReceiptsCountByType(
      {DashboardFilterEnum? view});
  Future<List<CustomersCountByViewModel>> fetchNbOfCustomersByViewHourly(
      {DashboardFilterEnum? view});

  Future<List<ReceiptModel>> getReceiptsByShiftWithPagination({
    int? shiftId, // optional shift ID (null for latest shift)
    required int userId,
    required String role,
    required int limit,
    required int offset,
    int? filterUserId, // optional: admin's selected user id filter
  });

  FutureEither<List<ShiftModel>> fetchLast10Shifts();
  FutureEither<ShiftModel> fetchShift(int currentShiftId,
      {bool isPrev = false, bool isNext = false, bool isLast = false});

  FutureEither<ShiftModel> fetchCurrentShift();

  FutureEither<ShiftModel> createShift();

  FutureEither<ReceiptModel> fetchLastInvoice({required UserModel userModel});

  FutureEither<List<ReceiptModel>> fetchReceiptsByCustomerId({
    required int customerId,
    required ReceiptStatus status,
  });
  FutureEither<Map<String, double>> fetchRevenueAndProfitByCustomer(
      {required int customerId});

// for backup
  FutureEither<List<ReceiptModel>> fetchReceiptsThisYear();
  FutureEither<List<FinancialTransactionModel>> fetchFinancialTransactionsThisYear();
  FutureEither<List<DetailsReceipt>> fetchDetailsReceiptsThisYear();

  FutureEitherVoid togglePayReceipt(ReceiptModel receipt, bool value);
  FutureEitherVoid payRemainingAmount(
      {required ReceiptModel receipt, required double value});
  FutureEitherVoid payAllReceiptsByCustomerId(
      CustomerModel customer, double amountToPay);

  FutureEither<List<NotificationModel>> fetchPendingReceiptsNotifications();

  // Revenue vs Purchases for line chart
  Future<List<RevenueVsPurchasesVsExpensesModel>> fetchRevenueVsPurchases({
    DashboardFilterEnum? view,
  });
}


