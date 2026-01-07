import 'package:desktoppossystem/controller/receipt_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/daily%20sales/components/balance_card.dart';
import 'package:desktoppossystem/screens/error_section.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/services/scroll_behavior_service.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

class BalanceSection extends ConsumerWidget {
  const BalanceSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var futureTotals = ref.watch(futureReceiptTotalsProvider);
    return futureTotals.when(
      data: (totals) {
        // deposit - withdraw - purchases
        final totalSecondaryToPrimary =
            (totals.totalSecondaryBalance /
                    ref.read(saleControllerProvider).dolarRate)
                .formatDouble();
        return ScrollConfiguration(
          behavior: MyCustomScrollBehavior(),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              spacing: 5,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                BalanceCard(
                  title: S.of(context).totalAmount,
                  color: Pallete.blueColor,
                  primary: totals.totalPrimaryBalance + totalSecondaryToPrimary,
                  // secondary: totals.totalSecondaryBalance,
                ),
                BalanceCard(
                  title: "💰 ${S.of(context).sales}",
                  color: Pallete.greenColor,
                  primary: totals.salesDolar,
                  secondary: totals.salesLebanon,
                ),
                BalanceCard(
                  title: "💵 ${S.of(context).deposit}",
                  color: Pallete.greenColor,
                  primary: totals.totalDepositDolar,
                  secondary: totals.totalDepositLebanon,
                ),
                if (ref.read(mainControllerProvider).subscriptionActivated)
                  BalanceCard(
                    title: "💵 ${S.of(context).subscriptions}",
                    color: Pallete.greenColor,
                    primary: totals.totalSubscriptions,
                  ),
                Tooltip(
                  message: S.of(context).collectedPendingAmountTooltip,
                  child: BalanceCard(
                    title: "💵 ${S.of(context).collectedPendingReceipts}",
                    color: Pallete.greenColor,
                    primary: totals.totalCollectedPending,
                  ),
                ),
                BalanceCard(
                  title: "📤 ${S.of(context).withdraw.capitalizeFirstLetter()}",
                  color: Pallete.purpleColor,
                  primary: totals.totalWithdrawDolar,
                  secondary: totals.totalWithdrawLebanon,
                ),
                const DefaultTextView(text: "-->", fontWeight: FontWeight.bold),
                BalanceCard(
                  title: "💸 ${S.of(context).fromCash}",
                  color: Pallete.redColor,
                  primary: totals.totalWithdrawDolarFromCash,
                  secondary: totals.totalWithdrawLebanonFromCash,
                ),
                BalanceCard(
                  title: "🛒${S.of(context).purchases}",
                  color: Pallete.redColor,
                  primary: totals.totalPurchasesPrimary,
                ),
                BalanceCard(
                  title: "↩️ ${S.of(context).refundButton}",
                  color: Pallete.redColor,
                  primary: totals.totalRefunds,
                ),
                BalanceCard(
                  title: "⏳ ${S.of(context).pending.capitalizeFirstLetter()}",
                  color: Pallete.orangeColor,
                  primary: totals.totalPendingAmount,
                ),
              ],
            ),
          ),
        );
      },
      error: (error, stackTrace) =>
          ErrorSection(retry: () => ref.refresh(futureReceiptTotalsProvider)),
      loading: () {
        return Skeletonizer(
          child: SingleChildScrollView(
            child: Row(
              spacing: 5,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                BalanceCard(
                  title: S.of(context).totalAmount,
                  color: Pallete.blueColor,
                  primary: 0,
                  secondary: 0,
                ),
                BalanceCard(
                  title: S.of(context).sales,
                  color: Pallete.greenColor,
                  primary: 0,
                  secondary: 0,
                ),
                BalanceCard(
                  title: S.of(context).deposit,
                  color: Pallete.greenColor,
                  primary: 0,
                  secondary: 0,
                ),
                BalanceCard(
                  title: S.of(context).collectedPendingReceipts,
                  color: Pallete.greenColor,
                  primary: 0,
                ),
                BalanceCard(
                  title: S.of(context).withdraw.capitalizeFirstLetter(),
                  color: Pallete.purpleColor,
                  primary: 0,
                  secondary: 0,
                ),
                const DefaultTextView(text: "-->", fontWeight: FontWeight.bold),
                if (context.isWindows) ...[
                  const BalanceCard(
                    title: "from cash",
                    color: Pallete.redColor,
                    primary: 0,
                    secondary: 0,
                  ),
                  BalanceCard(
                    title: S.of(context).pending.capitalizeFirstLetter(),
                    color: Pallete.orangeColor,
                    primary: 0,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
