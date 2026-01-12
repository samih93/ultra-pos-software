import 'package:desktoppossystem/models/category_model.dart';
import 'package:desktoppossystem/models/product_model.dart';
import 'package:desktoppossystem/models/reports/total_cost_price_model.dart';
import 'package:desktoppossystem/repositories/categories/category_repository.dart';
import 'package:desktoppossystem/repositories/categories/icategory_repository.dart';
import 'package:desktoppossystem/repositories/products/iproduct_repository.dart';
import 'package:desktoppossystem/repositories/products/product_repository.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final stockControllerProvider = ChangeNotifierProvider<StockController>((ref) {
  return StockController(
    ref: ref,
    productRepositoy: ref.read(productProviderRepository),
    categoryRepository: ref.read(categoryProviderRepository),
  );
});

final showActiveItemsProvider = StateProvider<bool>((ref) {
  return true;
});

final selectedStockCategoryProvider = StateProvider<CategoryModel?>((ref) {
  return null;
});

final futureProductStatsProvider = FutureProvider<ProductStatsModel>((
  ref,
) async {
  final category = ref.watch(selectedStockCategoryProvider);
  final res = await ref
      .read(productProviderRepository)
      .fetchProductsStats(categoryId: category?.id);
  return res.fold((l) {
    throw Exception(l.message);
  }, (r) => r);
});

class StockController extends ChangeNotifier {
  final Ref _ref;
  final IProductRepository _productRepositoy;
  final ICategoryRepository _categoryRepository;
  StockController({
    required Ref ref,
    required IProductRepository productRepositoy,
    required ICategoryRepository categoryRepository,
  }) : _ref = ref,
       _productRepositoy = productRepositoy,
       _categoryRepository = categoryRepository;

  deleteStockProductById(int productId) {
    stock.removeWhere((element) => element.id == productId);
    notifyListeners();
    _ref.refresh(futureProductStatsProvider);
  }

  restoreProductToStock(ProductModel product) {
    stock.add(product);
    _ref.refresh(futureProductStatsProvider);
  }

  // used after exit form stock
  clearStock() {
    stock.clear();
  }

  int _offset = 0;
  int _batchSize = 0;
  bool _isHasMoreData = true;

  RequestState getStockByBatchRequestState = RequestState.success;
  List<ProductModel> stock = [];

  Future getStockByBatch({int? batch, int? offset}) async {
    final categoryId = _ref.read(selectedStockCategoryProvider)?.id;

    if (getStockByBatchRequestState == RequestState.loading) return;
    // if on press stock
    if (batch != null && offset != null) {
      _offset = offset;
      _batchSize = batch;
      _isHasMoreData = true;
    }

    const int maxRecords = 3000;
    if (stock.length >= maxRecords) {
      _isHasMoreData = false; // Stop fetching
      getStockByBatchRequestState = RequestState.success;
      notifyListeners();
      return;
    }

    if (_isHasMoreData) {
      getStockByBatchRequestState = RequestState.loading;
      notifyListeners();
      final res = await _productRepositoy.getAllProducts(
        limit: _batchSize,
        offset: _offset,
        isStock: true,
        isDeleted: !_ref.read(showActiveItemsProvider),
        categoryId: categoryId,
      );
      res.fold(
        (l) {
          getStockByBatchRequestState = RequestState.error;
          notifyListeners();
        },
        (r) {
          _offset += _batchSize;
          // if the returned list equal batch size , so maybe we have more data
          _isHasMoreData = r.length == _batchSize;
          stock = batch != null && offset != null ? r : [...stock, ...r];
          getStockByBatchRequestState = RequestState.success;
          notifyListeners();
        },
      );
    }
  }

  //! update product by Id  from temp products
  updateStockById(ProductModel p) {
    for (var element in stock) {
      if (element.id == p.id) {
        element.name = p.name;
        element.sellingPrice = p.sellingPrice;
        element.originalSellingPrice = p.sellingPrice;
        element.profitRate = p.profitRate;
        element.costPrice = p.costPrice;
        element.barcode = p.barcode;
        element.qty = p.qty;
        element.warningAlert = p.warningAlert;
        element.enableNotification = p.enableNotification;
        element.isTracked = p.isTracked;
        element.discount = p.discount;
        element.expiryDate = p.expiryDate;
        break;
      }
    }
    notifyListeners();
  }

