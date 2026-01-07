import 'package:desktoppossystem/controller/financial_transaction_controller.dart';
import 'package:desktoppossystem/screens/daily%20sales/components/financial_transaction_item_mobile.dart';
import 'package:desktoppossystem/screens/daily%20sales/daily_financial_screen.dart';
import 'package:desktoppossystem/screens/error_section.dart';
import 'package:desktoppossystem/shared/default%20components/Loading_receipts.dart';
import 'package:desktoppossystem/shared/services/scroll_behavior_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class FinancialTransactionsListSectionMobile extends ConsumerWidget {
  const FinancialTransactionsListSectionMobile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSelectedDate = ref.watch(salesSelectedDateProvider);

    final futureTransactions = ref.watch(
      futureDailyTransactionProvider(currentSelectedDate),
    );

    return futureTransactions.when(
      data: (data) {
        return data.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      size: 60.spMax,
                      color: Colors.grey.withValues(alpha: 0.5),
                    ),
                    SizedBox(height: 16.h),
                    const Text(
                      "No Transactions yet",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            : ScrollConfiguration(
                behavior: MyCustomScrollBehavior(),
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return FinancialTransactionItemMobile(
                      data[index],
                      key: ValueKey(data[index].id),
                    );
                  },
                ),
              );
      },
      error: (error, stackTrace) => ErrorSection(
        retry: () =>
            ref.refresh(futureDailyTransactionProvider(currentSelectedDate)),
      ),
      loading: () => const LoadingReceipts(),
    );
  }
}
