import 'package:desktoppossystem/models/category_model.dart';
import 'package:desktoppossystem/models/failure_model.dart';
import 'package:desktoppossystem/repositories/categories/icategory_repository.dart';
import 'package:desktoppossystem/shared/constances/app_endpoint.dart';
import 'package:desktoppossystem/shared/services/dependency_injection.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/toast_utils.dart';
import 'package:desktoppossystem/shared/utils/type_def.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import '../../shared/constances/table_constant.dart';

final categoryProviderRepository = Provider((ref) {
  return CategoryRepository(ref);
});

class CategoryRepository extends ICategoryRepository {
  final Ref ref;
  CategoryRepository(this.ref);
  @override
  FutureEither<List<CategoryModel>> getAllCategories() async {
    try {
      final response = await ref
          .read(ultraPosDioProvider)
          .getData(endPoint: AppEndpoint.categories);
      if (response.data["code"] == 200) {
        List<CategoryModel> list = List<CategoryModel>.from(
          response.data["data"].map((e) => CategoryModel.fromJson(e)),
        );
        return right(list);
      } else {
        return left(FailureModel(response.data["message"] ?? "Unknown error"));
      }
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<CategoryModel> addCategory(CategoryModel c) async {
    try {
      final response = await ref
          .read(ultraPosDioProvider)
          .postData(
            endPoint: AppEndpoint.categories,
            data: c.toJsonWithoutId(),
          );
      if (response.data["code"] == 200) {
        return right(CategoryModel.fromJson(response.data["data"]["category"]));
      } else {
        return left(FailureModel(response.data["message"] ?? "Unknown error"));
      }
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<CategoryModel> updateCategory(CategoryModel c) async {
    try {
      final response = await ref
          .read(ultraPosDioProvider)
          .putData(
            endPoint: "${AppEndpoint.categories}/${c.id}",
            data: c.toJsonWithoutId(),
          );
      if (response.data["code"] == 200) {
        return right(CategoryModel.fromJson(response.data["data"]["category"]));
      } else {
        return left(FailureModel(response.data["message"] ?? "Unknown error"));
      }
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEitherVoid deleteCategory(int categoryId) async {
    try {
      await ref
          .read(ultraPosDioProvider)
          .delete(endPoint: "${AppEndpoint.categories}/$categoryId");
      return right(null);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<List<CategoryModel>> fetchCategoriesByQuery(String query) async {
    try {
      final response = await ref
          .read(ultraPosDioProvider)
          .getData(
            endPoint: AppEndpoint.searchCategories,
            query: {"name": query},
          );
      if (response.data["code"] == 200) {
        final categories = List<CategoryModel>.from(
          response.data["data"].map((e) => CategoryModel.fromJson(e)),
        );
        return right(categories);
      } else {
        return left(FailureModel("no data found"));
      }
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEitherVoid reOrderCategories({
    required List<CategoryModel> categories,
  }) async {
    try {
      final categoriesData = categories.map((category) {
        return category.toJsonForSorting();
      }).toList();

      final response = await ref
          .read(ultraPosDioProvider)
          .postData(
            endPoint: AppEndpoint.syncCategoriesOrder,
            data: {"categories": categoriesData},
          );

      if (response.data["code"] == 200) {
        debugPrint("Categories order synced successfully");
      } else {
        ToastUtils.showToast(
          message: response.data["message"] ?? "Failed to sync category order",
          type: RequestState.error,
        );
      }
      return right(null);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }
}
