import 'dart:async';
import 'dart:io';

import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/product_model.dart';
import 'package:desktoppossystem/controller/search_product_controller.dart';
import 'package:desktoppossystem/repositories/products/product_repository.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_screen.dart';
import 'package:desktoppossystem/shared/default%20components/app_text_form_field.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

final autoCompleteProductsearchTextProvider = StateProvider<String>(
  (ref) => "",
); // Holds search text globally

class AutoCompleteProduct extends ConsumerStatefulWidget {
  const AutoCompleteProduct({
    required this.onProductSelected,
    this.onFieldSubmit,
    this.clearSearchField,
    this.isForMarket,
    super.key,
  });
  final Function(ProductModel) onProductSelected;
  final Function(ProductModel)? onFieldSubmit;
  final VoidCallback? clearSearchField;
  final bool? isForMarket;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AutoCompleteProductState();
}

class _AutoCompleteProductState extends ConsumerState<AutoCompleteProduct> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  Timer? _debounceTimer;
  final FocusNode focusNode = FocusNode();

  @override
  void dispose() {
    _debounceTimer?.cancel(); // Properly cancel the timer
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isScanning = ref.watch(isScanningProvider); // Listen for changes
    final searchText = ref.watch(
      autoCompleteProductsearchTextProvider,
    ); // Watch search text

    return Form(
      key: _formkey,
      child: SizedBox(
        width: Platform.isWindows ? context.width * 0.24 : context.width * 0.5,
        child: TypeAheadField<ProductModel>(
          hideOnError: true,
          hideOnEmpty: true,
          focusNode: focusNode,
          builder: (context, controller, focusNode) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (controller.text != searchText) {
                controller.text = searchText;
              }
            });
            return AppTextFormField(
              backColor: widget.isForMarket == true
                  ? Pallete.coreMist50Color
                  : null,
              prefixIcon: const Icon(Icons.search, color: Pallete.greyColor),
              onfieldsubmit: (p0) async {
                if (isScanning) {
                  return;
                }
                ref.read(autoCompleteProductsearchTextProvider.notifier).state =
                    "";

                if (p0.isNotEmpty) {
                  if (p0.startsWith('27') && p0.length == 13) {
                    String prefix = p0.substring(0, 2);
                    String plu = p0.substring(2, 7);
                    String weightDigits = p0.substring(7, 12);
                    int weightGrams = int.parse(weightDigits);
                    double weightKg = weightGrams / 1000;

                    // Try to fetch by PLU first
                    final product = await ref
                        .read(productProviderRepository)
                        .fetchProductByPlu(plu.validateInteger());

                    if (product != null && widget.onFieldSubmit != null) {
                      product.weight = weightKg; // Set the weight
                      widget.onFieldSubmit!(product);

                      FocusScope.of(context).requestFocus(focusNode);
                      return;
                    }
                  }
                  // If PLU not found, continue to normal barcode processing
                  var products = await ref
                      .read(searchProductControllerProvider)
                      .searchForAProducts(p0, isForBarcode: true);
                  if (products.isNotEmpty && widget.onFieldSubmit != null) {
                    widget.onFieldSubmit!(products[0]);

                    FocusScope.of(context).requestFocus(focusNode);
                  }
                }
              },
              inputtype: TextInputType.text,
              controller: controller,
              focusNode: focusNode,
              hinttext: " ${S.of(context).searchByNameOrBarcode} ",
            );
          },
          itemBuilder: (context, ProductModel? suggestion) {
            return Stack(
              alignment: AlignmentDirectional.topEnd,
              children: [
                Column(
                  // mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      tileColor: Colors.white,
                      trailing: DefaultTextView(
                        color: Colors.black,
                        text: suggestion?.isWeighted != true
                            ? suggestion?.barcode ?? ''
                            : "code: ${suggestion?.plu ?? ''}",
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
                        text:
                            "${suggestion?.isWeighted == true ? "1kg" : ''} ${suggestion?.sellingPrice} \$",
                      ),
                    ),
                    const Divider(color: Colors.grey, height: 1),
                  ],
                ),
                if (suggestion != null &&
                    suggestion.discount != null &&
                    suggestion.discount! > 0)
                  DefaultTextView(
                    color: Pallete.redColor,
                    text: "${suggestion.discount} %",
                    fontWeight: FontWeight.bold,
                  ),
              ],
            );
          },
          suggestionsCallback: (String query) async {
            if (query.trim().length < 2) return [];
            // Create a completer to return the results
            Completer<List<ProductModel>> completer = Completer();

            _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
              // API call after debounce period
              List<ProductModel> products = await ref
                  .read(searchProductControllerProvider)
                  .searchForAProducts(query);

              // Complete the future with the result
              completer.complete(products.toList());
            });

            // Return the result of the completer (will complete after debounce)
            return completer.future;
          },
          onSelected: (ProductModel value) {
            _formkey.currentState!.reset();

            widget.onProductSelected(value);

            ref.invalidate(searchProductControllerProvider);
            ref.invalidate(autoCompleteProductsearchTextProvider);
          },
        ),
      ),
    );
  }
}
