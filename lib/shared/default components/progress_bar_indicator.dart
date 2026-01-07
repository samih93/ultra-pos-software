import 'package:desktoppossystem/shared/constances/app_constances.dart';
import 'package:desktoppossystem/shared/default%20components/default_price_text.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProgressBarIndicator extends ConsumerWidget {
  const ProgressBarIndicator({
    this.title,
    required this.percentage,
    required this.color,
    this.amount,
    this.forRevenue,
    super.key,
  });

  final String? title;
  final double percentage;
  final Color color;
  final double? amount;
  final bool? forRevenue;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          DefaultTextView(
            fontSize: 13,
            text:
                "${title != null ? "$title: " : ""}  ${forRevenue == true ? '' : "${percentage.toStringAsFixed(1)} %"}",
            fontWeight: FontWeight.bold,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                flex: 7,
                child: LinearProgressIndicator(
                  value: percentage / 100,
                  color: color,
                  backgroundColor: Colors.grey.shade300,
                  minHeight: 8,
                ),
              ),
              if (amount != null)
                Expanded(
                  flex: 3,
                  child: AppPriceText(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    text: "${amount.formatDouble()}",
                    unit: AppConstance.primaryCurrency.currencyLocalization(),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
