import 'package:collection/collection.dart';
import 'package:desktoppossystem/models/details_ingredients_receipt.dart';
import 'package:desktoppossystem/models/failure_model.dart';
import 'package:desktoppossystem/models/product_model.dart';
import 'package:desktoppossystem/models/reports/waste_by_stock_model.dart';
import 'package:desktoppossystem/models/stock_transaction_model.dart';
import 'package:desktoppossystem/models/ingrendient_model.dart';
import 'package:desktoppossystem/models/notification_model.dart';
import 'package:desktoppossystem/models/restaurant_stock_model.dart';
import 'package:desktoppossystem/screens/notifications_screen/notification_controller.dart';
import 'package:desktoppossystem/shared/constances/table_constant.dart';
import 'package:desktoppossystem/shared/services/dependency_injection.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:desktoppossystem/shared/utils/type_def.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:jiffy/jiffy.dart' as JIFFY_LIBRARY;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../models/reports/restaurant_stock_usage_model.dart';
import '../../models/sandwiches_ingredients.dart';

final restaurantProviderRepository = Provider<RestaurantStockRepository>((ref) {
  return RestaurantStockRepository(ref);
});

abstract class IRestaurantStockRepository {
  FutureEither<List<RestaurantStockModel>> fetchAllStockItems({
    bool? isForWarning,
  });

  FutureEither<double> fetchRestaurantInventoryCost();
  FutureEither<RestaurantStockModel> addRestaurantStockItem(
    RestaurantStockModel stockItemModel,
  );
  FutureEither<RestaurantStockModel> editRestaurantStockItem(
    RestaurantStockModel stockItemModel,
  );
  FutureEitherVoid deleteRestaurantStockItem(int id);

  FutureEither<IngredientModel> addIngredient(IngredientModel ingredientModel);
  FutureEither<IngredientModel> editIngredient(IngredientModel ingredientModel);
  FutureEitherVoid deleteIngredient(int id);
  FutureEither<List<IngredientModel>> fetchIngredientsByStockId(int id);

  FutureEitherVoid addSandwichIngredients(
    List<SandwichesIngredients> sandwichesIngrediets,
  );

  // by product id , and product id should be not tracked
  FutureEither<List<IngredientModel>> fetchIngredientsBySandwich(int id);
  FutureEitherVoid deleteSandwichIngredientById(int id);

  FutureEitherVoid addsalesIngredients(
    List<DetailsIngredientsReceipt> detailsIngredientsReceipts,
  );
  FutureEitherVoid refundIngredients(
    List<DetailsIngredientsReceipt> detailsIngredientsReceipts,
    double refundedQty, {
    bool isDelete,
  });

  FutureEither decreaseRestaurantStock(DetailsIngredientsReceipt details);
  FutureEither increaseRestaurantStock(DetailsIngredientsReceipt details);

  FutureEither<List<RestaurantStockUsageModel>> fetchStockUsageReport({
    String? date,
    ReportInterval? view,
  });
  FutureEither<List<RestaurantStockUsageModel>> fetchStockUsageReportByView({
    DashboardFilterEnum? view,
  });

  Future<List<DetailsIngredientsReceipt>>
  fetchSaledIngredientByDetailsReceiptId(int id);

  FutureEither<List<RestaurantStockModel>> fetchStockAlerts();
  FutureEither<int> fetchRestaurantNotificationCounts(int nbOfMonths);
  FutureEither<List<NotificationModel>> fetchRestaurantLowStockList();
  FutureEither<List<NotificationModel>> fetchRestaurantExpiryDateProducts(
    int nbOfMonths,
  );
  FutureEither makeStockTransactions(
    List<StockTransactionModel> stockTransactionList,
  );

  FutureEither bulkWasteTransaction(List<ProductModel> products);

  FutureEither<List<WasteByStockModel>> fetchWastesByView({
    ReportInterval? view,
    String? date,
  });
  FutureEither<List<StockTransactionModel>> fetchStockTransactionsByDate(
    DateTime date,
  );
}

