import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/screens/notifications_screen/notification_controller.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExpiryDateSelectionDialog extends ConsumerWidget {
  ExpiryDateSelectionDialog({super.key});
  final List<int> nbOfTablesList = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var nbOfMonths = ref.watch(nbOfMonthsProvider);
    return AlertDialog(
        title: const Center(
          child: DefaultTextView(
            text: 'Select Number of Months',
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          height: context.height * 0.5,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                kGap5,
                ...nbOfTablesList.map((e) {
                  return ListTile(
                      trailing: ref.watch(nbOfMonthsProvider) ==
                              nbOfTablesList[nbOfTablesList.indexOf(e)]
                          ? Icon(
                              Icons.check_circle,
                              color: context.primaryColor,
                            )
                          : kEmptyWidget,
                      title: DefaultTextView(text: e.toString()),
                      onTap: () async {
                        ref.read(nbOfMonthsProvider.notifier).state = e;

                        if (ref
                            .read(mainControllerProvider)
                            .isWorkWithIngredients) {
                          //! restaurant
                          ref.refresh(futureRestaurantExpiredStockProvider);
                          ref.refresh(restaurantNotificationCountProvider);
                        } else {
                          //! market
                          ref.refresh(futureMarketExpiredStockProvider);
                          ref.refresh(marketNotificationCountProvider);
                        }

                        context.pop();
                      });
                }),
              ],
            ),
          ),
        ));
  }
}
