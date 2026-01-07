import 'dart:convert';

import 'package:desktoppossystem/models/category_model.dart';
import 'package:desktoppossystem/models/failure_model.dart';
import 'package:desktoppossystem/models/product_model.dart';
import 'package:desktoppossystem/models/setting_model.dart';
import 'package:desktoppossystem/repositories/products/product_repository.dart';
import 'package:desktoppossystem/repositories/restaurant_stock/restaurant_stock_repository.dart';
import 'package:desktoppossystem/shared/constances/menu_enpoints.dart';
import 'package:desktoppossystem/shared/services/dependency_injection.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/toast_utils.dart';
import 'package:desktoppossystem/shared/utils/type_def.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

import '../../shared/global.dart';

final syncProgressProvider = StateProvider.autoDispose<String>((ref) => '0/0');

final menuProviderRepository = Provider((ref) {
  return MenuRepository(ref);
});

abstract class IMenuRepository {
  FutureEither<CategoryModel> createCategory(CategoryModel category);
  FutureEither<CategoryModel> updateCategory(CategoryModel category);
  FutureEitherVoid deleteCategory(int id);
  FutureEither<List<CategoryModel>> getAllCategories();
  FutureEither<void> syncCategoryOrder(List<CategoryModel> categories);

  FutureEither<ProductModel> createMenuItem(ProductModel productModel);
  FutureEither<ProductModel> updateMenuItem(ProductModel product);
  FutureEither<ProductModel> updateMenuImage(ProductModel product);
  FutureEitherVoid deleteProduct(int id);
  FutureEitherVoid syncProductsOrder(List<ProductModel> products);
  FutureEither<Map<String, dynamic>> getMenuItemsByCategoryId(
    int categoryId, {
    int? limit,
    int? offset,
  });

  // update categories
  FutureEither<void> updateCategories(List<CategoryModel> categories);

  FutureEitherVoid syncProductsWithImagesToCloud();
  FutureEitherVoid syncProductsToCloudWithoutImages();
  FutureEitherVoid toggleActive(int id, bool isActive);

  FutureEither<SettingModel> getMenuSettings();
  FutureEither<SettingModel> updateMenuSettings(SettingModel setting);
  FutureEitherVoid toggleProductActive(int id, bool isActive);
}

class MenuRepository implements IMenuRepository {
  final Ref ref;
  MenuRepository(this.ref);

