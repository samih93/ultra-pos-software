import 'package:desktoppossystem/models/invoice_details_model.dart';
import 'package:desktoppossystem/models/invoice_model.dart';
import 'package:desktoppossystem/models/supplier_model.dart';
import 'package:desktoppossystem/repositories/invoices/invoice_repository.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedSupplierProvider = StateProvider<SupplierModel?>((ref) => null);
final selectedDateInvoicesProvider =
    StateProvider<DateTime?>((ref) => DateTime.now());

class InvoiceFetchParams {
  final int? supplierId;
  final DateTime? invoiceDate;

  InvoiceFetchParams({this.supplierId, this.invoiceDate});
}

final invoicesProvider = FutureProvider<List<InvoiceModel>>((ref) async {
  final invoiceRepository = ref.read(invoiceProviderRepository);
  final selectedSupplier = ref.watch(selectedSupplierProvider);
  final selectedDate = ref.watch(selectedDateInvoicesProvider);
  ref.cacheFor(const Duration(minutes: 3));

  final response = await invoiceRepository.fetchAllInvoices(
      supplierId: selectedSupplier?.id, invoiceDate: selectedDate);

  return response.fold(
    (l) => throw Exception("Failed to fetch invoices"),
    (r) => r,
  );
});

final invoiceDetailsProvider =
    FutureProvider.family<List<PurchaseDetailsModel>, int>((ref, id) async {
  ref.cacheFor(const Duration(minutes: 3));

  final response = await ref
      .read(invoiceProviderRepository)
      .fetchInvoiceDetailsByInvoiceId(invoiceId: id);

  return response.fold(
    (l) => throw Exception("Failed to fetch invoice details"),
    (r) => r,
  );
});




// final invoiceControllerProvider =
//     ChangeNotifierProvider<InvoicesController>((ref) {
//   return InvoicesController(ref, ref.read(invoiceProviderRepository));
// });

// class InvoicesController extends ChangeNotifier {
//   final Ref ref;
//   final IInvoiceRepository invoiceRepository;
//   InvoicesController(this.ref, this.invoiceRepository) {
//     fetchInvoices();
//   }

//   RequestState fetchInvoicesRequestState = RequestState.success;
//   List<InvoiceModel> invoices = [];


// int supplierId
//   Future<void> fetchInvoices({int? supplierId, String? invoiceDate}) async {
//     fetchInvoicesRequestState = RequestState.loading;
//     notifyListeners();

//     final response = await invoiceRepository.fetchAllInvoices();
//     response.fold(
//       (l) {
//         fetchInvoicesRequestState = RequestState.error;
//         notifyListeners();
//       },
//       (r) {
//         invoices = r;
//         fetchInvoicesRequestState = RequestState.success;
//         notifyListeners();
//       },
//     );
//   }

//   /// Fetch invoice details on-click without changing global state

//   RequestState fetchInvoiceDetailsRequestState = RequestState.success;
//   List<InvoiceDetails> invoiceDetailsList = [];

//   Future<List<InvoiceDetails>> fetchInvoiceDetails(int invoiceId) async {
//     fetchInvoiceDetailsRequestState = RequestState.loading;
//     notifyListeners();

//     final response = await invoiceRepository.fetchInvoiceDetailsByInvoiceId(
//         invoiceId: invoiceId);
//     response.fold(
//       (l) {
//         fetchInvoiceDetailsRequestState = RequestState.error;
//         notifyListeners();
//       },
//       (r) {
//         invoiceDetailsList = r;
//         fetchInvoiceDetailsRequestState = RequestState.success;
//         notifyListeners();
//       },
//     );
//     return invoiceDetailsList;
//   }
// }
