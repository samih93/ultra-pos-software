// ignore_for_file: public_member_api_docs, sort_constructors_first, unused_result
import 'package:desktoppossystem/controller/global_controller.dart';
import 'package:desktoppossystem/controller/product_controller.dart';
import 'package:desktoppossystem/models/ingrendient_model.dart';
import 'package:desktoppossystem/models/product_model.dart';
import 'package:desktoppossystem/models/restaurant_stock_model.dart';
import 'package:desktoppossystem/models/sandwiches_ingredients.dart';
import 'package:desktoppossystem/models/stock_transaction_model.dart';
import 'package:desktoppossystem/repositories/products/product_repository.dart';
import 'package:desktoppossystem/repositories/restaurant_stock/restaurant_stock_repository.dart';
import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:desktoppossystem/shared/utils/toast_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final restaurantStockControllerProvider =
    ChangeNotifierProvider<RestaurantStockController>((ref) {
  return RestaurantStockController(
      ref: ref,
      restaurantStockRepository: ref.read(restaurantProviderRepository));
});

final ingredientsProvider = FutureProvider<List<IngredientModel>>((ref) async {
  List<IngredientModel> items = [];
  final selectedItem = ref.watch(selectedRestaurantStockProvider);
  if (selectedItem == null) {
    items = [];
  } else {
    var response = await ref
        .read(restaurantProviderRepository)
        .fetchIngredientsByStockId(selectedItem.id!);
    await response.fold<Future>(
      (l) async {
        ToastUtils.showToast(message: "failed fetching ingredients");
        items = [];
      },
      (r) async {
        items = r;

        // if sandwich is selected now
        ref.listen(
          selectedSandwichProvider,
          (previous, next) {
            if (next != null) {
              final selectedIngredients = ref.read(selectedIngredientsProvider);
              for (var item in items) {
                selectedIngredients.removeWhere((e) => e.id == item.id);
                ref.read(selectedIngredientsProvider.notifier).state =
                    Set.from(selectedIngredients);
              }
            }
          },
        );
      },
    );
  }
  return items;
});

final selectedIngredientsProvider =
    StateProvider<Set<IngredientModel>>((ref) => {});

final selectedRestaurantStockProvider =
    StateProvider<RestaurantStockModel?>((ref) {
  return null;
});

//  selected sandwich
final selectedSandwichProvider = StateProvider<ProductModel?>((ref) {
  return null;
});

final totalIngedientsCostProvider = Provider<double>((ref) {
  double cost = 0;
  ref.watch(futureingredientsBySandwichProvider).whenData((data) {
    for (var element in data) {
      if (!element.forPackaging!) cost += element.pricePerIngredient!;
    }
  });
  return cost;
});
final futureRestaurantInventoryCost = FutureProvider<double>((ref) async {
  final response = await ref
      .read(restaurantProviderRepository)
      .fetchRestaurantInventoryCost();
  return response.fold<double>(
    (l) {
      ToastUtils.showToast(
          message: "Failed to fetch inventory cost", type: RequestState.error);
      return 0.0;
    },
    (r) {
      return r;
    },
  );
});

final totalSelectedIngedientsCostProvider = Provider<double>((ref) {
  double cost = 0;
  var list = ref.watch(selectedIngredientsProvider);
  for (var element in list) {
    cost += (element.pricePerIngredient ?? 0);
  }

  return cost;
});

final futureingredientsBySandwichProvider =
    FutureProvider<List<IngredientModel>>((ref) async {
  int? sandwichId = ref.watch(selectedSandwichProvider)?.id;
  List<IngredientModel> list = [];
  if (sandwichId == null) {
    list = [];
  } else {
    list = await ref
        .read(restaurantStockControllerProvider)
        .fetchIngrdientsBySandwich(sandwichId);
  }

  return list;
});

class RestaurantStockController extends ChangeNotifier {
  final Ref ref;
  IRestaurantStockRepository restaurantStockRepository;
  RestaurantStockController({
    required this.ref,
    required this.restaurantStockRepository,
  });

