import 'package:desktoppossystem/screens/dashboard/components/cards/market_warning_stock_card.dart';
import 'package:desktoppossystem/screens/dashboard/components/cards/restaurant_warning_stock_card.dart';
import 'package:desktoppossystem/screens/dashboard/components/cards/total_cutomers_count_card.dart';
import 'package:desktoppossystem/screens/dashboard/components/cards/total_product_count_card.dart';
import 'package:desktoppossystem/screens/dashboard/components/cards/total_receipts_card.dart';
import 'package:desktoppossystem/screens/dashboard/components/cards/total_users_count.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DashboardCardsSection extends ConsumerWidget {
  const DashboardCardsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = context.isMobile;

    // Mobile: Horizontal scrollable cards
    if (isMobile) {
      return SizedBox(
        height: 0.06.sh, // Fixed height for cards
        width: context.width,
        child: Row(
          children: [
            Expanded(
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildMobileCard(const TotalProductCountCard()),
                  defaultGap,
                  _buildMobileCard(const TotalReceiptsCard()),
                  defaultGap,
                  _buildMobileCard(const TotalCutomersCountCard()),
                  defaultGap,
                  _buildMobileCard(const TotalUsersCount()),
                  defaultGap,
                  _buildMobileCard(
                    ref.watch(mainControllerProvider).isWorkWithIngredients
                        ? const RestaurantWarningStockCard()
                        : const MarketWarningStockCard(),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Desktop/Tablet: Row layout
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      spacing: 5,
      children: [
        const Expanded(child: TotalProductCountCard()),
        const Expanded(child: TotalReceiptsCard()),
        const Expanded(child: TotalCutomersCountCard()),
        const Expanded(child: TotalUsersCount()),
        Expanded(
          child: ref.watch(mainControllerProvider).isWorkWithIngredients
              ? const RestaurantWarningStockCard()
              : const MarketWarningStockCard(),
        ),
      ],
    );
  }

  // Helper to wrap cards with fixed width for mobile scrolling
  Widget _buildMobileCard(Widget card) {
    return SizedBox(
      width: 0.24.sw, // Increased width for better fit
      child: card,
    );
  }
}
