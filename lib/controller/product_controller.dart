// ignore_for_file: unused_result

import 'package:desktoppossystem/models/category_model.dart';
import 'package:desktoppossystem/models/product_model.dart';
import 'package:desktoppossystem/models/tracked_related_product.dart';
import 'package:desktoppossystem/repositories/products/iproduct_repository.dart';
import 'package:desktoppossystem/repositories/products/product_repository.dart';
import 'package:desktoppossystem/screens/add_edit_product/add_edit_product_controller.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_screen.dart';
import 'package:desktoppossystem/screens/notifications_screen/notification_controller.dart';
import 'package:desktoppossystem/screens/stock_screen/stock_controller.dart';
import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:desktoppossystem/shared/utils/toast_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final latestAddedProductProvider = StateProvider<ProductModel?>((ref) {
  return null;
});

final quiverSelectionProductsProvider = FutureProvider<List<ProductModel>>((
  ref,
) async {
  final response = await ref
      .read(productProviderRepository)
      .fetchQuickSelectionProducts();
  return response.fold(
    (l) {
      debugPrint(l.message);
      return [];
    },
    (r) {
      return r;
    },
  );
});

final productControllerProvider = ChangeNotifierProvider<ProductController>((
  ref,
) {
  return ProductController(
    ref: ref,
    productRepositoy: ref.read(productProviderRepository),
  );
});

class ProductController extends ChangeNotifier {
  final IProductRepository _productRepositoy;
  final Ref _ref;
  ProductController({
    required Ref ref,
    required IProductRepository productRepositoy,
  }) : _ref = ref,
       _productRepositoy = productRepositoy {
    if (ref.watch(mainControllerProvider).screenUI == ScreenUI.restaurant) {
      getAllProducts(limit: 100);
    }
  }

  List<ProductModel> products = [];
  List<ProductModel> originalproducts = [];

  RequestState getProductsRequestState = RequestState.success;
  // if limit null ==> 100 by default
  Future getAllProducts({int? limit}) async {
    products = [];
    originalproducts = [];
    getProductsRequestState = RequestState.loading;
    notifyListeners();
    final res = await _productRepositoy.getAllProducts(limit: limit);

    res.fold(
      (l) {
        getProductsRequestState = RequestState.error;
        notifyListeners();
      },
      (r) {
        originalproducts = List<ProductModel>.from(r);
        products = List<ProductModel>.from(r);
        sortProductList();

        getProductsRequestState = RequestState.success;
        notifyListeners();
      },
    );
  }

  RequestState getStockRequestState = RequestState.success;

  RequestState getDownloadStockRequestState = RequestState.success;
  Future<List<ProductModel>> getAllStock() async {
    List<ProductModel> stock = [];
    getDownloadStockRequestState = RequestState.loading;
    notifyListeners();
    final res = await _productRepositoy.getAllProducts(
      limit: 100000000000,
      isStock: true,
    );

    res.fold(
      (l) {
        getDownloadStockRequestState = RequestState.error;
        notifyListeners();
      },
      (r) {
        stock = r;
        getDownloadStockRequestState = RequestState.success;
        notifyListeners();
      },
    );
    return stock;
  }

  bool isSortByQty = false;
  bool isSortByPrice = false;

  //! filter product by category selected
  Future onselectcategory(CategoryModel c) async {
    getProductsRequestState = RequestState.loading;
    notifyListeners();
    //! if category already selected we need to reset products
    if (c.selected == true) {
      products = originalproducts;
      getProductsRequestState = RequestState.success;
    } else {
      final res = await _productRepositoy.getProductsByCategoryId(c.id!);
      res.fold(
        (l) {
          products = originalproducts;
          getProductsRequestState = RequestState.error;
        },
        (r) {
          products = r;
          getProductsRequestState = RequestState.success;
        },
      );
    }
    sortProductList();

    notifyListeners();
  }

  // ! without clocking on categroy
  fetchProductByCategoryId(int categoryId) async {
    getProductsRequestState = RequestState.loading;
    notifyListeners();
    //! if category already selected we need to reset products

    final res = await _productRepositoy.getProductsByCategoryId(categoryId);
    res.fold(
      (l) {
        products = originalproducts;
        getProductsRequestState = RequestState.error;
      },
      (r) {
        products = r;
        getProductsRequestState = RequestState.success;
      },
    );

    sortProductList();

    notifyListeners();
  }

  clearProductsSelection() {
    products = originalproducts;
    notifyListeners();
  }

