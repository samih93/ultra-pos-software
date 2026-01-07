import 'package:desktoppossystem/controller/category_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/category_model.dart';
import 'package:desktoppossystem/screens/add_edit_category/add_edit_category_screen.dart';
import 'package:desktoppossystem/screens/stock_screen/stock_controller.dart';
import 'package:desktoppossystem/shared/default%20components/app_squared_outlined_button.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class StockCategorySection extends ConsumerWidget {
  StockCategorySection({super.key});
  final TextEditingController _categoryTextController = TextEditingController();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoryControllerProvider).categories;

    final selectedCategory = ref.watch(selectedStockCategoryProvider);
    _categoryTextController.text = selectedCategory?.name.toString() ?? '';
    final categoryDropDown = Container(
      height: 45,
      padding: const EdgeInsets.only(left: 20, right: 20),
      decoration: BoxDecoration(
        borderRadius: defaultRadius,
        color: context.cardColor,
        border: Border.all(width: 1, color: Pallete.greyColor),
      ),
      child: DropdownMenu<CategoryModel>(
        enabled: selectedCategory == null,
        menuHeight: 300,
        controller: _categoryTextController,
        width: context.isMobile ? double.infinity : 250,
        enableSearch: true,
        enableFilter: true,
        textStyle: TextStyle(color: context.primaryColor),
        hintText: S.of(context).selectCategory,
        //   dropdownColor: Colors.white,
        initialSelection: selectedCategory,
        inputDecorationTheme: const InputDecorationTheme(
          contentPadding: EdgeInsets.only(bottom: 8),
          border: InputBorder.none,
        ),
        onSelected: (value) {
          ref.read(stockControllerProvider).onSelectCategory(value!);
        },
        searchCallback: (entries, query) {
          // final String searchText =
          //     _categoryTextController.value.text.toLowerCase();
          // if (searchText.isEmpty) {
          //   return null;
          // }
          final int index = entries.indexWhere(
            (DropdownMenuEntry<CategoryModel> entry) =>
                entry.label.toLowerCase().contains(query),
          );

          return index != -1 ? index : null;
        },
        dropdownMenuEntries: [
          ...categories
              .map(
                (e) => DropdownMenuEntry<CategoryModel>(
                  value: e,
                  label: '${e.name}',
                ),
              )
              .toList(),
        ],
      ),
    );
    return Row(
      spacing: 5,
      children: [
        if (!context.isMobile)
          DefaultTextView(text: "${S.of(context).filterByCategory}: "),

        if (context.isMobile)
          Expanded(child: categoryDropDown)
        else
          categoryDropDown,
        if (selectedCategory != null) ...[
          AppSquaredOutlinedButton(
            size: const Size(45, 45),
            child: const Icon(FontAwesomeIcons.penToSquare, size: 20),
            onPressed: () {
              context.to(AddEditCategoryScreen(selectedCategory));
            },
          ),
          AppSquaredOutlinedButton(
            size: const Size(45, 45),
            child: const Icon(Icons.close, color: Pallete.redColor),
            onPressed: () {
              ref.read(stockControllerProvider).clearCategory();
              _categoryTextController.clear();
            },
          ),
        ],
      ],
    );
  }
}