  //! update product by Id  from temp products
  addProductToTempStock(ProductModel p) {
    stock.add(p);
    notifyListeners();
  }

  RequestState getDownloadStockRequestState = RequestState.success;
  Future<List<ProductModel>> getAllStock() async {
    final categoryId = _ref.read(selectedStockCategoryProvider)?.id;

    List<ProductModel> list = [];
    getDownloadStockRequestState = RequestState.loading;
    notifyListeners();
    final res = await _productRepositoy.getAllStockGroupedByCategory(
      categoryId: categoryId,
    );

    res.fold(
      (l) {
        debugPrint(l.message);
        getDownloadStockRequestState = RequestState.error;
        notifyListeners();
      },
      (r) {
        list = r;
        getDownloadStockRequestState = RequestState.success;
        notifyListeners();
      },
    );
    return list;
  }

  bool isSortByQty = false;
  bool isSortByPrice = false;
  sortProductsByQty() {
    isSortByQty
        ? stock.sort(((a, b) => a.qty!.compareTo(b.qty!)))
        : stock.sort(((a, b) => b.qty!.compareTo(a.qty!)));

    isSortByQty = !isSortByQty;
    notifyListeners();
  }

  sortProductsByPrice() {
    isSortByPrice
        ? stock.sort(((a, b) => a.sellingPrice!.compareTo(b.sellingPrice!)))
        : stock.sort(((a, b) => b.sellingPrice!.compareTo(a.sellingPrice!)));

    isSortByPrice = !isSortByPrice;
    notifyListeners();
  }

  bool isSortByName = false;
  sortProductsByName() {
    isSortByName
        ? stock.sort(((a, b) => a.name!.compareTo(b.name!)))
        : stock.sort(((a, b) => b.name!.compareTo(a.name!)));

    isSortByName = !isSortByName;
    notifyListeners();
  }

  String lastSearchQuery = "";
  Future searchForAProductInStock(String query, {bool? isByName}) async {
    final categoryId = _ref.read(selectedStockCategoryProvider)?.id;
    lastSearchQuery = query.trim();

    if (query.trim() == "") {
      // if already cateogry selected , so return original products by categoryId
      // if (selectedCategory != null) {
      //   fetchProductsByCateogryId(selectedCategory!.id!);
      // } else {
      // if not category selected fetch first 30 records
      //  }

      getStockByBatch(batch: 30, offset: 0);

      return;
    } else {
      await _productRepositoy
          .searchByNameOrBarcode(
            query,
            categoryId: categoryId,
            isDeleted: !_ref.read(showActiveItemsProvider),
          )
          .then((value) {
            stock = value;
            sortProductList();
            notifyListeners();
          })
          .catchError((error) {
            debugPrint(error.toString());
          });
    }
  }

  sortProductList() {
    stock.sort((a, b) {
      // Sort by category first
      return a.name!.compareTo(b.name!);
    });
  }

  updateSelectedCategory(CategoryModel c) {
    _ref.read(selectedStockCategoryProvider.notifier).state = c;
  }

  Future onSelectCategory(CategoryModel categoryModel) async {
    _ref.read(selectedStockCategoryProvider.notifier).state = categoryModel;
    // get 30 on select category , the others shown on scroll
    await fetchProductsByCateogryId(categoryModel.id!, 30);
  }

  clearCategory() {
    _ref.read(selectedStockCategoryProvider.notifier).state = null;

    getStockByBatch(batch: 30, offset: 0);
  }

  Future fetchProductsByCateogryId(int categoryId, int batchSize) async {
    final res = await _productRepositoy.getProductsByCategoryId(
      categoryId,
      limit: batchSize,
    );
    res.fold(
      (l) {
        getStockByBatchRequestState = RequestState.error;
      },
      (r) {
        stock = r;
        _isHasMoreData = r.length == batchSize;

        getStockByBatchRequestState = RequestState.success;
        notifyListeners();
      },
    );
  }

  Future<List<CategoryModel>> fetchCategoriesByQuery(String query) async {
    List<CategoryModel> categories = [];
    final res = await _categoryRepository.fetchCategoriesByQuery(query);
    res.fold((l) {}, (r) {
      categories = r;
    });

    return categories;
  }
}
