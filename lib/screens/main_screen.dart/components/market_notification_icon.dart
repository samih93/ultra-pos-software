import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_screen.dart';
import 'package:desktoppossystem/screens/notifications_screen/market/market_notification_screen.dart';
import 'package:desktoppossystem/screens/notifications_screen/notification_controller.dart';
import 'package:desktoppossystem/shared/constances/screens_title_constant.dart';
import 'package:desktoppossystem/shared/default%20components/quiver_circular_indicator.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MarketNotificationIcon extends ConsumerWidget {
  const MarketNotificationIcon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(mainControllerProvider).isWorkWithIngredients &&
        ref.watch(currentMainScreenProvider) == ScreenName.SaleScreen &&
        !context.isMobile) {
      return ref
          .watch(marketNotificationCountProvider)
          .when(
            data: (data) => data == 0
                ? kEmptyWidget
                : Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          refreshNotifications();

                          context.to(const MarketLowStockNotificationsScreen());
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
            loading: () => const CoreCircularIndicator(),
          );
    }

    return kEmptyWidget;
  }
}
