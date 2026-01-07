import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/daily%20sales/components/balance_card.dart';
import 'package:desktoppossystem/screens/error_section.dart';
import 'package:desktoppossystem/screens/stock_screen/stock_controller.dart';
import 'package:desktoppossystem/shared/default%20components/quiver_circular_indicator.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductStatsWidget extends ConsumerWidget {
  const ProductStatsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var futurestats = ref.watch(futureProductStatsProvider);
    return futurestats.when(
      data: (data) => Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            spacing: 5,
            children: [
              BalanceCard(
                isCount: true,
                height: 40,
                primary: data.totalCount!.toDouble(),
                title: S.of(context).products,
                color: context.primaryColor,
              ),
              BalanceCard(
                height: 40,
                primary: data.totalCost.formatDouble(),
                title: S.of(context).totalCost,
                color: Pallete.orangeColor,
              ),
              BalanceCard(
                height: 40,
                primary: data.totalPrice.formatDouble(),
                title: S.of(context).totalPrice,
                color: Pallete.greenColor,
              ),
            ],
          ),
        ],
      ),
      error: (error, stackTrace) => ErrorSection(
        retry: () {
          ref.refresh(futureProductStatsProvider);
        },
      ),
      loading: () => const SizedBox(width: 100, child: CoreCircularIndicator()),
    );
  }
}
