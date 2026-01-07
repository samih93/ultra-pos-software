import 'package:desktoppossystem/models/customers_model.dart';
import 'package:desktoppossystem/models/product_model.dart';
import 'package:desktoppossystem/models/receipt_model.dart';
import 'package:desktoppossystem/repositories/customers/customer_repository.dart';
import 'package:desktoppossystem/repositories/customers/icustomer_repository.dart';
import 'package:desktoppossystem/repositories/products/product_repository.dart';
import 'package:desktoppossystem/repositories/receipts/receiptrepository.dart';
import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:desktoppossystem/shared/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final customerControllerProvider = ChangeNotifierProvider<CustomerController>((
  ref,
) {
  return CustomerController(
    ref: ref,
    iCustomerRepository: ref.read(customerProviderRepository),
  );
});

final customerCountsProvider = FutureProvider<int>((ref) async {
  return await ref.read(customerControllerProvider).getCustomersCounts();
});
final invoicesByCustomerProvider = FutureProvider.family
    .autoDispose<List<ReceiptModel>, ReceiptRequest>((ref, params) async {
      final customerId = params.customerId;
      final status = params.status;

      final response = await ref
          .read(receiptProviderRepository)
          .fetchReceiptsByCustomerId(customerId: customerId, status: status);
      return response.fold((l) => throw Exception(l.message), (r) {
        print("length is ${r.length}");

        return r;
      });
    });

final topSellingProductProvider =
    FutureProvider.family<List<ProductModel>, int>((ref, customerId) async {
      final response = await ref
          .read(productProviderRepository)
          .fetchMostSellingProductByCustomer(customerId: customerId);

      return response.fold((l) => throw Exception(l.message), (r) => r);
    });

final revenuAndProfitByCustomerProvider =
    FutureProvider.family<Map<String, double>, int>((ref, customerId) async {
      final response = await ref
          .read(receiptProviderRepository)
          .fetchRevenueAndProfitByCustomer(customerId: customerId);
      return response.fold((l) => throw Exception(l.message), (r) => r);
    });

class CustomerController extends ChangeNotifier {
  final Ref _ref;
  final ICustomerRepository _iCustomerRepository;
  CustomerController({
    required Ref ref,
    required ICustomerRepository iCustomerRepository,
  }) : _ref = ref,
       _iCustomerRepository = iCustomerRepository;

  // used for Clear customer if i am outside the customer screen
  clearCustomers() {
    customers.clear();
  }

  // For sale screen
  Future<List<CustomerModel>> getCustomersByPhoneOrNumber(String query) async {
    List<CustomerModel> customers = [];
    final customerRes = await _iCustomerRepository.getCustomersByNameOrPhone(
      query,
    );
    customerRes.fold((l) {}, (r) {
      customers = r;
    });
    return customers;
  }

  RequestState addCustomerRequestState = RequestState.success;
  String addCustomerStatusMessage = "";
  Future addCustomer(
    CustomerModel customerModel,
    BuildContext context, {
    bool? isInCustomerScreen,
  }) async {
    addCustomerRequestState = RequestState.loading;
    notifyListeners();
    CustomerModel c = CustomerModel.second();
    final addRes = await _iCustomerRepository.addCustomer(customerModel);
    addRes.fold(
      (l) {
        addCustomerStatusMessage = l.message;
        addCustomerRequestState = RequestState.error;
        ToastUtils.showToast(message: l.message, type: addCustomerRequestState);
        notifyListeners();
      },
      (r) {
        c = r;
        addCustomerRequestState = RequestState.success;
        addCustomerStatusMessage = "Customer $successAddedStatusMessage";
        ToastUtils.showToast(
          type: addCustomerRequestState,
          message: addCustomerStatusMessage,
        );
        // if not in customers screen , no need to select customer
        if (isInCustomerScreen != true) {
          _ref.read(saleControllerProvider).onselectCustomer(c);
        }
        notifyListeners();
        // if in stock refresh
        if (isInCustomerScreen == true) {
          fetchCustomersByBatch(batch: 20, offset: 0);
        }
        _ref.refresh(customerCountsProvider);
        context.pop();
      },
    );
  }

  RequestState updateCustomerRequestState = RequestState.success;