  @override
  FutureEither<CategoryModel> createCategory(CategoryModel category) async {
    try {
      category.color ??= '0xffff0000';
      final response = await ref
          .read(menuDioProvider)
          .postData(
            endPoint: MenuEndpoints.categories,
            data: category.toJsonForMenu(),
          );
      if (response.data["code"] == 200) {
        ToastUtils.showToast(
          message: response.data["message"] ?? "Category created successfully",
        );
        final createdCategory = CategoryModel.fromJson(
          response.data["data"]["category"],
        );

        return right(createdCategory);
      } else {
        ToastUtils.showToast(
          message: response.data["message"] ?? "Failed to create category",
          type: RequestState.error,
        );
        return left(FailureModel(response.data["message"] ?? "Unknown error"));
      }
    } catch (e) {
      ToastUtils.showToast(message: e.toString(), type: RequestState.error);
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<CategoryModel> updateCategory(CategoryModel category) async {
    try {
      final response = await ref
          .read(menuDioProvider)
          .putData(
            endPoint: '${MenuEndpoints.categories}/${category.id}',
            data: category.toJsonForMenu(),
          );
      if (response.data["code"] == 200) {
        ToastUtils.showToast(
          message: response.data["message"] ?? "Category updated successfully",
        );
        final updatedCategory = CategoryModel.fromJson(
          response.data["data"]["category"],
        );
        return right(updatedCategory);
      } else {
        ToastUtils.showToast(
          message: response.data["message"] ?? "Failed to update category",
          type: RequestState.error,
        );
        return left(FailureModel(response.data["message"] ?? "Unknown error"));
      }
    } catch (e) {
      ToastUtils.showToast(message: e.toString(), type: RequestState.error);
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<List<CategoryModel>> getAllCategories() async {
    try {
      final response = await ref
          .read(menuDioProvider)
          .getData(endPoint: MenuEndpoints.categories);

      if (response.data["code"] == 200) {
        final List<dynamic> categoriesData = response.data["data"] ?? [];
        final categories = categoriesData
            .map((json) => CategoryModel.fromJson(json))
            .toList();
        return right(categories);
      } else {
        ToastUtils.showToast(
          message: response.data["message"] ?? "Failed to fetch categories",
          type: RequestState.error,
        );
        return left(FailureModel(response.data["message"] ?? "Unknown error"));
      }
    } catch (e) {
      ToastUtils.showToast(message: e.toString(), type: RequestState.error);
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<ProductModel> createMenuItem(ProductModel productModel) async {
    try {
      final response = await ref
          .read(menuDioProvider)
          .postData(
            endPoint: MenuEndpoints.products,
            data: productModel.toJsonForMenu(),
          );
      if (response.data["code"] == 200) {
        final product = ProductModel.fromJsonForMenu(
          response.data["data"]["product"],
        );
        return right(product);
      } else {
        return left(FailureModel(response.data["message"] ?? "Unknown error"));
      }
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<void> updateCategories(List<CategoryModel> categories) async {
    try {
      // Convert categories list to the required format
      final categoriesData = categories.map((category) {
        return category.toJsonForMenu();
      }).toList();

      // Create the request body with categories object and encode it
      final requestBody = json.encode({'categories': categoriesData});

      final response = await ref
          .read(menuDioProvider)
          .putData(endPoint: MenuEndpoints.categories, data: requestBody);

      if (response.data["code"] == 200) {
        ToastUtils.showToast(
          message:
              response.data["message"] ?? "Categories updated successfully",
        );
        return right(null);
      } else {
        ToastUtils.showToast(
          message: response.data["message"] ?? "Failed to update categories",
          type: RequestState.error,
        );
        return left(FailureModel(response.data["message"] ?? "Unknown error"));
      }
    } catch (e) {
      ToastUtils.showToast(message: e.toString(), type: RequestState.error);
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<ProductModel> updateMenuItem(ProductModel product) async {
    try {
      final response = await ref
          .read(menuDioProvider)
          .putData(
            endPoint: '${MenuEndpoints.products}/${product.id}',
            data: product.toJsonForMenu(),
          );

      if (response.data["code"] == 200) {
        ToastUtils.showToast(
          message: response.data["message"] ?? "Menu item updated successfully",
        );
        final product = ProductModel.fromJsonForMenu(
          response.data["data"]["product"],
        );
        return right(product);
      } else {
        ToastUtils.showToast(
          message: response.data["message"] ?? "Failed to update menu item",
          type: RequestState.error,
        );
        return left(FailureModel(response.data["message"] ?? "Unknown error"));
      }
    } catch (e) {
      print(e.toString());
      ToastUtils.showToast(message: e.toString(), type: RequestState.error);
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEitherVoid syncProductsWithImagesToCloud() async {
    try {
      // Initialize progress
      globalAppWidgetRef?.read(syncProgressProvider.notifier).state = '0/0';

      // Step 1: Fetch all products
      final allProductsResult = await ref
          .read(productProviderRepository)
          .getAllProducts();

      await allProductsResult.fold(
        (failure) async {
          throw Exception('Failed to fetch products: ${failure.message}');
        },
        (products) async {
          // Step 2: Process each product to generate description
          List<Map<String, dynamic>> productUpdates = [];

          for (var product in products) {
            // Step 3: Fetch ingredients for this product
            final ingredientsResult = await ref
                .read(restaurantProviderRepository)
                .fetchIngredientsBySandwich(product.id!);

            await ingredientsResult.fold(
              (failure) async {
                // If no ingredients, send product with empty description
                final productData = product.toJsonForMenu();
                productUpdates.add(productData);
              },
              (ingredients) async {
                if (ingredients.isNotEmpty) {
                  // Step 4: Join ingredient names with comma
                  List<String> ingredientNames = ingredients
                      .map((ingredient) => ingredient.name)
                      .where((name) => name.isNotEmpty)
                      .toList();

                  String newDescription = ingredientNames.join(', ');
                  product.description = newDescription;
                  ref.read(posDbProvider).database.rawUpdate(
                    "update products set description = ? where id = ?",
                    [newDescription, product.id],
                  );
                  final productData = product.toJsonForMenu();
                  productUpdates.add(productData);
                } else {
                  final productData = product.toJsonForMenu();
                  productUpdates.add(productData);
                }
              },
            );
          }

          // Send updates to menu API in smaller batches to avoid 413 error
          if (productUpdates.isNotEmpty) {
            final totalProducts = productUpdates.length;

            // Send in batches of 5 products to avoid payload size limits
            const int batchSize = 5;
            int processedCount = 0;

            for (int i = 0; i < productUpdates.length; i += batchSize) {
              final endIndex = (i + batchSize < productUpdates.length)
                  ? i + batchSize
                  : productUpdates.length;
              final batch = productUpdates.sublist(i, endIndex);

              final requestBody = {'products': batch};

              try {
                debugPrint(
                  '📦 Sending batch ${i ~/ batchSize + 1} with ${batch.length} products',
                );
                final response = await ref
                    .read(menuDioProvider)
                    .putData(
                      endPoint: MenuEndpoints.updateProducts,
                      data: requestBody,
                    );

                if (response.statusCode == 200 || response.statusCode == 201) {
                  debugPrint('✅ Batch ${i ~/ batchSize + 1} sent successfully');
                  processedCount += batch.length;

                  // Update progress
                  globalAppWidgetRef
                          ?.read(syncProgressProvider.notifier)
                          .state =
                      '$processedCount/$totalProducts';
                } else {
                  debugPrint(
                    '⚠️ Batch ${i ~/ batchSize + 1} returned status: ${response.statusCode}',
                  );
                }

                // Small delay between batches to avoid overwhelming the server
                await Future.delayed(const Duration(milliseconds: 500));
              } catch (apiError) {
                debugPrint(
                  '❌ API Error for batch ${i ~/ batchSize + 1}: $apiError',
                );
                // Continue with next batch even if one fails
              }
            }
          }
        },
      );

      return right(null);
    } catch (e) {
      debugPrint('❌ Error in generateProductsDescriptions: $e');
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEitherVoid syncProductsToCloudWithoutImages() async {
    try {
      // Step 1: Fetch all products
      final allProductsResult = await ref
          .read(productProviderRepository)
          .getAllProducts();

      await allProductsResult.fold(
        (failure) async {
          throw Exception('Failed to fetch products: ${failure.message}');
        },
        (products) async {
          // Step 2: Prepare product data without images
          List<Map<String, dynamic>> productUpdates = [];

          for (var product in products) {
            // Step 3: Fetch ingredients for this product
            final ingredientsResult = await ref
                .read(restaurantProviderRepository)
                .fetchIngredientsBySandwich(product.id!);

            await ingredientsResult.fold(
              (failure) async {
                // If no ingredients, send product with empty description
                final productData = product.toJsonForMenuWithoutImage();
                productUpdates.add(productData);
              },
              (ingredients) async {
                if (ingredients.isNotEmpty) {
                  // Step 4: Join ingredient names with comma
                  List<String> ingredientNames = ingredients
                      .map((ingredient) => ingredient.name)
                      .where((name) => name.isNotEmpty)
                      .toList();

                  String newDescription = ingredientNames.join(', ');
                  product.description = newDescription;
                  ref.read(posDbProvider).database.rawUpdate(
                    "update products set description = ? where id = ?",
                    [newDescription, product.id],
                  );
                  final productData = product.toJsonForMenuWithoutImage();
                  productUpdates.add(productData);
                } else {
                  final productData = product.toJsonForMenuWithoutImage();
                  productUpdates.add(productData);
                }
              },
            );
          }

          // Step 3: Send product data to the API
          if (productUpdates.isNotEmpty) {
            final requestBody = {'products': productUpdates};

            try {
              final response = await ref
                  .read(menuDioProvider)
                  .putData(
                    endPoint: MenuEndpoints.updateProducts,
                    data: requestBody,
                  );

              if (response.statusCode == 200 || response.statusCode == 201) {
                debugPrint('✅ Products synced successfully');
              } else {
                debugPrint(
                  '⚠️ Error: Sync returned status: ${response.statusCode}',
                );
              }
            } catch (apiError) {
              debugPrint('❌ API Error: $apiError');
            }
          }
        },
      );

      return right(null);
    } catch (e) {
      debugPrint('❌ Error in syncProductsToCloudWithoutImages: $e');
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEitherVoid toggleActive(int id, bool isActive) async {
    try {
      final response = await ref
          .read(menuDioProvider)
          .putData(
            endPoint: '${MenuEndpoints.products}/$id/toggle-active',
            data: {'isActive': isActive ? 1 : 0},
          );

      if (response.data["code"] == 200) {
        ToastUtils.showToast(
          message: response.data["message"] ?? "Menu item deleted successfully",
        );
        return right(null);
      } else {
        ToastUtils.showToast(
          message: response.data["message"] ?? "Failed to delete menu item",
          type: RequestState.error,
        );
        return left(FailureModel(response.data["message"] ?? "Unknown error"));
      }
    } catch (e) {
      ToastUtils.showToast(message: e.toString(), type: RequestState.error);
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<void> syncCategoryOrder(List<CategoryModel> categories) async {
    try {
      // Convert categories list to the required format
      final categoriesData = categories.map((category) {
        return category.toJsonForSorting();
      }).toList();

      final response = await ref
          .read(menuDioProvider)
          .postData(
            endPoint: MenuEndpoints.syncCategoriesOrder,
            data: {"categories": categoriesData},
          );

      if (response.data["code"] == 200) {
        // Successfully synced category order
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

  @override
  FutureEitherVoid deleteCategory(int id) async {
    try {
      final response = await ref
          .read(menuDioProvider)
          .delete(endPoint: '${MenuEndpoints.categories}/$id');
      if (response.data["code"] == 200) {
        ToastUtils.showToast(
          message: response.data["message"] ?? "Menu item deleted successfully",
        );
        return right(null);
      } else {
        ToastUtils.showToast(
          message: response.data["message"] ?? "Failed to delete menu item",
          type: RequestState.error,
        );
        return left(FailureModel(response.data["message"] ?? "Unknown error"));
      }
    } catch (e) {
      ToastUtils.showToast(message: e.toString(), type: RequestState.error);
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEitherVoid deleteProduct(int id) async {
    try {
      final response = await ref
          .read(menuDioProvider)
          .delete(endPoint: '${MenuEndpoints.products}/$id');
      if (response.data["code"] == 200) {
        ToastUtils.showToast(
          message: response.data["message"] ?? "Product deleted successfully",
        );
        return right(null);
      } else {
        ToastUtils.showToast(
          message: response.data["message"] ?? "Failed to delete product",
          type: RequestState.error,
        );
        return left(FailureModel(response.data["message"] ?? "Unknown error"));
      }
    } catch (e) {
      ToastUtils.showToast(message: e.toString(), type: RequestState.error);
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<Map<String, dynamic>> getMenuItemsByCategoryId(
    int categoryId, {
    int? limit,
    int? offset,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'fetchAll': true,
        if (limit != null) 'limit': limit,
        if (offset != null) 'offset': offset,
      };

      final response = await ref
          .read(menuDioProvider)
          .getData(
            endPoint: '${MenuEndpoints.productsByCategory}/$categoryId',
            query: queryParameters,
          );

      if (response.data["code"] == 200) {
        final responseData = response.data["data"];
        final List<dynamic> productsData = responseData["products"] ?? [];
        final products = productsData
            .map((json) => ProductModel.fromJsonForMenu(json))
            .toList();

        // Get pagination info
        final pagination = responseData["pagination"];
        final hasNextPage = pagination["hasNextPage"] ?? false;

        // Return both products and hasNextPage
        return right({'products': products, 'hasNextPage': hasNextPage});
      } else {
        ToastUtils.showToast(
          message: response.data["message"] ?? "Failed to fetch products",
          type: RequestState.error,
        );
        return left(FailureModel(response.data["message"] ?? "Unknown error"));
      }
    } catch (e) {
      ToastUtils.showToast(message: e.toString(), type: RequestState.error);
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<ProductModel> updateMenuImage(ProductModel product) async {
    try {
      final imageData = product.toJsonForMenu()['imageData'];
      final response = await ref
          .read(menuDioProvider)
          .postData(
            endPoint: "${MenuEndpoints.products}/${product.id}/update-image",
            data: {"imageData": imageData},
          );
      if (response.data["code"] == 200) {
        final product = ProductModel.fromJsonForMenu(
          response.data["data"]["product"],
        );
        ToastUtils.showToast(
          message:
              response.data["message"] ??
              "Menu item image updated successfully",
        );
        return right(product);
      } else {
        return left(FailureModel(response.data["message"] ?? "Unknown error"));
      }
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEitherVoid syncProductsOrder(List<ProductModel> products) async {
    try {
      // Convert categories list to the required format
      final productsData = products.map((product) {
        return product.toJsonForSorting();
      }).toList();
      final response = await ref
          .read(menuDioProvider)
          .postData(
            endPoint: MenuEndpoints.syncProductsOrder,
            data: {"products": productsData},
          );

      if (response.data["code"] == 200) {
        // Successfully synced category order
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

  @override
  FutureEither<SettingModel> getMenuSettings() async {
    try {
      final response = await ref
          .read(menuDioProvider)
          .getData(endPoint: MenuEndpoints.settings);

      if (response.data["code"] == 200) {
        final settingData = response.data["data"]["settings"];
        final setting = SettingModel.fromJsonMenu(settingData);
        return right(setting);
      } else {
        ToastUtils.showToast(
          message: response.data["message"] ?? "Failed to fetch settings",
          type: RequestState.error,
        );
        return left(FailureModel(response.data["message"] ?? "Unknown error"));
      }
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<SettingModel> updateMenuSettings(SettingModel setting) async {
    try {
      final response = await ref
          .read(menuDioProvider)
          .putData(
            endPoint: MenuEndpoints.settings,
            data: setting.toJsonMenu(),
          );

      if (response.data["code"] == 200) {
        final updatedSetting = SettingModel.fromJsonMenu(
          response.data["data"]["settings"],
        );
        ToastUtils.showToast(
          message: response.data["message"] ?? "Settings updated successfully",
        );
        return right(updatedSetting);
      } else {
        ToastUtils.showToast(
          message: response.data["message"] ?? "Failed to update settings",
          type: RequestState.error,
        );
        return left(FailureModel(response.data["message"] ?? "Unknown error"));
      }
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEitherVoid toggleProductActive(int id, bool isActive) async {
    try {
      final response = await ref
          .read(menuDioProvider)
          .putData(
            endPoint: "${MenuEndpoints.products}/$id/toggle-active",
            data: {"isActive": isActive ? 1 : 0},
          );
      if (response.data["code"] == 200) {
        return right(null);
      } else {
        return left(FailureModel(response.data["message"] ?? "Unknown error"));
      }
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }
}
