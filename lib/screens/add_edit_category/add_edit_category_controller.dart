import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:desktoppossystem/models/category_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final addEditCategoryControllerProvider =
    ChangeNotifierProvider<AddEditCategoryController>((ref) {
  return AddEditCategoryController();
});

class AddEditCategoryController extends ChangeNotifier {
  GlobalKey<FormState> formkey = GlobalKey<FormState>();

  //! for display color and text in category
  CategoryModel? categoryModel;

  var categoryNameController = TextEditingController();

  onsetCategory(CategoryModel? c) {
    //! if category null create empty category
    categoryModel = c ?? CategoryModel.second();
    debugPrint("category color ${c?.color.toString()}");
    //! case edit category
    if (c != null) {
      selectedBackgroundColor = c.color!.getColorFromHex();
      selectedSection = c.sectionType!;
      hideOnMenu = c.hideOnMenu ?? false;
    }
    //!case add cateogry
    else {
      categoryModel!.color = "0xffff0000";
      categoryModel!.sectionType = SectionType.kitchen;
      selectedSection = SectionType.kitchen;
      selectedBackgroundColor = Colors.red;
    }

    //!set controller to the category name
    categoryNameController.text = categoryModel!.name == null
        ? ''.toString()
        : categoryModel!.name.toString();
  }

  //! onchange field name and display them into category item
  void onchangeFieldName(String val) {
    categoryModel?.name = val;
    notifyListeners();
  }

  //! change backgorund color of category
  //Color? pickercategorybackgorundColor;
  Color selectedBackgroundColor = Colors.red;
  void onchangeBackroundColor(Color color) {
    selectedBackgroundColor = color;
    categoryModel!.color = color.getStringColorFromHex();
    notifyListeners();
  }

  SectionType selectedSection = SectionType.kitchen;
  void onchangeSection(SectionType section) {
    selectedSection = section;
    categoryModel!.sectionType = selectedSection;
    notifyListeners();
  }

  bool hideOnMenu = false;
  void toggleHideOnMenu() {
    hideOnMenu = !hideOnMenu;
    categoryModel!.hideOnMenu = hideOnMenu;
    notifyListeners();
  }

  @override
  void dispose() {
    categoryNameController.dispose();
    super.dispose();
  }
}