class RestaurantStockRepository extends IRestaurantStockRepository {
  final Ref ref;
  RestaurantStockRepository(this.ref);
  @override
  FutureEither<IngredientModel> addIngredient(
    IngredientModel ingredientModel,
  ) async {
    try {
      IngredientModel ingredient;
      final insertedId = await ref
          .read(posDbProvider)
          .database
          .insert(TableConstant.ingredientTable, ingredientModel.toMap());

      ingredient = ingredientModel;
      ingredient.id = insertedId;
      return right(ingredient);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<RestaurantStockModel> addRestaurantStockItem(
    RestaurantStockModel stockItemModel,
  ) async {
    try {
      RestaurantStockModel stockItem;
      final insertedId = await ref
          .read(posDbProvider)
          .database
          .insert(TableConstant.restaurantStockTable, stockItemModel.toMap());

      stockItem = stockItemModel;
      stockItem.id = insertedId;
      return right(stockItem);
    } catch (e) {
      print(e.toString());
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<RestaurantStockModel> editRestaurantStockItem(
    RestaurantStockModel stockItemModel,
  ) async {
    try {
      RestaurantStockModel stockItem;

      await ref
          .read(posDbProvider)
          .database
          .update(
            TableConstant.restaurantStockTable,
            stockItemModel.toMap(),
            where: "id=${stockItemModel.id}",
          );
      // update ingredients name releated to this stock item
      updateIngredientName(stockItemModel);

      stockItem = stockItemModel;
      return right(stockItem);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<List<RestaurantStockModel>> fetchAllStockItems({
    bool? isForWarning,
  }) async {
    try {
      List<RestaurantStockModel> list = [];
      String query = "select * from ${TableConstant.restaurantStockTable}";
      if (isForWarning == true) {
        query += " where  qty <= warningAlert";
      }
      await ref.read(posDbProvider).database.rawQuery(query).then((response) {
        list = List.from(
          (response).map((e) => RestaurantStockModel.fromMap(e)),
        );
      });
      return right(list);
    } catch (e) {
      print(e.toString());
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEitherVoid deleteRestaurantStockItem(int id) async {
    try {
      await ref
          .read(posDbProvider)
          .database
          .delete(TableConstant.restaurantStockTable, where: "id=$id")
          .whenComplete(() {
            ref
                .read(posDbProvider)
                .database
                .delete(
                  TableConstant.ingredientTable,
                  where: "restaurantStockId=$id",
                );
          });

      return right(null);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<List<IngredientModel>> fetchIngredientsByStockId(int id) async {
    List<IngredientModel> ingredients = [];
    try {
      await ref
          .read(posDbProvider)
          .database
          .rawQuery(
            'select i.id,i.name,i.qtyAsGram,i.qtyAsPortion ,i.unitType , i.restaurantStockId,  rs.color,rs.textColor, rs.forPackaging, '
            ' CASE'
            ' WHEN rs.unitType = \'portion\' THEN'
            ' rs.pricePerUnit * i.qtyAsPortion'
            ' WHEN rs.unitType = \'kg\' THEN'
            ' rs.pricePerUnit * (i.qtyAsGram /1000)'
            ' ELSE 0'
            ' END AS pricePerIngredient'
            ' from ${TableConstant.ingredientTable} as i join ${TableConstant.restaurantStockTable} as rs  on rs.id=i.restaurantStockId where i.restaurantStockId=$id ',
          )
          .then((response) {
            ingredients = List.from(
              (response).map((e) => IngredientModel.fromMap(e)),
            );
          });

      return right(ingredients);
    } catch (e) {
      print(e.toString());
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEitherVoid deleteIngredient(int id) async {
    try {
      await ref
          .read(posDbProvider)
          .database
          .delete(TableConstant.ingredientTable, where: "id=$id");
      return right(null);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEitherVoid addSandwichIngredients(
    List<SandwichesIngredients> sandwichesIngrediets,
  ) async {
    try {
      await Future.delayed(Duration.zero).then((value) {
        Batch batch = ref.read(posDbProvider).database.batch();
        for (var p in sandwichesIngrediets) {
          batch.insert(TableConstant.sandwichesIngredientTable, p.toMap());
        }
        batch.commit(noResult: true);
      });

      return right(null);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<List<IngredientModel>> fetchIngredientsBySandwich(int id) async {
    try {
      List<IngredientModel> ingredients = [];
      final response = await ref
          .read(posDbProvider)
          .database
          .rawQuery(
            'select i.id , i.name , i.unitType ,qtyAsGram,qtyAsPortion , restaurantStockId , si.id as sandwichIngredientId , rs.forPackaging ,'
            ' CASE'
            ' WHEN rs.unitType = \'portion\' THEN'
            ' rs.pricePerUnit * i.qtyAsPortion'
            ' WHEN rs.unitType = \'kg\' THEN'
            ' rs.pricePerUnit * (i.qtyAsGram /1000)'
            ' ELSE 0'
            ' END AS pricePerIngredient'
            ' from ${TableConstant.ingredientTable} as i join ${TableConstant.sandwichesIngredientTable} as si on i.id = si.ingredientId join ${TableConstant.restaurantStockTable} as rs on rs.id = i.restaurantStockId  where si.productId = $id ',
          );
      ingredients = List.from(
        (response as List).map((element) => IngredientModel.fromMap(element)),
      );

      return right(ingredients);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEitherVoid deleteSandwichIngredientById(int id) async {
    try {
      await ref
          .read(posDbProvider)
          .database
          .delete(TableConstant.sandwichesIngredientTable, where: "id=$id");
      return right(null);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEitherVoid addsalesIngredients(
    List<DetailsIngredientsReceipt> detailsIngredientsReceipts,
  ) async {
    try {
      await Future.delayed(Duration.zero).then((value) async {
        Batch batch = ref.read(posDbProvider).database.batch();
        for (var detailsIng in detailsIngredientsReceipts) {
          batch.insert(TableConstant.salesIngredientTable, detailsIng.toMap());
          await decreaseRestaurantStock(detailsIng);
        }
        batch.commit(noResult: true);
      });
      ref.refresh(restaurantNotificationCountProvider);

      return right(null);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEitherVoid refundIngredients(
    List<DetailsIngredientsReceipt> detailsIngredientsReceipts,
    double refundedQty, {
    bool isDelete = false,
  }) async {
    try {
      await Future.delayed(Duration.zero).then((value) async {
        final batch = ref.read(posDbProvider).database.batch();

        for (final detailsIng in detailsIngredientsReceipts) {
          if (isDelete == true || refundedQty == detailsIng.qty) {
            // Full refund or delete - remove the ingredient record
            batch.delete(
              TableConstant.salesIngredientTable,
              where: "detailsReceiptId=${detailsIng.detailsReceiptId}",
            );

            // For delete operation, we refund the full quantity
            final qtyToRefund = isDelete ? detailsIng.qty : refundedQty;
            await increaseRestaurantStock(
              detailsIng.copyWith(qty: qtyToRefund),
            );
          } else {
            // Partial refund - update the remaining quantity
            batch.rawUpdate(
              "UPDATE ${TableConstant.salesIngredientTable} "
              "SET qty=${detailsIng.qty - refundedQty} "
              "WHERE detailsReceiptId=${detailsIng.detailsReceiptId}",
            );
            await increaseRestaurantStock(
              detailsIng.copyWith(qty: refundedQty),
            );
          }
        }

        await batch.commit(noResult: true);
      });

      return right(null);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither decreaseRestaurantStock(
    DetailsIngredientsReceipt details,
  ) async {
    try {
      final stockItem = await fetchRestaurantStockById(
        details.restaurantStockId,
      );
      if (stockItem != null) {
        double quantityToSubtract;

        if (stockItem.unitType == UnitType.kg) {
          quantityToSubtract = details.qtyAsGram * details.qty / 1000;
        } else {
          quantityToSubtract = details.qtyAsPortion * details.qty;
        }

        final newQty = (stockItem.qty - quantityToSubtract).formatDoubleWith6();

        await updateRestaurantStock(
          stockId: details.restaurantStockId,
          newQty: newQty,
        );
      }
      return right(null);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither increaseRestaurantStock(
    DetailsIngredientsReceipt details,
  ) async {
    try {
      final stockItem = await fetchRestaurantStockById(
        details.restaurantStockId,
      );
      if (stockItem != null) {
        double quantityToAdd;

        if (stockItem.unitType == UnitType.kg) {
          // (grams per item × quantity) → convert to kg
          quantityToAdd = details.qtyAsGram * details.qty / 1000;
        } else {
          // (portions per item × quantity)
          quantityToAdd = details.qtyAsPortion * details.qty;
        }

        final newQty = (stockItem.qty + quantityToAdd).formatDoubleWith6();

        await updateRestaurantStock(
          stockId: details.restaurantStockId,
          newQty: newQty,
        );
      }
      return right(null);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  Future updateRestaurantStock({
    required int stockId,
    required double newQty,
  }) async {
    await ref.read(posDbProvider).database.update(
      TableConstant.restaurantStockTable,
      {"qty": newQty.formatDouble()},
      where: "id=$stockId",
    );
  }

  Future<RestaurantStockModel?> fetchRestaurantStockById(int id) async {
    RestaurantStockModel? model;

    final response = await ref
        .read(posDbProvider)
        .database
        .query(TableConstant.restaurantStockTable, where: "id=$id");
    model = RestaurantStockModel.fromMap(response[0]);

    return model;
  }

  @override
  FutureEither<List<RestaurantStockUsageModel>> fetchStockUsageReport({
    String? date,
    ReportInterval? view,
    int? shiftId,
  }) async {
    try {
      List<RestaurantStockUsageModel> stockUsages = [];
      String query =
          'select rs.name, si.pricePerIngredient ,si.unitType, SUM(si.qtyAsGram*si.qty) /1000 as qtyAsKilo , SUM(si.qtyAsPortion*si.qty) as qtyAsPortion ,Sum(si.qty*si.pricePerIngredient) as totalPrice , rs.forPackaging '
          ' from ${TableConstant.restaurantStockTable} as rs join ${TableConstant.salesIngredientTable} as si  on rs.id = si.restaurantStockId join ${TableConstant.receiptTable} as r on r.id=si.receiptId ';
      DateTime currentDate = date != null
          ? DateTime.parse(date)
          : DateTime.now();

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
        if (shiftId != null) {
          query += " where r.shiftId=$shiftId";
        } else {
          query +=
              " where CAST(SUBSTR(r.receiptDate, 9, 11) AS integer)=${currentDate.day} and CAST(SUBSTR(r.receiptDate, 6, 8) AS integer)=${currentDate.month} and CAST(SUBSTR(r.receiptDate, 1, 4) AS integer)=${currentDate.year}";
        }
      }

      query += " group by rs.id  order by qtyAsKilo DESC ,qtyAsPortion DESC ";

      final response = await ref.read(posDbProvider).database.rawQuery(query);
      stockUsages = List.from(
        (response as List).map((e) => RestaurantStockUsageModel.fromMap(e)),
      );

      return right(stockUsages);
    } catch (e) {
      print(e.toString());
      return left(FailureModel(e.toString()));
    }
  }

  @override
  Future<List<DetailsIngredientsReceipt>>
  fetchSaledIngredientByDetailsReceiptId(int id) async {
    try {
      List<DetailsIngredientsReceipt> saledIngredients = [];
      final response = await ref
          .read(posDbProvider)
          .database
          .query(
            TableConstant.salesIngredientTable,
            where: "detailsReceiptId=$id",
          );
      saledIngredients = List.from(
        (response as List).map((e) => DetailsIngredientsReceipt.fromMap(e)),
      );
      return saledIngredients;
    } catch (e) {
      print(e.toString());
      return [];
    }
  }

  @override
  FutureEither<IngredientModel> editIngredient(
    IngredientModel ingredientModel,
  ) async {
    try {
      IngredientModel model;
      await ref
          .read(posDbProvider)
          .database
          .update(
            TableConstant.ingredientTable,
            ingredientModel.toMap(),
            where: "id=${ingredientModel.id}",
          );
      model = ingredientModel;
      return right(model);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  FutureEither updateIngredientName(RestaurantStockModel stockItem) async {
    try {
      await ref
          .read(posDbProvider)
          .database
          .rawUpdate(
            "update ${TableConstant.ingredientTable} set name='${stockItem.name}' where restaurantStockId=${stockItem.id}",
          );

      return right(null);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<List<RestaurantStockUsageModel>> fetchStockUsageReportByView({
    DashboardFilterEnum? view,
  }) async {
    try {
      List<RestaurantStockUsageModel> stockUsages = [];
      String query =
          'select rs.name,rs.color as color , si.pricePerIngredient ,si.unitType, SUM(si.qtyAsGram*si.qty) /1000 as qtyAsKilo , SUM(si.qtyAsPortion*si.qty) as qtyAsPortion ,Sum(si.qty*si.pricePerIngredient) as totalPrice '
          ' from ${TableConstant.restaurantStockTable} as rs join ${TableConstant.salesIngredientTable} as si  on rs.id = si.restaurantStockId join ${TableConstant.receiptTable} as r on r.id=si.receiptId ';
      DateTime currentDate = DateTime.now();

      if (view != null) {
        switch (view) {
          // for dashboard
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
                " and CAST(SUBSTR(r.receiptDate, 6, 8) AS integer)=${currentDate.month} and CAST(SUBSTR(r.receiptDate, 1, 4) AS integer)=${currentDate.year}";
            break;
          case DashboardFilterEnum.thisYear:
            query +=
                " and CAST(SUBSTR(r.receiptDate, 1, 4) AS integer)=${currentDate.year}";
            break;
        }
      } else {
        query +=
            " where CAST(SUBSTR(r.receiptDate, 9, 11) AS integer)=${currentDate.day} and CAST(SUBSTR(r.receiptDate, 6, 8) AS integer)=${currentDate.month} and CAST(SUBSTR(r.receiptDate, 1, 4) AS integer)=${currentDate.year}";
      }

      query += " group by rs.id order by qtyAsKilo,qtyAsPortion desc";

      final response = await ref.read(posDbProvider).database.rawQuery(query);
      stockUsages = List.from(
        (response as List).map((e) => RestaurantStockUsageModel.fromMap(e)),
      );

      return right(stockUsages);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<List<RestaurantStockModel>> fetchStockAlerts() async {
    List<RestaurantStockModel> stockItems = [];

    try {
      final response = await ref
          .read(posDbProvider)
          .database
          .query(
            TableConstant.restaurantStockTable,
            where: " qty <= warningAlert",
          );
      stockItems = List.from(
        (response as List).map((e) => RestaurantStockModel.fromMap(e)),
      );
      return right(stockItems);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<int> fetchRestaurantNotificationCounts(int nbOfMonths) async {
    try {
      final lowStockresponse = await ref
          .read(posDbProvider)
          .database
          .rawQuery(
            "select count(*) as count from ${TableConstant.restaurantStockTable} where qty is NOT NULL and warningAlert is NOT NULL AND qty<= warningAlert ",
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
            "select count(*) as count from ${TableConstant.restaurantStockTable} where expiryDate is NOT NULL and expiryDate <= '$formattedTargetDate' ",
          );

      int totalCount =
          (int.tryParse(lowStockresponse[0]["count"].toString()) ?? 0) +
          (int.tryParse(expiredCount[0]["count"].toString()) ?? 0);

      return right(totalCount);
    } catch (e) {
      print(e.toString());
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<List<NotificationModel>> fetchRestaurantExpiryDateProducts(
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

      final response = await ref.read(posDbProvider).database.rawQuery('''
  SELECT id, name AS title, expiryDate
  FROM ${TableConstant.restaurantStockTable}
  WHERE  expiryDate <= '$formattedTargetDate' order by expiryDate asc''');

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
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<List<NotificationModel>> fetchRestaurantLowStockList() async {
    try {
      final response = await ref.read(posDbProvider).database.rawQuery(
        '''SELECT id, name as title, qty, warningAlert ,unitType 
     FROM ${TableConstant.restaurantStockTable} 
     WHERE  qty IS NOT NULL 
       AND warningAlert IS NOT NULL 
       AND qty<= warningAlert order by title 
        limit 1000 ''',
      );

      // Parse the response and create NotificationModel objects
      List<NotificationModel> lowStockNotifications = [];
      for (var product in response) {
        int id = int.tryParse(product['id'].toString()) ?? 0;
        String productName = product['title'].toString();
        double qty = double.tryParse(product['qty'].toString()) ?? 0.0;
        double warningAlert =
            double.tryParse(product['warningAlert'].toString()) ?? 0.0;
        UnitType unitType = product["unitType"].toString().unitTypeToEnum();

        // Create the title, subtitle, and qty for the notification
        String title = productName;
        String subTitle =
            'Stock reached the warning limit of $warningAlert. Current stock is $qty ${unitType.name}.';

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
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither bulkWasteTransaction(List<ProductModel> products) async {
    try {
      for (var product in products) {
        for (var ingredient in product.ingredientsToBeAdded) {
          final stockItem = await fetchRestaurantStockById(
            ingredient.restaurantStockId,
          );
          if (stockItem != null) {
            double oldQty = stockItem.qty;
            double newQty = oldQty;
            if (stockItem.unitType == UnitType.kg) {
              newQty = oldQty - ((ingredient.qtyAsGram / 1000) * product.qty!);
            } else {
              newQty = oldQty - (ingredient.qtyAsPortion * product.qty!);
            }
            await updateRestaurantStock(
              stockId: ingredient.restaurantStockId,
              newQty: newQty,
            );
          }
        }
      }
      return right(null);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither makeStockTransactions(
    List<StockTransactionModel> stockTransactionList,
  ) async {
    try {
      for (var element in stockTransactionList) {
        await ref
            .read(posDbProvider)
            .database
            .insert(
              TableConstant.restaurantStockTransactionTable,
              element.toMap(),
            );
      }

      return right(null);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<List<WasteByStockModel>> fetchWastesByView({
    ReportInterval? view,
    String? date,
  }) async {
    List<WasteByStockModel> wastesList = [];

    try {
      String query =
          '''
 SELECT 
    rst.stockId,
    rs.name,
    rst.unitType,
    rst.pricePerUnit,
    SUM(rst.transactionQty) AS totalTransactionQty,
    
    ROUND(
      CASE 
        WHEN rst.unitType = 'kg' AND rst.wasteType = 'staff' THEN SUM(COALESCE(rst.qtyAsGram, 0)) / 1000 
        WHEN rst.unitType = 'kg' AND rst.wasteType = 'normal' THEN SUM(rst.transactionQty) 
        ELSE 0 
      END, 3) AS totalQtyAsKilo,
    
    --//! Conditional calculation for totalQtyAsPortions based on unitType
    CASE 
      WHEN rst.wasteType = 'staff' AND rst.unitType = 'portion' THEN  SUM(COALESCE(rst.qtyAsPortion, rst.transactionQty))
      WHEN rst.wasteType = 'normal' AND rst.unitType = 'portion' THEN SUM(rst.transactionQty)
      ELSE 0 
    END AS totalQtyAsPortions,

    --//! Conditional calculation for totalPriceForWeight based on unitType
    ROUND(
      CASE 
        WHEN rst.unitType = 'kg' THEN rst.pricePerUnit * SUM(rst.transactionQty) 
        ELSE 0 
      END, 3) AS totalPriceForWeight,

    --//! Conditional calculation for totalPriceForPortions based on unitType
    ROUND(
      CASE 
        WHEN rst.unitType = 'portion' THEN SUM(rst.transactionQty) * rst.pricePerUnit
        ELSE 0 
      END, 3) AS totalPriceForPortions

   

  FROM ${TableConstant.restaurantStockTransactionTable} AS rst
  LEFT JOIN ${TableConstant.restaurantStockTable} AS rs
    ON rst.stockId = rs.id 
    WHERE rst.transactionType = 'stockOut' ''';
      DateTime currentDate = date != null
          ? DateTime.parse(date)
          : DateTime.now();
      if (view != null) {
        switch (view) {
          case ReportInterval.daily:
            query +=
                " and CAST(SUBSTR(rst.transactionDate, 9, 11) AS integer)=${currentDate.day} and CAST(SUBSTR(rst.transactionDate, 6, 8) AS integer)=${currentDate.month} and CAST(SUBSTR(rst.transactionDate, 1, 4) AS integer)=${currentDate.year}";

            break;
          case ReportInterval.monthly:
            query +=
                "  and CAST(SUBSTR(rst.transactionDate, 6, 8) AS integer)=${currentDate.month} and CAST(SUBSTR(rst.transactionDate, 1, 4) AS integer)=${currentDate.year}";
            break;
          case ReportInterval.yearly:
            query +=
                "  and  CAST(SUBSTR(rst.transactionDate, 1, 4) AS integer)=${currentDate.year}";
            break;
        }
      } else {
        query +=
            " and CAST(SUBSTR(rst.transactionDate, 9, 11) AS integer)=${currentDate.day} and CAST(SUBSTR(rst.transactionDate, 6, 8) AS integer)=${currentDate.month} and CAST(SUBSTR(rst.transactionDate, 1, 4) AS integer)=${currentDate.year}";
      }

      query += "  GROUP BY rst.stockId, rst.unitType, rst.pricePerUnit";

      final response = await ref.read(posDbProvider).database.rawQuery(query);
      var groupedByStockId = groupBy(
        response,
        (obj) => (obj as dynamic)['stockId'],
      );

      // Print it
      groupedByStockId.forEach((key, value) {
        // Initialize the variables for summation
        double totalQtyAsPortions = 0;
        double totalQtyAsKg = 0;
        double totalPrice = 0;
        for (var item in value) {
          if (item['unitType'] == UnitType.portion.name) {
            totalQtyAsPortions +=
                double.tryParse(item['totalQtyAsPortions'].toString()) ??
                0.0; // Add to portions
            totalPrice +=
                double.tryParse(item['totalPriceForPortions'].toString()) ??
                0.0; // Add price for portions
          } else {
            totalQtyAsKg +=
                double.tryParse(item['totalQtyAsKilo'].toString()) ??
                0.0; // Add to kg quantity
            totalPrice +=
                double.tryParse(item['totalPriceForWeight'].toString()) ??
                0.0; // Add price for weight
          }
        }

        WasteByStockModel wasteByStockModel = WasteByStockModel(
          unitType: value[0]["unitType"].toString().unitTypeToEnum(),
          name: value[0]["name"].toString(),
          totalQtyAsPortions: totalQtyAsPortions,
          totalQtyAsKg: totalQtyAsKg,
          totalPrice: totalPrice,
        );
        wastesList.add(wasteByStockModel);
      });
      return right(wastesList);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<List<StockTransactionModel>> fetchStockTransactionsByDate(
    DateTime date,
  ) async {
    try {
      final query =
          '''
SELECT 
  st.id,
  st.stockId,
  st.employeeId,
  st.unitType,
  st.pricePerUnit,
  st.oldQty,
  st.transactionQty,
  st.transactionDate,
  st.wasteType,
  st.transactionReason,
  st.transactionType,
  
  -- Joined user data
  u.name as employeeName,
  
  -- Joined stock data
  rs.name as itemName
  
FROM ${TableConstant.restaurantStockTransactionTable} as st
LEFT JOIN ${TableConstant.userTable} u ON st.employeeId = u.id
LEFT JOIN ${TableConstant.restaurantStockTable} rs ON st.stockId = rs.id
  WHERE CAST(SUBSTR(transactionDate, 9, 11) AS integer)=${date.day} and CAST(SUBSTR(transactionDate, 6, 8) AS integer)=${date.month} and CAST(SUBSTR(transactionDate, 1, 4) AS integer)=${date.year} 
ORDER BY st.transactionDate DESC ''';
      final response = await ref.read(posDbProvider).database.rawQuery(query);
      List<StockTransactionModel> list = List.from(
        (response).map((e) => StockTransactionModel.fromMap(e)),
      );
      return right(list);
    } catch (e) {
      print(e.toString());
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<double> fetchRestaurantInventoryCost() async {
    try {
      final result = await ref
          .read(posDbProvider)
          .database
          .rawQuery(
            "SELECT SUM(qty * pricePerUnit) as totalCost FROM ${TableConstant.restaurantStockTable} WHERE qty IS NOT NULL AND pricePerUnit IS NOT NULL",
          );

      // Convert the result to double (handling null cases)
      double totalCost =
          double.tryParse(result[0]["totalCost"]?.toString() ?? '0') ?? 0.0;

      return right(totalCost);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }
}
