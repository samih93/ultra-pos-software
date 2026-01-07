import 'package:desktoppossystem/controller/restaurant_stock_controller.dart';
import 'package:desktoppossystem/screens/error_screen.dart';
import 'package:desktoppossystem/shared/constances/app_constances.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/default%20components/quiver_circular_indicator.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RestaurantStockBalance extends ConsumerWidget {
  const RestaurantStockBalance({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final futureCost = ref.watch(futureRestaurantInventoryCost);
    return futureCost.when(
      data: (data) => DefaultTextView(
        text:
            "(${data.formatDouble()} ${AppConstance.primaryCurrency.currencyLocalization()})",
        fontWeight: FontWeight.w500,
        color: Pallete.redColor,
        fontSize: 18,
      ),
      error: (Object error, StackTrace stackTrace) {
        return ErrorScreen(
          retry: () {
            ref.refresh(futureRestaurantInventoryCost);
          },
        );
      },
      loading: () {
        return const Center(child: CoreCircularIndicator());
      },
    );
  }
}
