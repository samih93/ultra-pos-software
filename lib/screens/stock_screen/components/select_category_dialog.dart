import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/category_model.dart';
import 'package:desktoppossystem/screens/add_edit_category/add_edit_category_screen.dart';
import 'package:desktoppossystem/screens/stock_screen/stock_controller.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/default%20components/elevated_button_widget.dart';
import 'package:desktoppossystem/shared/default%20components/app_text_form_field.dart';
import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class SearchAndSelectCategory extends ConsumerWidget {
  const SearchAndSelectCategory(
      {required this.onSelected, this.showAddButton, super.key});
  final Function(CategoryModel) onSelected;
  final bool? showAddButton;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var stockController = ref.watch(stockControllerProvider);
    return Scaffold(
      body: Padding(
        padding: kPaddH5,
        child: Column(
          children: [
            kGap5,
            if (showAddButton == true) ...[
              ElevatedButtonWidget(
                icon: Icons.add,
                text: S.of(context).add,
                width: double.infinity,
                onPressed: () {
                  context.to(const AddEditCategoryScreen(null));
                },
              ),
              kGap5
            ],
            TypeAheadField<CategoryModel>(
                hideOnError: true,
                hideOnEmpty: true,
                builder: (context, controller, focusNode) {
                  return AppTextFormField(
                    inputtype: TextInputType.text,
                    controller: controller,
                    focusNode: focusNode,
                    hinttext: S.of(context).searchByName,
                  );
                },
                itemBuilder: (context, CategoryModel? suggestion) {
                  return Column(
                    // mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        dense: true,
                        //  tileColor: Colors.white,
                        trailing: Container(
                          margin: kPadd3,
                          width: 40,
                          decoration: BoxDecoration(
                              color: Color(suggestion?.color != null
                                  ? int.parse(suggestion!.color!)
                                  : 0xFF0000),
                              border: Border.all(
                                color: Colors.grey,
                                width: 2,
                              )),
                        ),
                        title: DefaultTextView(
                          textAlign: isEnglishLanguage
                              ? TextAlign.left
                              : TextAlign.right,
                          fontWeight: FontWeight.bold,
                          text: "${suggestion?.name}",
                        ),
                      ),
                      const Divider(
                        color: Colors.grey,
                        height: 1,
                      )
                    ],
                  );
                },
                suggestionsCallback: (String query) async {
                  var categories =
                      await stockController.fetchCategoriesByQuery(query);
                  return categories;
                },
                onSelected: onSelected),
          ],
        ),
      ),
    );
  }
}