  List<RestaurantStockModel> stockItems = [];
  List<RestaurantStockModel> originalStockItems = [];

  RequestState fetchStockItemsRequestState = RequestState.success;

  Future fetchAllStockItems() async {
    fetchStockItemsRequestState = RequestState.loading;
    notifyListeners();
    final stockResponse = await restaurantStockRepository.fetchAllStockItems();
    stockResponse.fold((l) {
      fetchStockItemsRequestState = RequestState.error;
      notifyListeners();
      ToastUtils.showToast(
          message: "getting stock items failed : ${l.message}",
          type: RequestState.error);
      notifyListeners();
    }, (r) {
      stockItems = r;
      originalStockItems = r;
      fetchStockItemsRequestState = RequestState.success;
      notifyListeners();
    });
  }

  RestaurantStockFilter stockFilter = RestaurantStockFilter.all;

  onChangeStockFilter(RestaurantStockFilter filter) {
    stockFilter = filter;
    switch (filter) {
      case RestaurantStockFilter.all:
        stockItems = originalStockItems;
        break;
      case RestaurantStockFilter.foodItems:
        stockItems = originalStockItems.where((e) => !e.forPackaging!).toList();
        break;
      case RestaurantStockFilter.packaging:
        stockItems = originalStockItems.where((e) => e.forPackaging!).toList();
        break;
      case RestaurantStockFilter.lowStock:
        stockItems =
            originalStockItems.where((e) => e.qty <= e.warningAlert!).toList();
        break;
    }
    notifyListeners();
  }

