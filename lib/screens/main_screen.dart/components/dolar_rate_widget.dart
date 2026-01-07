import 'package:desktoppossystem/screens/dolar_rate_screen/dolar_rate_screen.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_screen.dart';
import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
import 'package:desktoppossystem/shared/constances/app_constances.dart';
import 'package:desktoppossystem/shared/constances/screens_title_constant.dart';
import 'package:desktoppossystem/shared/default%20components/default_price_text.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DolarRateWidget extends ConsumerWidget {
  const DolarRateWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isShowDolarRate =
        ref.watch(saleControllerProvider).isShowInDolarInSaleScreen;
    final currentMainScreen = ref.watch(currentMainScreenProvider);
    return isShowDolarRate && currentMainScreen == ScreenName.SaleScreen
        ? InkWell(
            onTap: ref.watch(mainControllerProvider).isAdmin
                ? () {
                    showDialog(
                      context: context,
                      builder: (context) => const AlertDialog(
                        content: DolarRateScreen(),
                      ),
                    );
                  }
                : null,
            child: Row(
              children: [
                AppPriceText(
                  text: "1",
                  unit:
                      "${AppConstance.primaryCurrency.currencyLocalization()}",
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                AppPriceText(
                  text:
                      "=> ${ref.read(saleControllerProvider).dolarRate.formatAmountNumber()}",
                  unit:
                      "${AppConstance.secondaryCurrency.currencyLocalization()}",
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ],
            ),
          )
        : kEmptyWidget;
  }
}
