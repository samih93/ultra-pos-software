import 'dart:convert';

import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/customers_model.dart';
import 'package:desktoppossystem/models/ingrendient_model.dart';
import 'package:desktoppossystem/models/product_model.dart';
import 'package:desktoppossystem/models/table_model.dart';
import 'package:desktoppossystem/models/temp_receipt_model.dart';
import 'package:desktoppossystem/repositories/tables/i_table_reposiotry.dart';
import 'package:desktoppossystem/repositories/tables/table_reposiotry.dart';
import 'package:desktoppossystem/screens/sale_screens/shared_components/order_type_section.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/services/dependency_injection.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:desktoppossystem/shared/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../main_screen.dart/main_controller.dart';

// Define a ChangeNotifierProvider for SaleController
final saleControllerProvider = ChangeNotifierProvider<SaleController>((ref) {
  // Return an instance of SaleController
  return SaleController(
    ref: ref,
    iTableRepository: ref.read(tableProviderRepository),
  );
});

class SaleController extends ChangeNotifier {
  final Ref _ref;
  final ITableRepository _iTableRepository;

  SaleController({required Ref ref, required ITableRepository iTableRepository})
    : _ref = ref,
      _iTableRepository = iTableRepository {
    loadTempReceipts();

    _fetchConfiguration();
  }

  Future loadTempReceipts() async {
    // Get the JSON string from SharedPreferences
    String? jsonString = _ref
        .read(appPreferencesProvider)
        .getData(key: 'tempReceipts');

    if (jsonString != null) {
      // Convert the JSON string to a map
      Map<String, dynamic> tempInvoicesJson = jsonDecode(jsonString);

      // Convert the map back to Map<int, TempInvoice>
      tempReceipts = tempInvoicesJson.map((key, value) {
        invoiceKeyCounter = (int.tryParse(key) ?? 0) + 1;

        return MapEntry(int.parse(key), TempReceiptModel.fromJson(value));
      });
    }
  }

  Future _fetchConfiguration() async {
    await Future.delayed(const Duration(milliseconds: 200));

    isShowInDolarInSaleScreen = _ref
        .read(appPreferencesProvider)
        .getBool(key: "showPriceInDolar", defaultValue: true);
    notifyListeners();
  }

  bool shouldAnimateToEnd = true; // Default to true

  CustomerModel? customerModel;
  var customerTextController = TextEditingController();
  // ! select customer
  onselectCustomer(CustomerModel? model) {
    customerModel = model;
    if (customerModel != null) {
      customerTextController.text =
          '${customerModel!.name.toString()} - ${customerModel!.address} - ${customerModel!.phoneNumber}';
      if (int.tryParse(customerModel!.discount.toString()) != null) {
        onchangeDiscount(double.parse(customerModel!.discount.toString()));
      }
    }

    notifyListeners();
  }

  // ! clear customer
  clearCustomer() {
    customerModel = null;
    customerTextController.clear();
    onchangeDiscount(0);
    notifyListeners();
  }

  // to cancel the discount if i have many product same id
  isSelectedProductAlreadyExsit(ProductModel p) {
    int counts = 0;
    for (var element in basketItems) {
      if (element.id == p.id) {
        counts++;
      }
    }
    return counts > 1;
  }

  double discount = 0;
  onchangeDiscount(double val) {
    if (basektSelectedProduct != null &&
        isSelectedProductAlreadyExsit(basektSelectedProduct!)) {
      ToastUtils.showToast(
        message: "can't add discount for item that already exist",
        type: RequestState.error,
      );
    } else {
      if (!basketItems.any(
        (element) =>
            element.isJustOrdered == true || element.isNewToBasket == true,
      )) {
        discount = val;
        if (basektSelectedProduct == null) {
          addDiscountOnAllBasket(discount);
        } else {
          updateDiscountOnSelectedItem(discount);
        }
        getforeignTotalPrice();
      }
    }
  }

  updateDiscountOnSelectedItem(double discount) {
    for (var item in basketItems.where((e) => e.selected == true).toList()) {
      item.discount = discount;
    }
  }

  addDiscountOnAllBasket(double discount) {
    for (var element in basketItems) {
      element.discount = discount;
    }
  }

  ProductModel? get basektSelectedProduct =>
      basketItems.where((e) => e.selected == true).firstOrNull;

  double dolarRate = 0;

