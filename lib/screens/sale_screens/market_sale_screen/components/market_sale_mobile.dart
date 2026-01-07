import 'package:desktoppossystem/screens/sale_screens/caffe_sale_screens/components/basket_list/basket_list.dart';
import 'package:desktoppossystem/screens/sale_screens/market_sale_screen/components/mobile_scanner_section.dart';
import 'package:desktoppossystem/screens/sale_screens/shared_components/total_amount_section.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MarketSaleMobile extends ConsumerWidget {
  const MarketSaleMobile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isScanning = ref.watch(mobileScannerActiveProvider);
    return Padding(
      padding: kPadd5,
      child: Column(
        children: [
          if (isScanning) ...[
            const Expanded(child: MobileScannerSection()),
            kGap8,
          ],

          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: defaultRadius,
                color: context.cardColor,
                border: Border.all(color: Pallete.greyColor),
              ),
              child: const BasketList(),
            ),
          ),
          kGap8,
          Container(
            padding: defaultPadding,
            decoration: BoxDecoration(
              borderRadius: defaultRadius,
              border: Border.all(color: Pallete.greyColor),
              color: context.cardColor,
            ),
            child: const TotalAmountSection(),
          ),
        ],
      ),
    );
  }
}