  String updateCustomerStatusMessage = "";
  Future<CustomerModel> updateCustomer(
    CustomerModel customerModel,
    BuildContext context, {
    bool? isInCustomerScreen,
  }) async {
    CustomerModel c = CustomerModel.second();
    updateCustomerRequestState = RequestState.loading;
    notifyListeners();
    final updateRes = await _iCustomerRepository.updateCustomer(customerModel);
    updateRes.fold(
      (l) {
        updateCustomerRequestState = RequestState.error;
        ToastUtils.showToast(type: RequestState.error, message: l.message);
        notifyListeners();
      },
      (r) {
        c = customerModel;

        updateCustomerRequestState = RequestState.success;
        ToastUtils.showToast(
          type: RequestState.success,
          message: "Customer $successUpdatedStatusMessage",
        );
        if (isInCustomerScreen != true) {
          _ref.read(saleControllerProvider).onselectCustomer(c);
        }
        context.pop(); // if in stock refresh
        if (isInCustomerScreen == true) {
          fetchCustomersByBatch(batch: 20, offset: 0);
        }
        notifyListeners();
      },
    );

    return c;
  }

  int _offset = 0;
  int _batchSize = 0;
  bool _isHasMoreData = true;

  List<CustomerModel> customers = [];
  RequestState fetchCustomerByBatchRequestState = RequestState.success;
  Future fetchCustomersByBatch({int? batch, int? offset}) async {
    if (fetchCustomerByBatchRequestState == RequestState.loading) return;
    // if on press customers
    if (batch != null && offset != null) {
      _offset = offset;
      _batchSize = batch;
      _isHasMoreData = true;
    }

    if (_isHasMoreData) {
      fetchCustomerByBatchRequestState = RequestState.loading;
      notifyListeners();
      final customerRes = await _iCustomerRepository.fetchCustomersByBatch(
        batchSize: _batchSize,
        offset: _offset,
      );
      customerRes.fold(
        (l) {
          fetchCustomerByBatchRequestState = RequestState.error;
          notifyListeners();
        },
        (r) {
          _offset += _batchSize;
          // if the returned list equal batch size , so maybe we have more data
          _isHasMoreData = r.length == _batchSize;
          customers = batch != null && offset != null
              ? r
              : [...customers, ...r];
          fetchCustomerByBatchRequestState = RequestState.success;
          notifyListeners();
        },
      );
    }
  }

  // For customer screen
  Future searchByPhoneOrName(String query) async {
    if (query.trim() == "") {
      fetchCustomersByBatch(batch: 20, offset: 0);
      return;
    } else {
      final customerRes = await _iCustomerRepository.getCustomersByNameOrPhone(
        query,
      );
      customerRes.fold(
        (l) {
          debugPrint(l.message);
        },
        (r) {
          customers = r;
          notifyListeners();
        },
      );
    }
  }

  Future deleteCustomerByI(int id, BuildContext context) async {
    final deleteRes = await _iCustomerRepository.deleteCustomerById(id);
    deleteRes.fold(
      (l) => ToastUtils.showToast(message: l.message, type: RequestState.error),
      (r) {
        ToastUtils.showToast(
          message: "Customer deleted successfully",
          type: RequestState.success,
        );
        fetchCustomersByBatch(batch: 20, offset: 0);
        _ref.refresh(customerCountsProvider);

        context.pop();
      },
    );
  }

  RequestState getDownloadCustomersRequestState = RequestState.success;
  Future<List<CustomerModel>> getAllCustomers() async {
    List<CustomerModel> list = [];
    getDownloadCustomersRequestState = RequestState.loading;
    notifyListeners();
    final res = await _iCustomerRepository.fetchCustomersByBatch(
      batchSize: 100000000000,
      offset: 0,
    );

    res.fold(
      (l) {
        getDownloadCustomersRequestState = RequestState.error;
        notifyListeners();
      },
      (r) {
        list = r;
        getDownloadCustomersRequestState = RequestState.success;
        notifyListeners();
      },
    );
    return list;
  }

  Future getCustomersCounts() async {
    int count = 0;
    final res = await _iCustomerRepository.fetchCustomersCount();

    res.fold<Future>((l) async {}, (r) async {
      count = r;
    });
    return count;
  }
}
