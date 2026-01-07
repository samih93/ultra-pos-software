// ignore_for_file: unused_result

import 'package:desktoppossystem/models/supplier_model.dart';
import 'package:desktoppossystem/repositories/suppliers/supplier_repository.dart';
import 'package:desktoppossystem/shared/utils/toast_utils.dart';

import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final supplierControllerProvider =
    ChangeNotifierProvider<SupplierController>((ref) {
  return SupplierController(
      ref: ref, supplierRepository: ref.read(supplierProviderRepository));
});

class SupplierController extends ChangeNotifier {
  final Ref ref;
  final ISupplierRepository supplierRepository;

  SupplierController({required this.ref, required this.supplierRepository});

  RequestState addSupplierRequestState = RequestState.success;
  Future addSupplier(BuildContext context, SupplierModel supplier) async {
    addSupplierRequestState = RequestState.loading;
    notifyListeners();
    final response = await supplierRepository.addSupplier(supplier);
    response.fold(
      (l) {
        addSupplierRequestState = RequestState.error;
        notifyListeners();
        ToastUtils.showToast(message: l.message, type: RequestState.error);
      },
      (r) {
        suppliers.add(r);
        addSupplierRequestState = RequestState.success;
        notifyListeners();
        context.pop();
      },
    );
  }

  RequestState updateSupplierRequestState = RequestState.success;
  Future updateSupplier(BuildContext context, SupplierModel supplier) async {
    updateSupplierRequestState = RequestState.loading;
    notifyListeners();
    final response = await supplierRepository.updateSuplier(supplier);
    response.fold(
      (l) {
        updateSupplierRequestState = RequestState.error;
        notifyListeners();
        ToastUtils.showToast(message: l.message, type: RequestState.error);
      },
      (r) {
        updateSupplierInTempList(supplier);
        updateSupplierRequestState = RequestState.success;
        notifyListeners();
        context.pop();
      },
    );
  }

  Future deleteSupplier(int id) async {
    final response = await supplierRepository.deleteSupplier(id);
    response.fold(
      (l) {
        ToastUtils.showToast(message: l.message, type: RequestState.error);
      },
      (r) {
        suppliers.removeWhere((e) => e.id == id);
        notifyListeners();
      },
    );
  }

  void updateSupplierInTempList(SupplierModel supplier) {
    final index = suppliers.indexWhere((e) => e.id == supplier.id);
    if (index != -1) {
      suppliers[index] = supplier;
      notifyListeners();
    } else {
      ToastUtils.showToast(
          message: "Supplier not found", type: RequestState.error);
    }
  }

  Future searchByNameOrPhone(
    String query,
  ) async {
    if (query.trim() == "") {
      fetchSuppliersByBatch(batch: 20, offset: 0);
      return;
    } else {
      final response = await supplierRepository.searchByNameOrPhone(query);
      response.fold((l) {
        debugPrint(l.message);
      }, (r) {
        suppliers = r;
        notifyListeners();
      });
    }
  }

  Future<List<SupplierModel>> autoCompleteSupplierByName(String query) async {
    final response = await supplierRepository.searchByNameOrPhone(query);
    return response.fold((l) => [], (r) => r);
  }

  int _offset = 0;
  int _batchSize = 0;
  bool _isHasMoreData = true;

  List<SupplierModel> suppliers = [];
  RequestState fetchSuppliersByBatchRequestState = RequestState.success;
  Future fetchSuppliersByBatch({int? batch, int? offset}) async {
    if (fetchSuppliersByBatchRequestState == RequestState.loading) return;
// if on press customers
    if (batch != null && offset != null) {
      _offset = offset;
      _batchSize = batch;
      _isHasMoreData = true;
    }

    if (_isHasMoreData) {
      fetchSuppliersByBatchRequestState = RequestState.loading;
      notifyListeners();
      final customerRes = await supplierRepository.fetchCustomersByBatch(
          batchSize: _batchSize, offset: _offset);
      customerRes.fold(
        (l) {
          fetchSuppliersByBatchRequestState = RequestState.error;
          notifyListeners();
        },
        (r) {
          _offset += _batchSize;
          // if the returned list equal batch size , so maybe we have more data
          _isHasMoreData = r.length == _batchSize;
          suppliers =
              batch != null && offset != null ? r : [...suppliers, ...r];
          fetchSuppliersByBatchRequestState = RequestState.success;
          notifyListeners();
        },
      );
    }
  }
}
