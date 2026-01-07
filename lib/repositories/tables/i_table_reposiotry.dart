import 'package:desktoppossystem/models/product_model.dart';
import 'package:desktoppossystem/models/table_model.dart';
import 'package:desktoppossystem/shared/utils/type_def.dart';

abstract class ITableRepository {
  Future addProductToTable(ProductModel productModel);
  FutureEither<ProductModel> existedProductInTable(int id, String tableTName);
  Future addUpdateProductInTable(ProductModel productModel);
  Future getProductQtyInTable(
      {required int productId, required String tableName});
  Future<Map<String, dynamic>> fetchTable(String name);
  Future deleteTableByName(String name);
  Future deleteProductById({
    required int id,
  });
  Future<List<TableModel>> fetchOpenedTables();
  Future<String> openTable(String name, int userId);
  Future<bool> isTableOpened(String name);

  FutureEitherVoid updateNbOfCustomers({
    required int nbOfCustomers,
    required String tableName,
  });
}