  sortProductList() {
    products.sort((a, b) {
      // 1. First sort by category (if needed)
      final categoryComparison = a.categorySort!.compareTo(b.categorySort!);
      if (categoryComparison != 0) return categoryComparison;

      // 2. Then sort by product's sortOrder (or productSequence)
      final orderComparison = a.sortOrder!.compareTo(b.sortOrder!);
      if (orderComparison != 0) return orderComparison;

      // 3. Finally, sort by ID (fallback)
      return a.id!.compareTo(b.id!);
    });

    // Apply the same sorting to originalproducts (if needed)
    originalproducts.sort((a, b) {
      final categoryComparison = a.categorySort!.compareTo(b.categorySort!);
      if (categoryComparison != 0) return categoryComparison;

      final orderComparison = a.sortOrder!.compareTo(b.sortOrder!);
      if (orderComparison != 0) return orderComparison;
      if (a.id == null || b.id == null) return 0;
      return a.id!.compareTo(b.id!);
    });
  }

  // on change category order
  void updateProductOrderByCategory({
    required List<CategoryModel> newCategoryOrder,
  }) {
    final categoryIdToOrder = {
      for (var cat in newCategoryOrder)
        cat.id: cat.sort, // Map: {categoryId → newOrder}
    };
    final updatedProducts = originalproducts.map((product) {
      final newOrder = categoryIdToOrder[product.categoryId];
      newOrder != null ? product.categorySort = newOrder : product;
      return product;
    }).toList();

    // Update the original list (if needed)
    originalproducts = updatedProducts;
    products = updatedProducts;

    sortProductList();
    notifyListeners();
  }

  //! search in  products by name
  Future<List<ProductModel>> searchForAProduct(
    String query, {
    bool? isForBarcode,
  }) async {
    if (query.trim() == '') {
      products = originalproducts;
    } else {
      await _productRepositoy
          .searchByNameOrBarcode(
            query.toUpperCase(),
            isForBarcode: isForBarcode,
          )
          .then((value) {
            products = value;
          })
          .catchError((error) {
            debugPrint(error.toString());
          });
    }

    sortProductList();
    notifyListeners();
    return products;
  }

  Future<ProductModel?> fetchProductByBarcode(String barcode) async {
    // String cleanedBarcode = barcode.replaceAll(' ', '').trim();
    String cleanedBarcode = barcode.replaceAll(RegExp(r'\s+'), '').trim();

    return await _productRepositoy.getProductByBarcode(cleanedBarcode);
  }

  Future<ProductModel?> fetchProductById(int id) async {
    return await _productRepositoy.getProduct(id);
  }

  //! clear search
  void resetProductList() {
    products = originalproducts;
    notifyListeners();
  }

  //!NOTE : for add, edit, delete product
  String statusMessage = "";
  RequestState updateRequestState = RequestState.success;

  //! update product
  Future<ProductModel> updateProduct({
    required ProductModel p,
    required List<TrackedRelatedProductModel> trackedRelatedProductModel,
    bool? isFromStock,
    bool? fromNotifications,
    required BuildContext context,
  }) async {
    updateRequestState = RequestState.loading;
    notifyListeners();
    var product = ProductModel.second();
    final res = await _productRepositoy.updateProduct(
      p,
      trackedRelatedProductModel,
    );
    res.fold(
      (l) {
        updateRequestState = RequestState.error;
        notifyListeners();
        ToastUtils.showToast(type: RequestState.error, message: l.message);
      },
      (r) {
        if (r.id != null) {
          product = r;
          _ref.refresh(marketNotificationCountProvider);

          if (_ref.read(mainControllerProvider).screenUI ==
              ScreenUI.restaurant) {
            // ! this will update current product list
            getAllProducts(limit: 200);
            fetchProductByCategoryId(product.categoryId ?? 0);
          }
          // update product in stock if i am in stock
          if (isFromStock == true) {
            final stockQuery = _ref
                .read(stockControllerProvider)
                .lastSearchQuery;
            if (stockQuery.isNotEmpty) {
              _ref
                  .read(stockControllerProvider)
                  .searchForAProductInStock(stockQuery);
            } else {
              _ref.read(stockControllerProvider).updateStockById(product);
            }

            _ref.refresh(futureProductStatsProvider);
          }

          context.pop();
          _ref.refresh(quiverSelectionProductsProvider);
          _ref.invalidate(addEditProductControllerProvider);
          _ref.read(barcodeListenerEnabledProvider.notifier).state = true;

          ToastUtils.showToast(
            type: RequestState.success,
            message: "product $successUpdatedStatusMessage",
          );
          updateRequestState = RequestState.success;
          sortProductList();
          if (fromNotifications == true) {
            //! after updating from notification we need to refresh notifications
            refreshNotifications();
          }
          notifyListeners();
        }
      },
    );

    return product;
  }

  //! delete product by id from temp products
  deleteproductById(int productId) {
    products.removeWhere((element) => element.id == productId);
    originalproducts.removeWhere((element) => element.id == productId);
    sortProductList();
    notifyListeners();
  }

