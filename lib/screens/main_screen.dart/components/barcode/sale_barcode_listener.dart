import 'dart:io';

import 'package:desktoppossystem/controller/product_controller.dart';
import 'package:desktoppossystem/repositories/products/product_repository.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_screen.dart';
import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
import 'package:desktoppossystem/shared/constances/screens_title_constant.dart';
import 'package:desktoppossystem/shared/default%20components/auto_complete_product.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BarcodeScanListener extends ConsumerWidget {
  final TextEditingController barcodeSearchTextController;

  const BarcodeScanListener({
    super.key,
    required this.barcodeSearchTextController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isActive =
        ref.watch(currentMainScreenProvider) == ScreenName.SaleScreen &&
            ref.watch(barcodeListenerEnabledProvider);

    if (!isActive) {
      return kEmptyWidget;
    }

    return BarcodeKeyboardListener(
      useKeyDownEvent: Platform.isWindows,
      bufferDuration: const Duration(milliseconds: 200),
      onBarcodeScanned: (barcode) async {
        // Set scanning state FIRST to prevent other components from processing
        ref.read(isScanningProvider.notifier).state = true;

        // Clear any existing text immediately
        barcodeSearchTextController.clear();
        ref.read(autoCompleteProductsearchTextProvider.notifier).state = "";

        // Unfocus any active text fields
        FocusScope.of(context).unfocus();

        barcode = barcode.trim();

        // Ignore empty barcode or invalid scan
        if (barcode.isEmpty || barcode == "V") {
          ref.read(isScanningProvider.notifier).state = false;
          return;
        }

        if (barcode.startsWith('27') && barcode.length == 13) {
          String prefix = barcode.substring(0, 2);
          String plu = barcode.substring(2, 7);
          String weightDigits = barcode.substring(7, 12);
          int weightGrams = int.parse(weightDigits);
          double weightKg = weightGrams / 1000;

          // Try to fetch by PLU first
          final product = await ref
              .read(productProviderRepository)
              .fetchProductByPlu(plu.validateInteger());

          if (product != null) {
            // Add weighted product to basket with the calculated weight
            ref.read(saleControllerProvider).addItemToBasket(
                  product,
                  weight: weightKg,
                );

            Future.delayed(const Duration(milliseconds: 750), () {
              ref.read(isScanningProvider.notifier).state = false;
            });
            return; // Exit after handling weighted product
          }
          // If PLU not found, continue to normal barcode processing
        }
        // Fetch product by barcode and add to basket
        ref
            .read(productControllerProvider)
            .fetchProductByBarcode(barcode.trim())
            .then((value) {
          if (value != null) {
            ref.read(saleControllerProvider).addItemToBasket(value);
            Future.delayed(
              const Duration(milliseconds: 750),
              () {
                ref.read(isScanningProvider.notifier).state = false;
              },
            );
          } else {
            showDialog(
              context: context,
              builder: (_) {
                // Automatically pop the dialog after 2 seconds
                Future.delayed(
                  const Duration(seconds: 2),
                  () {
                    barcodeSearchTextController.clear();
                    FocusScope.of(context).unfocus();

                    context.pop();
                  },
                );
                return AlertDialog(
                  title: const Center(
                    child: DefaultTextView(text: 'Not found !!!'),
                  ),
                  actions: [
                    TextButton(
                      child: const Text('Ok'),
                      onPressed: () {
                        barcodeSearchTextController.clear();
                        ref
                            .read(isOnSearchProvider.notifier)
                            .update((state) => false);

                        context.pop();
                      },
                    ),
                  ],
                );
              },
            );
          }
        });
      },
      child: kEmptyWidget,
    );
  }
}
