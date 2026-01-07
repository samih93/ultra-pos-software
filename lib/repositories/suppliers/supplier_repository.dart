import 'package:desktoppossystem/models/failure_model.dart';
import 'package:desktoppossystem/models/supplier_model.dart';
import 'package:desktoppossystem/shared/constances/table_constant.dart';
import 'package:desktoppossystem/shared/services/dependency_injection.dart';
import 'package:desktoppossystem/shared/utils/type_def.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

final supplierProviderRepository = Provider((ref) {
  return SupplierRepository(ref);
});

abstract class ISupplierRepository {
  FutureEither<List<SupplierModel>> searchByNameOrPhone(String query);
  FutureEither<SupplierModel> addSupplier(SupplierModel supplier);
  FutureEither<List<SupplierModel>> fetchCustomersByBatch(
      {required int offset, required int batchSize});
  FutureEither<SupplierModel> updateSuplier(SupplierModel model);
  FutureEitherVoid deleteSupplier(int id);
}

class SupplierRepository extends ISupplierRepository {
  final Ref ref;
  SupplierRepository(this.ref);
  @override
  FutureEither<List<SupplierModel>> searchByNameOrPhone(String query) async {
    try {
      List<SupplierModel> suppliers = [];
      String q = "";

      List<String> keywords = query.split(" ");
      for (int i = 0; i < keywords.length; i++) {
        q +=
            " (name LIKE '%${keywords[i]}%'  or phoneNumber like '%${keywords[i]}%' or contactDetails like '%${keywords[i]}%')";
        if (i < keywords.length - 1) {
          q += " AND";
        }
      }

      final response = await ref
          .read(posDbProvider)
          .database
          .query(TableConstant.suppliers, where: q);

      suppliers = List.from(response.map((e) => SupplierModel.fromMap(e)));
      return right(suppliers);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<SupplierModel> addSupplier(SupplierModel supplier) async {
    try {
      final supplierId = await ref
          .read(posDbProvider)
          .database
          .insert(TableConstant.suppliers, supplier.toMap());
      supplier = supplier.copyWith(id: supplierId);

      return right(supplier);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<List<SupplierModel>> fetchCustomersByBatch(
      {required int offset, required int batchSize}) async {
    List<SupplierModel> suppliers = [];

    try {
      await ref
          .read(posDbProvider)
          .database
          .query(TableConstant.suppliers, limit: batchSize, offset: offset)
          .then((response) {
        suppliers = List.from((response).map((e) => SupplierModel.fromMap(e)));
      });

      return right(suppliers);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<SupplierModel> updateSuplier(SupplierModel model) async {
    try {
      final response = await ref.read(posDbProvider).database.rawUpdate(
          "update ${TableConstant.suppliers} set name='${model.name}', phoneNumber='${model.phoneNumber}' ,  contactDetails='${model.contactDetails}',supplierAddress ='${model.supplierAddress}'  where id=${model.id}");

      return right(model);
    } catch (e) {
      print(e.toString());
      return left(FailureModel(e.toString()));
    }
  }

  Future<bool> isSupplierIdInOldInvoice(int supplierId) async {
    final database = ref.read(posDbProvider).database;

    // Query the invoice table for the supplierId
    final result = await database.rawQuery(
        'SELECT COUNT(*) as count FROM ${TableConstant.invoices} WHERE supplierId = ?',
        [supplierId]);
    int count = result.isNotEmpty
        ? int.tryParse(result.first.values.first.toString()) ?? 0
        : 0;
    // If the result count is greater than 0, supplierId exists in an old invoice
    return count > 0;
  }

  @override
  FutureEitherVoid deleteSupplier(int id) async {
    try {
      final isInOldInvoice = await isSupplierIdInOldInvoice(id);
      if (isInOldInvoice) {
        return left(FailureModel(
            "Cannot delete supplier, it is used in old invoices."));
      }
      final response = await ref
          .read(posDbProvider)
          .database
          .delete(TableConstant.suppliers, where: "id = ?", whereArgs: [id]);
      return right(null);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }
}
