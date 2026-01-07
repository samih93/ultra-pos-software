import 'package:desktoppossystem/controller/search_product_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/product_model.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_form.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class SearchAndSelectProductDialog extends ConsumerWidget {
  const SearchAndSelectProductDialog({required this.onSelected, super.key});
  final Function(ProductModel) onSelected;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var searchProductController = ref.watch(searchProductControllerProvider);
    return AlertDialog(
      content: SizedBox.square(
        dimension: 300,
        child: Column(
          children: [
            TypeAheadField<ProductModel>(
              hideOnError: true,
              hideOnEmpty: true,
              builder: (context, controller, focusNode) {
                return DefaultTextFormField(
                  autofocus: true,
                  inputtype: TextInputType.text,
                  controller: controller,
                  focusNode: focusNode,
                  textColor: context.brightnessColor,
                  hinttext: " ${S.of(context).searchByNameOrBarcode} ",
                );
              },

              itemBuilder: (context, ProductModel? suggestion) {
                return Column(
                  // mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      tileColor: Colors.white,
                      trailing: DefaultTextView(
                        color: Colors.black,
                        text: "${suggestion?.barcode}",
                      ),
                      title: DefaultTextView(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        text: "${suggestion?.name}",
                      ),
                      subtitle: DefaultTextView(
                        fontSize: 12,
                        color: Colors.black,
                        text: "${suggestion?.sellingPrice} \$",
                      ),
                    ),
                    const Divider(color: Colors.grey, height: 1),
                  ],
                );
              },

              // onSuggestionSelected: (ProductModel? suggestion) async {
              //   if (suggestion != null) {
              //     context.read<SaleController>().addItemToBasket(suggestion);
              //     context.pop();
              //   }
              // },

              //   noItemsFoundBuilder: (context) => kEmptyWidget,
              suggestionsCallback: (String query) async {
                if (query.trim().length >= 2) {
                  var products = await searchProductController
                      .searchForAProducts(query);
                  return products.toList();
                }
                return [];
              },
              onSelected: (ProductModel value) {
                onSelected(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}
