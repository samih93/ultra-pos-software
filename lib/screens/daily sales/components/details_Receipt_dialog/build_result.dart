import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/shared/constances/app_constances.dart';
import 'package:desktoppossystem/shared/default%20components/default_price_text.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';

class BuildResult extends StatelessWidget {
  const BuildResult(
      {required this.price,
      required this.lebanesePrice,
      this.remainingAmount,
      super.key});
  final String price;
  final String lebanesePrice;
  final double? remainingAmount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Expanded(child: kEmptyWidget),
            AppPriceText(
              unit: AppConstance.primaryCurrency.currencyLocalization(),
              text: "${S.of(context).totalAmount} : $price",
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Expanded(child: kEmptyWidget),
            AppPriceText(
              unit: AppConstance.secondaryCurrency.currencyLocalization(),
              text:
                  "${S.of(context).totalAmount} : ${double.parse(lebanesePrice).formatAmountNumber()}",
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ],
        ),
        if (remainingAmount != null && remainingAmount! > 0) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Expanded(child: kEmptyWidget),
              AppPriceText(
                unit: AppConstance.primaryCurrency.currencyLocalization(),
                text:
                    "${S.of(context).remaining.capitalizeFirstLetter()} : ${remainingAmount!.formatDouble()} ",
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ],
          ),
        ],
      ],
    );
  }
}
