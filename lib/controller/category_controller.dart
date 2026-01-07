// ignore_for_file: use_build_context_synchronously

import 'package:desktoppossystem/controller/product_controller.dart';
import 'package:desktoppossystem/repositories/categories/category_repository.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_screen.dart';
import 'package:desktoppossystem/screens/stock_screen/stock_controller.dart';
import 'package:desktoppossystem/shared/constances/screens_title_constant.dart';
import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:desktoppossystem/shared/utils/toast_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:desktoppossystem/models/category_model.dart';
import 'package:desktoppossystem/repositories/categories/icategory_repository.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final categoryControllerProvider = ChangeNotifierProvider<CategoryController>((
  ref,
) {
  return CategoryController(
    ref: ref,
    categoryRepository: ref.read(categoryProviderRepository),
  );
});

class CategoryController extends ChangeNotifier {
  final Ref _ref;
  final ICategoryRepository _categoryRepository;

  CategoryController({
    required Ref ref,
    required ICategoryRepository categoryRepository,
  }) : _ref = ref,
       _categoryRepository = categoryRepository {
    getAllCategories();
  }

  //! get all categories
  List<CategoryModel> categories = [];
  RequestState getCategoriesRequestState = RequestState.success;
  CategoryModel? selectedCategory;

  Future getAllCategories() async {
    getCategoriesRequestState = RequestState.loading;
    notifyListeners();

    final response = await _categoryRepository.getAllCategories();
    response.fold(
      (l) {
        getCategoriesRequestState = RequestState.error;
        notifyListeners();
      },
      (r) {
        categories = r;
        getCategoriesRequestState = RequestState.success;
        notifyListeners();
      },
    );
  }

  categoryNameById(int categoryId) {
    return categories.where((c) => c.id == categoryId).firstOrNull?.name ??
        "Unknown Category";
  }

  //! on select category
  onselectcategory(CategoryModel c) {
    // Create a copy of the list to maintain sort order
    List<CategoryModel> updatedCategories = [];

    for (var element in categories) {
      if (element.id == c.id) {
        // Toggle selection for the clicked category
        final updatedElement = element.copyWith(selected: !element.selected!);
        updatedCategories.add(updatedElement);

        if (updatedElement.selected == true) {
          selectedCategory = updatedElement;
        } else {
          selectedCategory = null;
        }
      } else {
        // Deselect all other categories while preserving their properties
        final updatedElement = element.copyWith(selected: false);
        updatedCategories.add(updatedElement);
      }
    }

    // Replace the categories list while maintaining the original order
    categories = updatedCategories;
    notifyListeners();
  }

  //! clear category selection
  void clearCategorySelection() {
    for (var element in categories) {
      element.selected = false;
    }
    selectedCategory = null;
  }

  //!NOTE : for add, edit, delete category
  String statusMessage = "";
  RequestState requestState = RequestState.success;

  //! update category
  Future<CategoryModel> updateCategory(
    CategoryModel c,
    BuildContext context,
  ) async {
    requestState = RequestState.loading;
    notifyListeners();

    final updateRes = await _categoryRepository.updateCategory(c);
    updateRes.fold(
      (l) {
        requestState = RequestState.error;
        notifyListeners();

        ToastUtils.showToast(
          message: l.message.toString(),
          type: RequestState.success,
        );
      },
      (r) {
        updateCategoryById(r);

        // Re-sort the categories list to maintain proper order after update
        categories.sort((a, b) {
          // First sort by sort field, then by id if sort is the same
          int sortComparison = (a.sort ?? 0).compareTo(b.sort ?? 0);
          if (sortComparison != 0) return sortComparison;
          return (a.id ?? 0).compareTo(b.id ?? 0);
        });

        c = r;
        // for edit in stock
        if (_ref.read(currentMainScreenProvider) ==
            ScreenName.InventoryScreen) {
          _ref.read(selectedStockCategoryProvider.notifier).state = null;
          _ref.read(selectedStockCategoryProvider.notifier).state = r;
        }
        requestState = RequestState.success;
        notifyListeners();
        context.pop();
        ToastUtils.showToast(
          message: "category $successUpdatedStatusMessage",
          type: RequestState.success,
        );
        if (_ref.read(mainControllerProvider).screenUI == ScreenUI.restaurant) {
          _ref.read(productControllerProvider).getAllProducts();
        }
      },
    );
    return c;
  }

