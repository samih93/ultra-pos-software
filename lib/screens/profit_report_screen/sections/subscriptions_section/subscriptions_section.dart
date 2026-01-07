import 'package:desktoppossystem/screens/profit_report_screen/sections/subscriptions_section/components/subscriptions_header.dart';
import 'package:desktoppossystem/screens/profit_report_screen/sections/subscriptions_section/components/subscription_items.dart';
import 'package:desktoppossystem/screens/profit_report_screen/sections/subscriptions_section/components/subscription_card_mobile.dart';
import 'package:desktoppossystem/screens/profit_report_screen/sections/subscriptions_section/components/total_subscription_amount.dart';
import 'package:desktoppossystem/screens/profit_report_screen/profit_controller.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SubscriptionsSection extends ConsumerWidget {
  SubscriptionsSection({super.key});
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var profitController = ref.watch(profitControllerProvider);

    if (profitController.subscriptionStatsList.isEmpty) {
      return const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          DefaultTextView(
            text: "No subscription payments yet",
            color: Colors.grey,
            fontSize: 25,
          ),
        ],
      );
    }

    return Padding(
      padding: kPadd10,
      child: Column(
        children: [
          // Mobile view
          if (context.isMobile) ...[
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: profitController.subscriptionStatsList.length,
                itemBuilder: (context, index) {
                  return SubscriptionCardMobile(
                    subscriptionModel:
                        profitController.subscriptionStatsList[index],
                  );
                },
              ),
            ),
          ]
          // Desktop view
          else ...[
            const SubscriptionsHeader(),
            Divider(height: 1, color: context.primaryColor),
            Expanded(
              child: Scrollbar(
                controller: _scrollController,
                trackVisibility: true,
                thumbVisibility: true,
                thickness: 10,
                child: CustomScrollView(
                  controller: _scrollController,
                  cacheExtent: 30,
                  slivers: [
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final backgroundColor = index.isEven
                              ? ref.watch(isDarkModeProvider)
                                    ? context.cardColor
                                    : Pallete.whiteColor
                              : context.selectedPrimaryColor.withValues(
                                  alpha: 0.5,
                                );
                          return SubscriptionItems(
                            profitController.subscriptionStatsList[index],
                            backgroundColor: backgroundColor,
                            key: ValueKey(
                              profitController
                                  .subscriptionStatsList[index]
                                  .customerName,
                            ),
                          );
                        },
                        childCount:
                            profitController.subscriptionStatsList.length,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          TotalSubscriptionAmount(
            totalSubscriptions: profitController.totalSubscriptionIncome,
          ),
        ],
      ),
    );
  }
}