  restoreProductToTempList(ProductModel product) {
    products.add(product);
    originalproducts.add(product);

    sortProductList();
    notifyListeners();
  }

  deleteProductsByCategoryId(int categoryId) {
    products.removeWhere((element) => element.categoryId == categoryId);
    originalproducts.removeWhere((element) => element.categoryId == categoryId);
    sortProductList();
    notifyListeners();
  }

  resetState() {
    updateRequestState = RequestState.success;
    addProductRequestState = RequestState.success;
    notifyListeners();
  }

  //!! add category
  RequestState addProductRequestState = RequestState.success;
  Future<ProductModel> addProduct(
    ProductModel p,
    List<TrackedRelatedProductModel> trackedRelatedProductModel,
    BuildContext context,
  ) async {
    addProductRequestState = RequestState.loading;
    notifyListeners();

    final res = await _productRepositoy.addProduct(
      p,
      trackedRelatedProductModel,
    );
    var product = ProductModel.second();
    res.fold(
      (l) {
        addProductRequestState = RequestState.error;
        notifyListeners();
        ToastUtils.showToast(type: RequestState.error, message: l.message);
      },
      (r) {
        _ref.refresh(futureProductStatsProvider);

        _ref.read(latestAddedProductProvider.notifier).state = r.cloneWithoutId(
          id: null,
        );

        product = r;
        product = product.copyWith(
          id: r.id,
          categorySort: r.categorySort,
          expiryDate: p.expiryDate ?? '',
        );
        //!! add product in the temp list of products
        product.selected = false;
        //! added to temp products
        if (_ref.read(mainControllerProvider).screenUI == ScreenUI.restaurant) {
          //! and original product setted in initialize so we need to add it to the original list
          originalproducts.add(product);

          fetchProductByCategoryId(product.categoryId ?? 0);
        } else {
          _ref.read(stockControllerProvider).addProductToTempStock(product);
        }

        // !after adding product , applly orderby categoryId
        sortProductList();

        addProductRequestState = RequestState.success;
        statusMessage = "product $successAddedStatusMessage";

        context.pop();
        _ref.invalidate(addEditProductControllerProvider);
        _ref.read(barcodeListenerEnabledProvider.notifier).state = true;

        ToastUtils.showToast(
          message: "product $successAddedStatusMessage",
          type: RequestState.success,
        );

        notifyListeners();
      },
    );

    return product;
  }

  RequestState deleteProductRequestState = RequestState.success;
  Future deleteProduct(
    int productId,
    BuildContext context, {
    bool? isFromStock,
  }) async {
    deleteProductRequestState = RequestState.loading;
    notifyListeners();
    final res = await _productRepositoy.deleteProduct(productId);
    res.fold(
      (l) {
        deleteProductRequestState = RequestState.error;
        notifyListeners();
        ToastUtils.showToast(message: l.message, type: RequestState.error);
      },
      (r) {
        _ref.refresh(futureProductStatsProvider);
        deleteproductById(productId);
        ToastUtils.showToast(
          message: "product $successDeletedStatusMessage",
          type: RequestState.success,
        );
        deleteProductRequestState = RequestState.success;
        debugPrint("isFromStock $isFromStock");
        if (isFromStock == true) {
          _ref.read(stockControllerProvider).deleteStockProductById(productId);
        } else {
          sortProductList();
        }

        notifyListeners();
      },
    );
  }

  RequestState restoreProductRequestState = RequestState.success;
  Future restoreProduct(int productId) async {
    restoreProductRequestState = RequestState.loading;
    notifyListeners();
    final res = await _productRepositoy.restoreProduct(productId);
    res.fold(
      (l) {
        restoreProductRequestState = RequestState.error;
        notifyListeners();
        ToastUtils.showToast(message: l.message, type: RequestState.error);
      },
      (r) {
        _ref.refresh(futureProductStatsProvider);
        restoreProductToTempList(r);
        ToastUtils.showToast(
          message: "product $successRestoredStatusMessage",
          type: RequestState.success,
        );
        restoreProductRequestState = RequestState.success;
        _ref
            .read(stockControllerProvider)
            .getStockByBatch(batch: 30, offset: 0);

        notifyListeners();
      },
    );
  }

  Future increaseDecreaseListOfProducts({
    required List<ProductModel> list,
    required bool isForDecrease,
  }) async {
    final res = await _productRepositoy.increasedecreaseProductQty(
      products: list,
      isForDescrease: isForDecrease,
    );
    res.fold((l) => debugPrint(l.message), (r) {
      //! decrease qty in temp product list wihtout getting the new data
      increaseDecreasProductQtyInTempProductList(
        list: list,
        isForDecrease: isForDecrease,
      );
    });
  }

