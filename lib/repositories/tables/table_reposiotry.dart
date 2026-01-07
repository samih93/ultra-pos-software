import 'package:desktoppossystem/models/failure_model.dart';
import 'package:desktoppossystem/models/product_model.dart';
import 'package:desktoppossystem/models/table_model.dart';
import 'package:desktoppossystem/repositories/tables/i_table_reposiotry.dart';
import 'package:desktoppossystem/shared/constances/table_constant.dart';
import 'package:desktoppossystem/shared/services/dependency_injection.dart';
import 'package:desktoppossystem/shared/utils/type_def.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

final tableProviderRepository = Provider((ref) {
  return TableRepository(ref: ref);
});

class TableRepository implements ITableRepository {
  final Ref ref;
  TableRepository({required this.ref});

  @override
  Future<Map<String, dynamic>> fetchTable(String name) async {
    List<ProductModel> products = [];
    int nbOfCustomers = 0;

    // Fetch products
    await ref
        .read(posDbProvider)
        .database
        .rawQuery(
            'SELECT * FROM ${TableConstant.tableProductsTable} WHERE tableName="$name"')
        .then((value) async {
      if (value.isNotEmpty) {
        products = List.from(value.map((e) => ProductModel.fromJsonTables(e)));
      }
    });

    // Fetch nbOfCustomers
    await ref
        .read(posDbProvider)
        .database
        .rawQuery(
            'SELECT nbOfCustomers FROM ${TableConstant.tablesTable} WHERE tableName="$name"')
        .then((value) async {
      if (value.isNotEmpty) {
        nbOfCustomers =
            int.tryParse(value.first['nbOfCustomers'].toString()) ?? 1;
      }
    });

    return {
      'products': products,
      'nbOfCustomers': nbOfCustomers,
    };
  }

  @override
  Future addProductToTable(ProductModel productModel) async {
    try {
      await ref.read(posDbProvider).database.insert(
          TableConstant.tableProductsTable, productModel.toJsonForTables());
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Future deleteTableByName(String name) async {
    Future.wait([
      ref
          .read(posDbProvider)
          .database
          .delete(TableConstant.tablesTable, where: "tableName='$name'"),
      ref
          .read(posDbProvider)
          .database
          .delete(TableConstant.tableProductsTable, where: "tableName='$name'"),
    ]);
  }

  @override
  Future<List<TableModel>> fetchOpenedTables() async {
    List<TableModel> tables = [];
    await ref
        .read(posDbProvider)
        .database
        .query(
          TableConstant.tablesTable,
        )
        .then((value) {
      tables = List.from(value.map((e) => TableModel.fromMap(e)));
    });

    return tables;
  }

  @override
  Future deleteProductById({required int id}) async {
    await ref
        .read(posDbProvider)
        .database
        .delete(TableConstant.tableProductsTable, where: "id=$id");
  }

  @override
  Future addUpdateProductInTable(ProductModel productModel) async {
    final existProductResult =
        await existedProductInTable(productModel.id!, productModel.tableName!);

    existProductResult.fold((l) async {
      await addProductToTable(productModel);
    }, (r) async {
      double newQty = r.qty! + double.parse(productModel.qty.toString());
      await ref.read(posDbProvider).database.rawUpdate(
          "update ${TableConstant.tableProductsTable} set qty='$newQty'  where productId=${productModel.id} and tableName='${productModel.tableName}'");
    });
  }

  @override
  Future getProductQtyInTable(
      {required int productId, required String tableName}) async {
    double qty = 0;
    await ref
        .read(posDbProvider)
        .database
        .query(TableConstant.tableProductsTable,
            where: "productId=$productId and tableName='$tableName'")
        .then((value) {
      qty = double.parse(value[0]['qty'].toString());
    });
    return qty;
  }

  @override
  Future<String> openTable(String name, int userId) async {
    var isOpened = await isTableOpened(name);
    if (!isOpened) {
      await ref
          .read(posDbProvider)
          .database
          .insert(
              TableConstant.tablesTable,
              TableModel(tableName: name, isOpened: true, openedBy: userId)
                  .toMap())
          .then((value) {})
          .catchError((error) {
        throw Exception(error);
      });
    }

    return name;
  }

  @override
  Future<bool> isTableOpened(String name) async {
    bool isOpened = false;

    await ref
        .read(posDbProvider)
        .database
        .query(TableConstant.tablesTable, where: "tableName='$name'")
        .then((value) {
      if (value.isNotEmpty) {
        isOpened = true;
      }
    }).catchError((error) {
      throw Exception(error);
    });
    return isOpened;
  }

  @override
  FutureEither<ProductModel> existedProductInTable(
      int id, String tableName) async {
    try {
      late ProductModel p;
      final res = await ref.read(posDbProvider).database.query(
          TableConstant.tableProductsTable,
          where: " productId=$id and tableName='$tableName'");

      if (res.isEmpty) {
        throw Exception("not exist");
      }
      p = ProductModel.fromTableJson(res[0]);
      return right(p);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEitherVoid updateNbOfCustomers({
    required int nbOfCustomers,
    required String tableName,
  }) async {
    try {
      final response = ref.read(posDbProvider).database.rawUpdate(
          "update ${TableConstant.tablesTable} set nbOfCustomers=$nbOfCustomers where tableName=$tableName");
      return right(null);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }
}
