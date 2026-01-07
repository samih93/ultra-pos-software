import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/restaurant_stock/subscreens/stock_transactions/components/stock_transaction_header.dart';
import 'package:desktoppossystem/screens/restaurant_stock/subscreens/stock_transactions/components/stock_transaction_item.dart';
import 'package:desktoppossystem/screens/restaurant_stock/subscreens/stock_transactions/stock_transactions_state.dart';
import 'package:desktoppossystem/shared/constances/app_constances.dart';
import 'package:desktoppossystem/shared/default%20components/default_price_text.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StockInTab extends ConsumerWidget {
  const StockInTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stockInList = ref.watch(stockInProvider);
    final totalCost = stockInList.fold(
      0.0,
      (double sum, item) => sum + (item.transactionQty * item.pricePerUnit),
    );
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Row(
            children: [
              DefaultTextView(
                fontSize: 18,
                text: "${S.of(context).totalCost}: ",
                fontWeight: FontWeight.bold,
              ),
              AppPriceText(
                text: "${totalCost.formatDouble()}",
                fontSize: 18,
                color: Pallete.redColor,
                fontWeight: FontWeight.bold,
                unit: AppConstance.primaryCurrency.currencyLocalization(),
              ),
            ],
          ),
        ),
        const StockTransactionHeader(),
        Expanded(
          child: Column(
            children: [
              Divider(color: context.primaryColor, height: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: stockInList.length, // Ensure itemCount is set

                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        kGap5,
                        StockTransactionItem(
                          model: stockInList[index],
                          key: ValueKey(stockInList[index].id),
                        ),
                        if (index != stockInList.length - 1) ...[
                          kGap5,
                          const Divider(
                            height: 0.7,
                            color: Pallete.greyColor,
                          ), // Add the divider except for the last item
                        ],
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
