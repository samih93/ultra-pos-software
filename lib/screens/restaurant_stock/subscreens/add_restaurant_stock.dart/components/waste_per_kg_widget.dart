import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/restaurant_stock/subscreens/add_restaurant_stock.dart/add_restauarnt_stock_item_screen.dart';
import 'package:desktoppossystem/shared/default%20components/default_price_text.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WastePerKgWidget extends ConsumerWidget {
  const WastePerKgWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wastePerKg = ref.watch(wastePerKgProvider);
    return Row(
      children: [
        DefaultTextView(
          text: "${S.of(context).wastePerKg} :",
          color: Pallete.redColor,
        ),
        kGap10,
        AppPriceText(
          text: "$wastePerKg",
          unit: UnitType.kg.uniteTypeToString(),
          fontWeight: FontWeight.w600,
        )
      ],
    );
  }
}
