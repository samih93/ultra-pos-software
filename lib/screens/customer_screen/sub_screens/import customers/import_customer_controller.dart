import 'package:desktoppossystem/controller/customer_controller.dart';
import 'package:desktoppossystem/models/customers_model.dart';
import 'package:desktoppossystem/repositories/customers/customer_repository.dart';
import 'package:desktoppossystem/repositories/customers/icustomer_repository.dart';
import 'package:desktoppossystem/shared/utils/toast_utils.dart';

import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:excel/excel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final importCustomerControllerProvider =
    ChangeNotifierProvider<ImportCustomerController>((ref) {
  return ImportCustomerController(
      ref: ref, customerRepository: ref.read(customerProviderRepository));
});

class ImportCustomerController extends ChangeNotifier {
  final Ref _ref;
  final ICustomerRepository _customerRepository;
  ImportCustomerController(
      {required Ref ref, required ICustomerRepository customerRepository})
      : _ref = ref,
        _customerRepository = customerRepository;

  List<CustomerModel> customers = [];
  RequestState readExcelRequestState = RequestState.success;
  Future readExcelProducts(List<int> bytes) async {
    customers = [];
    uniquePhone = {};
    readExcelRequestState = RequestState.loading;
    notifyListeners();

    try {
      await Future.delayed(Duration.zero).then((value) {
        var excel = Excel.decodeBytes(bytes);

        for (var table in excel.tables.keys) {
          for (var i = 1; i < excel.tables[table]!.maxRows; i++) {
            final row = excel.tables[table]!.row(i);

            CustomerModel customerModel = CustomerModel(
              id: 0,
              name: row[0] != null ? row[0]!.value.toString().trim() : "",
              address: row[1] != null ? row[1]!.value.toString().trim() : "",
              phoneNumber:
                  row[2] != null ? row[2]!.value.toString().trim() : "",
            );

            customers.add(customerModel);
            // ! add barcode in set to check if i have duplicates
            if (customerModel.phoneNumber != null &&
                customerModel.phoneNumber!.isNotEmpty) {
              uniquePhone.add(customerModel.phoneNumber.toString());
            }
          }
        }
      }).then((value) {
        readExcelRequestState = RequestState.success;
        notifyListeners();
      });
    } catch (e) {
      debugPrint(e.toString());
      readExcelRequestState = RequestState.error;

      notifyListeners();
    }
  }

  Set<String> uniquePhone = <String>{};

  RequestState bulkAddRequestState = RequestState.success;
  Future addCustomers(BuildContext context) async {
    bulkAddRequestState = RequestState.loading;
    notifyListeners();
    if (customers.length == uniquePhone.length) {
      final res = await _customerRepository.addBulkCustomers(customers);
      res.fold((l) {
        ToastUtils.showToast(
            type: RequestState.error,
            message: l.message,
            duration: const Duration(seconds: 4));
      }, (r) {
        ToastUtils.showToast(
            type: RequestState.success,
            message: "${customers.length} customers inserted",
            duration: const Duration(seconds: 4));
        customers.clear();
        _ref.refresh(customerCountsProvider);
        notifyListeners();
      });
    } else {
      ToastUtils.showToast(
          type: RequestState.error,
          message:
              "${customers.length - uniquePhone.length} phone Number duplicated",
          duration: const Duration(seconds: 4));
    }
  }
}
