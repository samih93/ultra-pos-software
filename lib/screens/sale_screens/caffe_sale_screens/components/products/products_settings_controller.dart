import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/services/dependency_injection.dart';

final productsSettingsControllerProvider =
    ChangeNotifierProvider<ProductSettingsController>((ref) {
  return ProductSettingsController(ref: ref);
});

class ProductSettingsController extends ChangeNotifier {
  final Ref _ref;
  ProductSettingsController({required Ref ref}) : _ref = ref {
    _fetchProductSetting();
  }

  Future _fetchProductSetting() async {
    productWidth =
        await _ref.read(appPreferencesProvider).getData(key: "productWidth") ??
            90;
    profitRate =
        await _ref.read(appPreferencesProvider).getData(key: "profitRate") ?? 0;

    showText = _ref.read(appPreferencesProvider).getBool(key: "showText");
    showMinSellingPrice =
        _ref.read(appPreferencesProvider).getBool(key: "showMinSellingPrice");
    showProductImage =
        _ref.read(appPreferencesProvider).getBool(key: "showProductImage");

    isBold = _ref
        .read(appPreferencesProvider)
        .getBool(key: "isBold", defaultValue: false);
    isShowQty = _ref.read(appPreferencesProvider).getBool(key: "isShowQty");
    duplicateLatestProductOnAdd = _ref
        .read(appPreferencesProvider)
        .getBool(key: "duplicateLatestProductOnAdd");

    isUsingScale = _ref
        .read(appPreferencesProvider)
        .getBool(key: "isUsingScale", defaultValue: false);
    notifyListeners();
  }

  double productWidth = 90;
  double profitRate = 0;
  int lowQty = 10;
  bool isBold = true;
  bool isShowQty = false;
  bool showText = false;
  bool duplicateLatestProductOnAdd = false;
  bool showMinSellingPrice = false;
  bool isUsingScale = false;

  onChangeUsingScale() {
    isUsingScale = !isUsingScale;
    _ref
        .read(appPreferencesProvider)
        .saveData(key: "isUsingScale", value: isUsingScale);
    notifyListeners();
  }

  onchangeFontWeight() {
    isBold = !isBold;
    _ref.read(appPreferencesProvider).saveData(key: "isBold", value: isBold);
    notifyListeners();
  }

  onchangeMinSellingPrice() {
    showMinSellingPrice = !showMinSellingPrice;
    _ref
        .read(appPreferencesProvider)
        .saveData(key: "showMinSellingPrice", value: showMinSellingPrice);
    notifyListeners();
  }

  toggleQuickAdd() {
    duplicateLatestProductOnAdd = !duplicateLatestProductOnAdd;
    _ref.read(appPreferencesProvider).saveData(
        key: "duplicateLatestProductOnAdd", value: duplicateLatestProductOnAdd);
    notifyListeners();
  }

  onchangeTextVisibility() {
    showText = !showText;
    _ref
        .read(appPreferencesProvider)
        .saveData(key: "showText", value: showText);
    notifyListeners();
  }

  bool showProductImage = false;
  toggleProductImage() {
    showProductImage = !showProductImage;
    _ref
        .read(appPreferencesProvider)
        .saveData(key: "showProductImage", value: showProductImage);
    notifyListeners();
  }

  onchangeQtyVisibility() {
    isShowQty = !isShowQty;
    _ref
        .read(appPreferencesProvider)
        .saveData(key: "isShowQty", value: isShowQty);
    notifyListeners();
  }

  onchangeProductWidth(double width) {
    productWidth = width;
    _ref
        .read(appPreferencesProvider)
        .saveData(key: "productWidth", value: productWidth);

    notifyListeners();
  }

  onchangeProfitRate(double profit) {
    profitRate = profit;
    _ref
        .read(appPreferencesProvider)
        .saveData(key: "profitRate", value: profitRate);

    notifyListeners();
  }
}
