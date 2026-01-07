import 'package:desktoppossystem/controller/receipt_controller.dart';
import 'package:desktoppossystem/screens/daily%20sales/components/daily_sales_receipt_item_mobile.dart';
import 'package:desktoppossystem/screens/daily%20sales/daily_financial_screen.dart';
import 'package:desktoppossystem/shared/default%20components/Loading_receipts.dart';
import 'package:desktoppossystem/shared/default%20components/quiver_circular_indicator.dart';
import 'package:desktoppossystem/shared/services/scroll_behavior_service.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DailySalesReceiptListMobile extends ConsumerStatefulWidget {
  const DailySalesReceiptListMobile({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DailySalesReceiptListMobileState();
}

class _DailySalesReceiptListMobileState
    extends ConsumerState<DailySalesReceiptListMobile> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100) {
        final filterId = ref.read(salesSelectedUser)?.id;
        if (ref.read(receiptControllerProvider).isHasMoreReceiptsData) {
          ref
              .read(receiptControllerProvider)
              .fetchPaginatedReceiptsByDay(filterUserId: filterId);
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var receiptController = ref.watch(receiptControllerProvider);
    return receiptController.getReceiptByDayRequestState ==
                RequestState.loading &&
            receiptController.currentOffset == 0
        ? const LoadingReceipts()
        : ScrollConfiguration(
            behavior: MyCustomScrollBehavior(),
            child: ListView.builder(
              controller: _scrollController,
              itemCount:
                  receiptController.receiptsListByDay.length +
                  (receiptController.isHasMoreReceiptsData ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == receiptController.receiptsListByDay.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CoreCircularIndicator(),
                    ),
                  );
                }

                final receipt = receiptController.receiptsListByDay[index];
                return DailySalesReceiptItemMobile(
                  receipt,
                  key: ValueKey(receipt.id.toString()),
                );
              },
            ),
          );
  }
}
