import 'package:desktoppossystem/shared/services/dependency_injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final categoriesSettingsControllerProvider =
    ChangeNotifierProvider<CategoriesSettingsController>((ref) {
  return CategoriesSettingsController(ref: ref);
});

class CategoriesSettingsController extends ChangeNotifier {
  final Ref _ref;
  CategoriesSettingsController({required Ref ref}) : _ref = ref {
    _fetchCategorySetting();

    notifyListeners();
  }

  Future _fetchCategorySetting() async {
    categoryWidth =
        await _ref.read(appPreferencesProvider).getData(key: "categoryWidth") ??
            100;
    isShowRestaurantStock = _ref
        .read(appPreferencesProvider)
        .getBool(key: "isShowRestaurantStock", defaultValue: true);

    nbOfLines =
        await _ref.read(appPreferencesProvider).getData(key: "nbOfLines") ?? 2;
    categoriesSectionHeight = nbOfLines == 2 ? 130 : 65;
    notifyListeners();
  }

  double categoriesSectionHeight = 65;
  int nbOfLines = 2;
  double categoryWidth = 100;

  bool isShowRestaurantStock = true;

  onchangeNbOfLine(int lines) {
    nbOfLines = lines;
    categoriesSectionHeight = nbOfLines == 2 ? 130 : 65;

    _ref
        .read(appPreferencesProvider)
        .saveData(key: "nbOfLines", value: nbOfLines);

    notifyListeners();
  }

  onChangeCategoryWidth(double width) {
    categoryWidth = width;
    _ref
        .read(appPreferencesProvider)
        .saveData(key: "categoryWidth", value: categoryWidth);
    notifyListeners();
  }

  onChangeCategorySectionHeight(double height) {
    categoriesSectionHeight = height;
    _ref.read(appPreferencesProvider).saveData(
        key: "categoriesSectionHeight", value: categoriesSectionHeight);
    notifyListeners();
  }

  // onchangeVisibilityOfCategories() {
  //   isHiddenCategoriesList = !isHiddenCategoriesList;
  //   sl<SharedPreferences>()
  //       .setBool("isHiddenCategoriesList", isHiddenCategoriesList);
  //   notifyListeners();
  // }

  onchangeVisibilityOfRestaurantStock() {
    isShowRestaurantStock = !isShowRestaurantStock;
    _ref
        .read(appPreferencesProvider)
        .saveData(key: "isShowRestaurantStock", value: isShowRestaurantStock);
    notifyListeners();
  }
}