  //! on change dolar rate
  Future onchangeDolarRate(double val) async {
    dolarRate = val;
    getforeignTotalPrice();
  }

  List<ProductModel> basketItems = [];
  // ! for Tables get all news items
  List<ProductModel> get basketItemsNew =>
      basketItems.where((element) => element.isNewToBasket == true).toList();

  // for creating many basket
  Map<int, TempReceiptModel> tempReceipts = {};

  int invoiceKeyCounter = 1;
  onHoldInvoice(BuildContext context) async {
    List<ProductModel> list = basketItems;

    // Show a dialog to get a note from the user
    String note =
        await showDialog<String>(
          context: context,
          builder: (context) {
            TextEditingController controller = TextEditingController();
            return AlertDialog(
              title: Text(S.of(context).note),
              content: TextField(
                onSubmitted: (value) {
                  context.pop(value: controller.text);
                },
                autofocus: true,
                controller: controller,
                decoration: const InputDecoration(hintText: 'Enter your note'),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    context.pop(value: controller.text);
                  },
                  child: const Text('OK'),
                ),
              ],
            );
          },
        ) ??
        ''; // Default empty string if the user cancels

    // Create a new Invoice object with the products and the note
    TempReceiptModel newInvoice = TempReceiptModel(products: list, note: note);

    // Add the new invoice to tempInvoices
    tempReceipts.addAll({invoiceKeyCounter: newInvoice});
    // Convert the map to a JSON string
    saveTempInvoiceToLocalStorage();

    invoiceKeyCounter++;
    basketItems = [];
    foreignTotalPrice = 0;
    localTotalPrice = 0;
    totalItemQty = 0;
    notifyListeners();
  }

  void saveTempInvoiceToLocalStorage() {
    Map<String, dynamic> tempReceiptsJson = tempReceipts.map((key, value) {
      return MapEntry(
        key.toString(),
        value.toJson(),
      ); // Convert map keys to strings
    });

    String jsonString = jsonEncode(
      tempReceiptsJson,
    ); // Convert the entire map to a JSON string
    _ref
        .read(appPreferencesProvider)
        .saveData(key: "tempReceipts", value: jsonString);
  }

  onOpenHoldInvoice(int key) async {
    // to run it befor removing it form tempinvoices
    await Future.delayed(Duration.zero).then((value) {
      if (tempReceipts.containsKey(key)) {
        basketItems = tempReceipts[key]!.products;
      }
    });

    tempReceipts.remove(key);
    lastDeletedItem = null;

    saveTempInvoiceToLocalStorage();
    getforeignTotalPrice();
  }

  RequestState fetchTablesRequestState = RequestState.success;
  Future fetchTables() async {
    nbOfTables =
        _ref.read(appPreferencesProvider).getData(key: "nbOfTables") ?? 100;
    tables = [];
    await Future.delayed(const Duration(milliseconds: 1)).then((value) {
      for (int i = 1; i <= nbOfTables; i++) {
        tables.add(TableModel(tableName: "$i", isOpened: false));
      }
    });

    fetchTablesRequestState = RequestState.loading;
    notifyListeners();
    await _iTableRepository.fetchOpenedTables().then((value) {
      value.take(nbOfTables);
      for (var element in value) {
        int t = int.parse(element.tableName.toString());
        tables[t - 1].isOpened = true;
        tables[t - 1].openedBy = element.openedBy;
      }
      fetchTablesRequestState = RequestState.success;
      notifyListeners();
    });
  }

  int nbOfTables = 100;

  setNbOfTables(int nb, BuildContext context) async {
    await _iTableRepository.fetchOpenedTables().then((value) {
      bool containsGreaterNbOfTables = value.any(
        (number) => int.parse(number.tableName.toString()) >= nb,
      );
      if (!containsGreaterNbOfTables) {
        nbOfTables = nb;
        notifyListeners();
        _ref
            .read(appPreferencesProvider)
            .saveData(key: "nbOfTables", value: nb);
        context.pop();
      } else {
        ToastUtils.showToast(
          message:
              "You can't set the number of tables to the selected value because you already have an open table number greater than that value",
          type: RequestState.error,
        );
      }
    });
  }

  // Receipt Number
  int receiptNumber = 1;
  bool isJustClickedQuickORder = false;
  onIncreaseReceiptNumber({bool? isQuickOrder}) {
    if (isQuickOrder == true) {
      isJustClickedQuickORder = true;
    } else {
      isJustClickedQuickORder = false;
    }
    receiptNumber++;
  }

  onSetReceiptNumber(int nb) {
    receiptNumber = nb;
    notifyListeners();
  }

  // ! change searching by barcode or name
  // bool isSearchByQr = true;
  // onchangeSearchByQrOrName() {
  //   isSearchByQr = !isSearchByQr;
  //   notifyListeners();
  // }

  ProductModel? lastScannedItem;
  ProductModel? lastDeletedItem;

  addItemToBasket(ProductModel p, {double? weight}) {
    lastScannedItem = p;
    foreignTotalPrice = 0;

    // ! table is selected

    ProductModel newproduct = ProductModel.second();
    newproduct.id = p.id;
    newproduct.qty = weight ?? 1;
    newproduct.qtyInStock = p.qty;
    newproduct.name = p.name;
    newproduct.originalSellingPrice = p.originalSellingPrice;
    newproduct.sellingPrice = p.sellingPrice;
    newproduct.minSellingPrice = p.minSellingPrice;
    newproduct.costPrice = p.costPrice;
    newproduct.ingredients = p.ingredients ?? [];
    newproduct.ingredientsToBeAdded = p.ingredients ?? [];
    newproduct.categoryId = p.categoryId;
    newproduct.barcode = p.barcode;
    newproduct.isTracked = p.isTracked;
    newproduct.enableNotification = p.enableNotification;
    newproduct.countsAsItem = p.countsAsItem;
    newproduct.discount = p.discount;
    newproduct.image = p.image;
    newproduct.warningAlert = p.warningAlert;
    newproduct.sectionType = p.sectionType;

    newproduct.sectionType = p.sectionType;
    newproduct.isNewToBasket = selectedTable != null ? true : false;
    basketItems.add(newproduct);
    onselectProduct(newproduct);
    //  }
    //   }

    shouldAnimateToEnd = true;
    tempVal = "";
    getforeignTotalPrice();
    //  notifyListeners();
  }

  void restoreLastDeletedItem() {
    if (lastDeletedItem != null) {
      for (var element in basketItems) {
        element.selected = false;
      }
      lastDeletedItem!.selected = true;
      basketItems.add(lastDeletedItem!);
      getforeignTotalPrice();
      lastDeletedItem = null;
      shouldAnimateToEnd = true;
      notifyListeners();
    }
  }

  void changeSelectedIndex(bool isUp) {
    if (basketItems.isEmpty) return;

    int selectedIndex = basketItems.indexWhere((e) => e.selected == true);

    // If none selected, select first or last based on direction
    if (selectedIndex == -1) {
      selectedIndex = isUp ? basketItems.length - 1 : 0;
      basketItems[selectedIndex].selected = true;
      notifyListeners();
      return;
    }

    // Unselect current
    basketItems[selectedIndex].selected = false;

    // Calculate new index
    int newIndex = isUp ? selectedIndex - 1 : selectedIndex + 1;

    // Clamp to valid range
    if (newIndex < 0) newIndex = 0;
    if (newIndex >= basketItems.length) newIndex = basketItems.length - 1;

    basketItems[newIndex].selected = true;
    lastScannedItem = basketItems[newIndex];

    tempVal = "";
    notifyListeners();
  }

  removeItemFromBasket(BuildContext context, {int? index}) {
    if (basketItems.any(
      (element) => element.selected == true || index != null,
    )) {
      ProductModel p = index != null
          ? basketItems.elementAt(index)
          : basketItems.where((element) => element.selected == true).first;
      // ! if the product already added to table
      if (selectedTable != null &&
          (p.isNewToBasket == false && p.isJustOrdered == false)) {
        if (_ref.watch(mainControllerProvider).isAdmin) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const DefaultTextView(
                text:
                    "Are You Sure you want to remove this product from the Table ?",
              ),
              actions: [
                TextButton(
                  child: const Text('No'),
                  onPressed: () {
                    context.pop();
                  },
                ),
                TextButton(
                  child: const Text('Yes'),
                  onPressed: () async {
                    //! delete record  from table by record id
                    await _iTableRepository
                        .deleteProductById(id: p.productTableId!)
                        .then((value) {
                          basketItems.removeWhere(
                            (element) => element.selected == true,
                          );
                          notifyListeners();
                          getforeignTotalPrice();
                          context.pop();
                        });

                    // return;
                  },
                ),
              ],
            ),
          );
        } else {
          // ! here the role is user
          ToastUtils.showToast(
            type: RequestState.error,
            message: "you don't have permission to delete product",
          );
        }
      } else {
        // ! if just ordered maybe we have same product in database , so here the product increase in database , i need to reopen table to regenerate table
        if (p.isJustOrdered == false) {
          if (index != null) {
            lastDeletedItem = basketItems[index];

            basketItems.removeAt(index);
          } else {
            final index = basketItems.indexWhere((e) => e.selected == true);
            if (index != -1) {
              lastDeletedItem = basketItems[index];

              basketItems.removeAt(index);

              // Auto-select next or previous
              if (basketItems.isNotEmpty) {
                final newIndex = index < basketItems.length
                    ? index
                    : basketItems.length - 1;

                for (var i = 0; i < basketItems.length; i++) {
                  basketItems[i].selected = false;
                }

                basketItems[newIndex].selected = true;
              }
            }
          }
          getforeignTotalPrice();
        } else {
          ToastUtils.showToast(
            type: RequestState.error,
            message: "reopen table then try again",
          );
        }
      }
    }
  }

  onselectProduct(ProductModel p) {
    for (var element in basketItems) {
      if (element == p) {
        lastScannedItem = p;
        element.selected = !(element.selected ?? false);
        if (element.selected == true) {
          discount = element.discount ?? 0;
        }
      } else {
        element.selected = false;
      }
    }
    tempVal = "";
    shouldAnimateToEnd = false;
    notifyListeners();
  }

  void unSelectIngredients(
    ProductModel p, {
    required List<IngredientModel> updatedIngredients,
    String? notes = "",
  }) {
    for (var element in basketItems) {
      if (element == p) {
        element.ingredients = updatedIngredients;

        element.withoutIngredients = updatedIngredients
            .where((e) => !e.isSelected)
            .toList();
        element.ingredientsToBeAdded = updatedIngredients
            .where((e) => e.isSelected)
            .toList();
        p.notes = notes.toString();
      }
    }
    notifyListeners();
  }

  String tempVal = "";

  onchangeQty(String value) {
    foreignTotalPrice = 0;
    tempVal += value;
    for (var element in basketItems) {
      if (element.selected == true) {
        element.qty = double.parse(tempVal);
      }
    }
    getforeignTotalPrice();
    //  notifyListeners();
  }

  onChangeSellingPrice(int productId, double val) {
    foreignTotalPrice = 0;

    for (var element in basketItems) {
      if (element.id == productId) {
        // Calculate the discount
        if (element.sellingPrice != 0) {
          double newDiscountValue =
              ((1 - (val / element.originalSellingPrice!)) * 100)
                  .formatDoubleWith6();
          element.discount = newDiscountValue;
          discount = newDiscountValue;
        }

        getforeignTotalPrice();
        return;
      }
    }
  }

  resetQty() {
    foreignTotalPrice = 0;
    for (var element in basketItems) {
      if (element.selected == true) {
        element.qty = 1;
      }
    }
    //! reset temp value
    tempVal = "";
    getforeignTotalPrice();
    //notifyListeners();
  }

  double foreignTotalPrice = 0;
  double originalForeignPrice = 0;
  double originalLocalPrice = 0;
  double localTotalPrice = 0;
  double totalItemQty = 0;
  getforeignTotalPrice() async {
    foreignTotalPrice = 0;
    originalForeignPrice = 0;
    localTotalPrice = 0;
    totalItemQty = 0;
    for (var element in basketItems) {
      totalItemQty += (element.qty! < 1 ? 1 : element.qty!);
      originalForeignPrice += element.originalSellingPrice! * element.qty!;
      element.sellingPrice =
          element.originalSellingPrice! -
          ((element.originalSellingPrice! * element.discount!) / 100);

      foreignTotalPrice +=
          (element.sellingPrice ?? 0) * double.parse(element.qty.toString());
    }
    localTotalPrice = foreignTotalPrice * dolarRate;
    originalLocalPrice = originalForeignPrice * dolarRate;
    notifyListeners();
  }

  toggleShouldAnimated(bool val) {
    shouldAnimateToEnd = val;
  }

  //! after pay i need to clear recent data
  resetSaleScreen() {
    basketItems.clear();
    totalItemQty = 0;
    foreignTotalPrice = 0;
    localTotalPrice = 0;
    selectedTable = null;
    isJustClickedQuickORder = false;
    customerTextController.clear();
    customerModel = null;
    discount = 0;
    nbOfCustomers = 1;
    lastScannedItem = null;
    lastDeletedItem = null;

    //  resetReceivedAmount();
    _ref.invalidate(selectedOrderTypeProvider);
    notifyListeners();
  }

  //! check if a product exist in basket //! used in remove product
  bool existInBasketProducts(int productId) {
    return basketItems.any((element) => element.id == productId);
  }

  bool isShowInDolarInSaleScreen = false;
  void onchangeShowInDolar() {
    isShowInDolarInSaleScreen = !isShowInDolarInSaleScreen;
    _ref
        .read(appPreferencesProvider)
        .saveData(key: "showPriceInDolar", value: isShowInDolarInSaleScreen);
    notifyListeners();
  }

  // double cashReturns = 0;
  // String receivedAmount = "0";
  // void onReceiveAmount(value) {
  //   if (value == null) {
  //     cashReturns = 0;
  //   } else {
  //     receivedAmount += value.toString();
  //     cashReturns = isShowInDolarInSaleScreen
  //         ? double.parse(receivedAmount) - foreignTotalPrice
  //         : double.parse(receivedAmount) - localTotalPrice;
  //   }
  //   if (isShowInDolarInSaleScreen) {
  //     totalChangeInLebanonInDialog = cashReturns * dolarRate;
  //   }

  //   notifyListeners();
  // }

  // void resetReceivedAmount() {
  //   receivedAmount = "0";
  //   cashReturns = 0;
  //   notifyListeners();
  // }

  //! Tables

  List<TableModel> tables = [];

  TableModel? selectedTable;
  int nbOfCustomers = 1;

  increaseCustomers() {
    nbOfCustomers++;
    notifyListeners();
    if (selectedTable != null) {
      _ref
          .read(tableProviderRepository)
          .updateNbOfCustomers(
            nbOfCustomers: nbOfCustomers,
            tableName: selectedTable!.tableName.toString(),
          );
    }
  }

  decreaseCustomers() {
    nbOfCustomers = --nbOfCustomers < 1 ? 1 : nbOfCustomers;
    notifyListeners();
    if (selectedTable != null) {
      _ref
          .read(tableProviderRepository)
          .updateNbOfCustomers(
            nbOfCustomers: nbOfCustomers,
            tableName: selectedTable!.tableName.toString(),
          );
    }
  }

  Future openTable(String name, int userId) async {
    await _iTableRepository.openTable(name, userId).then((value) {
      tables.where((element) => element.tableName == name).first.isOpened =
          true;
      notifyListeners();
    });
  }

  clearTables() {
    tables = [];
    nbOfCustomers = 1;
    // notifyListeners();
  }

  RequestState fetchTableRequestState = RequestState.success;
  onSelectTable(TableModel tableModel) async {
    fetchTableRequestState = RequestState.loading;
    notifyListeners();

    await _iTableRepository
        .fetchTable(tableModel.tableName.toString())
        .then((value) {
          selectedTable = tableModel;
          nbOfCustomers = value["nbOfCustomers"];
          fetchTableRequestState = RequestState.success;
          basketItems = List<ProductModel>.from(value["products"]);

          for (var element in basketItems) {
            element.isNewToBasket = false;
            element.originalSellingPrice = element.sellingPrice;

            // re add ingredients
            for (var i in element.ingredients!) {
              if (element.withoutIngredients!.any((e) => e.id == i.id)) {
                i.isSelected = false;
              } else {
                i.isSelected = true;
              }
            }
            element.withoutIngredients = element.ingredients!
                .where((e) => !e.isSelected)
                .toList();
            element.ingredientsToBeAdded = element.ingredients!
                .where((e) => e.isSelected)
                .toList();
          }
          discount = 0;
          getforeignTotalPrice();
        })
        .catchError((error) {
          fetchTableRequestState = RequestState.error;
          notifyListeners();
          debugPrint(error.toString());
        });
    notifyListeners();
  }

  unselectTable() {
    resetSaleScreen();
  }

  closeTable(TableModel tableModel) async {
    tables
            .where((element) => element.tableName == tableModel.tableName)
            .first
            .isOpened =
        false;
    await _iTableRepository.deleteTableByName(tableModel.tableName.toString());
    resetSaleScreen();
  }

  // ! on order
  addBasketToTable() async {
    if (selectedTable != null) {
      var basketItemsNew = basketItems
          .where((element) => element.isNewToBasket == true)
          .toList();
      for (var element in basketItemsNew) {
        element.tableName = selectedTable!.tableName;

        await _iTableRepository.addProductToTable(element);
      }

      //! set all just ordered to false after order
      basketItems.where((element) => element.isJustOrdered == true).forEach((
        element,
      ) {
        element.isNewToBasket = false;
        element.isJustOrdered = false;
      });
      //! then set all is new to basket to  just ordered
      basketItems.where((element) => element.isNewToBasket == true).forEach((
        element,
      ) {
        element.isNewToBasket = false;
        element.isJustOrdered = true;
      });
    }

    notifyListeners();
  }

  isAlreadyExistInBasket(ProductModel p) {
    return basketItems
        .where((element) => element.isNewToBasket == false)
        .any((element) => element.id == p.id);
  }

  // on update product
  //  if already product added before changing price , so we will update the price in basket
  onUpdateBasketProductPrice(ProductModel product) {
    for (var element in basketItems) {
      if (element.id == product.id) {
        element.costPrice = product.costPrice;
        element.sellingPrice = product.sellingPrice;
        element.qtyInStock = product.qty;
        element.originalSellingPrice = product.sellingPrice;
        element.discount = product.discount;
        element.isTracked = product.isTracked;
        element.enableNotification = product.enableNotification;
        element.warningAlert = product.warningAlert;
        element.minSellingPrice = product.minSellingPrice;
      }
    }

    getforeignTotalPrice();
  }

  // ! cash dialog

  double changeDue = 0; // total change in USD
  double remainingReturn = 0; // remaining change to return in USD
  double receivedAmount = 0; // total received from customer
  double returnedSoFar = 0; // amount already returned to customer
  double totalChangeInLebanonInDialog = 0;

  bool payInDolar = true;
  bool onEnterReceived = true;

  // Toggle between LBP and USD
  void onchangePaymentCurrency() {
    payInDolar = !payInDolar;
    resetAmounts();
    notifyListeners();
  }

  // Toggle between entering received or return
  void onChangeEnteringAmountType(bool value) {
    onEnterReceived = value;
    if (value == false) {
      returnedSoFar = 0;
      returnedSoFarString = "";
    } else {
      receivedAmount = 0;
      receivedAmountString = "";
    }
    notifyListeners();
  }

  // Reset for new transaction
  void resetAmounts() {
    onEnterReceived = true;
    receivedAmount = 0;
    returnedSoFar = 0;
    changeDue = 0;
    remainingReturn = 0;
    totalChangeInLebanonInDialog = 0;
    receivedAmountString = "";
    returnedSoFarString = "";
    notifyListeners();
  }

  String receivedAmountString = "";
  String returnedSoFarString = "";
  // Call this when pressing keys (like a keypad)
  void onReceiveAmount(String digit) {
    double input = double.tryParse(digit) ?? 0;

    if (onEnterReceived) {
      // Build amount using string concatenation
      receivedAmountString += digit;

      double parsedAmount = double.tryParse(receivedAmountString) ?? 0;
      receivedAmount = parsedAmount;

      // Calculate change due in USD
      if (payInDolar) {
        changeDue = (receivedAmount - foreignTotalPrice).formatDouble();
      } else {
        double receivedUSD = (receivedAmount - localTotalPrice) / dolarRate;
        changeDue = receivedUSD.formatDouble();
      }

      // Reset return tracking
      returnedSoFar = 0;
      remainingReturn = changeDue;
    } else {
      if (changeDue <= 0) return;

      // Build returned value as number keypad (string approach optional here too)
      returnedSoFarString += digit;
      returnedSoFar = double.tryParse(returnedSoFarString) ?? 0;

      remainingReturn = (changeDue - returnedSoFar).clamp(0, double.infinity);
    }

    totalChangeInLebanonInDialog = (remainingReturn * dolarRate).formatDouble();
    notifyListeners();
  }

  bool isShowInLebanonInCashDialog = false;
  void onchangeShowInLebanon() {
    isShowInLebanonInCashDialog = !isShowInLebanonInCashDialog;
    notifyListeners();
  }
}
