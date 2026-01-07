import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_screen.dart';
import 'package:desktoppossystem/screens/notifications_screen/notification_controller.dart';
import 'package:desktoppossystem/screens/notifications_screen/restaurant/restaurant_notification_screen.dart';
import 'package:desktoppossystem/shared/constances/screens_title_constant.dart';
import 'package:desktoppossystem/shared/default%20components/default_prodgress_indicator.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RestaurantNotificationIcon extends ConsumerWidget {
  const RestaurantNotificationIcon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(currentMainScreenProvider) == ScreenName.SaleScreen &&
        ref.watch(mainControllerProvider).isWorkWithIngredients &&
        !context.isMobile) {
      return ref
          .watch(restaurantNotificationCountProvider)
          .when(
            data: (data) => data == 0
                ? kEmptyWidget
                : Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          ref.refresh(futureRestaurantLowStockProvider);
                          ref.refresh(futureRestaurantExpiredStockProvider);
                          context.to(const RestaurantNotificationScreen());
                        },
                        icon: Badge.count(
                          largeSize: 14,
                          count: data,
                          child: const Icon(
                            Icons.notifications_active_outlined,
                          ),
                        ),
                      ),
                      kGap10,
                    ],
                  ),
            error: (error, stackTrace) => kEmptyWidget,
            loading: () =>
                const SizedBox(width: 80, child: DefaultProgressIndicator()),
          );
    }

    return kEmptyWidget;
  }
}
