import 'package:desktoppossystem/controller/auth_controller.dart';
import 'package:desktoppossystem/controller/receipt_controller.dart';
import 'package:desktoppossystem/models/customers_model.dart';
import 'package:desktoppossystem/models/details_receipt.dart';
import 'package:desktoppossystem/models/failure_model.dart';
import 'package:desktoppossystem/models/financial_transaction_model.dart';
import 'package:desktoppossystem/models/notification_model.dart';
import 'package:desktoppossystem/models/receipt_model.dart';
import 'package:desktoppossystem/models/receipts_count_by_view_model.dart';
import 'package:desktoppossystem/models/reports/daily_sale_model.dart';
import 'package:desktoppossystem/models/reports/revenue_vs_purchases_model.dart';
import 'package:desktoppossystem/models/shift_model.dart';
import 'package:desktoppossystem/models/user_model.dart';
import 'package:desktoppossystem/repositories/financial_transaction.dart/financial_transaction_repository.dart';
import 'package:desktoppossystem/repositories/receipts/ireceiptrepository.dart';
import 'package:desktoppossystem/screens/notifications_screen/notification_controller.dart';
import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
import 'package:desktoppossystem/shared/constances/auth_role.dart';
import 'package:desktoppossystem/shared/constances/table_constant.dart';
import 'package:desktoppossystem/shared/services/dependency_injection.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:desktoppossystem/shared/utils/type_def.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:jiffy/jiffy.dart' as jiffy_library;

import '../../models/details_ingredients_receipt.dart';
import '../../screens/main_screen.dart/main_controller.dart';
import '../restaurant_stock/restaurant_stock_repository.dart';

final receiptProviderRepository = Provider((ref) {
  return ReceiptRepository(ref: ref);
});

class ReceiptRepository extends IReceiptRepository {
  final Ref ref;
  ReceiptRepository({required this.ref});

  @override
  Future<int> addReceipt(ReceiptModel receiptModel) async {
    int receiptId = 0;
    await ref
        .read(posDbProvider)
        .database
        .insert(TableConstant.receiptTable, receiptModel.toJson())
        .then((value) {
          receiptId = value;
        })
        .catchError((error) {
          throw Exception(error);
        });
    return receiptId;
  }

  @override
  Future<void> addDetailsReceipt({
    required List<DetailsReceipt> detailsReceipt,
    required OrderType orderType,
  }) async {
    for (var element in detailsReceipt) {
      await ref
          .read(posDbProvider)
          .database
          .insert(TableConstant.detailsReceiptTable, element.toJsonForInsert())
          .then((insertedId) async {
            // add  sales ingredients
            if (element.ingredients != null &&
                element.ingredients!.isNotEmpty) {
              List<DetailsIngredientsReceipt> salesIngredients = [];
              // filtering out the packaging if dine in
              if (orderType == OrderType.dineIn) {
                element.ingredients = element.ingredients!
                    .where((e) => !e.forPackaging!)
                    .toList();
              }

              for (var ingredient in element.ingredients!) {
                DetailsIngredientsReceipt detailsIngredientsReceipt =
                    DetailsIngredientsReceipt(
                      forPackaging: ingredient.forPackaging,
                      ingredientId: ingredient.id!,
                      detailsReceiptId: insertedId,
                      receiptId: element.receiptId!,
                      name: ingredient.name,
                      unitType: ingredient.unitType,
                      qtyAsGram: ingredient.qtyAsGram,
                      qtyAsPortion: ingredient.qtyAsPortion,
                      qty: element.qty!,
                      restaurantStockId: ingredient.restaurantStockId,
                      pricePerIngredient: (ingredient.pricePerIngredient ?? 0)
                          .formatDouble(),
                    );
                salesIngredients.add(detailsIngredientsReceipt);
              }

              await ref
                  .read(restaurantProviderRepository)
                  .addsalesIngredients(salesIngredients);
            }
          })
          .catchError((error) {
            throw Exception(error);
          });
    }
  }

  @override
  Future<ReceiptModel?> getReceiptById(int id) async {
    ReceiptModel? receiptModel;
    await ref
        .read(posDbProvider)
        .database
        .query(TableConstant.receiptTable, where: "id=$id")
        .then((value) {
          if (value.isNotEmpty) receiptModel = ReceiptModel.fromJson(value[0]);
        })
        .catchError((error) {
          throw Exception(error);
        });
    return receiptModel;
  }

  @override
  Future updateReceiptPrice(
    int id,
    double newprice,
    double lebanesePrice,
  ) async {
    await ref
        .read(posDbProvider)
        .database
        .rawUpdate(
          "update ${TableConstant.receiptTable} set foreignReceiptPrice='$newprice' ,localReceiptPrice ='$lebanesePrice'  where id=$id",
        )
        .then((value) {})
        .catchError((error) {
          throw Exception(error);
        });
  }

  //MARK: receipts by
  @override
  Future<List<ReceiptModel>> getReceiptsByDayWithPagination({
    required String date,
    required int userId,
    required String role,
    required int limit,
    required int offset,
    int? filterUserId, // optional: admin's selected user id filter
  }) async {
    DateTime currentDate = DateTime.parse(date);
    List<ReceiptModel> receipts = [];
    String query =
        "CAST(SUBSTR(receiptDate, 1, 4) AS integer)=${currentDate.year} AND "
        "CAST(SUBSTR(receiptDate, 6, 7) AS integer)=${currentDate.month} AND "
        "CAST(SUBSTR(receiptDate, 9, 10) AS integer)=${currentDate.day}";
    if (role == AuthRole.userRole) {
      query += " AND userId=$userId";
    } else if ((role == AuthRole.adminRole ||
            role == AuthRole.superAdminRole) &&
        filterUserId != null) {
      query += " AND userId=$filterUserId";
    }
    query += " ORDER BY receiptDate DESC LIMIT $limit OFFSET $offset";
    try {
      final response = await ref
          .read(posDbProvider)
          .database
          .rawQuery(
            "SELECT r.id, receiptDate, foreignReceiptPrice, localReceiptPrice, userId, dolarRate, paymentType, shiftId, transactionType, orderType, expenseId, r.isTransactionInPrimary, e.expensePurpose, customerId, r.isHasDiscount, r.invoiceDelivered, r.withDrawFromCash,r.isPaid,r.remainingAmount , c.name, c.address, c.phoneNumber "
            "FROM ${TableConstant.receiptTable} AS r "
            "LEFT JOIN ${TableConstant.customersTable} AS c ON r.customerId = c.id "
            "LEFT JOIN ${TableConstant.expensesTable} AS e ON e.id = r.expenseId "
            "WHERE $query",
          );
      receipts = List.from(response.map((e) => ReceiptModel.fromJson(e)));
    } catch (error) {
      print(error.toString());
      throw Exception(error);
    }

    return receipts;
  }

  @override
  Future<List<DetailsReceipt>> getDetailsReceiptById(int id) async {
    List<DetailsReceipt> detailsReceipt = [];
    await ref
        .read(posDbProvider)
        .database
        .rawQuery(
          "select  p.name as productName,p.id as productId,dr.id, dr.receiptId ,dr.qty, dr.originalSellingPrice,dr.sellingPrice , dr.costPrice ,dr.isRefunded,dr.refundReason ,dr.refundDate,dr.discount,   p.isTracked  from ${TableConstant.productTable} as p join ${TableConstant.detailsReceiptTable} as dr on p.id=dr.productId where dr.receiptId=$id",
        )
        .then((value) {
          detailsReceipt = List.from(
            (value).map((e) => DetailsReceipt.fromJson(e)),
          );
        })
        .catchError((error) {
          throw Exception(error);
        });
    return detailsReceipt;
  }

