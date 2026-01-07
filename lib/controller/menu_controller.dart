import 'package:desktoppossystem/models/category_model.dart';
import 'package:desktoppossystem/models/product_model.dart';
import 'package:desktoppossystem/models/setting_model.dart';
import 'package:desktoppossystem/repositories/menu_repository/menu_repository.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/toast_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MenuState {
  final RequestState updateCategoriesState;
  final RequestState deleteCategoryRequestState;
  final RequestState generateProductsWithImagesRequestState;
  final RequestState generateProductsSyncState;
  final RequestState createCategoryState;
  final RequestState updateCategoryState;
  final RequestState getAllCategoriesState;
  final RequestState getProductsState;
  final RequestState getSettingsState;
  final RequestState updateSettingsState;
  final List<CategoryModel> categories;
  final List<ProductModel> products;
  final CategoryModel? selectedCategory;
  final SettingModel? settingModel;
  final int currentOffset;
  final bool hasMoreProducts;
  final bool isLoadingMore;

  MenuState({
    this.updateCategoriesState = RequestState.success,
    this.deleteCategoryRequestState = RequestState.success,
    this.generateProductsWithImagesRequestState = RequestState.success,
    this.generateProductsSyncState = RequestState.success,
    this.createCategoryState = RequestState.success,
    this.updateCategoryState = RequestState.success,
    this.getAllCategoriesState = RequestState.success,
    this.getProductsState = RequestState.success,
    this.getSettingsState = RequestState.success,
    this.updateSettingsState = RequestState.success,
    this.categories = const [],
    this.products = const [],
    this.selectedCategory,
    this.settingModel,
    this.currentOffset = 0,
    this.hasMoreProducts = true,
    this.isLoadingMore = false,
  });

  MenuState copyWith({
    RequestState? updateCategoriesState,
    RequestState? generateProductsWithImagesRequestState,
    RequestState? generateProductsSyncState,
    RequestState? createCategoryState,
    RequestState? updateCategoryState,
    RequestState? getAllCategoriesState,
    RequestState? deleteCategoryRequestState,
    RequestState? deleteProductRequestState,
    RequestState? getProductsState,
    RequestState? getSettingsState,
    RequestState? updateSettingsState,
    List<CategoryModel>? categories,
    List<ProductModel>? products,
    CategoryModel? selectedCategory,
    SettingModel? settingModel,
    int? currentOffset,
    bool? hasMoreProducts,
    bool? isLoadingMore,
  }) {
    return MenuState(
      updateCategoriesState:
          updateCategoriesState ?? this.updateCategoriesState,
      generateProductsWithImagesRequestState:
          generateProductsWithImagesRequestState ??
          this.generateProductsWithImagesRequestState,
      generateProductsSyncState:
          generateProductsSyncState ?? this.generateProductsSyncState,
      createCategoryState: createCategoryState ?? this.createCategoryState,
      updateCategoryState: updateCategoryState ?? this.updateCategoryState,
      getAllCategoriesState:
          getAllCategoriesState ?? this.getAllCategoriesState,
      deleteCategoryRequestState:
          deleteCategoryRequestState ?? this.deleteCategoryRequestState,

      getProductsState: getProductsState ?? this.getProductsState,
      getSettingsState: getSettingsState ?? this.getSettingsState,
      updateSettingsState: updateSettingsState ?? this.updateSettingsState,
      categories: categories ?? this.categories,
      products: products ?? this.products,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      settingModel: settingModel ?? this.settingModel,
      currentOffset: currentOffset ?? this.currentOffset,
      hasMoreProducts: hasMoreProducts ?? this.hasMoreProducts,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

final menuControllerProvider =
    StateNotifierProvider.autoDispose<MenuController, MenuState>((ref) {
      return MenuController(ref.read(menuProviderRepository));
    });

class MenuController extends StateNotifier<MenuState> {
  final MenuRepository _menuRepository;

  MenuController(this._menuRepository) : super(MenuState()) {
    getAllCategories();
    getMenuSettings();
  }

  Future createMenuItem(ProductModel product) async {
    try {
      final response = await _menuRepository.createMenuItem(product);
      response.fold(
        (failure) {
          ToastUtils.showToast(
            message: failure.message,
            type: RequestState.error,
          );
        },
        (product) {
          ToastUtils.showToast(
            message: "Menu item created successfully",
            type: RequestState.success,
          );
          state = state.copyWith(products: [...state.products, product]);
        },
      );
    } catch (e) {
      ToastUtils.showToast(message: e.toString(), type: RequestState.error);
    }
  }

  /// Update a menu item
  Future updateMenuItem(ProductModel product) async {
    try {
      final response = await _menuRepository.updateMenuItem(product);
      response.fold((failure) {}, (success) {
        //update local product list
        final updatedProducts = state.products.map((p) {
          if (p.id == success.id) {
            return success;
          }
          return p;
        }).toList();
        state = state.copyWith(products: updatedProducts);
      });
    } catch (e) {
      ToastUtils.showToast(message: e.toString(), type: RequestState.error);
    }
  }

  Future createCategory(CategoryModel category) async {
    state = state.copyWith(createCategoryState: RequestState.loading);
    final response = await _menuRepository.createCategory(category);
    response.fold(
      (l) {
        state = state.copyWith(createCategoryState: RequestState.error);
      },
      (r) {
        state = state.copyWith(
          createCategoryState: RequestState.success,
          categories: [...state.categories, r],
        );
      },
    );
  }

  Future updateCategory(CategoryModel category) async {
    state = state.copyWith(updateCategoryState: RequestState.loading);
    final response = await _menuRepository.updateCategory(category);
    response.fold(
      (l) {
        state = state.copyWith(updateCategoryState: RequestState.error);
      },
      (r) {
        state = state.copyWith(updateCategoryState: RequestState.success);
      },
    );
  }

  Future<bool> deleteCategory(int categoryId) async {
    // Store original list for rollback
    final originalCategories = List<CategoryModel>.from(state.categories);

    // Optimistically remove from UI
    final updatedCategories = state.categories
        .where((cat) => cat.id != categoryId)
        .toList();
    state = state.copyWith(
      deleteCategoryRequestState: RequestState.loading,
      categories: updatedCategories,
    );

    // Try to delete from server
    final response = await _menuRepository.deleteCategory(categoryId);

    return response.fold(
      (failure) {
        // Rollback on failure
        state = state.copyWith(
          deleteCategoryRequestState: RequestState.error,
          categories: originalCategories,
        );

        return false;
      },
      (_) {
        state = state.copyWith(
          deleteCategoryRequestState: RequestState.success,
        );

        return true;
      },
    );
  }

  Future<bool> deleteProduct(int productId) async {
    // Store original list for rollback
    final originalProducts = List<ProductModel>.from(state.products);

    // Optimistically remove from UI
    final updatedProducts = state.products
        .where((prod) => prod.id != productId)
        .toList();
    state = state.copyWith(
      deleteProductRequestState: RequestState.loading,
      products: updatedProducts,
    );

    // Try to delete from server
    final response = await _menuRepository.deleteProduct(productId);

    return response.fold(
      (failure) {
        // Rollback on failure
        state = state.copyWith(
          deleteProductRequestState: RequestState.error,
          products: originalProducts,
        );

        return false;
      },
      (_) {
        state = state.copyWith(deleteProductRequestState: RequestState.success);

        return true;
      },
    );
  }

  Future getAllCategories() async {
    state = state.copyWith(getAllCategoriesState: RequestState.loading);
    final response = await _menuRepository.getAllCategories();
    response.fold(
      (l) {
        state = state.copyWith(getAllCategoriesState: RequestState.error);
      },
      (r) {
        state = state.copyWith(
          getAllCategoriesState: RequestState.success,
          categories: r,
          selectedCategory: null,
        );
      },
    );
  }

  Future syncCategoryOrder(List<CategoryModel> categories) async {
    state = state.copyWith(updateCategoriesState: RequestState.loading);

    final response = await _menuRepository.syncCategoryOrder(categories);
    response.fold(
      (l) {
        ToastUtils.showToast(message: l.message, type: RequestState.error);
        state = state.copyWith(updateCategoriesState: RequestState.error);
      },
      (r) {
        state = state.copyWith(
          updateCategoriesState: RequestState.success,
          categories: categories, // Update state with new order
        );
      },
    );
  }

  Future syncProductsOrder(List<ProductModel> products) async {
    // Update UI immediately (optimistic update)
    state = state.copyWith(
      products: products,
      getProductsState: RequestState.loading,
    );

    final response = await _menuRepository.syncProductsOrder(products);
    response.fold(
      (l) {
        ToastUtils.showToast(message: l.message, type: RequestState.error);
        state = state.copyWith(getProductsState: RequestState.error);
      },
      (r) {
        state = state.copyWith(getProductsState: RequestState.success);
      },
    );
  }

  Future updateCategories(List<CategoryModel> categories) async {
    state = state.copyWith(updateCategoriesState: RequestState.loading);

    final response = await _menuRepository.updateCategories(categories);
    response.fold(
      (l) {
        ToastUtils.showToast(message: l.message, type: RequestState.error);
        state = state.copyWith(updateCategoriesState: RequestState.error);
      },
      (r) {
        state = state.copyWith(updateCategoriesState: RequestState.success);
      },
    );
  }

  // Select category and fetch its products
  Future selectCategory(CategoryModel category) async {
    state = state.copyWith(
      selectedCategory: category,
      products: [],
      currentOffset: 0,
      hasMoreProducts: true,
      isLoadingMore: false,
      getProductsState: RequestState.loading,
    );
    await fetchProducts(category.id!, limit: 20, offset: 0);
  }

  // Fetch products by category with pagination
  Future fetchProducts(int categoryId, {int limit = 20, int offset = 0}) async {
    if (offset == 0) {
      state = state.copyWith(getProductsState: RequestState.loading);
    }

    final response = await _menuRepository.getMenuItemsByCategoryId(
      categoryId,
      limit: limit,
      offset: offset,
    );

    response.fold(
      (failure) {
        state = state.copyWith(
          getProductsState: RequestState.error,
          isLoadingMore: false,
        );
      },
      (data) {
        final List<ProductModel> newProducts =
            data['products'] as List<ProductModel>;
        final bool hasNextPage = data['hasNextPage'] as bool;

        final updatedProducts = offset == 0
            ? newProducts
            : [...state.products, ...newProducts];

        state = state.copyWith(
          getProductsState: RequestState.success,
          products: updatedProducts,
          currentOffset: offset + newProducts.length,
          hasMoreProducts: hasNextPage,
          isLoadingMore: false,
        );
      },
    );
  }

  // Load more products when reaching end of list
  Future loadMoreProducts() async {
    if (state.selectedCategory != null &&
        state.hasMoreProducts &&
        !state.isLoadingMore &&
        state.getProductsState != RequestState.loading) {
      // Set loading flag immediately to prevent duplicate calls
      state = state.copyWith(isLoadingMore: true);

      await fetchProducts(
        state.selectedCategory!.id!,
        limit: 20,
        offset: state.currentOffset,
      );
    }
  }

  Future syncProductsToCloud() async {
    state = state.copyWith(
      generateProductsWithImagesRequestState: RequestState.loading,
    );
    final response = await _menuRepository.syncProductsWithImagesToCloud();
    response.fold(
      (l) {
        ToastUtils.showToast(
          type: RequestState.error,
          message: "Failed to generate descriptions",
        );
        state = state.copyWith(
          generateProductsWithImagesRequestState: RequestState.error,
        );
      },
      (r) {
        ToastUtils.showToast(
          type: RequestState.success,
          message: "Product descriptions generated successfully",
        );
        state = state.copyWith(
          generateProductsWithImagesRequestState: RequestState.success,
        );
      },
    );
  }

  Future syncProductsToCloudWithoutImages() async {
    state = state.copyWith(generateProductsSyncState: RequestState.loading);
    final response = await _menuRepository.syncProductsToCloudWithoutImages();
    response.fold(
      (l) {
        ToastUtils.showToast(
          type: RequestState.error,
          message: "Failed to generate descriptions",
        );
        state = state.copyWith(generateProductsSyncState: RequestState.error);
      },
      (r) {
        ToastUtils.showToast(
          type: RequestState.success,
          message: "Product descriptions generated successfully",
        );
        state = state.copyWith(generateProductsSyncState: RequestState.success);
      },
    );
  }

  Future toggleActive(int id, bool isActive) async {
    final response = await _menuRepository.toggleActive(id, isActive);
    response.fold(
      (l) {
        ToastUtils.showToast(message: l.message, type: RequestState.error);
      },
      (r) {
        ToastUtils.showToast(
          message: isActive
              ? "Menu item activated successfully"
              : "Menu item deactivated successfully",
          type: RequestState.success,
        );
      },
    );
  }

  Future getMenuSettings() async {
    state = state.copyWith(getSettingsState: RequestState.loading);
    final response = await _menuRepository.getMenuSettings();
    response.fold(
      (l) {
        state = state.copyWith(getSettingsState: RequestState.error);
      },
      (settingModel) {
        state = state.copyWith(
          getSettingsState: RequestState.success,
          settingModel: settingModel,
        );
      },
    );
  }

  Future updateMenuSettings(SettingModel setting) async {
    state = state.copyWith(updateSettingsState: RequestState.loading);
    final response = await _menuRepository.updateMenuSettings(setting);
    response.fold(
      (l) {
        state = state.copyWith(updateSettingsState: RequestState.error);
      },
      (updatedSetting) {
        state = state.copyWith(
          updateSettingsState: RequestState.success,
          settingModel: updatedSetting,
        );
      },
    );
  }

  Future toggleProductActive(int id, bool isActive) async {
    final response = await _menuRepository.toggleProductActive(id, isActive);
    response.fold(
      (l) {
        ToastUtils.showToast(message: l.message, type: RequestState.error);
      },
      (_) {
        state = state.copyWith(
          products: state.products.map((product) {
            if (product.id == id) {
              return product.copyWith(isActive: isActive);
            }
            return product;
          }).toList(),
        );
        ToastUtils.showToast(
          message: isActive
              ? "Product activated successfully"
              : "Product deactivated successfully",
          type: RequestState.success,
        );
      },
    );
  }
}
