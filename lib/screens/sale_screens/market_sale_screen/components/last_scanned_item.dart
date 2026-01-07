import 'package:desktoppossystem/models/product_model.dart';
import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
import 'package:desktoppossystem/shared/constances/app_constances.dart';
import 'package:desktoppossystem/shared/default%20components/default_price_text.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LastScannedItem extends ConsumerWidget {
  const LastScannedItem({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ProductModel? lastScannedItem = ref
        .watch(saleControllerProvider)
        .lastScannedItem;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: defaultPadding,
      //  width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(color: Pallete.greyColor),
        borderRadius: defaultRadius,
        color: context.cardColor,
      ),
      child: lastScannedItem != null
          ? Column(
              children: [
                if (lastScannedItem.image != null) ...[
                  Expanded(child: Image.memory(lastScannedItem.image!)),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: DefaultTextView(
                          maxlines: 2,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          text: lastScannedItem.name.toString(),
                        ),
                      ),
                      if (lastScannedItem.barcode != null &&
                          lastScannedItem.barcode!.isNotEmpty)
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: DefaultTextView(
                            fontSize: 12,
                            text: lastScannedItem.barcode.toString(),
                          ),
                        ),
                      Flexible(
                        child: Row(
                          children: [
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.center,
                                child: AppPriceText(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  unit: AppConstance.primaryCurrency,
                                  text:
                                      "${lastScannedItem.sellingPrice.formatDouble()}",
                                ),
                              ),
                            ),
                            Container(
                              width: 1,
                              color: Pallete.greyColor,
                              height: 25,
                            ),
                            Expanded(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.center,
                                child: AppPriceText(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  unit: AppConstance.secondaryCurrency,
                                  text:
                                      (lastScannedItem.sellingPrice! *
                                              ref
                                                  .watch(saleControllerProvider)
                                                  .dolarRate)
                                          .formatAmountNumber(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Container(width: double.infinity),
    );
  }
}