  // ! after adding service we need to descrease the qty in temp product list
  //! this function will update products data in view without getting all new products data
  Future increaseDecreasProductQtyInTempProductList({
    required List<ProductModel> list,
    required bool isForDecrease,
  }) async {
    if (list.any((element) => element.isTracked == true)) {
      for (var basketItem in list) {
        if (basketItem.isTracked == true) {
          for (var element in originalproducts) {
            if (element.id == basketItem.id) {
              element.qty = isForDecrease
                  ? element.qty! - basketItem.qty!
                  : element.qty! + basketItem.qty!;
            }
          }
        } else {
          //! i dont need to calculate in temp cz  its in stock after pressing stock it will display new data
          debugPrint("not tracked");
          // ! check if exist  related track
        }
      }
    }

    notifyListeners();
  }

  // user in restaurant stock
  RequestState updateCostRequestState = RequestState.success;
  Future updateCostPrice({required double cost, required int productId}) async {
    updateCostRequestState = RequestState.loading;
    notifyListeners();
    final updateResponse = await _ref
        .read(productProviderRepository)
        .updateProductCost(cost: cost, productId: productId);

    updateResponse.fold(
      (l) {
        updateCostRequestState = RequestState.error;
        notifyListeners();
        ToastUtils.showToast(message: l.message, type: RequestState.error);
      },
      (r) {
        updateCostRequestState = RequestState.success;
        notifyListeners();
        ToastUtils.showToast(
          message: "Cost updated successfully",
          type: RequestState.success,
        );
      },
    );
  }

  RequestState setAllProductsActiveRequestState = RequestState.success;
  Future setAllProductsAsActive() async {
    setAllProductsActiveRequestState = RequestState.loading;
    notifyListeners();
    final response = await _productRepositoy.setAllProductsAsActive();
    response.fold(
      (l) {
        setAllProductsActiveRequestState = RequestState.error;
        notifyListeners();
        ToastUtils.showToast(type: RequestState.error, message: l.message);
      },
      (r) {
        setAllProductsActiveRequestState = RequestState.success;
        notifyListeners();
        ToastUtils.showToast(
          type: RequestState.success,
          message: "operation successfully",
        );
      },
    );
  }

  void reSortList(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final ProductModel item = products.removeAt(oldIndex);
    products.insert(newIndex, item);
    for (int i = 0; i < products.length; i++) {
      products[i] = products[i].copyWith(id: products[i].id, sortOrder: i);
    }

    //update original products
    for (final product in products) {
      final index = originalproducts.indexWhere((p) => p.id == product.id);
      if (index != -1) {
        originalproducts[index] = originalproducts[index].copyWith(
          id: originalproducts[index].id,
          sortOrder: product.sortOrder,
        );
      }
    }
    notifyListeners();
  }

  saveNewProductsSortOrder() {
    _ref.read(productProviderRepository).reOrderProducts(products: products);
  }

  Future addProductToQuickSelection(int productId) async {
    final response = await _productRepositoy.addQuickSelectionProduct(
      productId,
    );
    response.fold(
      (l) {
        if (l.message.contains("UNIQUE constraint failed")) {
          ToastUtils.showToast(
            type: RequestState.error,
            message: "Product already in quick selection",
          );
          return;
        }
      },
      (r) {
        // ToastUtils.showToast(
        //     type: RequestState.success,
        //     message: "Product added to quick selection");
        _ref.refresh(quiverSelectionProductsProvider);
      },
    );
  }

  Future removeProductToQuickSelection(int productId) async {
    final response = await _productRepositoy.removeQuickSelectionProduct(
      productId,
    );
    response.fold((l) {}, (r) {
      _ref.refresh(quiverSelectionProductsProvider);
    });
  }

  Future reorderQuickSelectionProducts(
    int oldIndex,
    int newIndex,
    List<ProductModel> currentList,
  ) async {
    if (oldIndex == newIndex) return;
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    // Create a copy of the list to reorder
    final reorderedList = List<ProductModel>.from(currentList);
    final ProductModel item = reorderedList.removeAt(oldIndex);
    reorderedList.insert(newIndex, item);

    // Update sortOrder for each product in the new order
    for (int i = 0; i < reorderedList.length; i++) {
      reorderedList[i] = reorderedList[i].copyWith(sortOrder: i);
    }
    // Save the new order to database
    final response = await _productRepositoy.reorderQuickSelectionProducts(
      reorderedList,
    );
    response.fold(
      (l) {
        ToastUtils.showToast(
          type: RequestState.error,
          message: "Failed to reorder products",
        );
      },
      (r) {
        // Refresh the provider to show updated order
        _ref.refresh(quiverSelectionProductsProvider);
      },
    );
  }
}
