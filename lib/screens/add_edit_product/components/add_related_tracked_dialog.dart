import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/product_model.dart';
import 'package:desktoppossystem/screens/add_edit_product/add_edit_product_controller.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_form.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/default%20components/elevated_button_widget.dart';
import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class AddRelatedTrackedProductDialog extends ConsumerWidget {
  const AddRelatedTrackedProductDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: DefaultTextView(
        text: S.of(context).selectProductFromStock,
        fontWeight: FontWeight.bold,
        textAlign: TextAlign.center,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: TypeAheadField<ProductModel>(
                  hideOnError: true,
                  hideOnEmpty: true,
                  builder: (context, controller, focusNode) {
                    ref
                            .read(addEditProductControllerProvider)
                            .offerProductController =
                        controller;

                    return DefaultTextFormField(
                      inputtype: TextInputType.text,
                      controller: ref
                          .read(addEditProductControllerProvider)
                          .offerProductController,
                      focusNode: focusNode,
                      text: "${S.of(context).selectProductFromStock} ",
                      hinttext: " ${S.of(context).searchByNameOrBarcode}",
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
                            maxlines: 2,
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
                  suggestionsCallback: (String query) async {
                    var products = await ref
                        .read(addEditProductControllerProvider)
                        .searchForAProducts(query, isTracked: true);
                    return products.toList();
                  },
                  onSelected: (ProductModel value) {
                    // context.pop();
                    ref
                        .read(addEditProductControllerProvider)
                        .onSetCurrentSelectedProduct(value);
                  },
                ),
              ),
            ],
          ),
          Row(
            children: [
              Expanded(
                child: DefaultTextFormField(
                  hinttext: S.of(context).qty,
                  inputtype: TextInputType.number,
                  onchange: (val) {
                    ref
                        .read(addEditProductControllerProvider)
                        .onSetCurrentSelectedQty(
                          double.tryParse(val.toString()) ?? 0,
                        );
                  },
                  format: numberTextFormatter,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        ElevatedButtonWidget(
          icon: Icons.add,
          text: S.of(context).add,
          onPressed: () {
            ref
                .read(addEditProductControllerProvider)
                .addTrackedRelatedProduct();
            context.pop();
          },
        ),
      ],
    );
  }
}
