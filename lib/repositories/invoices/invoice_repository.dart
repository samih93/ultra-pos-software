import 'package:desktoppossystem/models/failure_model.dart';
import 'package:desktoppossystem/models/invoice_details_model.dart';
import 'package:desktoppossystem/models/invoice_model.dart';
import 'package:desktoppossystem/repositories/products/product_repository.dart';
import 'package:desktoppossystem/shared/constances/table_constant.dart';
import 'package:desktoppossystem/shared/services/dependency_injection.dart';
import 'package:desktoppossystem/shared/utils/type_def.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

final invoiceProviderRepository = Provider((ref) {
  return InvoiceRepository(ref);
});

abstract class IInvoiceRepository {
  FutureEither<InvoiceModel> addInvoice(InvoiceModel invoice);
  FutureEitherVoid addInvoiceDetails(List<PurchaseDetailsModel> invoiceDetails);
  FutureEither<List<InvoiceModel>> fetchAllInvoices(
      {int? supplierId, DateTime? invoiceDate});
  FutureEither<List<PurchaseDetailsModel>> fetchInvoiceDetailsByInvoiceId(
      {required int invoiceId});
}

class InvoiceRepository extends IInvoiceRepository {
  final Ref ref;
  InvoiceRepository(this.ref);
  @override
  FutureEither<InvoiceModel> addInvoice(InvoiceModel invoice) async {
    try {
      final invoiceId = await ref
          .read(posDbProvider)
          .database
          .insert(TableConstant.invoices, invoice.toMap());
      invoice = invoice.copyWith(id: invoiceId);
      return right(invoice);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEitherVoid addInvoiceDetails(
      List<PurchaseDetailsModel> invoiceDetails) async {
    try {
      for (var element in invoiceDetails) {
        await ref
            .read(posDbProvider)
            .database
            .insert(TableConstant.invoiceDetails, element.toMap());
        await ref
            .read(productProviderRepository)
            .updateStockByInvoiceDetails(element);
      }
      return right(null);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<List<InvoiceModel>> fetchAllInvoices(
      {int? supplierId, DateTime? invoiceDate}) async {
    try {
      DateTime currentDate = DateTime.now();
      DateTime previousMonth = currentDate.subtract(const Duration(
          days: 30)); // A simple approximation of the previous month

      // Extract year and month from current and previous month
      int currentMonth = currentDate.month;
      int currentYear = currentDate.year;
      int prevMonth = previousMonth.month;
      int prevYear = previousMonth.year;
      String query =
          "select i.id, i.referenceId , i.foreignPrice ,i.localPrice , i.receiptDate , s.name as supplierName from ${TableConstant.invoices} as i join ${TableConstant.suppliers} as s on i.supplierId = s.id where 1=1";
      if (supplierId != null) {
        query += " and i.supplierId = $supplierId";
      }
      if (invoiceDate != null) {
        query +=
            " and CAST(SUBSTR(i.receiptDate, 9, 11) AS integer)=${invoiceDate.day} and CAST(SUBSTR(i.receiptDate, 6, 8) AS integer)=${invoiceDate.month} and CAST(SUBSTR(i.receiptDate, 1, 4) AS integer)=${invoiceDate.year}";
      } else {
        query += " and ("
            "(CAST(SUBSTR(i.receiptDate, 6, 8) AS integer)=$currentMonth and CAST(SUBSTR(i.receiptDate, 1, 4) AS integer)=$currentYear) "
            "or "
            "(CAST(SUBSTR(i.receiptDate, 6, 8) AS integer)=$prevMonth and CAST(SUBSTR(i.receiptDate, 1, 4) AS integer)=$prevYear) "
            ")";
      }
      query += " order by i.receiptDate desc";
      final response = await ref.read(posDbProvider).database.rawQuery(query);
      List<InvoiceModel> invoices =
          List.from((response).map((e) => InvoiceModel.fromMap(e)));
      return right(invoices);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<List<PurchaseDetailsModel>> fetchInvoiceDetailsByInvoiceId(
      {required int invoiceId}) async {
    try {
      final response = await ref.read(posDbProvider).database.rawQuery(
          "select p.barcode,p.name as productName, id.oldQty , id.qty , id.oldCostPrice ,id.costPrice , id.oldSellingPrice,id.sellingPrice from ${TableConstant.productTable} as p join ${TableConstant.invoiceDetails} as id on p.id = id.productId where id.invoiceId=$invoiceId order by p.name");
      List<PurchaseDetailsModel> invoiceDetails =
          List.from((response).map((e) => PurchaseDetailsModel.fromMap(e)));
      return right(invoiceDetails);
    } catch (e) {
      print(e.toString());
      return left(FailureModel(e.toString()));
    }
  }
}
