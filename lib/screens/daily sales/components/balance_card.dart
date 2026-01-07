import 'package:desktoppossystem/shared/constances/app_constances.dart';
import 'package:desktoppossystem/shared/default%20components/default_price_text.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BalanceCard extends ConsumerWidget {
  const BalanceCard({
    required this.title,
    required this.color,
    required this.primary,
    this.secondary,
    this.height,
    this.isCount,
    super.key,
  });

  final Color color;
  final String title;
  final double primary;
  final double? secondary;
  final double? height;
  final bool? isCount;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        DefaultTextView(
          text: title,
          fontSize: context.smallSize,
          fontWeight: FontWeight.bold,
        ),
        ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: context.isMobile ? 100 : 120,
            minHeight: height ?? 50,
            maxHeight: 60,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.rectangle,
              borderRadius: kRadius8,
              border: Border.all(color: color),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppPriceText(
                  fontSize: context.smallSize,
                  fontWeight: FontWeight.bold,
                  text: "${primary.formatDouble()}",
                  unit:
                      " ${isCount == true ? "" : AppConstance.primaryCurrency.currencyLocalization()}",
                ),
                if (secondary != null)
                  AppPriceText(
                    fontSize: context.smallSize,
                    text: secondary.formatAmountNumber(),
                    unit:
                        "${AppConstance.secondaryCurrency.currencyLocalization()}",
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
