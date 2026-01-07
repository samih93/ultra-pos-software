import 'package:desktoppossystem/controller/restaurant_stock_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RestaurantStockFilterDialog extends ConsumerWidget {
  const RestaurantStockFilterDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: DefaultTextView(
        textAlign: TextAlign.center,
        text: S.of(context).filter,
        fontSize: 16,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...RestaurantStockFilter.values.map((e) {
            return ListTile(
              trailing:
                  e == ref.watch(restaurantStockControllerProvider).stockFilter
                  ? Icon(Icons.check_circle, color: context.primaryColor)
                  : kEmptyWidget,
              leading: e.name.restaurantFilterICon(),
              title: DefaultTextView(
                text: e.name.stockFilterLocalization(context),
              ),
              onTap: () {
                ref
                    .read(restaurantStockControllerProvider)
                    .onChangeStockFilter(e);
                context.pop();
              },
            );
          }),
        ],
      ),
    );
  }
}
