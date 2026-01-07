import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/error_section.dart';
import 'package:desktoppossystem/screens/notifications_screen/market/market_notification_screen.dart';
import 'package:desktoppossystem/screens/notifications_screen/notification_controller.dart';
import 'package:desktoppossystem/shared/default%20components/dashboard_card.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

class MarketWarningStockCard extends ConsumerWidget {
  const MarketWarningStockCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(marketNotificationCountProvider)
        .when(
          data: (data) => InkWell(
            onTap: context.isMobile
                ? null
                : () {
                    ref.refresh(futureMarketLowStockProvider);
                    ref.refresh(futureMarketExpiredStockProvider);
                    ref.refresh(futureMarketOutOfStockProvider);
                    context.to(const MarketLowStockNotificationsScreen());
                  },
            child: DashboardCard(
              value: data.toString(),
              color: Pallete.orangeColor,
              icon: Icons.warning_amber_rounded,
              title: S.of(context).stockWarning,
            ),
          ),
          error: (error, stackTrace) => ErrorSection(
            retry: () {
              ref.refresh(futureMarketLowStockProvider);
              ref.refresh(futureMarketExpiredStockProvider);
              ref.refresh(futureMarketOutOfStockProvider);
            },
          ),
          loading: () => Skeletonizer(
            enabled: true,
            effect: const PulseEffect(duration: Duration(milliseconds: 300)),
            child: DashboardCard(
              value: "0",
              color: Pallete.orangeColor,
              icon: Icons.warning_amber_rounded,
              title: S.of(context).stockWarning,
            ),
          ),
        );
  }
}