  //! update category by Id  from temp cateogries
  updateCategoryById(CategoryModel updatedCategory) {
    // Find the category and update it while preserving the exact list order
    final targetIndex = categories.indexWhere(
      (cat) => cat.id == updatedCategory.id,
    );

    if (targetIndex != -1) {
      // Update the category using the correct sort value from the repository
      categories[targetIndex] = categories[targetIndex].copyWith(
        name: updatedCategory.name,
        color: updatedCategory.color,
        hideOnMenu: updatedCategory.hideOnMenu,
        sectionType: updatedCategory.sectionType,
        // Use the correct sort value from the repository (not the corrupted in-memory one)
        sort: updatedCategory.sort,
      );

      // Update selectedCategory reference if this was the selected one
      if (selectedCategory != null &&
          selectedCategory!.id == updatedCategory.id) {
        selectedCategory = categories[targetIndex];
      }
    }
  }

  //! add category
  Future addCategory(CategoryModel c, BuildContext context) async {
    requestState = RequestState.loading;
    notifyListeners();

    CategoryModel category = CategoryModel.second();

    final response = await _categoryRepository.addCategory(c);
    response.fold(
      (l) {
        requestState = RequestState.error;
        ToastUtils.showToast(
          message: l.message.toString(),
          type: RequestState.error,
        );
        notifyListeners();
      },
      (r) {
        category = r;
        context.pop();
        ToastUtils.showToast(
          message: "Category $successAddedStatusMessage",
          type: RequestState.success,
        );

        categories.add(category);

        requestState = RequestState.success;
        notifyListeners();
      },
    );
  }

  RequestState deleteCategoryRequestState =
      RequestState.success; // for delete category
  Future deleteCategory(int categoryId, BuildContext context) async {
    deleteCategoryRequestState = RequestState.loading;
    notifyListeners();
    final response = await _categoryRepository.deleteCategory(categoryId);
    response.fold(
      (l) {
        deleteCategoryRequestState = RequestState.error;
        notifyListeners();
        ToastUtils.showToast(
          message: l.message.toString(),
          type: RequestState.error,
        );
      },
      (r) {
        deletecategoryById(categoryId);

        context.pop();
        ToastUtils.showToast(
          message: "category $successDeletedStatusMessage",
          type: RequestState.success,
        );
        deleteCategoryRequestState = RequestState.success;
        notifyListeners();

        _ref
            .read(productControllerProvider)
            .deleteProductsByCategoryId(categoryId);
      },
    );
  }

  //! delete category by id from temp categories
  deletecategoryById(int categoryId) {
    categories.removeWhere((element) => element.id == categoryId);
  }

  void reSortList(int oldIndex, int newIndex) {
    if (oldIndex == newIndex) return;
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }
    final CategoryModel item = categories.removeAt(oldIndex);
    categories.insert(newIndex, item);

    // Update sort order while preserving all other properties including selection
    for (int i = 0; i < categories.length; i++) {
      categories[i] = categories[i].copyWith(sort: i);

      // Ensure selectedCategory reference is updated if it was moved
      if (selectedCategory != null &&
          categories[i].id == selectedCategory!.id) {
        selectedCategory = categories[i];
      }
    }

    notifyListeners();
    _ref
        .read(productControllerProvider)
        .updateProductOrderByCategory(newCategoryOrder: categories);
    //  update in database
  }

  saveNewCategoriesSort() {
    _ref
        .read(categoryProviderRepository)
        .reOrderCategories(categories: categories);
  }
}
