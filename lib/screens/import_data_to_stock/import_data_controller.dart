import 'package:desktoppossystem/models/category_model.dart';
import 'package:desktoppossystem/models/product_model.dart';
import 'package:desktoppossystem/repositories/products/iproduct_repository.dart';
import 'package:desktoppossystem/repositories/products/product_repository.dart';
import 'package:desktoppossystem/shared/utils/toast_utils.dart';

import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:excel/excel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final importDataControllerProvider =
    ChangeNotifierProvider<ImportDataController>((ref) {
      return ImportDataController(
        ref: ref,
        productRepositoy: ref.read(productProviderRepository),
      );
    });

class ImportDataController extends ChangeNotifier {
  final IProductRepository _productRepositoy;
  ImportDataController({
    required Ref ref,
    required IProductRepository productRepositoy,
  }) : _productRepositoy = productRepositoy;
  CategoryModel? selectedCategory;
  Future onSelectCategory(CategoryModel categoryModel) async {
    selectedCategory = categoryModel;
    notifyListeners();
  }

  clearCategory() {
    selectedCategory = null;
    notifyListeners();
  }

  List<ProductModel> products = [];
  RequestState readExcelRequestState = RequestState.success;
  Future readExcelProducts(List<int> bytes) async {
    products = [];
    uniqueBarcodes = {};
    readExcelRequestState = RequestState.loading;
    notifyListeners();

    try {
      await Future.delayed(Duration.zero)
          .then((value) {
            var excel = Excel.decodeBytes(bytes);

            for (var table in excel.tables.keys) {
              for (var i = 1; i < excel.tables[table]!.maxRows; i++) {
                final row = excel.tables[table]!.row(i);

                ProductModel productModel = ProductModel(
                  isActive: true,
                  id: 0,
                  name: row[0] != null ? row[0]!.value.toString().trim() : "",
                  barcode: row[1] != null
                      ? row[1]!.value.toString().trim()
                      : "",
                  costPrice: row[2] != null
                      ? double.tryParse(row[2]!.value.toString().trim()) != null
                            ? double.parse(
                                row[2]!.value.toString(),
                              ).formatDouble()
                            : 0
                      : 0,
                  sellingPrice: row[3] != null
                      ? double.tryParse(row[3]!.value.toString().trim()) != null
                            ? double.parse(
                                row[3]!.value.toString(),
                              ).formatDouble()
                            : 0
                      : 0,
                  qty: row[4] != null
                      ? double.tryParse(row[4]!.value.toString().trim()) != null
                            ? double.parse(row[4]!.value.toString())
                            : 0
                      : 0,
                  isTracked: row[5] != null
                      ? bool.tryParse(row[5]!.value.toString()) ?? false
                      : false,
                  selected: false,
                  categoryId: selectedCategory?.id,
                );
                double profitRate =
                    ((productModel.sellingPrice! - productModel.costPrice!) /
                        productModel.costPrice!) *
                    100;
                productModel = productModel.copyWith(
                  profitRate: profitRate.formatDouble(),
                );

                products.add(productModel);
                // ! add barcode in set to check if i have duplicates
                if (productModel.barcode != null &&
                    productModel.barcode!.isNotEmpty) {
                  uniqueBarcodes.add(productModel.barcode.toString());
                }
              }
            }
          })
          .then((value) {
            readExcelRequestState = RequestState.success;
            notifyListeners();
          });
    } catch (e) {
      debugPrint(e.toString());
      readExcelRequestState = RequestState.error;

      notifyListeners();
    }
  }

  Set<String> uniqueBarcodes = <String>{};

  RequestState bulkAddRequestState = RequestState.success;
  Future addProducts(BuildContext context) async {
    bulkAddRequestState = RequestState.loading;
    notifyListeners();
    if (products.length == uniqueBarcodes.length) {
      final res = await _productRepositoy.addBulkProducts(products);
      res.fold(
        (l) {
          ToastUtils.showToast(
            type: RequestState.error,
            message: l.message,
            duration: const Duration(seconds: 4),
          );
        },
        (r) {
          ToastUtils.showToast(
            type: RequestState.success,
            message: "${products.length} Products inserted",
            duration: const Duration(seconds: 4),
          );
          products.clear();
          notifyListeners();
        },
      );
    } else {
      ToastUtils.showToast(
        type: RequestState.error,
        message:
            "${products.length - uniqueBarcodes.length} barcode duplicated",
        duration: const Duration(seconds: 4),
      );
    }
  }
}