  searchInRestaurantStock(String query) {
    clearSelectedEntry();
    stockFilter = RestaurantStockFilter.all;

    if (query.trim() == "") {
      stockItems = originalStockItems;
    } else {
      stockItems = originalStockItems
          .where((e) => e.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  clearSearchInRestaurantStock() {
    stockFilter = RestaurantStockFilter.all;
    stockItems = originalStockItems;
    notifyListeners();
  }

  onSelectStockItem(RestaurantStockModel model) {
    for (var item in stockItems) {
      if (item == model) {
        item.isSelected = !item.isSelected!;
        ref
            .read(selectedRestaurantStockProvider.notifier)
            .update((state) => item.isSelected == true ? model : null);
      } else {
        item.isSelected = false;
      }
    }
    notifyListeners();
  }

// Listen to changes in selectedSandwichProvider to manage selected ingredients
  void listenToSandwichProvider(WidgetRef ref) {
    ref.listen(selectedSandwichProvider, (previous, next) {
      if (next != null) {
        final selectedIngredients = ref.read(selectedIngredientsProvider);
        final ingredients = ref.read(ingredientsProvider).maybeWhen(
              data: (data) => data,
              orElse: () => [],
            );

        for (var item in ingredients) {
          selectedIngredients.removeWhere((e) => e.id == item.id);
        }
        ref.read(selectedIngredientsProvider.notifier).state =
            Set.from(selectedIngredients);
      }
    });
  }

  RequestState addRequestState = RequestState.success;
  Future addItem(RestaurantStockModel model, BuildContext context) async {
    addRequestState = RequestState.loading;
    notifyListeners();
    final addResponse =
        await restaurantStockRepository.addRestaurantStockItem(model);
    addResponse.fold((l) {
      addRequestState = RequestState.error;
      notifyListeners();
      ToastUtils.showToast(
          message: "add stock item failed", type: RequestState.error);
    }, (r) {
      addRequestState = RequestState.success;
      notifyListeners();
      ToastUtils.showToast(
          message: "stock item $successAddedStatusMessage",
          type: RequestState.success);
      context.pop();
      fetchAllStockItems();
      ref.refresh(futureRestaurantInventoryCost);
    });
  }

  RequestState updateRequestState = RequestState.success;

  Future editItem(RestaurantStockModel model, BuildContext context,
      {bool? isInDailyEntry, bool? isStockOut}) async {
    if (updateRequestState == RequestState.loading) return;
    updateRequestState = RequestState.loading;
    notifyListeners();
    final updateResponse =
        await restaurantStockRepository.editRestaurantStockItem(model);
    updateResponse.fold(
      (l) {
        updateRequestState = RequestState.error;
        notifyListeners();
      },
      (r) {
        updateRequestState = RequestState.success;

        updateStockItemInTemp(model);
        if (isInDailyEntry != true) {
          context.pop();
        }
        if (isStockOut != true) {
          ToastUtils.showToast(
              message: "stock item $successUpdatedStatusMessage",
              type: RequestState.success);
          updateAllSandwichesCost();
        }
        // if already select a sandwich
        if (ref.read(selectedSandwichProvider) != null) {
          ref.refresh(futureingredientsBySandwichProvider);
        }
        // refresh the ingredients by stock Id if selected
        ref.refresh(ingredientsProvider);
        ref.refresh(futureRestaurantInventoryCost);
        notifyListeners();
      },
    );
  }

  updateStockItemInTemp(RestaurantStockModel model) {
    for (var item in stockItems) {
      if (item.id == model.id) {
        item.name = model.name;
        item.portionsPerKg = model.portionsPerKg;
        item.unitType = model.unitType;
        item.pricePerUnit = model.pricePerUnit;
        item.qty = model.qty;
        item.color = model.color;
        //  item.textColor = model.textColor;
        item.warningAlert = model.warningAlert;
        item.wasteFormula = model.wasteFormula;
        item.forPackaging = model.forPackaging;
      }
    }
  }

  RequestState deleteStockItemRequestState = RequestState.success;
  Future deleteStockItem(int id, BuildContext context) async {
    final deleteResponse =
        await restaurantStockRepository.deleteRestaurantStockItem(id);
    deleteResponse.fold((l) {
      ToastUtils.showToast(message: "delete failed", type: RequestState.error);
    }, (r) {
      originalStockItems.removeWhere((e) => e.id == id);
      stockItems = originalStockItems;
      notifyListeners();
      ToastUtils.showToast(
          message: "stock item $successDeletedStatusMessage",
          type: RequestState.success);
      context.pop();
      if (ref.read(selectedSandwichProvider) != null) {
        ref.refresh(futureingredientsBySandwichProvider);
      }
      ref.refresh(ingredientsProvider);
      ref.refresh(futureRestaurantInventoryCost);
    });
  }

  RequestState addIngredientRequestState = RequestState.success;
  Future addIngredient(IngredientModel model, BuildContext context) async {
    addIngredientRequestState = RequestState.loading;
    notifyListeners();
    final addResponse = await restaurantStockRepository.addIngredient(model);
    addResponse.fold(
      (l) {
        addIngredientRequestState = RequestState.error;
        notifyListeners();
        ToastUtils.showToast(
            message: "add ingredient failed ${l.message}",
            type: RequestState.error);
      },
      (r) {
        addIngredientRequestState = RequestState.success;
        notifyListeners();
        ToastUtils.showToast(
            message: "Ingredient $successAddedStatusMessage",
            type: RequestState.success);
        ref.refresh(ingredientsProvider);
        context.pop();
      },
    );
  }

  RequestState editIngredientRequestState = RequestState.success;
  Future editIngredient(IngredientModel model, BuildContext context) async {
    editIngredientRequestState = RequestState.loading;
    notifyListeners();
    final editResponse = await restaurantStockRepository.editIngredient(model);
    editResponse.fold(
      (l) {
        editIngredientRequestState = RequestState.error;
        notifyListeners();
        ToastUtils.showToast(
            message: "edit ingredient failed ${l.message}",
            type: RequestState.error);
      },
      (r) {
        editIngredientRequestState = RequestState.success;
        notifyListeners();
        ToastUtils.showToast(
            message: "Ingredient $successUpdatedStatusMessage",
            type: RequestState.success);
        ref.refresh(ingredientsProvider);
        // if already select a sandwich
        if (ref.read(selectedSandwichProvider) != null) {
          ref.refresh(futureingredientsBySandwichProvider);
        }
        context.pop();
      },
    );
  }

  unSelectIngredient(IngredientModel ingredient) {
    final selectedIngredients = ref.read(selectedIngredientsProvider);

    selectedIngredients.removeWhere((e) => e.id == ingredient.id);
    ref.read(selectedIngredientsProvider.notifier).state =
        Set.from(selectedIngredients);
  }

  void onIngredientPressed(IngredientModel ingredient) {
    final selectedIngredients = ref.read(selectedIngredientsProvider);
    ref.read(futureingredientsBySandwichProvider).whenData((data) {
      if (ref.read(selectedSandwichProvider)?.id != null) {
        if (data.any((e) => e.id == ingredient.id)) {
          ToastUtils.showToast(
              message: "Ingredient already exist", type: RequestState.error);
        } else {
          if (selectedIngredients.any((e) => e.id == ingredient.id)) {
            selectedIngredients.remove(ingredient);
          } else {
            selectedIngredients.add(ingredient);
          }
          ref.read(selectedIngredientsProvider.notifier).state =
              Set.from(selectedIngredients);
        }
      }
    });
  }

  RequestState deleteIngredientRequestState = RequestState.success;
  Future deleteIngredient(int id, BuildContext context) async {
    deleteIngredientRequestState = RequestState.loading;
    notifyListeners();
    final deleteResponse = await restaurantStockRepository.deleteIngredient(id);
    deleteResponse.fold((l) {
      deleteIngredientRequestState = RequestState.error;
      notifyListeners();
      ToastUtils.showToast(message: "delete failed", type: RequestState.error);
    }, (r) {
      deleteIngredientRequestState = RequestState.success;
      notifyListeners();
      ToastUtils.showToast(
          message: "ingredient  $successDeletedStatusMessage",
          type: RequestState.success);
      context.pop();
      ref.refresh(ingredientsProvider);
    });
  }

  RequestState addIngredientToSandwichRequestState = RequestState.success;
  Future addSandwichesIngredients(List<SandwichesIngredients> list) async {
    addIngredientRequestState = RequestState.loading;
    notifyListeners();
    final addRespone =
        await restaurantStockRepository.addSandwichIngredients(list);
    addRespone.fold((l) {
      addIngredientRequestState = RequestState.error;
      notifyListeners();
      ToastUtils.showToast(
          message: "failed : ${l.message}", type: RequestState.error);
    }, (r) {
      addIngredientRequestState = RequestState.success;
      notifyListeners();
      ToastUtils.showToast(message: "Success", type: RequestState.success);
    });
  }

  Future<List<IngredientModel>> fetchIngrdientsBySandwich(int id) async {
    List<IngredientModel> ingredients = [];

    final response =
        await restaurantStockRepository.fetchIngredientsBySandwich(id);
    response.fold((l) {
      ToastUtils.showToast(message: l.message, type: RequestState.error);
    }, (r) {
      ingredients = r;
    });
    return ingredients;
  }

  Future deleteSandwichIngrdientById(int id) async {
    final response =
        await restaurantStockRepository.deleteSandwichIngredientById(id);
    response.fold((l) {
      ToastUtils.showToast(message: l.message, type: RequestState.error);
    }, (r) {
      ToastUtils.showToast(
          message: "Sandiwch ingredient $successDeletedStatusMessage",
          type: RequestState.success);
      ref.refresh(futureingredientsBySandwichProvider);
    });
  }

  RequestState updateAllSandwichesCostRequestState = RequestState.success;
  Future updateAllSandwichesCost() async {
    updateAllSandwichesCostRequestState = RequestState.loading;
    notifyListeners();
    final fetchSandwichesResponse = await ref
        .read(productProviderRepository)
        .fetchAllSandwichesWithIngredients();
    fetchSandwichesResponse.fold<Future>(
      (l) async {
        updateAllSandwichesCostRequestState = RequestState.error;
        notifyListeners();
      },
      (r) async {
        for (var sandwich in r) {
          double cost = 0;
          for (var ingredient in sandwich.ingredients!) {
            if (!ingredient.forPackaging!) {
              cost += ingredient.pricePerIngredient!;
            }
          }

          await ref.read(productProviderRepository).updateProductCost(
              cost: cost.formatDouble(), productId: sandwich.id!);
        }
        ref.read(productControllerProvider).getAllProducts();
        ToastUtils.showToast(
            message: "Sandwiches costs updated successfully",
            type: RequestState.success);
        updateAllSandwichesCostRequestState = RequestState.success;
        notifyListeners();
      },
    );
  }

  // for daily entry stock

  RestaurantStockModel? get selectedEntryStockItem =>
      stockItems.where((e) => e.isSelected == true).firstOrNull;

  onSelectEntryItem(RestaurantStockModel model) {
    for (var item in stockItems) {
      if (item == model) {
        item.isSelected = !item.isSelected!;
      } else {
        item.isSelected = false;
      }
    }
    notifyListeners();
  }

  clearSelectedEntry() {
    for (var item in stockItems) {
      item.isSelected = false;
    }
    notifyListeners();
  }

  RequestState downloadItemsRequestState = RequestState.success;
  Future fetchAndDownloadItems() async {
    downloadItemsRequestState = RequestState.loading;
    notifyListeners();
    final res = await ref.read(productProviderRepository).getAllProducts(
          limit: 100000000000,
        );

    res.fold((l) {
      debugPrint(l.message);
      downloadItemsRequestState = RequestState.error;
      notifyListeners();
    }, (r) async {
      await ref.read(globalControllerProvider).openItemsWithCostInExcel(r);
      downloadItemsRequestState = RequestState.success;
      notifyListeners();
    });
  }

  RequestState downloadItemsWithIngredientsRequestState = RequestState.success;
  Future fetchAndDownloadItemsWithIngredients() async {
    downloadItemsWithIngredientsRequestState = RequestState.loading;
    notifyListeners();
    final res = await ref
        .read(productProviderRepository)
        .fetchAllSandwichesWithIngredients();

    res.fold((l) {
      debugPrint(l.message);
      downloadItemsWithIngredientsRequestState = RequestState.error;
      notifyListeners();
    }, (r) async {
      await ref
          .read(globalControllerProvider)
          .openItemsWithIngredientsInExcel(r);
      downloadItemsWithIngredientsRequestState = RequestState.success;
      notifyListeners();
    });
  }

  RequestState makeWasteRequestState = RequestState.success;
  Future makeStockTransaction(List<StockTransactionModel> stockTransactions,
      {bool? isStaffWaste}) async {
    makeWasteRequestState = RequestState.loading;
    notifyListeners();
    final wasteResponse = await restaurantStockRepository
        .makeStockTransactions(stockTransactions);
    wasteResponse.fold((l) {
      makeWasteRequestState = RequestState.error;
      notifyListeners();
      ToastUtils.showToast(
          message: "failed to make waste ${l.message}",
          type: RequestState.error);
    }, (r) {
      makeWasteRequestState = RequestState.success;
      notifyListeners();
      ref.refresh(futureRestaurantInventoryCost);

      if (stockTransactions[0].transactionType ==
              StockTransactionType.stockOut &&
          isStaffWaste != true) {
        ToastUtils.showToast(
            message: "waste $successAddedStatusMessage",
            type: RequestState.success);
      }
    });
  }

  RequestState bulkWasteTransactionRequestState = RequestState.success;
  Future bulkWasteTransaction(List<ProductModel> products) async {
    bulkWasteTransactionRequestState = RequestState.loading;
    notifyListeners();

    final transactionResponse =
        await restaurantStockRepository.bulkWasteTransaction(products);
    transactionResponse.fold((l) {
      bulkWasteTransactionRequestState = RequestState.error;
      notifyListeners();
      ToastUtils.showToast(
          message: "failed to make waste ${l.message}",
          type: RequestState.error);
    }, (r) {
      bulkWasteTransactionRequestState = RequestState.success;
      notifyListeners();
      ref.refresh(futureRestaurantInventoryCost);

      ToastUtils.showToast(
          message: "waste $successAddedStatusMessage",
          type: RequestState.success);
    });
  }
}
