import 'package:desktoppossystem/controller/financial_transaction_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/daily%20sales/components/financial_transaction_item.dart';
import 'package:desktoppossystem/screens/daily%20sales/daily_financial_screen.dart';
import 'package:desktoppossystem/screens/error_section.dart';
import 'package:desktoppossystem/shared/constances/app_constances.dart';
import 'package:desktoppossystem/shared/default%20components/Loading_receipts.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/services/scroll_behavior_service.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FinancialTransactionsListSection extends ConsumerWidget {
  const FinancialTransactionsListSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSelectedDate = ref.watch(salesSelectedDateProvider);

    final futureTransactions =
        ref.watch(futureDailyTransactionProvider(currentSelectedDate));
    return futureTransactions.when(
        data: (data) {
          return data.isEmpty
              ? const Center(
                  child: Text(
                    "No Transactions yet",
                    style: TextStyle(color: Colors.grey, fontSize: 25),
                  ),
                )
              : Column(
                  children: [
                    kGap5,
                    Row(children: [
                      Expanded(
                          child: DefaultTextView(
                        text: S.of(context).transaction.capitalizeFirstLetter(),
                        fontWeight: FontWeight.bold,
                      )),
                      Expanded(
                          child: Center(
                              child: DefaultTextView(
                        text: S.of(context).date.capitalizeFirstLetter(),
                        fontWeight: FontWeight.bold,
                      ))),
                      Expanded(
                          child: Center(
                        child: DefaultTextView(
                          fontWeight: FontWeight.bold,
                          text: AppConstance.primaryCurrency
                              .currencyLocalization(),
                        ),
                      )),
                      Expanded(
                          child: Center(
                        child: DefaultTextView(
                            fontWeight: FontWeight.bold,
                            text: AppConstance.secondaryCurrency
                                .currencyLocalization()),
                      )),
                      Expanded(
                          flex: 2,
                          child: Center(
                            child: DefaultTextView(
                              fontWeight: FontWeight.bold,
                              maxlines: 3,
                              text: S.of(context).note,
                            ),
                          )),
                      DefaultTextView(
                          fontWeight: FontWeight.bold,
                          text: S.of(context).delete),
                    ]),
                    Divider(
                      color: context.primaryColor,
                    ),
                    Expanded(
                        child: ScrollConfiguration(
                      behavior: MyCustomScrollBehavior(),
                      child: CustomScrollView(
                        cacheExtent: 45,
                        slivers: [
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                return Column(
                                  children: [
                                    kGap5,
                                    FinancialTransactionItem(
                                      data[index],
                                      key: ValueKey(data[index].id),
                                    ),
                                    if (index != data.length - 1) ...[
                                      kGap5,
                                      const Divider(
                                        height: 0.7,
                                        color: Pallete.greyColor,
                                      ), // Add the divider except for the last item
                                    ],
                                  ],
                                );
                              },
                              childCount: data.length,
                            ),
                          ),
                        ],
                      ),
                    )),
                  ],
                );
        },
        error: (error, stackTrace) => ErrorSection(
              retry: () => ref
                  .refresh(futureDailyTransactionProvider(currentSelectedDate)),
            ),
        loading: () => const LoadingReceipts());
  }
}
