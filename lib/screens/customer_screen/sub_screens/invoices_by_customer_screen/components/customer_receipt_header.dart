import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/shared/constances/app_constances.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomerReceiptHeader extends ConsumerWidget {
  const CustomerReceiptHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      crossAxisAlignment: .start,
      children: [
        Expanded(
          child: Center(
            child: DefaultTextView(
              text: S.of(context).receiptNumber,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Center(
            child: DefaultTextView(
              text: S.of(context).time,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: DefaultTextView(
              text: '(${AppConstance.primaryCurrency.currencyLocalization()})',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: DefaultTextView(
              text: '${AppConstance.secondaryCurrency.currencyLocalization()}',
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: DefaultTextView(
              text:
                  "${S.of(context).remaining}${AppConstance.primaryCurrency.currencyLocalization()}",
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        kGap30,
      ],
    );
  }
}
