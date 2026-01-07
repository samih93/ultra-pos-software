import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
import 'package:desktoppossystem/screens/sale_screens/shared_components/footer_section/components/pay_button.dart';
import 'package:desktoppossystem/shared/constances/app_constances.dart';
import 'package:desktoppossystem/shared/default%20components/default_price_text.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TotalAmountSection extends ConsumerWidget {
  const TotalAmountSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var saleController = ref.watch(saleControllerProvider);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Row for primary and secondary prices
        Expanded(
          flex: 2,
          child: Column(
            children: [
              Row(
                children: [
                  if (saleController.discount > 0)
                    DefaultTextView(
                      text:
                          "${saleController.originalForeignPrice.formatDouble()}",
                      color: Colors.grey.shade800,
                      textDecoration: TextDecoration.lineThrough,
                      fontSize: 14,
                    ),
                  kGap5,
                  AppPriceText(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    text: "${saleController.foreignTotalPrice.formatDouble()}",
                    unit:
                        " ${AppConstance.primaryCurrency.currencyLocalization()}",
                    color: context.primaryColor,
                  ),
                ],
              ),
              Row(
                children: [
                  if (saleController.discount > 0)
                    DefaultTextView(
                      text: saleController.originalLocalPrice
                          .formatAmountNumber(),
                      textDecoration: TextDecoration.lineThrough,
                      fontSize: 12,
                      color: Colors.grey.shade800,
                    ),
                  kGap5,
                  AppPriceText(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    text: saleController.localTotalPrice.formatAmountNumber(),
                    unit:
                        " ${AppConstance.secondaryCurrency.currencyLocalization()}",
                    color: context.primaryColor,
                  ),
                ],
              ),
            ],
          ),
        ),

        // Pay button section
        const Expanded(child: PayButton()),
      ],
    );
  }
}
