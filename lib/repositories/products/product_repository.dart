import "package:collection/collection.dart";
import 'package:desktoppossystem/models/expense_model.dart';
import 'package:desktoppossystem/models/failure_model.dart';
import 'package:desktoppossystem/models/invoice_details_model.dart';
import 'package:desktoppossystem/models/notification_model.dart';
import 'package:desktoppossystem/models/product_model.dart';
import 'package:desktoppossystem/models/reports/product_history_model.dart';
import 'package:desktoppossystem/models/reports/sales_product_model.dart';
import 'package:desktoppossystem/models/reports/total_cost_price_model.dart';
import 'package:desktoppossystem/models/tracked_related_product.dart';
import 'package:desktoppossystem/repositories/products/iproduct_repository.dart';
import 'package:desktoppossystem/repositories/restaurant_stock/restaurant_stock_repository.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/shared/constances/app_endpoint.dart';
import 'package:desktoppossystem/shared/services/dependency_injection.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:desktoppossystem/shared/utils/type_def.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:jiffy/jiffy.dart' as JIFFY_LIBRARY;
import 'package:sqflite/sqflite.dart';

import '../../shared/constances/table_constant.dart';

final productProviderRepository = Provider((ref) {
  return ProductRepository(ref: ref);
});

class ProductRepository extends IProductRepository {
  final Ref ref;
  ProductRepository({required this.ref});
  @override
  FutureEither<List<ProductModel>> getAllProducts({
    int? limit,
    int? offset,
    int? categoryId,
    bool? isStock,
    bool? isDeleted,
  }) async {
    try {
      final response = await ref
          .read(ultraPosDioProvider)
          .getData(
            endPoint: "${AppEndpoint.products}/fetch",
            query: {
              if (limit != null) 'limit': limit.toString(),
              if (offset != null) 'offset': offset.toString(),
              if (categoryId != null) 'categoryId': categoryId.toString(),
              if (isStock != null) 'isStock': isStock ? '1' : '0',
              if (isDeleted != null) 'isDeleted': isDeleted ? '1' : '0',
            },
          );
      if (response.data["code"] == 200) {
        List<ProductModel> list = List.from(
          (response.data["data"]["products"] as List).map(
            (e) => ProductModel.fromJson(e),
          ),
        );

        // // ! getting notes
        //   if (isStock != true) {
        //     if (ref.read(mainControllerProvider).isWorkWithIngredients ==
        //         true) {
        //       for (var e in list) {
        //         final ingredientsResponse = await ref
        //             .read(restaurantProviderRepository)
        //             .fetchIngredientsBySandwich(e.id!);
        //         ingredientsResponse.fold<Future>((l) async {}, (r) async {
        //           e.ingredients = r;
        //         });
        //       }
        //     }
        //   }

        return right(list);
      } else {
        return left(FailureModel(response.data["message"] ?? "Unknown error"));
      }
    } catch (e) {
      print(e.toString());
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<List<ProductModel>> getAllStockGroupedByCategory({
    int? categoryId,
  }) async {
    List<ProductModel> list = [];
    try {
      // Always join with category table to get category name
      const joinedTables =
          '${TableConstant.productTable} p '
          'JOIN ${TableConstant.categoryTable} c ON p.categoryId = c.id';

      const columns = 'p.*, c.name as categoryName';

      // Build where clause
      String whereClause = 'p.isTracked = 1 AND p.isActive = 1';
      List<dynamic> whereArgs = [];

      if (categoryId != null) {
        whereClause += ' AND p.categoryId = ?';
        whereArgs.add(categoryId);
      }

      // Execute query
      final response = await ref
          .read(posDbProvider)
          .database
          .query(
            joinedTables,
            columns: columns.split(','),
            where: whereClause,
            whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
            orderBy: "p.categoryId, p.sortOrder, p.id",
          );

      list = List.from((response).map((e) => ProductModel.fromJson(e)));

      return right(list);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<ProductModel> addProduct(
    ProductModel p,
    List<TrackedRelatedProductModel> trackedRelatedProductModel,
  ) async {
    try {
      p.isActive = true;
      var checkProduct = await getProductByBarcode(p.barcode.toString());
      if (checkProduct != null) {
        throw Exception("barcode exist try another one");
      }

      if (p.isWeighted == true) {
        final checkPluProduct = await fetchProductByPlu(p.plu ?? 0);
        if (checkPluProduct != null) {
          throw Exception("Plu exist try another one");
        }
      }

      final insertedId = await ref
          .read(posDbProvider)
          .database
          .insert(TableConstant.productTable, p.toJsonWithoutId());
      ProductModel product = await getProductWithCategoryColor(insertedId);

      for (var element in trackedRelatedProductModel) {
        element.productId = insertedId;
      }
      addRelatedTrackedProductsList(trackedRelatedProductModel);

      return right(product);
    } catch (e) {
      print(e.toString());
      return left(FailureModel(e.toString()));
    }
  }

  Future<ProductModel> getProductWithCategoryColor(int productId) async {
    final data = await ref
        .read(posDbProvider)
        .database
        .rawQuery(
          '''
    SELECT p.*, c.color , c.sort as categorySort 
    FROM ${TableConstant.productTable} p
    JOIN ${TableConstant.categoryTable} c ON p.categoryId = c.id
    WHERE p.id = ?
  ''',
          [productId],
        );

    return ProductModel.fromJson(data.first);
  }

  @override
  FutureEither<ProductModel> updateProduct(
    ProductModel p,
    List<TrackedRelatedProductModel> trackedRelatedProductModel,
  ) async {
    try {
      var checkBarcodeProduct = await getProductByBarcode(p.barcode.toString());

      if (checkBarcodeProduct != null && checkBarcodeProduct.id != p.id) {
        throw Exception("barcode exist try another one");
      }
      if (p.isWeighted == true) {
        final checkPluProduct = await fetchProductByPlu(p.plu ?? 0);
        if (checkPluProduct != null && checkPluProduct.id != p.id) {
          throw Exception("Plu exist try another one");
        }
      }

      final response = await ref
          .read(posDbProvider)
          .database
          .update(
            TableConstant.productTable,
            p.toJsonWithoutId(),
            where: "id =${p.id}",
          );
      await removeRelatedTrackedProductsList(p.id!);

      if (p.isOffer == true) {
        // Handle offer product case
        await addRelatedTrackedProductsList(trackedRelatedProductModel);
      } else {
        // Update offers cost if this is a base product
        await updateOffersCostByBaseProductId(p.id!, p.costPrice ?? 0);
      }
      ProductModel product = await getProductWithCategoryColor(p.id!);

      return right(product);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither deleteProduct(int productId) async {
    try {
      await ref
          .read(posDbProvider)
          .database
          .rawUpdate(
            "update ${TableConstant.productTable} set isActive =0  where id=?",
            [productId],
          )
          .then((value) async {
            // await ref.read(posDbProvider).database.rawDelete(
            //     "delete from ${TableConstant.detailsReceiptTable} where productId=?",
            //     [productId]);
            // remove from tracked if this product is offer
            ref.read(posDbProvider).database.rawDelete(
              "delete from ${TableConstant.trackedProductTable} where productId=?",
              [productId],
            );
          });
      return right(null);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  Future<List<ProductModel>> getMostSellingProductByType({
    DashboardFilterEnum? view,
    int? limit,
    String? date,
    int? shiftId,
    bool? isForReports,
    bool? isForStaff,
  }) async {
    List<ProductModel> list = [];
    String query =
        "select p.name, SUM(dr.qty) as qty  ,  r.receiptDate from ${TableConstant.productTable} as p join ${TableConstant.detailsReceiptTable} as dr on dr.productId = p.id join ${TableConstant.receiptTable} as r on r.id=dr.receiptId";
    DateTime currentDate = date != null ? DateTime.parse(date) : DateTime.now();
    if (view != null) {
      switch (view) {
        case DashboardFilterEnum.lastYear:
          query +=
              " where CAST(SUBSTR(r.receiptDate, 1, 4) AS integer)=${currentDate.year - 1}";

          break;
        case DashboardFilterEnum.yesterday:
          DateTime yesterday = currentDate.subtract(const Duration(days: 1));
          query +=
              " where CAST(SUBSTR(r.receiptDate, 9, 11) AS integer)=${yesterday.day} and CAST(SUBSTR(r.receiptDate, 6, 8) AS integer)=${yesterday.month} and CAST(SUBSTR(r.receiptDate, 1, 4) AS integer)=${yesterday.year}";
          break;
        case DashboardFilterEnum.today:
          query +=
              " where CAST(SUBSTR(r.receiptDate, 9, 11) AS integer)=${currentDate.day} and CAST(SUBSTR(r.receiptDate, 6, 8) AS integer)=${currentDate.month} and CAST(SUBSTR(r.receiptDate, 1, 4) AS integer)=${currentDate.year}";
          break;
        case DashboardFilterEnum.thisWeek:

          //  Setting your preferred locale
          // ! if i am in arabic set en to use the clear date then return it

          String startDate =
              JIFFY_LIBRARY.Jiffy.parseFromDateTime(
                    DateTime.parse(currentDate.toString()),
                  )
                  .startOf(JIFFY_LIBRARY.Unit.week)
                  .dateTime
                  .toString()
                  .split(' ')
                  .first;
          String endDate = JIFFY_LIBRARY.Jiffy.parseFromDateTime(
            DateTime.parse(currentDate.toString()),
          ).endOf(JIFFY_LIBRARY.Unit.week).dateTime.toString().split(' ').first;

          query +=
              " where SUBSTR(r.receiptDate, 1, 10)>='$startDate' and SUBSTR(r.receiptDate, 1, 10)<='$endDate'";

          break;
        case DashboardFilterEnum.lastMonth:
          int currentYear = currentDate.month == 1
              ? currentDate.year - 1
              : currentDate.year;
          int currentMonth = currentDate.month == 1
              ? 12
              : currentDate.month - 1;
          query +=
              "  where CAST(SUBSTR(r.receiptDate, 1, 4) AS integer)=$currentYear and CAST(SUBSTR(r.receiptDate, 6, 8) AS integer)=$currentMonth";
          break;
        case DashboardFilterEnum.thisMonth:
          query +=
              " where CAST(SUBSTR(r.receiptDate, 6, 8) AS integer)=${currentDate.month} and CAST(SUBSTR(r.receiptDate, 1, 4) AS integer)=${currentDate.year}";
          break;
        case DashboardFilterEnum.thisYear:
          query +=
              " where CAST(SUBSTR(r.receiptDate, 1, 4) AS integer)=${currentDate.year}";
          break;
      }
    } else {
      // ! get current day if view null
      if (shiftId != null) {
        query += " where r.shiftId=$shiftId";
      } else {
        query +=
            " where CAST(SUBSTR(r.receiptDate, 9, 11) AS integer)=${currentDate.day} and CAST(SUBSTR(r.receiptDate, 6, 8) AS integer)=${currentDate.month} and CAST(SUBSTR(r.receiptDate, 1, 4) AS integer)=${currentDate.year}";
      }
    }

    if (isForReports == true) {
      query += " and dr.isRefunded=1";
    } else {
      query += " and (dr.isRefunded is NULL or dr.isRefunded <> 1)";
    }
    if (isForStaff == true) {
      query += " and isForStuff=1";
    } else {
      query += " and (isForStuff is NULL or isForStuff <> 1)";
    }

    query += ' group by p.id order by qty desc';
    query += ' limit ${limit ?? 10}';

    await ref
        .read(posDbProvider)
        .database
        .rawQuery(query)
        .then((value) {
          list = List.from(
            (value).map((e) {
              ProductModel p = ProductModel.second();

              p.name = e['name'].toString();
              p.qty = double.tryParse(e['qty'].toString()) ?? 0;

              p.countsAsItem =
                  double.tryParse(e["countsAsItem"].toString()) ?? 0;
              return p;
            }),
          );
        })
        .catchError((e) {
          debugPrint(e.toString());
        });

    return list;
  }

  @override
  Future<List<ProductModel>> getMostProfitableProducts({
    DashboardFilterEnum? view,
    String? date,
  }) async {
    List<ProductModel> list = [];

    // Calculate profit as (sellingPrice - costPrice) * qty for non-refunded items
    String query =
        """
      SELECT 
        p.name, 
        SUM((dr.sellingPrice - dr.costPrice) * dr.qty) as totalProfit,
        SUM(dr.qty) as qty,
        r.receiptDate 
      FROM ${TableConstant.productTable} as p 
      JOIN ${TableConstant.detailsReceiptTable} as dr ON dr.productId = p.id 
      JOIN ${TableConstant.receiptTable} as r ON r.id = dr.receiptId
    """;

    DateTime currentDate = date != null ? DateTime.parse(date) : DateTime.now();

    if (view != null) {
      switch (view) {
        case DashboardFilterEnum.lastYear:
          query +=
              " WHERE CAST(SUBSTR(r.receiptDate, 1, 4) AS integer) = ${currentDate.year - 1}";
          break;

        case DashboardFilterEnum.yesterday:
          DateTime yesterday = currentDate.subtract(const Duration(days: 1));
          query +=
              " WHERE CAST(SUBSTR(r.receiptDate, 9, 11) AS integer) = ${yesterday.day} AND CAST(SUBSTR(r.receiptDate, 6, 8) AS integer) = ${yesterday.month} AND CAST(SUBSTR(r.receiptDate, 1, 4) AS integer) = ${yesterday.year}";
          break;

        case DashboardFilterEnum.today:
          query +=
              " WHERE CAST(SUBSTR(r.receiptDate, 9, 11) AS integer) = ${currentDate.day} AND CAST(SUBSTR(r.receiptDate, 6, 8) AS integer) = ${currentDate.month} AND CAST(SUBSTR(r.receiptDate, 1, 4) AS integer) = ${currentDate.year}";
          break;

        case DashboardFilterEnum.thisWeek:
          String startDate =
              JIFFY_LIBRARY.Jiffy.parseFromDateTime(
                    DateTime.parse(currentDate.toString()),
                  )
                  .startOf(JIFFY_LIBRARY.Unit.week)
                  .dateTime
                  .toString()
                  .split(' ')
                  .first;
          String endDate = JIFFY_LIBRARY.Jiffy.parseFromDateTime(
            DateTime.parse(currentDate.toString()),
          ).endOf(JIFFY_LIBRARY.Unit.week).dateTime.toString().split(' ').first;
          query +=
              " WHERE SUBSTR(r.receiptDate, 1, 10) >= '$startDate' AND SUBSTR(r.receiptDate, 1, 10) <= '$endDate'";
          break;

        case DashboardFilterEnum.lastMonth:
          int currentYear = currentDate.month == 1
              ? currentDate.year - 1
              : currentDate.year;
          int currentMonth = currentDate.month == 1
              ? 12
              : currentDate.month - 1;
          query +=
              " WHERE CAST(SUBSTR(r.receiptDate, 1, 4) AS integer) = $currentYear AND CAST(SUBSTR(r.receiptDate, 6, 8) AS integer) = $currentMonth";
          break;

        case DashboardFilterEnum.thisMonth:
          query +=
              " WHERE CAST(SUBSTR(r.receiptDate, 6, 8) AS integer) = ${currentDate.month} AND CAST(SUBSTR(r.receiptDate, 1, 4) AS integer) = ${currentDate.year}";
          break;

        case DashboardFilterEnum.thisYear:
          query +=
              " WHERE CAST(SUBSTR(r.receiptDate, 1, 4) AS integer) = ${currentDate.year}";
          break;
      }
    } else {
      // Default to current day if view is null
      query +=
          " WHERE CAST(SUBSTR(r.receiptDate, 9, 11) AS integer) = ${currentDate.day} AND CAST(SUBSTR(r.receiptDate, 6, 8) AS integer) = ${currentDate.month} AND CAST(SUBSTR(r.receiptDate, 1, 4) AS integer) = ${currentDate.year}";
    }

    // Filter out refunded items
    query += " AND (dr.isRefunded IS NULL OR dr.isRefunded <> 1)";

    // Group by product and order by total profit descending
    query += " GROUP BY p.id ORDER BY totalProfit DESC LIMIT 15";

    await ref
        .read(posDbProvider)
        .database
        .rawQuery(query)
        .then((value) {
          list = List.from(
            (value).map((e) {
              ProductModel p = ProductModel.second();
              p.name = e['name'].toString();
              // Store the total profit in qty field for chart display
              p.qty = double.tryParse(e['totalProfit'].toString()) ?? 0;
              return p;
            }),
          );
        })
        .catchError((e) {
          debugPrint(e.toString());
        });

    return list;
  }

  // ! expenses
  @override
  FutureEither<List<ExpenseModel>> getExpensesByType({
    DashboardFilterEnum? view,
    int? limit,
    String? date,
    int? shiftId,
  }) async {
    List<ExpenseModel> expenses = [];
    try {
      String query =
          "select ft.*, e.expensePurpose from ${TableConstant.financialTransactionTable} as ft left join ${TableConstant.expensesTable} as e on e.id=ft.expenseId where ft.transactionType='${TransactionType.withdraw.name}'";

      DateTime currentDate = date != null
          ? DateTime.parse(date)
          : DateTime.now();

      if (view != null) {
        switch (view) {
          case DashboardFilterEnum.lastYear:
            query +=
                " and CAST(SUBSTR(ft.transactionDate, 1, 4) AS integer)=${currentDate.year - 1}";
            break;
          case DashboardFilterEnum.yesterday:
            DateTime yesterday = currentDate.subtract(const Duration(days: 1));
            query +=
                " and CAST(SUBSTR(ft.transactionDate, 9, 11) AS integer)=${yesterday.day} and CAST(SUBSTR(ft.transactionDate, 6, 8) AS integer)=${yesterday.month} and CAST(SUBSTR(ft.transactionDate, 1, 4) AS integer)=${yesterday.year}";
            break;
          case DashboardFilterEnum.today:
            query +=
                " and CAST(SUBSTR(ft.transactionDate, 9, 11) AS integer)=${currentDate.day} and CAST(SUBSTR(ft.transactionDate, 6, 8) AS integer)=${currentDate.month} and CAST(SUBSTR(ft.transactionDate, 1, 4) AS integer)=${currentDate.year}";
            break;
          case DashboardFilterEnum.thisWeek:
            String startDate =
                JIFFY_LIBRARY.Jiffy.parseFromDateTime(
                      DateTime.parse(currentDate.toString()),
                    )
                    .startOf(JIFFY_LIBRARY.Unit.week)
                    .dateTime
                    .toString()
                    .split(' ')
                    .first;
            String endDate =
                JIFFY_LIBRARY.Jiffy.parseFromDateTime(
                      DateTime.parse(currentDate.toString()),
                    )
                    .endOf(JIFFY_LIBRARY.Unit.week)
                    .dateTime
                    .toString()
                    .split(' ')
                    .first;

            query +=
                " and SUBSTR(ft.transactionDate, 1, 10)>='$startDate' and SUBSTR(ft.transactionDate, 1, 10)<='$endDate'";
            break;
          case DashboardFilterEnum.lastMonth:
            int currentYear = currentDate.month == 1
                ? currentDate.year - 1
                : currentDate.year;
            int currentMonth = currentDate.month == 1
                ? 12
                : currentDate.month - 1;
            query +=
                " and CAST(SUBSTR(ft.transactionDate, 1, 4) AS integer)=$currentYear and CAST(SUBSTR(ft.transactionDate, 6, 8) AS integer)=$currentMonth";
            break;
          case DashboardFilterEnum.thisMonth:
            query +=
                " and CAST(SUBSTR(ft.transactionDate, 6, 8) AS integer)=${currentDate.month} and CAST(SUBSTR(ft.transactionDate, 1, 4) AS integer)=${currentDate.year}";
            break;
          case DashboardFilterEnum.thisYear:
            query +=
                " and CAST(SUBSTR(ft.transactionDate, 1, 4) AS integer)=${currentDate.year}";
            break;
        }
      } else {
        // Get current day if view null
        if (shiftId != null) {
          query += " and ft.shiftId=$shiftId";
        } else {
          query +=
              " and CAST(SUBSTR(ft.transactionDate, 9, 11) AS integer)=${currentDate.day} and CAST(SUBSTR(ft.transactionDate, 6, 8) AS integer)=${currentDate.month} and CAST(SUBSTR(ft.transactionDate, 1, 4) AS integer)=${currentDate.year}";
        }
      }

      await ref.read(posDbProvider).database.rawQuery(query).then((value) {
        if (value.isNotEmpty) {
          // Group by expense purpose
          var groupedByExpenseType = groupBy(
            value,
            (obj) => obj['expensePurpose'],
          );

          groupedByExpenseType.forEach((key, transactions) {
            double amount = 0;
            String note = key?.toString() ?? 'Unknown';

            for (var transaction in transactions) {
              // Use isTransactionInPrimary to determine which amount to use
              bool isInPrimary = (transaction['isTransactionInPrimary'] == 1);

              if (isInPrimary) {
                // Use primary amount (local currency)
                amount +=
                    double.tryParse(
                      transaction['primaryAmount']?.toString() ?? '0',
                    ) ??
                    0;
              } else {
                double dollarRate =
                    double.tryParse(
                      transaction['dollarRate']?.toString() ?? '1',
                    ) ??
                    1;
                double primaryAmount =
                    double.tryParse(
                      transaction['secondaryAmount']?.toString() ?? '0',
                    ) ??
                    0;
                amount += primaryAmount / (dollarRate == 0 ? 1 : dollarRate);
              }
            }

            ExpenseModel expenseModel = ExpenseModel(
              expensePurpose: note,
              expenseAmount: amount.formatDouble(),
            );
            expenses.add(expenseModel);
          });
        }
      });

      return right(expenses);
    } catch (e) {
      debugPrint("error $e");
      return left(FailureModel(e.toString()));
    }
  }

  // ! if is byname null search by name and barcode
  @override
  Future<List<ProductModel>> searchByNameOrBarcode(
    String query, {
    int? categoryId,
    bool? isTracked,
    bool? isForBarcode,
    bool? isDeleted,
  }) async {
    List<ProductModel> products = [];

    try {
      // Build query parameters
      Map<String, dynamic> queryParams = {'query': query};

      if (categoryId != null) {
        queryParams['categoryId'] = categoryId.toString();
      }

      if (isForBarcode != null) {
        queryParams['isForBarcode'] = isForBarcode.toString();
      }

      if (isTracked != null) {
        queryParams['isTracked'] = isTracked.toString();
      }

      if (isDeleted != null) {
        queryParams['isDeleted'] = isDeleted.toString();
      }

      final response = await ref
          .read(ultraPosDioProvider)
          .getData(
            endPoint: AppEndpoint.searchAdvancedProducts,
            query: queryParams,
          );

      print(response.data);

      if (response.data["code"] == 200) {
        products = List.from(
          (response.data["data"] as List).map((e) => ProductModel.fromJson(e)),
        );

        // // ! getting notes
        // if (ref.read(mainControllerProvider).isShowRestaurantStock == true) {
        //   for (var e in products) {
        //     final ingredientsResponse = await ref
        //         .read(restaurantProviderRepository)
        //         .fetchIngredientsBySandwich(e.id!);
        //     ingredientsResponse.fold<Future>((l) async {}, (r) async {
        //       e.ingredients = r;
        //     });
        //   }
        // }
      } else {
        products = [];
      }
    } catch (error) {
      debugPrint(error.toString());
      throw Exception(error);
    }

    return products;
  }

  @override
  Future<ProductModel?> getProductByBarcode(String? barcode) async {
    ProductModel? productModel;
    if (barcode != null && barcode.toString().trim() == "") return null;

    await ref
        .read(posDbProvider)
        .database
        .query(
          TableConstant.productTable,
          where: "barcode='${barcode!.trim().toUpperCase()}'",
        )
        .then((value) {
          if (value.isNotEmpty) productModel = ProductModel.fromJson(value[0]);
        })
        .catchError((error) {
          debugPrint(error.toString());
          throw Exception(error);
        });
    return productModel;
  }

  @override
  Future<ProductModel?> getProduct(int id) async {
    try {
      final response = await ref
          .read(ultraPosDioProvider)
          .getData(endPoint: "${AppEndpoint.products}/$id");
      if (response.data["code"] == 200) {
        return ProductModel.fromJson(response.data["data"]);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  @override
  FutureEither increasedecreaseProductQty({
    required List<ProductModel> products,
    required bool isForDescrease,
  }) async {
    try {
      Batch batch = ref.read(posDbProvider).database.batch();
      var groupedByProductsId = groupBy(products, (obj) => obj.id);
      groupedByProductsId.forEach((key, value) async {
        // ! total qty for each product in basket
        double totalQty = 0;
        for (var element in value) {
          totalQty += element.qty!;
        }
        if (value[0].isTracked == true) {
          var p = await getProduct(value[0].id!);
          if (p != null) {
            p.qty = isForDescrease ? p.qty! - totalQty : p.qty! + totalQty;

            batch.rawUpdate(
              "update ${TableConstant.productTable} set  qty=${p.qty} where id=$key",
            );
          }
        } else {
          // ! if  not tracked , check if has releatedTracked from stock
          if (!ref.read(mainControllerProvider).isWorkWithIngredients) {
            final trackedRes = await fetchRelatedTrackedByProductId(key!);
            trackedRes.fold((l) => null, (r) async {
              for (var element in r) {
                var p = await getProduct(element.relatedProductId);

                if (p != null) {
                  p.qty = isForDescrease
                      ? p.qty! - (element.qtyFromRelatedProduct * totalQty)
                      : p.qty! + (element.qtyFromRelatedProduct * totalQty);

                  batch.rawUpdate(
                    "update ${TableConstant.productTable} set  qty=${p.qty} where id=${element.relatedProductId}",
                  );
                  batch.commit();
                }
              }
            });
          }
        }
      });

      batch.commit(noResult: true);

      return right(null);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  Future<List<SalesProductModel>> getProfitPerProduct({
    String? date,
    ReportInterval? view,
  }) async {
    List<SalesProductModel> profitlist = [];
    String query =
        "select  p.id ,p.categoryId, p.name,p.barcode, dr.costPrice ,  dr.qty as qty ,dr.originalSellingPrice, dr.sellingPrice as sellingPrice ,dr.isRefunded, r.receiptDate , (SELECT COUNT(*) FROM ${TableConstant.sandwichesIngredientTable} as si WHERE si.productId = p.id) AS isHasIngredients  from ${TableConstant.productTable} as p join ${TableConstant.detailsReceiptTable} as dr on dr.productId = p.id join ${TableConstant.receiptTable} as r on r.id=dr.receiptId ";

    DateTime currentDate = date != null ? DateTime.parse(date) : DateTime.now();

    if (view != null) {
      switch (view) {
        case ReportInterval.daily:
          query +=
              " where CAST(SUBSTR(r.receiptDate, 9, 11) AS integer)=${currentDate.day} and CAST(SUBSTR(r.receiptDate, 6, 8) AS integer)=${currentDate.month} and CAST(SUBSTR(r.receiptDate, 1, 4) AS integer)=${currentDate.year}";

          break;
        case ReportInterval.monthly:
          query +=
              "  where CAST(SUBSTR(r.receiptDate, 6, 8) AS integer)=${currentDate.month} and CAST(SUBSTR(r.receiptDate, 1, 4) AS integer)=${currentDate.year}";
          break;
        case ReportInterval.yearly:
          query +=
              "  where  CAST(SUBSTR(r.receiptDate, 1, 4) AS integer)=${currentDate.year}";
          break;
      }
    } else {
      query +=
          " where CAST(SUBSTR(r.receiptDate, 9, 11) AS integer)=${currentDate.day} and CAST(SUBSTR(r.receiptDate, 6, 8) AS integer)=${currentDate.month} and CAST(SUBSTR(r.receiptDate, 1, 4) AS integer)=${currentDate.year}";
    }

    query += " and(dr.isRefunded is NULL or dr.isRefunded <> 1)";

    await ref.read(posDbProvider).database.rawQuery(query).then((value) {
      //! group by date
      var groupByDate = groupBy(value, (obj) => (obj as dynamic)['id']!);

      groupByDate.forEach((key, value) {
        SalesProductModel salesProductModel = SalesProductModel(
          profit: 0,
          totalCost: 0,
          paidCost: 0,
          qty: 0,
          categoryId: 0,
        );
        if (value.isNotEmpty) {
          salesProductModel.name = value[0]["name"].toString();
          salesProductModel.barcode = value[0]["barcode"] as String? ?? "";
          salesProductModel.id = int.tryParse(value[0]["id"].toString()) ?? 0;
          salesProductModel.categoryId =
              int.tryParse(value[0]["categoryId"].toString()) ?? 0;
          salesProductModel.isHasIngredients =
              (int.tryParse(value[0]["isHasIngredients"].toString()) ?? 0) >= 1
              ? true
              : false;
          for (var element in value) {
            if (double.tryParse(element["sellingPrice"].toString()) != null &&
                double.tryParse(element["costPrice"].toString()) != null) {
              salesProductModel.totalCost +=
                  (double.parse(element["costPrice"].toString()) *
                          double.parse((element["qty"].toString())))
                      .formatDouble();
              salesProductModel.paidCost +=
                  (double.parse(element["sellingPrice"].toString()) *
                          double.parse((element["qty"].toString())))
                      .formatDouble();
              salesProductModel.qty += (double.tryParse(
                element["qty"].toString(),
              )).formatDouble();
            }
          }

          salesProductModel.profit =
              (salesProductModel.paidCost - salesProductModel.totalCost);
        }

        profitlist.add(salesProductModel);
      });
    });
    profitlist.sort((a, b) => b.qty.compareTo(a.qty));

    return profitlist;
  }

  @override
  FutureEither<ProductStatsModel> fetchProductsStats({int? categoryId}) async {
    try {
      final response = await ref
          .read(ultraPosDioProvider)
          .getData(
            endPoint: AppEndpoint.productsStats,
            query: {
              if (categoryId != null) 'categoryId': categoryId.toString(),
            },
          );

      ProductStatsModel totalCostPriceModel = ProductStatsModel.fromMap(
        response.data["data"],
      );

      return Right(totalCostPriceModel);
    } catch (e) {
      debugPrint(e.toString());
      return Left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<List<ProductModel>> getProductsByCategoryId(
    int categoryId, {
    int? offset,
    int? limit,
  }) async {
    List<ProductModel> list = [];
    try {
      final response = await ref
          .read(ultraPosDioProvider)
          .getData(
            endPoint: "${AppEndpoint.productsByCategory}/$categoryId",
            query: {
              if (limit != null) 'limit': limit.toString(),
              if (offset != null) 'offset': offset.toString(),
            },
          );

      if (response.data["code"] == 200) {
        list = List.from(
          (response.data["data"]["products"] as List).map(
            (e) => ProductModel.fromJson(e),
          ),
        );

        // if (ref.read(mainControllerProvider).isShowRestaurantStock == true) {
        //   for (var e in list) {
        //     final ingredientsResponse = await ref
        //         .read(restaurantProviderRepository)
        //         .fetchIngredientsBySandwich(e.id!);
        //     ingredientsResponse.fold<Future>((l) async {}, (r) async {
        //       e.ingredients = r;
        //     });
        //   }
        // }

        return right(list);
      } else {
        return left(FailureModel(response.data["message"] ?? "Unknown error"));
      }
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<List<TrackedRelatedProductModel>> fetchRelatedTrackedByProductId(
    int productId,
  ) async {
    List<TrackedRelatedProductModel> trackedRelatedProducts = [];
    try {
      final db = ref.read(posDbProvider).database;

      // SQL JOIN query to fetch tracked products with their real cost
      final query =
          '''
      SELECT tp.*, p.costPrice , profitRate
      FROM ${TableConstant.trackedProductTable} tp
      JOIN ${TableConstant.productTable} p ON tp.productId = p.id
      WHERE tp.productId = $productId
      ORDER BY tp.id
    ''';

      final result = await db.rawQuery(query);

      trackedRelatedProducts = result
          .map((e) => TrackedRelatedProductModel.fromMap(e))
          .toList();

      return right(trackedRelatedProducts);
    } catch (e) {
      print(e.toString());
      return left(FailureModel(e.toString()));
    }
  }

  FutureEitherVoid updateOffersCostByBaseProductId(
    int productId,
    double cost,
  ) async {
    try {
      final db = ref.read(posDbProvider).database;

      // SQL JOIN query to fetch tracked products with their real cost
      final query =
          '''
      SELECT tp.*, p.costPrice , profitRate
      FROM ${TableConstant.trackedProductTable} tp
      JOIN ${TableConstant.productTable} p ON tp.productId = p.id
      WHERE tp.relatedProductId = $productId
      ORDER BY tp.id
    ''';

      final result = await db.rawQuery(query);

      final list = result
          .map((e) => TrackedRelatedProductModel.fromMap(e))
          .toList();
      if (list.isNotEmpty) {
        // change the cost based on the new avg cost and based on qty in this offer
        for (var item in list) {
          double newCost = (cost * item.qtyFromRelatedProduct).formatDouble();
          print("new cost is $newCost");
          double sellingPrice = ((item.profitRate! * newCost / 100) + newCost)
              .formatDoubleWith6();
          await ref
              .read(posDbProvider)
              .database
              .rawUpdate(
                "update ${TableConstant.productTable} set costPrice =$newCost,price=$sellingPrice ,profitRate =${item.profitRate} where id=${item.productId}",
              );
        }
      }

      return right(null);
    } catch (e) {
      print(e.toString());
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither addRelatedTrackedProductsList(
    List<TrackedRelatedProductModel> list,
  ) async {
    try {
      Batch batch = ref.read(posDbProvider).database.batch();
      for (var p in list) {
        batch.insert(TableConstant.trackedProductTable, p.toMap());
      }
      batch.commit(noResult: true);

      return right([]);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither removeRelatedTrackedProductsList(int productId) async {
    try {
      await ref
          .read(posDbProvider)
          .database
          .rawDelete(
            "delete from ${TableConstant.trackedProductTable} where productId=?",
            [productId],
          )
          .then((value) async {});
      return right(null);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEitherVoid addBulkProducts(List<ProductModel> products) async {
    try {
      final checkIexistRes = await isContainsSameBarcodeInDatabase(products);
      checkIexistRes.fold(
        (l) {
          throw Exception(l.message);
        },
        (r) {
          Batch batch = ref.read(posDbProvider).database.batch();

          for (var product in products) {
            batch.insert(TableConstant.productTable, product.toJsonWithoutId());
          }
          batch.commit();
        },
      );

      return right(null);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  FutureEither<bool> isContainsSameBarcodeInDatabase(
    List<ProductModel> products,
  ) async {
    try {
      await ref
          .read(posDbProvider)
          .database
          .query(
            TableConstant.productTable,
            where:
                "barcode in  (${products.map((e) => "'${e.barcode?.toUpperCase()}'").toList().join(',')})",
          )
          .then((value) {
            if (value.isNotEmpty) {
              throw Exception("There are one or more barcodes already exist");
            }
          });
      return right(true);
    } catch (e) {
      debugPrint(e.toString());
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<List<ProductModel>> searchForAProductOrASandwich(
    String query,
  ) async {
    try {
      List<ProductModel> products = [];
      String q = "";

      List<String> keywords = query.split(" ");
      for (int i = 0; i < keywords.length; i++) {
        q += " (name LIKE '%${keywords[i]}%')";
        if (i < keywords.length - 1) {
          q += " AND";
        }
      }

      q += " and isTracked=0 and isActive=1";
      final response = await ref
          .read(posDbProvider)
          .database
          .query(TableConstant.productTable, where: q);

      if (response.isNotEmpty) {
        products = List.from(response.map((e) => ProductModel.fromJson(e)));
      }
      return right(products);
    } catch (e) {
      debugPrint(e.toString());
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEitherVoid updateProductCost({
    required double cost,
    required int productId,
  }) async {
    try {
      await ref
          .read(posDbProvider)
          .database
          .rawUpdate(
            "update ${TableConstant.productTable} set costPrice='$cost'  where id=$productId",
          );
      return right(null);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<List<ProductModel>> fetchAllSandwichesWithIngredients() async {
    try {
      List<ProductModel> list = [];

      await ref
          .read(posDbProvider)
          .database
          .rawQuery('''
  SELECT p.*, c.sort as categorySort 
  FROM ${TableConstant.productTable} p
  JOIN ${TableConstant.categoryTable} c ON p.categoryId = c.id
  WHERE p.isTracked IS NULL OR p.isTracked <> 1
  ORDER BY c.sort, p.sortOrder
''')
          .then((response) async {
            list = List.from((response).map((e) => ProductModel.fromJson(e)));

            for (var e in list) {
              final ingredientsResponse = await ref
                  .read(restaurantProviderRepository)
                  .fetchIngredientsBySandwich(e.id!);
              await ingredientsResponse.fold<Future>((l) async {}, (r) async {
                e.ingredients = r;
              });
            }
          });

      return right(list);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEitherVoid updateStockByInvoiceDetails(
    PurchaseDetailsModel invoiceDetails,
  ) async {
    try {
      double updatedQty = (invoiceDetails.oldQty! + invoiceDetails.qty!)
          .formatDouble();
      await ref
          .read(posDbProvider)
          .database
          .rawUpdate(
            "update ${TableConstant.productTable} set name='${invoiceDetails.productName}', costPrice =${invoiceDetails.newAverageCost},price=${invoiceDetails.sellingPrice} ,profitRate =${invoiceDetails.profitRate} ,  qty=$updatedQty where id=${invoiceDetails.productId}",
          );

      updateOffersCostByBaseProductId(
        invoiceDetails.productId ?? 0,
        invoiceDetails.newAverageCost ?? 0,
      );

      return right(null);
    } catch (e) {
      print(e.toString());
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<List<ProductModel>> fetchMostSellingProductByCustomer({
    required int customerId,
  }) async {
    try {
      String query =
          "select p.name, SUM(dr.qty) as qty ,sum(dr.qty) ,  r.receiptDate from ${TableConstant.productTable} as p join ${TableConstant.detailsReceiptTable} as dr on dr.productId = p.id join ${TableConstant.receiptTable} as r on r.id=dr.receiptId where r.customerId=$customerId";

      query += ' group by p.id order by qty desc';
      query += ' limit 10';
      List<ProductModel> list = [];

      final response = await ref.read(posDbProvider).database.rawQuery(query);
      list = List.from(
        (response).map((e) {
          ProductModel p = ProductModel.second();

          p.name = e['name'].toString();
          p.qty = double.tryParse(e['qty'].toString()) ?? 0;

          return p;
        }),
      );

      return right(list);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<ProductModel> restoreProduct(int productId) async {
    try {
      await ref.read(posDbProvider).database.rawUpdate(
        "update ${TableConstant.productTable} set isActive =1  where id=?",
        [productId],
      );
      ProductModel? productModel = await getProduct(productId);
      if (productModel == null) {
        return left(FailureModel("Product not found"));
      }
      return right(productModel);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither setAllProductsAsActive() async {
    try {
      await ref
          .read(posDbProvider)
          .database
          .rawUpdate("update ${TableConstant.productTable} set isActive =1");
      return right(null);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<int> fetchProductsCount() async {
    try {
      final response = await ref
          .read(posDbProvider)
          .database
          .rawQuery(
            "select count(*) as count from products where isActive = 1",
          );

      return right(int.tryParse(response[0]["count"].toString()) ?? 0);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<int> fetchMarketNotificationCounts(int nbOfMonths) async {
    try {
      final lowStockresponse = await ref
          .read(posDbProvider)
          .database
          .rawQuery(
            "select count(*) as count from ${TableConstant.productTable} where isTracked =1 and qty is NOT NULL and warningAlert is NOT NULL AND qty<=  CAST(warningAlert AS INTEGER)  and  isActive = 1 and isTracked=1 and enableNotification =1",
          );
      final zeroStockResponse = await ref
          .read(posDbProvider)
          .database
          .rawQuery(
            "select count(*) as count from ${TableConstant.productTable} where qty=0 and  isActive = 1 and  isTracked=1 and enableNotification =1",
          );

      //fetch expired count
      DateTime currentDate = DateTime.now();
      // Add `nbOfMonths` months to the current date
      DateTime targetExpiryDate = currentDate.add(
        Duration(days: 30 * nbOfMonths),
      );

      // Convert targetExpiryDate to string format for SQL query, e.g., 'YYYY-MM-DD'
      String formattedTargetDate =
          '${targetExpiryDate.year}-${targetExpiryDate.month.toString().padLeft(2, '0')}-${targetExpiryDate.day.toString().padLeft(2, '0')}';
      final expiredCount = await ref
          .read(posDbProvider)
          .database
          .rawQuery(
            "select count(*) as count from ${TableConstant.productTable} where  expiryDate IS NOT NULL AND expiryDate != '' and expiryDate <= '$formattedTargetDate' and isActive = 1 and isTracked=1 and enableNotification =1",
          );

      // pending receipts count by customer
      final customerCountResponse = await ref
          .read(posDbProvider)
          .database
          .rawQuery(
            "SELECT COUNT(DISTINCT customerId) as count "
            "FROM ${TableConstant.receiptTable} "
            "WHERE isPaid = 0 AND remainingAmount > 0",
          );

      int totalCount =
          (int.tryParse(lowStockresponse[0]["count"].toString()) ?? 0) +
          (int.tryParse(expiredCount[0]["count"].toString()) ?? 0) +
          (int.tryParse(zeroStockResponse[0]["count"].toString()) ?? 0) +
          (int.tryParse(customerCountResponse[0]["count"].toString()) ?? 0);

      return right(totalCount);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<List<NotificationModel>> fetchMarketLowStockList() async {
    try {
      final response = await ref.read(posDbProvider).database.rawQuery(
        '''SELECT id, name as title, qty, warningAlert 
     FROM ${TableConstant.productTable} 
     WHERE isTracked = 1  
       AND qty IS NOT NULL 
       AND warningAlert IS NOT NULL 
       AND qty <= CAST(warningAlert AS INTEGER) 
       AND isActive = 1 AND enableNotification =1 limit 1000''',
      );

      // Parse the response and create NotificationModel objects
      List<NotificationModel> lowStockNotifications = [];
      for (var product in response) {
        int id = int.tryParse(product['id'].toString()) ?? 0;
        String productName = product['title'].toString();
        double qty = double.tryParse(product['qty'].toString()) ?? 0.0;
        double warningAlert =
            double.tryParse(product['warningAlert'].toString()) ?? 0.0;

        // Create the title, subtitle, and qty for the notification
        String title = productName;
        String subTitle =
            'Stock reached the warning limit of $warningAlert. Current stock is $qty.';

        // Create a NotificationModel and add it to the list
        NotificationModel notification = NotificationModel(
          title: title,
          subTitle: subTitle,
          qty: qty,
          id: id,
        );

        lowStockNotifications.add(notification);
      }
      return right(lowStockNotifications);

      // Now, `lowStockNotifications` will contain the list of NotificationModel instances
      // You can use this list to trigger notifications, show them in the UI, etc.
    } catch (e) {
      print(e.toString());
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<List<NotificationModel>> fetchMarketOutOfStockProducts() async {
    try {
      final response = await ref.read(posDbProvider).database.rawQuery(
        '''SELECT id, name as title
     FROM ${TableConstant.productTable} 
     WHERE isTracked = 1  and isActive = 1
       AND qty IS NOT NULL 
       AND qty <=0 AND enableNotification =1
       limit 1000''',
      );

      // Parse the response and create NotificationModel objects
      List<NotificationModel> lowStockNotifications = [];
      for (var product in response) {
        int id = int.tryParse(product['id'].toString()) ?? 0;
        String productName = product['title'].toString();

        // Create the title, subtitle, and qty for the notification
        String title = productName;
        String subTitle = '$productName is out of stock.';

        // Create a NotificationModel and add it to the list
        NotificationModel notification = NotificationModel(
          title: title,
          subTitle: subTitle,
          qty: 0, // Set qty to 0, as it's out of stock
          id: id,
        );

        lowStockNotifications.add(notification);
      }
      return right(lowStockNotifications);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<List<NotificationModel>> fetchMarketExpiryDateProducts(
    int nbOfMonths,
  ) async {
    try {
      DateTime currentDate = DateTime.now();
      // Add `nbOfMonths` months to the current date
      DateTime targetExpiryDate = currentDate.add(
        Duration(days: 30 * nbOfMonths),
      );
      // Convert targetExpiryDate to string format for SQL query, e.g., 'YYYY-MM-DD'
      String formattedTargetDate =
          '${targetExpiryDate.year}-${targetExpiryDate.month.toString().padLeft(2, '0')}-${targetExpiryDate.day.toString().padLeft(2, '0')}';

      final response = await ref.read(posDbProvider).database.rawQuery(
        '''
  SELECT id, name AS title, expiryDate
  FROM products
  WHERE isActive = 1 and enableNotification =1 and expiryDate IS NOT NULL
  and expiryDate != '' and  expiryDate <= '$formattedTargetDate'  order by expiryDate asc''',
      );

      List<NotificationModel> expiredStockNotifications = [];

      for (var product in response) {
        int id = int.tryParse(product['id'].toString()) ?? 0;
        String productName = product['title'].toString();
        String expiryDate = product['expiryDate'].toString();

        // Create the title and subtitle for notifications
        String title = '$productName is expiring soon!';
        String subTitle = '$productName expires on $expiryDate.';

        // Create a NotificationModel and add it to the list
        NotificationModel notification = NotificationModel(
          title: title,
          subTitle: subTitle,
          qty: 0,
          id: id,
        );

        expiredStockNotifications.add(notification);
      }

      return right(expiredStockNotifications);

      // Handle the response (e.g., map it to a list of products, etc.)
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEitherVoid reOrderProducts({
    required List<ProductModel> products,
  }) async {
    try {
      for (var i = 0; i < products.length; i++) {
        await ref
            .read(posDbProvider)
            .database
            .rawUpdate(
              "update ${TableConstant.productTable} set sortOrder=$i where id=${products[i].id}",
            );
      }

      return right(null);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<List<ProductHistoryModel>> fetchProductHistory({
    required int productId,
  }) async {
    try {
      final db = ref.read(posDbProvider).database;

      final List<Map<String, dynamic>> results = await db.rawQuery(
        '''
      SELECT 
        p.name as productName,
        p.barcode as productBarcode,
        s.name as supplierName,
        i.receiptDate as puchaseDate,
        d.oldQty as oldQty,
        d.qty as newQty,
        d.costPrice as cost,
        d.oldCostPrice as oldCost,
        d.newAverageCost as averageCost
      FROM InvoiceDetails d
      INNER JOIN Invoices i ON d.invoiceId = i.id
      INNER JOIN Suppliers s ON i.supplierId = s.id
      INNER JOIN Products p ON d.productId = p.id
      WHERE d.productId = ?
      ORDER BY i.receiptDate asc
    ''',
        [productId],
      );

      final history = results
          .map((map) => ProductHistoryModel.fromMap(map))
          .toList();
      return Right(history);
    } catch (e) {
      return Left(FailureModel(e.toString()));
    }
  }

  @override
  Future<ProductModel?> fetchProductByPlu(int plu) async {
    ProductModel? p;
    await ref
        .read(posDbProvider)
        .database
        .query(TableConstant.productTable, where: "plu=$plu")
        .then((value) {
          if (value.isNotEmpty) {
            p = ProductModel.fromJson(value[0]);
          }
        });
    return p;
  }

  @override
  FutureEither<List<ProductModel>> fetchWeightedProducts() async {
    try {
      final response = await ref
          .read(posDbProvider)
          .database
          .query(
            TableConstant.productTable,
            where: "isTracked=1 and isActive=1 and isWeighted=1",
            orderBy: "plu asc",
          );
      List<ProductModel> list = List.from(
        (response).map((e) => ProductModel.fromJson(e)),
      );
      return right(list);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEitherVoid addQuickSelectionProduct(int productId) async {
    try {
      final response = await ref.read(posDbProvider).database.insert(
        TableConstant.quickSelectProductsTable,
        {"productId": productId},
      );
      return right(null);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<List<ProductModel>> fetchQuickSelectionProducts() async {
    try {
      final db = ref.read(posDbProvider).database;

      final response = await db.rawQuery('''
  SELECT p.*, q.sortOrder 
  FROM ${TableConstant.productTable} p
  JOIN ${TableConstant.quickSelectProductsTable} q 
    ON p.id = q.productId
  WHERE p.isActive = 1
  ORDER BY q.sortOrder
''');

      List<ProductModel> list = response
          .map((e) => ProductModel.fromJson(e))
          .toList();
      return right(list);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEitherVoid removeQuickSelectionProduct(int productId) async {
    try {
      final db = ref.read(posDbProvider).database;

      await db.rawDelete(
        'DELETE FROM ${TableConstant.quickSelectProductsTable} WHERE productId = ?',
        [productId],
      );

      return right(null);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEitherVoid reorderQuickSelectionProducts(
    List<ProductModel> products,
  ) async {
    try {
      print("products ${products.map((e) => e.id).toList()}");
      final db = ref.read(posDbProvider).database;
      Batch batch = db.batch();

      // Update sortOrder for each product in the quick selection table
      for (int i = 0; i < products.length; i++) {
        batch.rawUpdate(
          'UPDATE ${TableConstant.quickSelectProductsTable} SET sortOrder = ? WHERE productId = ?',
          [i, products[i].id],
        );
      }

      await batch.commit(noResult: true);
      return right(null);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<List<ProductModel>> fetchProductsForBackupToCloud() async {
    List<ProductModel> list = [];

    try {
      final response = await ref.read(posDbProvider).database.rawQuery('''
      SELECT 
        id, 
        name, 
        costPrice, 
        price, 
        barcode, 
        qty, 
        categoryId, 
        profitRate, 
        expiryDate, 
        isTracked, 
        isActive, 
        countsAsItem, 
        discount, 
        warningAlert, 
        enableNotification, 
        sortOrder, 
        minSellingPrice, 
        isWeighted, 
        plu, 
        isOffer
      FROM Products
      ''');

      list = List.from((response).map((e) => ProductModel.fromJson(e)));

      return right(list);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }
}