  @override
  Future<List<DailySalesModel>> getSalesByType({
    DashboardFilterEnum? view,
  }) async {
    try {
      DateTime currentDate = DateTime.now();
      List<DailySalesModel> dailySalesInMonthList = [];

      // Build WHERE condition using helper
      final conditions = _buildDateFilterConditions(
        view,
        currentDate,
        'transactionDate',
      );
      String dateCondition = conditions['dateCondition']!;
      String groupBy = conditions['groupBy']!;
      String periodFormat = conditions['periodFormat']!;

      // Build query based on view type (year vs other periods)
      String query;
      if (view == DashboardFilterEnum.thisYear ||
          view == DashboardFilterEnum.lastYear) {
        // Group by month for yearly views
        query =
            """
          SELECT 
            $periodFormat as period,
            SUM(CASE 
              WHEN transactionType = '${TransactionType.salePayment.name}' THEN primaryAmount
              WHEN transactionType = '${TransactionType.refund.name}' THEN -primaryAmount
              ELSE 0
            END) as totalAmount
          FROM ${TableConstant.financialTransactionTable}
          WHERE $dateCondition
            AND paymentType = 'cash'
            AND (transactionType = '${TransactionType.salePayment.name}' OR transactionType = '${TransactionType.refund.name}')
          GROUP BY $groupBy
          ORDER BY period
        """;
      } else {
        // Group by day for other views
        query =
            """
          SELECT 
            $periodFormat as period,
            SUM(CASE 
              WHEN transactionType = '${TransactionType.salePayment.name}' THEN primaryAmount
              WHEN transactionType = '${TransactionType.refund.name}' THEN -primaryAmount
              ELSE 0
            END) as totalAmount
          FROM ${TableConstant.financialTransactionTable}
          WHERE $dateCondition
            AND paymentType = 'cash'
            AND (transactionType = '${TransactionType.salePayment.name}' OR transactionType = '${TransactionType.refund.name}')
          GROUP BY $groupBy
          ORDER BY period
        """;
      }

      final response = await ref.read(posDbProvider).database.rawQuery(query);

      dailySalesInMonthList = response.map((row) {
        return DailySalesModel(
          row['period'].toString(),
          double.parse(row['totalAmount'].toString()).formatDouble(),
        );
      }).toList();

      return dailySalesInMonthList;
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  @override
  Future refundItems(List<DetailsReceipt> products) async {
    try {
      double totalpricerefunded = 0;
      for (var element in products) {
        totalpricerefunded += element.sellingPrice! * element.refundedQty!;

        // if refunded qty equal the qty  , so set the record to refund 1
        if (element.qty == element.refundedQty) {
          await ref
              .read(posDbProvider)
              .database
              .rawQuery(
                "update ${TableConstant.detailsReceiptTable} set isRefunded=1 , refundReason='${element.refundReason}',refundDate='${DateTime.now().toString()}' where id = ${element.id}",
              );
        } else {
          double restQty = element.qty! - element.refundedQty!;

          // update old record and set rest qty
          ref
              .read(posDbProvider)
              .database
              .rawQuery(
                "update ${TableConstant.detailsReceiptTable} set qty=$restQty  where id=${element.id}",
              );

          // insert new refund reccord
          element.isRefunded = true;
          element.qty = element.refundedQty;
          element.refundDate = DateTime.now().toString();
          ref
              .read(posDbProvider)
              .database
              .insert(
                TableConstant.detailsReceiptTable,
                element.toJsonForInsert(),
              );
        }
        if (ref.read(mainControllerProvider).isShowRestaurantStock &&
            ref.read(mainControllerProvider).screenUI == ScreenUI.restaurant) {
          List<DetailsIngredientsReceipt> detailsIngredientsReceipt = await ref
              .read(restaurantProviderRepository)
              .fetchSaledIngredientByDetailsReceiptId(element.id!);
          ref
              .read(restaurantProviderRepository)
              .refundIngredients(detailsIngredientsReceipt, element.qty!);
        }
      }

      await getReceiptById(products[0].receiptId!).then((value) async {
        //! set new price for receipt
        if (value != null) {
          // Calculate new total after refund
          double newTotal = value.foreignReceiptPrice! - totalpricerefunded;
          double newTotalSecondary =
              value.localReceiptPrice! -
              (totalpricerefunded * value.dollarRate!);

          // Calculate how much was already paid
          double paidAmount =
              value.foreignReceiptPrice! - (value.remainingAmount ?? 0);

          // Calculate new remaining amount
          double newRemaining = newTotal - paidAmount;

          // Update receipt price
          await updateReceiptPrice(value.id!, newTotal, newTotalSecondary);

          // Handle three cases:
          if (newRemaining >= 0) {
            // Case 1 & 2: Normal refund - update remaining amount
            await ref
                .read(posDbProvider)
                .database
                .rawUpdate(
                  "UPDATE ${TableConstant.receiptTable} SET remainingAmount=$newRemaining WHERE id=${value.id}",
                );

            // Create refund transaction
            var transaction = FinancialTransactionModel.fromReceipt(value);
            transaction.transactionType = TransactionType.refund;
            transaction.flow = TransactionFlow.OUT;
            transaction.note =
                "Refund for receipt num : ${value.id} , reason : ${products.map((e) => e.refundReason).join(", ")}";
            transaction.primaryAmount = (totalpricerefunded.formatDouble());
            transaction.secondaryAmount =
                (totalpricerefunded * value.dollarRate!).formatDouble();
            ref
                .read(financialTransactionProviderRepository)
                .addFinancialTransaction(transaction);
          } else {
            // Case 3 & 4: Overpayment - customer paid more than new total
            double overpayment = newRemaining.abs();

            // Set remaining to 0
            await ref
                .read(posDbProvider)
                .database
                .rawUpdate(
                  "UPDATE ${TableConstant.receiptTable} SET remainingAmount=0 WHERE id=${value.id}",
                );

            // Create refund transaction for the refunded items
            var refundTransaction = FinancialTransactionModel.fromReceipt(
              value,
            );
            refundTransaction.transactionType = TransactionType.refund;
            refundTransaction.flow = TransactionFlow.OUT;
            refundTransaction.note =
                "Refund for receipt num : ${value.id} , reason : ${products.map((e) => e.refundReason).join(", ")}";
            refundTransaction.primaryAmount = (totalpricerefunded
                .formatDouble());
            refundTransaction.secondaryAmount =
                (totalpricerefunded * value.dollarRate!).formatDouble();
            ref
                .read(financialTransactionProviderRepository)
                .addFinancialTransaction(refundTransaction);
          }
        }
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<DetailsReceipt?> checkIfAlreadyrefundedSameItemInSameReceipt(
    DetailsReceipt detailsReceipt,
  ) async {
    DetailsReceipt? oldDetailsReceipt;
    final checkRes = await ref
        .read(posDbProvider)
        .database
        .query(
          TableConstant.detailsReceiptTable,
          where:
              "productId=${detailsReceipt.productId} and receiptId=${detailsReceipt.receiptId} and  isRefunded=1",
        );
    if (checkRes.isNotEmpty) {
      oldDetailsReceipt = DetailsReceipt.fromJson(checkRes[0]);
    }
    return oldDetailsReceipt;
  }

  @override
  FutureEitherVoid deleteReceipt(int receiptId) async {
    try {
      await ref.read(posDbProvider).database.rawDelete(
        "delete from ${TableConstant.receiptTable} where id=?",
        ['$receiptId'],
      );

      await ref.read(posDbProvider).database.rawDelete(
        "delete from ${TableConstant.detailsReceiptTable} where receiptId=?",
        ['$receiptId'],
      );
      // delete transaction if exists
      ref
          .read(financialTransactionProviderRepository)
          .deleteFinancialTransactionByReceiptId(receiptId);
      return right(null);
    } catch (e) {
      debugPrint(e.toString());
      return left(FailureModel(e.toString()));
    }
  }

  @override
  Future<int> fetchNbOfReceiptsByType({DashboardFilterEnum? view}) async {
    DateTime currentDate = DateTime.now();

    String query =
        "select count(*) as count from ${TableConstant.receiptTable} ";
    int nbOfReceipts = 0;
    if (view != null) {
      switch (view) {
        case DashboardFilterEnum.lastYear:
          query +=
              " where CAST(SUBSTR(receiptDate, 1, 4) AS integer)=${currentDate.year - 1}";
          break;
        case DashboardFilterEnum.yesterday:
          DateTime yesterday = currentDate.subtract(const Duration(days: 1));
          query +=
              " where CAST(SUBSTR(receiptDate, 9, 11) AS integer)=${yesterday.day} and CAST(SUBSTR(receiptDate, 6, 8) AS integer)=${yesterday.month} and CAST(SUBSTR(receiptDate, 1, 4) AS integer)=${yesterday.year}";
          break;
        case DashboardFilterEnum.today:
          query +=
              " where CAST(SUBSTR(receiptDate, 9, 11) AS integer)=${currentDate.day} and CAST(SUBSTR(receiptDate, 6, 8) AS integer)=${currentDate.month} and CAST(SUBSTR(receiptDate, 1, 4) AS integer)=${currentDate.year}";
          break;
        case DashboardFilterEnum.thisWeek:
          String startDate =
              jiffy_library.Jiffy.parse(currentDate.toString().split(' ').first)
                  .startOf(jiffy_library.Unit.week)
                  .dateTime
                  .toString()
                  .split(' ')
                  .first;

          String endDate = jiffy_library.Jiffy.parse(
            currentDate.toString().split(' ').first,
          ).endOf(jiffy_library.Unit.week).dateTime.toString().split(' ').first;
          query +=
              " where receiptDate>='$startDate' and receiptDate<='$endDate'";

          break;
        case DashboardFilterEnum.lastMonth:
          int currentYear = currentDate.month == 1
              ? currentDate.year - 1
              : currentDate.year;
          int currentMonth = currentDate.month == 1
              ? 12
              : currentDate.month - 1;
          query +=
              "  where CAST(SUBSTR(receiptDate, 1, 4) AS integer)=$currentYear and CAST(SUBSTR(receiptDate, 6, 8) AS integer)=$currentMonth";
          break;
        case DashboardFilterEnum.thisMonth:
          query +=
              "  where CAST(SUBSTR(receiptDate, 1, 4) AS integer)=${currentDate.year} and CAST(SUBSTR(receiptDate, 6, 8) AS integer)=${currentDate.month}";
          break;
        case DashboardFilterEnum.thisYear:
          query +=
              " where CAST(SUBSTR(receiptDate, 1, 4) AS integer)=${currentDate.year}";
          break;
      }
    } else {
      // ! get current day if view null
      query +=
          " where CAST(SUBSTR(receiptDate, 9, 11) AS integer)=${currentDate.day} and CAST(SUBSTR(receiptDate, 6, 8) AS integer)=${currentDate.month} and CAST(SUBSTR(receiptDate, 1, 4) AS integer)=${currentDate.year}";
    }
    query +=
        " and paymentType='cash' and transactionType ='${TransactionType.salePayment.name}'";

    final response = await ref.read(posDbProvider).database.rawQuery(query);
    if (response.isNotEmpty) {
      nbOfReceipts = int.tryParse(response.first["count"].toString()) ?? 0;
    }
    return nbOfReceipts;
  }

  //MARK:Totals by Day
  @override
  FutureEither<ReceiptTotals> getReceiptTotalsByDay({
    required String date,
    required int userId,
    required String role,
    int? filterUserId, // optional: admin's selected user id filter
  }) async {
    DateTime currentDate = DateTime.parse(date);
    String receiptsCondition =
        "CAST(SUBSTR(receiptDate, 1, 4) AS integer)=${currentDate.year} AND CAST(SUBSTR(receiptDate, 6, 2) AS integer)=${currentDate.month} AND CAST(SUBSTR(receiptDate, 9, 2) AS integer)=${currentDate.day}";
    String transactionCondtion =
        "CAST(SUBSTR(transactionDate, 1, 4) AS integer)=${currentDate.year} AND CAST(SUBSTR(transactionDate, 6, 2) AS integer)=${currentDate.month} AND CAST(SUBSTR(transactionDate, 9, 2) AS integer)=${currentDate.day}";

    if (role == AuthRole.userRole) {
      receiptsCondition += " AND userId=$userId";
      transactionCondtion += " AND userId=$userId";
    } else if ((role == AuthRole.adminRole ||
            role == AuthRole.superAdminRole) &&
        filterUserId != null) {
      receiptsCondition += " AND userId=$filterUserId";
      transactionCondtion += " AND userId=$filterUserId";
    }
    try {
      final transactionResult = await ref.read(posDbProvider).database.rawQuery(
        '''
    SELECT

      -- Sales for primary currency
      SUM(CASE WHEN transactionType = '${TransactionType.salePayment.name}' 
               THEN primaryAmount ELSE 0 END) AS salesDolar,
      -- Sales for secondary currency
      SUM(CASE WHEN transactionType = '${TransactionType.salePayment.name}' 
               THEN secondaryAmount ELSE 0 END) AS salesLebanon,

      -- Deposit
      SUM(CASE WHEN transactionType = '${TransactionType.deposit.name}' 
               THEN primaryAmount ELSE 0 END) AS totalDepositDolar,
      SUM(CASE WHEN transactionType = '${TransactionType.deposit.name}' 
               THEN secondaryAmount ELSE 0 END) AS totalDepositLebanon,

      -- Withdraw
      SUM(CASE WHEN transactionType = '${TransactionType.withdraw.name}' 
               THEN primaryAmount ELSE 0 END) AS totalWithdrawDolar,
      SUM(CASE WHEN transactionType = '${TransactionType.withdraw.name}' 
               THEN secondaryAmount ELSE 0 END) AS totalWithdrawLebanon,

      -- Withdraw from cash
      SUM(CASE WHEN transactionType = '${TransactionType.withdraw.name}' AND fromCash = 1 
               THEN primaryAmount ELSE 0 END) AS totalWithdrawDolarFromCash,
      SUM(CASE WHEN transactionType = '${TransactionType.withdraw.name}' AND fromCash = 1 
               THEN secondaryAmount ELSE 0 END) AS totalWithdrawLebanonFromCash,

    -- Purchase in primary currency
      SUM(CASE WHEN transactionType = '${TransactionType.purchase.name}'
           THEN primaryAmount ELSE 0 END) AS totalPurchasesPrimary,
            -- Purchase in secondary currency
       SUM(CASE WHEN transactionType = '${TransactionType.purchase.name}'
           THEN secondaryAmount ELSE 0 END) AS totalPurchasesSecondary,

      -- Subscriptions payments
      SUM(CASE WHEN transactionType = '${TransactionType.subscriptionPayment.name}' 
           THEN primaryAmount ELSE 0 END) AS totalSubscriptions,

       SUM(CASE WHEN transactionType = '${TransactionType.pendingPayment.name}' 
        THEN primaryAmount ELSE 0 END) AS totalCollectedPending,

      SUM(CASE WHEN transactionType = '${TransactionType.refund.name}' 
           THEN primaryAmount ELSE 0 END) AS totalRefunds,

      SUM(CASE WHEN transactionType = '${TransactionType.pendingPayment.name}' 
     THEN primaryAmount ELSE 0 END) AS totalCollectedPending ,

      (
    COALESCE(SUM(CASE WHEN transactionType = '${TransactionType.salePayment.name}' THEN primaryAmount ELSE 0 END), 0)
    + COALESCE(SUM(CASE WHEN transactionType = '${TransactionType.deposit.name}' THEN primaryAmount ELSE 0 END), 0)
    + COALESCE(SUM(CASE WHEN transactionType = '${TransactionType.pendingPayment.name}' THEN primaryAmount ELSE 0 END), 0)
    + COALESCE(SUM(CASE WHEN transactionType = '${TransactionType.subscriptionPayment.name}' THEN primaryAmount ELSE 0 END), 0)
    - COALESCE(SUM(CASE WHEN transactionType = '${TransactionType.withdraw.name}' AND fromCash = 1 THEN primaryAmount ELSE 0 END), 0)
    - COALESCE(SUM(CASE WHEN transactionType = '${TransactionType.purchase.name}' AND fromCash = 1 THEN primaryAmount ELSE 0 END), 0)
    - COALESCE(SUM(CASE WHEN transactionType = '${TransactionType.refund.name}' THEN primaryAmount ELSE 0 END), 0)
  ) AS totalPrimaryBalance,

  -- Total Balance in Secondary (deposits and withdrawals only, no purchases/refunds)
  (
     COALESCE(SUM(CASE WHEN transactionType = '${TransactionType.deposit.name}' THEN secondaryAmount ELSE 0 END), 0)
    - COALESCE(SUM(CASE WHEN transactionType = '${TransactionType.withdraw.name}' AND fromCash = 1 THEN secondaryAmount ELSE 0 END), 0)
  ) AS totalSecondaryBalance

    FROM ${TableConstant.financialTransactionTable}
    WHERE $transactionCondtion''',
      );

      // 2️⃣ Get pending amounts from receiptTable
      final pendingResult = await ref.read(posDbProvider).database.rawQuery('''
  SELECT
  COUNT(DISTINCT id) AS totalInvoices,
  SUM(CASE WHEN remainingAmount > 0 
           AND orderType = '${OrderType.delivery.name}' 
           THEN remainingAmount ELSE 0 END) AS totalPendingAmount,
  COUNT(CASE WHEN remainingAmount > 0 
             AND orderType = '${OrderType.delivery.name}' 
             THEN 1 ELSE NULL END) AS totalPendingReceipts
FROM ${TableConstant.receiptTable}
WHERE  $receiptsCondition''');

      final t = transactionResult.first;
      final p = pendingResult.first;
      // Calculate sales dollar (paid + pending)
      final salesDolarTotal =
          t['salesDolar'].toString().validateDouble().formatDouble() +
          p['totalPendingAmount'].toString().validateDouble();

      // Calculate pending amount in Lebanese using dollar rate
      final dollarRate = ref.read(saleControllerProvider).dolarRate;
      final pendingAmountLebanon =
          p['totalPendingAmount'].toString().validateDouble() * dollarRate;

      return Right(
        ReceiptTotals(
          // Sales Dollar = Paid sales + Pending amount
          salesDolar: salesDolarTotal,

          // Sales Lebanon = Paid sales in Lebanese + Pending amount in Lebanese
          salesLebanon:
              t['salesLebanon'].toString().validateDouble() +
              pendingAmountLebanon,

          totalDepositDolar: t['totalDepositDolar'].toString().validateDouble(),
          totalDepositLebanon: t['totalDepositLebanon']
              .toString()
              .validateDouble(),
          totalWithdrawDolar: t['totalWithdrawDolar']
              .toString()
              .validateDouble(),
          totalWithdrawLebanon: t['totalWithdrawLebanon']
              .toString()
              .validateDouble(),
          totalWithdrawDolarFromCash: t['totalWithdrawDolarFromCash']
              .toString()
              .validateDouble(),
          totalWithdrawLebanonFromCash: t['totalWithdrawLebanonFromCash']
              .toString()
              .validateDouble(),
          totalRefunds: t['totalRefunds'].toString().validateDouble(),
          totalCollectedPending: t['totalCollectedPending']
              .toString()
              .validateDouble(),
          totalPrimaryBalance: t['totalPrimaryBalance']
              .toString()
              .validateDouble()
              .formatDouble(),
          totalSecondaryBalance: t['totalSecondaryBalance']
              .toString()
              .validateDouble(),
          totalInvoices: p['totalInvoices'].toString().validateInteger(),
          totalPendingAmount: p['totalPendingAmount']
              .toString()
              .validateDouble(),
          totalPendingReceipts: p['totalPendingReceipts']
              .toString()
              .validateInteger(),
          totalPurchasesPrimary: t['totalPurchasesPrimary']
              .toString()
              .validateDouble(),
          totalPurchasesSecondary: t['totalPurchasesSecondary']
              .toString()
              .validateDouble(),
          totalSubscriptions: t['totalSubscriptions']
              .toString()
              .validateDouble(),
        ),
      );
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  //MARK:Totals by Shift
  @override
  FutureEither<ReceiptTotals> getReceiptTotalsByShift({
    required int userId,
    required String role,
    int? filterUserId,
    int? shiftId,
  }) async {
    final shiftCondition = shiftId != null
        ? "shiftId = $shiftId"
        : "shiftId = (SELECT MAX(id) FROM ${TableConstant.shiftTable})";

    String userCondition = "";
    if (role == AuthRole.userRole) {
      userCondition = " AND userId = $userId";
    } else if ((role == AuthRole.adminRole ||
            role == AuthRole.superAdminRole) &&
        filterUserId != null) {
      userCondition = " AND userId = $filterUserId";
    }
    try {
      final transactionResult = await ref.read(posDbProvider).database.rawQuery(
        '''
     SELECT

      -- Sales
      SUM(CASE WHEN transactionType = '${TransactionType.salePayment.name}' 
               THEN primaryAmount ELSE 0 END) AS salesDolar,
      SUM(CASE WHEN transactionType = '${TransactionType.salePayment.name}' 
               THEN secondaryAmount ELSE 0 END) AS salesLebanon,

      -- Deposit
      SUM(CASE WHEN transactionType = '${TransactionType.deposit.name}' 
               THEN primaryAmount ELSE 0 END) AS totalDepositDolar,
      SUM(CASE WHEN transactionType = '${TransactionType.deposit.name}' 
               THEN secondaryAmount ELSE 0 END) AS totalDepositLebanon,

      -- Withdraw
      SUM(CASE WHEN transactionType = '${TransactionType.withdraw.name}' 
               THEN primaryAmount ELSE 0 END) AS totalWithdrawDolar,
      SUM(CASE WHEN transactionType = '${TransactionType.withdraw.name}' 
               THEN secondaryAmount ELSE 0 END) AS totalWithdrawLebanon,

      -- Withdraw from cash
      SUM(CASE WHEN transactionType = '${TransactionType.withdraw.name}' AND fromCash = 1 
               THEN primaryAmount ELSE 0 END) AS totalWithdrawDolarFromCash,
      SUM(CASE WHEN transactionType = '${TransactionType.withdraw.name}' AND fromCash = 1 
               THEN secondaryAmount ELSE 0 END) AS totalWithdrawLebanonFromCash,

   -- Purchase in primary currency
      SUM(CASE WHEN transactionType = '${TransactionType.purchase.name}'
           THEN primaryAmount ELSE 0 END) AS totalPurchasesPrimary,
            -- Purchase in secondary currency
       SUM(CASE WHEN transactionType = '${TransactionType.purchase.name}'
           THEN secondaryAmount ELSE 0 END) AS totalPurchasesSecondary,

          -- Subscriptions payments
      SUM(CASE WHEN transactionType = '${TransactionType.subscriptionPayment.name}' 
           THEN primaryAmount ELSE 0 END) AS totalSubscriptions,


       SUM(CASE WHEN transactionType = '${TransactionType.pendingPayment.name}' 
        THEN primaryAmount ELSE 0 END) AS totalCollectedPending,

      SUM(CASE WHEN transactionType = '${TransactionType.refund.name}' 
           THEN primaryAmount ELSE 0 END) AS totalRefunds,

      SUM(CASE WHEN transactionType = '${TransactionType.pendingPayment.name}' 
     THEN primaryAmount ELSE 0 END) AS totalCollectedPending ,

      (
    COALESCE(SUM(CASE WHEN transactionType = '${TransactionType.salePayment.name}' THEN primaryAmount ELSE 0 END), 0)
    + COALESCE(SUM(CASE WHEN transactionType = '${TransactionType.deposit.name}' THEN primaryAmount ELSE 0 END), 0)
   + COALESCE(SUM(CASE WHEN transactionType = '${TransactionType.pendingPayment.name}' THEN primaryAmount ELSE 0 END), 0)
       + COALESCE(SUM(CASE WHEN transactionType = '${TransactionType.subscriptionPayment.name}' THEN primaryAmount ELSE 0 END), 0)

    - COALESCE(SUM(CASE WHEN transactionType = '${TransactionType.withdraw.name}' AND fromCash = 1 THEN primaryAmount ELSE 0 END), 0)
    - COALESCE(SUM(CASE WHEN transactionType = '${TransactionType.purchase.name}' AND fromCash = 1 THEN primaryAmount ELSE 0 END), 0)
    - COALESCE(SUM(CASE WHEN transactionType = '${TransactionType.refund.name}' THEN primaryAmount ELSE 0 END), 0)
  ) AS totalPrimaryBalance,

  -- Total Balance in Secondary (deposits and withdrawals only, no purchases/refunds)
  (
   
     COALESCE(SUM(CASE WHEN transactionType = '${TransactionType.deposit.name}' THEN secondaryAmount ELSE 0 END), 0)
       + COALESCE(SUM(CASE WHEN transactionType = '${TransactionType.pendingPayment.name}' THEN secondaryAmount ELSE 0 END), 0)
    - COALESCE(SUM(CASE WHEN transactionType = '${TransactionType.withdraw.name}' AND fromCash = 1 THEN secondaryAmount ELSE 0 END), 0)
  ) AS totalSecondaryBalance
    FROM ${TableConstant.financialTransactionTable}
    WHERE $shiftCondition $userCondition  ''',
      );

      // 2️⃣ Get pending amounts from receiptTable
      final pendingResult = await ref.read(posDbProvider).database.rawQuery('''
  SELECT
  COUNT(DISTINCT id) AS totalInvoices,
  SUM(CASE WHEN remainingAmount > 0 
           AND orderType = '${OrderType.delivery.name}' 
           THEN remainingAmount ELSE 0 END) AS totalPendingAmount,
  COUNT(CASE WHEN remainingAmount > 0 
             AND orderType = '${OrderType.delivery.name}' 
             THEN 1 ELSE NULL END) AS totalPendingReceipts
FROM ${TableConstant.receiptTable}
WHERE   $shiftCondition $userCondition  ''');

      final t = transactionResult.first;
      final p = pendingResult.first;
      // Calculate sales dollar (paid + pending)
      final salesDolarTotal =
          t['salesDolar'].toString().validateDouble().formatDouble() +
          p['totalPendingAmount'].toString().validateDouble();

      // Calculate pending amount in Lebanese using dollar rate
      final dollarRate = ref.read(saleControllerProvider).dolarRate;
      final pendingAmountLebanon =
          p['totalPendingAmount'].toString().validateDouble() * dollarRate;

      return Right(
        ReceiptTotals(
          // Sales Dollar = Paid sales + Pending amount
          salesDolar: salesDolarTotal,

          // Sales Lebanon = Paid sales in Lebanese + Pending amount in Lebanese
          salesLebanon:
              t['salesLebanon'].toString().validateDouble() +
              pendingAmountLebanon,
          totalDepositDolar: t['totalDepositDolar'].toString().validateDouble(),
          totalDepositLebanon: t['totalDepositLebanon']
              .toString()
              .validateDouble(),
          totalWithdrawDolar: t['totalWithdrawDolar']
              .toString()
              .validateDouble(),
          totalWithdrawLebanon: t['totalWithdrawLebanon']
              .toString()
              .validateDouble(),
          totalWithdrawDolarFromCash: t['totalWithdrawDolarFromCash']
              .toString()
              .validateDouble(),
          totalWithdrawLebanonFromCash: t['totalWithdrawLebanonFromCash']
              .toString()
              .validateDouble(),
          totalRefunds: t['totalRefunds'].toString().validateDouble(),
          totalCollectedPending: t['totalCollectedPending']
              .toString()
              .validateDouble(),
          totalPrimaryBalance: t['totalPrimaryBalance']
              .toString()
              .validateDouble(),
          totalSecondaryBalance: t['totalSecondaryBalance']
              .toString()
              .validateDouble(),
          totalInvoices: p['totalInvoices'].toString().validateInteger(),
          totalPendingReceipts: p['totalPendingReceipts']
              .toString()
              .validateInteger(),
          totalPendingAmount: p['totalPendingAmount']
              .toString()
              .validateDouble(),
          totalPurchasesPrimary: t['totalPurchasesPrimary']
              .toString()
              .validateDouble(),
          totalPurchasesSecondary: t['totalPurchasesSecondary']
              .toString()
              .validateDouble(),
          totalSubscriptions: t['totalSubscriptions']
              .toString()
              .validateDouble(),
        ),
      );
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  Future<List<ReceiptModel>> getReceiptsByShiftWithPagination({
    int? shiftId, // optional shift ID (null for latest shift)
    required int userId,
    required String role,
    required int limit,
    required int offset,
    int? filterUserId, // optional: admin's selected user id filter
  }) async {
    List<ReceiptModel> receipts = [];

    // Build the base condition for shift filtering
    String baseCondition;
    if (shiftId != null) {
      baseCondition = "shiftId = $shiftId";
    } else {
      baseCondition =
          "shiftId = (SELECT MAX(id) FROM ${TableConstant.shiftTable})";
    }

    // Add user filtering based on role
    if (role == AuthRole.userRole) {
      baseCondition += " AND userId = $userId";
    } else if ((role == AuthRole.adminRole ||
            role == AuthRole.superAdminRole) &&
        filterUserId != null) {
      baseCondition += " AND userId = $filterUserId";
    }

    // Add ordering and pagination
    String query =
        "$baseCondition ORDER BY receiptDate DESC LIMIT $limit OFFSET $offset";

    try {
      final response = await ref
          .read(posDbProvider)
          .database
          .rawQuery(
            "SELECT r.id, receiptDate, foreignReceiptPrice, localReceiptPrice, userId, dolarRate, paymentType, shiftId, transactionType, orderType, expenseId, r.isTransactionInPrimary, e.expensePurpose, customerId, r.isHasDiscount, r.invoiceDelivered, r.withDrawFromCash, c.name, c.address, c.phoneNumber "
            "FROM ${TableConstant.receiptTable} AS r "
            "LEFT JOIN ${TableConstant.customersTable} AS c ON r.customerId = c.id "
            "LEFT JOIN ${TableConstant.expensesTable} AS e ON e.id = r.expenseId "
            "WHERE $query",
          );

      receipts = List.from(response.map((e) => ReceiptModel.fromJson(e)));
    } catch (error) {
      print(error.toString());
      throw Exception(error);
    }

    return receipts;
  }

  @override
  FutureEither<List<ShiftModel>> fetchLast10Shifts() async {
    try {
      List<ShiftModel> shifts = [];
      await ref
          .read(posDbProvider)
          .database
          .rawQuery(
            "select * from ${TableConstant.shiftTable} order by id desc limit 10",
          )
          .then((value) {
            if (value.isNotEmpty) {
              shifts = List.from(
                (value as List).map((e) => ShiftModel.fromJson(e)),
              );
            }
          });
      return right(shifts);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<ShiftModel> fetchShift(
    int currentShiftId, {
    bool isPrev = false,
    bool isNext = false,
    bool isLast = false,
  }) async {
    try {
      ShiftModel? shift;

      String query;
      if (isLast == true) {
        query =
            """
        SELECT * FROM ${TableConstant.shiftTable} 
        ORDER BY id DESC LIMIT 1
      """;
      } else {
        // Determine the query based on isPrev or isNext flag
        if (isPrev) {
          query =
              """
        SELECT * FROM ${TableConstant.shiftTable} 
        WHERE id < $currentShiftId 
        ORDER BY id DESC LIMIT 1
      """;
        } else if (isNext) {
          query =
              """
        SELECT * FROM ${TableConstant.shiftTable} 
        WHERE id > $currentShiftId 
        ORDER BY id ASC LIMIT 1
      """;
        } else {
          // If neither isPrev nor isNext is true, return the current shift itself
          query =
              """
        SELECT * FROM ${TableConstant.shiftTable} 
        WHERE id = $currentShiftId
      """;
        }
      }

      // Execute the query
      var value = await ref.read(posDbProvider).database.rawQuery(query);

      if (value.isNotEmpty) {
        shift = ShiftModel.fromJson(value.first);
      } else {
        // If no shift found, fetch the latest shift (in case of next) or the latest previous shift (in case of prev)
        if (isPrev) {
          // If no previous shift is found, fetch the latest shift
          query =
              """
          SELECT * FROM ${TableConstant.shiftTable} 
          ORDER BY id DESC LIMIT 1
        """;
        } else if (isNext) {
          // If no next shift is found, fetch the latest previous shift
          query =
              """
          SELECT * FROM ${TableConstant.shiftTable} 
          WHERE id < $currentShiftId 
          ORDER BY id DESC LIMIT 1
        """;
        }

        value = await ref.read(posDbProvider).database.rawQuery(query);
        if (value.isNotEmpty) {
          shift = ShiftModel.fromJson(value.first);
        }
      }

      if (shift != null) {
        return right(shift);
      } else {
        return left(FailureModel("No shift found"));
      }
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<ShiftModel> fetchCurrentShift() async {
    ShiftModel shiftModel = ShiftModel.second();
    try {
      await ref
          .read(posDbProvider)
          .database
          .rawQuery(
            "select * from ${TableConstant.shiftTable} order by id desc",
          )
          .then((value) async {
            if (value.isNotEmpty) {
              shiftModel = ShiftModel.fromJson(value.first);
            } else {
              shiftModel = ShiftModel(
                startShiftDate: DateTime.now().toString(),
              );
              int insertedId = await ref
                  .read(posDbProvider)
                  .database
                  .insert(
                    TableConstant.shiftTable,
                    shiftModel.toJsonForInsert(),
                  );
              shiftModel.id = insertedId;
            }
          });
      return right(shiftModel);
    } catch (e) {
      debugPrint("error ${e.toString()}");
      return left(FailureModel(e.toString()));
    }
  }

  Future updatetLatestEndShiftDate() async {
    try {
      final latestShiftRes = await fetchCurrentShift();
      latestShiftRes.fold<Future>(
        (l) async => () {},
        (r) async => {
          ref.read(posDbProvider).database.update(TableConstant.shiftTable, {
            "endShiftDate": DateTime.now().toString(),
          }, where: "id=${r.id}"),
        },
      );
    } catch (e) {}
  }

  @override
  FutureEither<ShiftModel> createShift() async {
    try {
      updatetLatestEndShiftDate();
      ShiftModel shiftModel = ShiftModel.second();

      shiftModel = ShiftModel(startShiftDate: DateTime.now().toString());
      int insertedId = await ref
          .read(posDbProvider)
          .database
          .insert(TableConstant.shiftTable, shiftModel.toJsonForInsert());
      shiftModel.id = insertedId;

      return right(shiftModel);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<ReceiptModel> fetchLastInvoice({
    required UserModel userModel,
  }) async {
    try {
      // for max id of receipt , if role user fetch by max by receipt id , else fetch last
      String whereQuery = "";
      if (userModel.role?.name != AuthRole.adminRole ||
          userModel.role?.name != AuthRole.superAdminRole) {
        whereQuery += "where  userId=${userModel.id}";
      }

      String query =
          "select r.id , receiptDate , foreignReceiptPrice , localReceiptPrice , userId , dolarRate , paymentType , shiftId, note , customerId ,r.isHasDiscount,r.invoiceDelivered, c.name,c.address,c.phoneNumber from ${TableConstant.receiptTable} as r left join ${TableConstant.customersTable} as c on r.customerId = c.id where r.id=(select MAX(id) from ${TableConstant.receiptTable} $whereQuery)";
      final response = await ref.read(posDbProvider).database.rawQuery(query);
      if (response.isNotEmpty) {
        ReceiptModel receiptModel = ReceiptModel.fromJson(response[0]);
        return Right(receiptModel);
      } else {
        return left(FailureModel("No invoices yet"));
      }
    } catch (e) {
      debugPrint("error $e");
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<List<ReceiptModel>> fetchReceiptsByCustomerId({
    required int customerId,
    required ReceiptStatus status,
  }) async {
    try {
      String query =
          "select r.id , receiptDate , foreignReceiptPrice , localReceiptPrice , userId , dolarRate , paymentType , shiftId, transactionType ,expenseId,r.isTransactionInPrimary  , customerId ,r.isHasDiscount,r.invoiceDelivered,r.withDrawFromCash ,r.isPaid,r.remainingAmount from ${TableConstant.receiptTable} as r  where r.customerId=$customerId";

      if (status == ReceiptStatus.paid) {
        query += " AND r.isPaid = 1";
      } else if (status == ReceiptStatus.pending) {
        query += " AND r.isPaid = 0";
      }

      query += " order by id desc";

      final response = await ref.read(posDbProvider).database.rawQuery(query);
      List<ReceiptModel> receipts = List.from(
        (response).map((e) => ReceiptModel.fromJson(e)),
      );
      return right(receipts);
    } catch (e) {
      print(e.toString());
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<Map<String, double>> fetchRevenueAndProfitByCustomer({
    required int customerId,
  }) async {
    try {
      double totalRevenue = 0;
      double totalProfit = 0;
      final revenuResult = await ref
          .read(posDbProvider)
          .database
          .rawQuery(
            "select Sum(foreignReceiptPrice) as totalRevenue from ${TableConstant.receiptTable} as r  where r.customerId=$customerId",
          );
      if (revenuResult.isNotEmpty) {
        totalRevenue =
            (revenuResult.first['totalRevenue'] as num?)?.toDouble() ?? 0.0;
      }
      final profitResult = await ref
          .read(posDbProvider)
          .database
          .rawQuery(
            "SELECT SUM((dr.sellingPrice - dr.costPrice) * qty) as totalProfit FROM ${TableConstant.detailsReceiptTable} as dr join ${TableConstant.receiptTable} as r on r.id=dr.receiptId   where r.customerId=$customerId",
          );

      totalProfit =
          (profitResult.first['totalProfit'] as num?)?.toDouble() ?? 0.0;
      print("total revenue $totalRevenue");
      return right({"revenue": totalRevenue, "profit": totalProfit});
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<List<ReceiptModel>> fetchReceiptsThisYear() async {
    try {
      List<ReceiptModel> receipts = [];
      DateTime currentDate = DateTime.now();

      final response = await ref
          .read(posDbProvider)
          .database
          .query(
            TableConstant.receiptTable,
            where:
                "CAST(SUBSTR(receiptDate, 1, 4) AS integer)=${currentDate.year}",
          );
      receipts = List.from((response).map((e) => ReceiptModel.fromJson(e)));
      return right(receipts);
    } catch (e) {
      debugPrint(e.toString());
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<List<FinancialTransactionModel>>
  fetchFinancialTransactionsThisYear() async {
    try {
      List<FinancialTransactionModel> transactions = [];
      DateTime currentDate = DateTime.now();

      final response = await ref
          .read(posDbProvider)
          .database
          .query(
            TableConstant.financialTransactionTable,
            where:
                "CAST(SUBSTR(transactionDate, 1, 4) AS integer)=${currentDate.year}",
          );
      transactions = List.from(
        (response).map((e) => FinancialTransactionModel.fromMap(e)),
      );
      return right(transactions);
    } catch (e) {
      debugPrint(e.toString());
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<List<DetailsReceipt>> fetchDetailsReceiptsThisYear() async {
    try {
      List<DetailsReceipt> detailsReceipts = [];
      DateTime currentDate = DateTime.now();
      final query =
          """
  SELECT p.name as productName, p.id as productId, dr.id, dr.receiptId, dr.qty, dr.originalSellingPrice, dr.sellingPrice, dr.costPrice, dr.isRefunded, dr.refundReason, dr.refundDate, dr.discount, p.isTracked 
  FROM ${TableConstant.productTable} AS p 
  JOIN ${TableConstant.detailsReceiptTable} AS dr ON p.id = dr.productId 
  WHERE dr.receiptId IN (SELECT id FROM ${TableConstant.receiptTable} WHERE  CAST(SUBSTR(receiptDate, 1, 4) AS integer)=${currentDate.year})
""";

      final response = await ref.read(posDbProvider).database.rawQuery(query);
      detailsReceipts = List.from(
        (response).map((e) => DetailsReceipt.fromJson(e)),
      );
      return right(detailsReceipts);
    } catch (e) {
      print(e.toString());
      return left(FailureModel(e.toString()));
    }
  }

  @override
  Future<List<SalesByUserModel>> fetchSalesByUserAndType({
    DashboardFilterEnum? view,
  }) async {
    try {
      DateTime currentDate = DateTime.now();
      List<SalesByUserModel> salesByUsers = [];

      // Build WHERE condition using helper
      final conditions = _buildDateFilterConditions(
        view,
        currentDate,
        'transactionDate',
      );
      String dateCondition = conditions['dateCondition']!;

      String query =
          """
        SELECT 
          u.id as userId,
          u.name as userName,
          SUM(CASE 
            WHEN r.transactionType = '${TransactionType.salePayment.name}' THEN r.primaryAmount
            WHEN r.transactionType = '${TransactionType.refund.name}' THEN -r.primaryAmount
            ELSE 0
          END) as totalAmount
        FROM ${TableConstant.financialTransactionTable} as r 
        JOIN ${TableConstant.userTable} as u ON r.userId = u.id
        WHERE $dateCondition
          AND r.paymentType = 'cash'
          AND (r.transactionType = '${TransactionType.salePayment.name}' OR r.transactionType = '${TransactionType.refund.name}')
        GROUP BY u.id, u.name
        ORDER BY totalAmount DESC
      """;

      final response = await ref.read(posDbProvider).database.rawQuery(query);

      salesByUsers = response.map((row) {
        return SalesByUserModel(
          userName: row['userName'].toString(),
          amount: double.parse(row['totalAmount'].toString()),
        );
      }).toList();

      return salesByUsers;
    } catch (e) {
      debugPrint(e.toString());
      return [];
    }
  }

  @override
  Future<List<CustomersCountByViewModel>> fetchNbOfCustomersByViewHourly({
    DashboardFilterEnum? view,
  }) async {
    DateTime currentDate = DateTime.now();
    List<CustomersCountByViewModel> hourlyReceipts = [];
    String query =
        "select sum(nbOfCustomers) as nbOfCustomers , receiptDate from ${TableConstant.receiptTable} ";

    if (view != null) {
      switch (view) {
        case DashboardFilterEnum.lastYear:
          query +=
              " where CAST(SUBSTR(receiptDate, 1, 4) AS integer)=${currentDate.year - 1}";
          break;
        case DashboardFilterEnum.yesterday:
          DateTime yesterday = currentDate.subtract(const Duration(days: 1));
          query +=
              " where CAST(SUBSTR(receiptDate, 9, 11) AS integer)=${yesterday.day} and CAST(SUBSTR(receiptDate, 6, 8) AS integer)=${yesterday.month} and CAST(SUBSTR(receiptDate, 1, 4) AS integer)=${yesterday.year}";
          break;
        case DashboardFilterEnum.today:
          query +=
              " where CAST(SUBSTR(receiptDate, 9, 11) AS integer)=${currentDate.day} and CAST(SUBSTR(receiptDate, 6, 8) AS integer)=${currentDate.month} and CAST(SUBSTR(receiptDate, 1, 4) AS integer)=${currentDate.year}";
          break;
        case DashboardFilterEnum.thisWeek:
          String startDate =
              jiffy_library.Jiffy.parse(currentDate.toString().split(' ').first)
                  .startOf(jiffy_library.Unit.week)
                  .dateTime
                  .toString()
                  .split(' ')
                  .first;

          String endDate = jiffy_library.Jiffy.parse(
            currentDate.toString().split(' ').first,
          ).endOf(jiffy_library.Unit.week).dateTime.toString().split(' ').first;
          query +=
              " where receiptDate>='$startDate' and receiptDate<='$endDate'";

          break;
        case DashboardFilterEnum.lastMonth:
          int currentYear = currentDate.month == 1
              ? currentDate.year - 1
              : currentDate.year;
          int currentMonth = currentDate.month == 1
              ? 12
              : currentDate.month - 1;
          query +=
              "  where CAST(SUBSTR(receiptDate, 1, 4) AS integer)=$currentYear and CAST(SUBSTR(receiptDate, 6, 8) AS integer)=$currentMonth";
          break;
        case DashboardFilterEnum.thisMonth:
          query +=
              "  where CAST(SUBSTR(receiptDate, 1, 4) AS integer)=${currentDate.year} and CAST(SUBSTR(receiptDate, 6, 8) AS integer)=${currentDate.month}";
          break;
        case DashboardFilterEnum.thisYear:
          query +=
              " where CAST(SUBSTR(receiptDate, 1, 4) AS integer)=${currentDate.year}";
          break;
      }
    } else {
      // ! get current day if view null
      query +=
          " where CAST(SUBSTR(receiptDate, 9, 11) AS integer)=${currentDate.day} and CAST(SUBSTR(receiptDate, 6, 8) AS integer)=${currentDate.month} and CAST(SUBSTR(receiptDate, 1, 4) AS integer)=${currentDate.year}";
    }
    query +=
        " and paymentType='cash' and transactionType ='${TransactionType.salePayment.name}'";

    query += "  group by receiptDate order by receiptDate";
    final result = await ref.read(posDbProvider).database.rawQuery(query);
    // Initialize a map for all 24 hours with 0 count
    final hourCounts = <String, int>{};
    for (int i = 0; i < 24; i++) {
      hourCounts['${i.toString().padLeft(2, '0')}:00'] = 0;
    }

    // Count customers by hour
    int nbOfCustomers = 0;
    for (final receipt in result) {
      try {
        nbOfCustomers = int.tryParse(receipt["nbOfCustomers"].toString()) ?? 0;
        final receiptTime = DateTime.parse(receipt['receiptDate'] as String);
        final hour = receiptTime.hour.toString().padLeft(2, '0');
        final hourKey = '$hour:00';

        hourCounts[hourKey] = (hourCounts[hourKey] ?? 0) + nbOfCustomers;
      } catch (e) {
        print('Error parsing date: ${receipt['receiptDate']}');
      }
    }

    hourlyReceipts = hourCounts.entries
        .where(
          (entry) => entry.value > 0,
        ) // Filter out hours with zero receipts
        .map((entry) {
          final currentTime = DateTime.parse('1970-01-01 ${entry.key}');
          final formatedTime = currentTime.toAmPmFormat();
          return CustomersCountByViewModel(formatedTime, entry.value);
        })
        .toList();

    // Sort by hour
    hourlyReceipts.sort((a, b) => a.day.compareTo(b.day));

    return hourlyReceipts;
  }

  //MARK: toggle pay receipt
  @override
  FutureEitherVoid togglePayReceipt(ReceiptModel receipt, bool value) async {
    try {
      String remainingQuery = value ? ", remainingAmount=0.0" : "";

      final response = await ref
          .read(posDbProvider)
          .database
          .rawUpdate(
            "update ${TableConstant.receiptTable} set isPaid=${value ? 1 : 0} $remainingQuery   where id=${receipt.id}",
          );

      final receiptDate = DateTime.parse(receipt.receiptDate);
      if (receiptDate.isToday()) {
        receipt.transactionType = TransactionType.salePayment;
      } else {
        receipt.transactionType = TransactionType.pendingPayment;
      }
      receipt.receiptDate = DateTime.now().toString();
      receipt.note = "Payment for Pending Receipt number #${receipt.id}";
      if (receipt.customerId != null) {
        receipt.foreignReceiptPrice = receipt.remainingAmount;
      }
      ref
          .read(financialTransactionProviderRepository)
          .addFinancialTransaction(
            FinancialTransactionModel.fromReceipt(receipt),
          );
      refreshNotifications();
      return right(null);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<Map<String, int>> fetchDeliveryReceiptsCountByType({
    DashboardFilterEnum? view,
  }) async {
    DateTime currentDate = DateTime.now();
    String whereClause = "";

    if (view != null) {
      switch (view) {
        case DashboardFilterEnum.lastYear:
          whereClause =
              "CAST(SUBSTR(receiptDate, 1, 4) AS integer)=${currentDate.year - 1}";
          break;
        case DashboardFilterEnum.yesterday:
          DateTime yesterday = currentDate.subtract(const Duration(days: 1));
          whereClause =
              "CAST(SUBSTR(receiptDate, 9, 11) AS integer)=${yesterday.day} AND CAST(SUBSTR(receiptDate, 6, 8) AS integer)=${yesterday.month} AND CAST(SUBSTR(receiptDate, 1, 4) AS integer)=${yesterday.year}";
          break;
        case DashboardFilterEnum.today:
          whereClause =
              "CAST(SUBSTR(receiptDate, 9, 11) AS integer)=${currentDate.day} AND CAST(SUBSTR(receiptDate, 6, 8) AS integer)=${currentDate.month} AND CAST(SUBSTR(receiptDate, 1, 4) AS integer)=${currentDate.year}";
          break;
        case DashboardFilterEnum.thisWeek:
          String startDate =
              jiffy_library.Jiffy.parse(currentDate.toString().split(' ').first)
                  .startOf(jiffy_library.Unit.week)
                  .dateTime
                  .toString()
                  .split(' ')
                  .first;
          String endDate = jiffy_library.Jiffy.parse(
            currentDate.toString().split(' ').first,
          ).endOf(jiffy_library.Unit.week).dateTime.toString().split(' ').first;
          whereClause = "receiptDate>='$startDate' AND receiptDate<='$endDate'";
          break;
        case DashboardFilterEnum.lastMonth:
          int currentYear = currentDate.month == 1
              ? currentDate.year - 1
              : currentDate.year;
          int currentMonth = currentDate.month == 1
              ? 12
              : currentDate.month - 1;
          whereClause =
              "CAST(SUBSTR(receiptDate, 1, 4) AS integer)=$currentYear AND CAST(SUBSTR(receiptDate, 6, 8) AS integer)=$currentMonth";
          break;
        case DashboardFilterEnum.thisMonth:
          whereClause =
              "CAST(SUBSTR(receiptDate, 1, 4) AS integer)=${currentDate.year} AND CAST(SUBSTR(receiptDate, 6, 8) AS integer)=${currentDate.month}";
          break;
        case DashboardFilterEnum.thisYear:
          whereClause =
              "CAST(SUBSTR(receiptDate, 1, 4) AS integer)=${currentDate.year}";
          break;
      }
    } else {
      whereClause =
          "CAST(SUBSTR(receiptDate, 9, 11) AS integer)=${currentDate.day} AND CAST(SUBSTR(receiptDate, 6, 8) AS integer)=${currentDate.month} AND CAST(SUBSTR(receiptDate, 1, 4) AS integer)=${currentDate.year}";
    }

    String query =
        """
    SELECT 
      SUM(CASE WHEN isPaid=1 THEN 1 ELSE 0 END) as paid,
      SUM(CASE WHEN isPaid=0 THEN 1 ELSE 0 END) as pending
    FROM ${TableConstant.receiptTable}
    WHERE $whereClause
      AND paymentType='cash' AND transactionType IS NULL
  """;

    final response = await ref.read(posDbProvider).database.rawQuery(query);
    int paid = 0;
    int pending = 0;
    if (response.isNotEmpty) {
      paid = int.tryParse(response.first["paid"].toString()) ?? 0;
      pending = int.tryParse(response.first["pending"].toString()) ?? 0;
    }
    return right({"paid": paid, "pending": pending});
  }

  @override
  FutureEitherVoid payRemainingAmount({
    required ReceiptModel receipt,
    required double value,
  }) async {
    try {
      var updateFieldsQuery = "";

      if (receipt.remainingAmount! <= value) {
        updateFieldsQuery = "isPaid =1 , remainingAmount=0.0";
      } else {
        final newRemaining = receipt.remainingAmount.validateDouble() - value;
        updateFieldsQuery = "remainingAmount=$newRemaining";
      }

      final response = await ref
          .read(posDbProvider)
          .database
          .rawUpdate(
            "update ${TableConstant.receiptTable} set $updateFieldsQuery  where id=${receipt.id}",
          );

      final receiptDate = DateTime.parse(receipt.receiptDate);
      if (receiptDate.isToday()) {
        receipt.transactionType = TransactionType.salePayment;
      } else {
        receipt.transactionType = TransactionType.pendingPayment;
      }
      receipt.receiptDate = DateTime.now().toString();

      receipt.note = "Payment for Pending Receipt number #${receipt.id}";
      FinancialTransactionModel transactionModel =
          FinancialTransactionModel.fromReceipt(receipt);
      transactionModel.primaryAmount = value;
      ref
          .read(financialTransactionProviderRepository)
          .addFinancialTransaction(transactionModel);
      refreshNotifications();
      return right(null);
    } catch (e) {
      print(e.toString());
      return left(FailureModel(e.toString()));
    }
  }

  //MARK: pay all
  @override
  FutureEitherVoid payAllReceiptsByCustomerId(
    CustomerModel customer,
    double amountToPay,
  ) async {
    try {
      final receipts = await ref
          .read(posDbProvider)
          .database
          .rawQuery(
            "SELECT * from ${TableConstant.receiptTable} WHERE customerId=${customer.id} AND isPaid=0 AND remainingAmount>0",
          );
      // Lists to track today's and old receipts
      List<int> todayReceipts = [];
      List<int> oldReceipts = [];
      double todayAmount = 0.0;
      double oldAmount = 0.0;
      // Split receipts into today's and older receipts
      for (var receipt in receipts) {
        final receiptDate = DateTime.parse(receipt['receiptDate'].toString());
        if (receiptDate.isToday()) {
          todayReceipts.add(int.tryParse(receipt['id'].toString()) ?? 0);
          todayAmount +=
              double.tryParse(receipt['remainingAmount'].toString()) ??
              0; // Sum for today's receipts
        } else {
          oldReceipts.add(int.tryParse(receipt['id'].toString()) ?? 0);
          oldAmount +=
              double.tryParse(receipt['remainingAmount'].toString()) ??
              0; // Sum for today's receipts
        }
      }

      final response = await ref
          .read(posDbProvider)
          .database
          .rawUpdate(
            "update ${TableConstant.receiptTable} set isPaid =1 , remainingAmount=0.0  where customerId=${customer.id}",
          );

      // Create transaction for today's receipts (salePayment)
      if (todayReceipts.isNotEmpty) {
        FinancialTransactionModel transaction = FinancialTransactionModel(
          transactionDate: DateTime.now().toString(),
          primaryAmount: todayAmount,
          dollarRate: ref.read(saleControllerProvider).dolarRate,
          secondaryAmount: 0,
          isTransactionInPrimary: true,
          paymentType: PaymentType.cash,
          flow: TransactionFlow.IN,
          transactionType: TransactionType.salePayment, // For today's receipts
          receiptId: null,
          fromCash: null,
          expenseId: null,
          note: "",
          customerId: customer.id,
          shiftId: ref.read(currentShiftProvider).id!,
          userId: ref.read(currentUserProvider)?.id ?? 0,
        );
        await ref
            .read(financialTransactionProviderRepository)
            .addFinancialTransaction(transaction);
      }

      // Create transaction for old receipts (pendingPayment)
      if (oldReceipts.isNotEmpty) {
        FinancialTransactionModel transaction = FinancialTransactionModel(
          transactionDate: DateTime.now().toString(),
          primaryAmount: oldAmount,
          dollarRate: ref.read(saleControllerProvider).dolarRate,
          secondaryAmount: 0,
          isTransactionInPrimary: true,
          paymentType: PaymentType.cash,
          flow: TransactionFlow.IN,
          transactionType: TransactionType.pendingPayment, // For older receipts
          receiptId: null,
          fromCash: null,
          expenseId: null,
          note:
              "Payment for Pending Receipts(${oldReceipts.join(',')}) for ${customer.name} ${customer.phoneNumber ?? ''}",
          customerId: customer.id,
          shiftId: ref.read(currentShiftProvider).id!,
          userId: ref.read(currentUserProvider)?.id ?? 0,
        );
        await ref
            .read(financialTransactionProviderRepository)
            .addFinancialTransaction(transaction);
      }

      refreshNotifications();

      return right(null);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<List<NotificationModel>>
  fetchPendingReceiptsNotifications() async {
    try {
      // Query to fetch customers with pending receipts (isPaid = 0 and remainingAmount > 0)
      final response = await ref.read(posDbProvider).database.rawQuery('''
      SELECT r.customerId, c.name as name,c.id , SUM(r.remainingAmount) as totalPending
      FROM ${TableConstant.receiptTable} r
      JOIN ${TableConstant.customersTable} c ON r.customerId = c.id
      WHERE r.isPaid = 0 AND r.remainingAmount > 0
      GROUP BY r.customerId
    ''');

      List<NotificationModel> pendingNotifications = [];

      // Iterate over the response to create notifications
      for (var row in response) {
        int customerId = int.tryParse(row['customerId'].toString()) ?? 0;
        String customerName = row['name'].toString();
        double totalPending =
            double.tryParse(row['totalPending'].toString()) ?? 0.0;

        // Create the title, subtitle, and qty for the notification
        String title = 'Customer: $customerName';
        String subTitle =
            'You have pending amounts of ${totalPending.formatDouble()} for this customer.';

        // Create a NotificationModel and add it to the list
        NotificationModel notification = NotificationModel(
          title: title,
          subTitle: subTitle,
          qty: totalPending, // Use the total pending amount as qty
          id: customerId, // Use the customer ID
          customerModel: CustomerModel(id: customerId, name: customerName),
        );

        pendingNotifications.add(notification);
      }

      return right(pendingNotifications);
    } catch (e) {
      print(e.toString());
      return left(FailureModel(e.toString()));
    }
  }

  // Helper method to build date conditions and grouping for queries
  Map<String, String> _buildDateFilterConditions(
    DashboardFilterEnum? view,
    DateTime currentDate,
    String dateFieldName,
  ) {
    String dateCondition = '';
    String groupBy = '';
    String periodFormat = '';

    if (view != null) {
      switch (view) {
        case DashboardFilterEnum.lastYear:
          dateCondition =
              "CAST(SUBSTR($dateFieldName, 1, 4) AS integer) = ${currentDate.year - 1}";
          groupBy = "SUBSTR($dateFieldName, 6, 2)"; // Group by month
          periodFormat = "SUBSTR($dateFieldName, 6, 2)"; // Return month number
          break;

        case DashboardFilterEnum.yesterday:
          DateTime yesterday = currentDate.subtract(const Duration(days: 1));
          dateCondition =
              "CAST(SUBSTR($dateFieldName, 9, 2) AS integer) = ${yesterday.day} AND "
              "CAST(SUBSTR($dateFieldName, 6, 2) AS integer) = ${yesterday.month} AND "
              "CAST(SUBSTR($dateFieldName, 1, 4) AS integer) = ${yesterday.year}";
          groupBy = "SUBSTR($dateFieldName, 9, 2)"; // Group by day
          periodFormat = "SUBSTR($dateFieldName, 9, 2)"; // Return day number
          break;

        case DashboardFilterEnum.today:
          dateCondition =
              "CAST(SUBSTR($dateFieldName, 9, 2) AS integer) = ${currentDate.day} AND "
              "CAST(SUBSTR($dateFieldName, 6, 2) AS integer) = ${currentDate.month} AND "
              "CAST(SUBSTR($dateFieldName, 1, 4) AS integer) = ${currentDate.year}";
          groupBy = "SUBSTR($dateFieldName, 9, 2)"; // Group by day
          periodFormat = "SUBSTR($dateFieldName, 9, 2)"; // Return day number
          break;

        case DashboardFilterEnum.thisWeek:
          String startDate = jiffy_library.Jiffy.parseFromDateTime(currentDate)
              .startOf(jiffy_library.Unit.week)
              .dateTime
              .toString()
              .split(' ')
              .first;
          String endDate = jiffy_library.Jiffy.parseFromDateTime(
            currentDate,
          ).endOf(jiffy_library.Unit.week).dateTime.toString().split(' ').first;
          dateCondition =
              "SUBSTR($dateFieldName, 1, 10) >= '$startDate' AND SUBSTR($dateFieldName, 1, 10) <= '$endDate'";
          groupBy = "SUBSTR($dateFieldName, 1, 10)"; // Group by full date
          periodFormat = "SUBSTR($dateFieldName, 9, 2)"; // Return day number
          break;

        case DashboardFilterEnum.lastMonth:
          int currentYear = currentDate.month == 1
              ? currentDate.year - 1
              : currentDate.year;
          int currentMonth = currentDate.month == 1
              ? 12
              : currentDate.month - 1;
          dateCondition =
              "CAST(SUBSTR($dateFieldName, 1, 4) AS integer) = $currentYear AND "
              "CAST(SUBSTR($dateFieldName, 6, 2) AS integer) = $currentMonth";
          groupBy = "SUBSTR($dateFieldName, 1, 10)"; // Group by full date
          periodFormat = "SUBSTR($dateFieldName, 9, 2)"; // Return day number
          break;

        case DashboardFilterEnum.thisMonth:
          dateCondition =
              "CAST(SUBSTR($dateFieldName, 6, 2) AS integer) = ${currentDate.month} AND "
              "CAST(SUBSTR($dateFieldName, 1, 4) AS integer) = ${currentDate.year}";
          groupBy = "SUBSTR($dateFieldName, 1, 10)"; // Group by full date
          periodFormat = "SUBSTR($dateFieldName, 9, 2)"; // Return day number
          break;

        case DashboardFilterEnum.thisYear:
          dateCondition =
              "CAST(SUBSTR($dateFieldName, 1, 4) AS integer) = ${currentDate.year}";
          groupBy = "SUBSTR($dateFieldName, 6, 2)"; // Group by month
          periodFormat = "SUBSTR($dateFieldName, 6, 2)"; // Return month number
          break;
      }
    } else {
      // Default to current day if view is null
      dateCondition =
          "CAST(SUBSTR($dateFieldName, 9, 2) AS integer) = ${currentDate.day} AND "
          "CAST(SUBSTR($dateFieldName, 6, 2) AS integer) = ${currentDate.month} AND "
          "CAST(SUBSTR($dateFieldName, 1, 4) AS integer) = ${currentDate.year}";
      groupBy = "SUBSTR($dateFieldName, 9, 2)"; // Group by day
      periodFormat = "SUBSTR($dateFieldName, 9, 2)"; // Return day number
    }

    return {
      'dateCondition': dateCondition,
      'groupBy': groupBy,
      'periodFormat': periodFormat,
    };
  }

  // Helper method to format period labels (day or month names)
  String _formatPeriodLabel(String period, DashboardFilterEnum? view) {
    try {
      int periodNum = int.parse(period);

      // For yearly view, return month names
      if (view == DashboardFilterEnum.thisYear ||
          view == DashboardFilterEnum.lastYear) {
        const monthNames = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
        return monthNames[periodNum - 1];
      }

      // For all other views (daily), return day number
      return period;
    } catch (e) {
      return period;
    }
  }

  @override
  Future<List<RevenueVsPurchasesVsExpensesModel>> fetchRevenueVsPurchases({
    DashboardFilterEnum? view,
  }) async {
    try {
      final isWorkWithIngredients = ref
          .read(mainControllerProvider)
          .isWorkWithIngredients;
      DateTime currentDate = DateTime.now();
      // Build date conditions for revenue query (uses transactionDate)
      final revenueConditions = _buildDateFilterConditions(
        view,
        currentDate,
        'transactionDate',
      );

      // Fetch Revenue (salePayment - refunds)
      String revenueQuery =
          """
        SELECT 
          ${revenueConditions['periodFormat']} as period,
          COALESCE(SUM(CASE 
            WHEN transactionType = 'salePayment' THEN primaryAmount
            WHEN transactionType = 'refund' THEN -primaryAmount
            ELSE 0
          END), 0.0) as revenue
        FROM ${TableConstant.financialTransactionTable}
        WHERE ${revenueConditions['dateCondition']}
          AND (transactionType = 'salePayment' OR transactionType = 'refund')
        GROUP BY ${revenueConditions['groupBy']}
        ORDER BY period
      """;

      final revenueResult = await ref
          .read(posDbProvider)
          .database
          .rawQuery(revenueQuery);

      // Fetch Expenses (withdrawals)
      String expensesQuery =
          """
        SELECT 
          ${revenueConditions['periodFormat']} as period,
          COALESCE(SUM(
            CASE 
              WHEN isTransactionInPrimary = 1 THEN primaryAmount
              ELSE secondaryAmount / CASE WHEN dollarRate = 0 THEN 1 ELSE dollarRate END
            END
          ), 0.0) as expenses
        FROM ${TableConstant.financialTransactionTable}
        WHERE ${revenueConditions['dateCondition']}
          AND transactionType = '${TransactionType.withdraw.name}'
        GROUP BY ${revenueConditions['groupBy']}
        ORDER BY period
      """;

      final expensesResult = await ref
          .read(posDbProvider)
          .database
          .rawQuery(expensesQuery);

      // Fetch Purchases based on isWorkWithIngredients
      String purchasesQuery;
      if (isWorkWithIngredients) {
        // Build date conditions for restaurant stock (uses transactionDate)
        final stockConditions = _buildDateFilterConditions(
          view,
          currentDate,
          'transactionDate',
        );

        purchasesQuery =
            """
          SELECT 
            ${stockConditions['periodFormat']} as period,
            COALESCE(SUM(transactionQty * pricePerUnit), 0.0) as purchases
          FROM ${TableConstant.restaurantStockTransactionTable}
          WHERE ${stockConditions['dateCondition']}
            AND transactionType = 'stockIn'
          GROUP BY ${stockConditions['groupBy']}
          ORDER BY period
        """;
      } else {
        // Build date conditions for invoices (uses receiptDate)
        final invoiceConditions = _buildDateFilterConditions(
          view,
          currentDate,
          'receiptDate',
        );

        purchasesQuery =
            """
          SELECT 
            ${invoiceConditions['periodFormat']} as period,
            COALESCE(SUM(foreignPrice), 0.0) as purchases
          FROM ${TableConstant.invoices}
          WHERE ${invoiceConditions['dateCondition']}
          GROUP BY ${invoiceConditions['groupBy']}
          ORDER BY period
        """;
      }

      final purchasesResult = await ref
          .read(posDbProvider)
          .database
          .rawQuery(purchasesQuery);

      // Convert results to maps for easy lookup
      Map<String, double> revenueMap = {};
      for (var row in revenueResult) {
        String period = row['period'].toString();
        revenueMap[period] = (row['revenue'] ?? 0.0) as double;
      }

      Map<String, double> expensesMap = {};
      for (var row in expensesResult) {
        String period = row['period'].toString();
        expensesMap[period] = (row['expenses'] ?? 0.0) as double;
      }

      Map<String, double> purchasesMap = {};
      for (var row in purchasesResult) {
        String period = row['period'].toString();
        purchasesMap[period] = (row['purchases'] ?? 0.0) as double;
      }

      // Combine all periods
      Set<String> allPeriods = {
        ...revenueMap.keys,
        ...purchasesMap.keys,
        ...expensesMap.keys,
      };
      List<String> sortedPeriods = allPeriods.toList()..sort();

      // Create result list with formatted labels and values
      List<RevenueVsPurchasesVsExpensesModel> result = [];
      for (String period in sortedPeriods) {
        String formattedPeriod = _formatPeriodLabel(period, view);
        double revenue = (revenueMap[period] ?? 0.0).formatDouble();
        double purchases = (purchasesMap[period] ?? 0.0).formatDouble();
        double expenses = (expensesMap[period] ?? 0.0).formatDouble();

        result.add(
          RevenueVsPurchasesVsExpensesModel(
            period: formattedPeriod,
            revenue: revenue,
            purchases: purchases,
            expenses: expenses,
          ),
        );
      }

      return result;
    } catch (e) {
      print('Error fetching revenue vs purchases: $e');
      return [];
    }
  }
}
