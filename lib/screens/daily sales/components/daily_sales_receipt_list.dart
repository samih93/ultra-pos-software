import 'package:desktoppossystem/controller/receipt_controller.dart';
import 'package:desktoppossystem/screens/daily%20sales/components/daily_sales_header_receipt.dart';
import 'package:desktoppossystem/screens/daily%20sales/components/daily_sales_receipt_item.dart';
import 'package:desktoppossystem/screens/daily%20sales/daily_financial_screen.dart';
import 'package:desktoppossystem/shared/default%20components/Loading_receipts.dart';
import 'package:desktoppossystem/shared/default%20components/quiver_circular_indicator.dart';
import 'package:desktoppossystem/shared/services/scroll_behavior_service.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DailySalesReceiptList extends ConsumerStatefulWidget {
  const DailySalesReceiptList({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DailySalesReceiptListState();
}

class _DailySalesReceiptListState extends ConsumerState<DailySalesReceiptList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100) {
        // Near the bottom (adjust offset if needed)
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
  Widget build(BuildContext context) {
    var receiptController = ref.watch(receiptControllerProvider);
    return receiptController.getReceiptByDayRequestState ==
                RequestState.loading &&
            receiptController.currentOffset == 0
        ? const LoadingReceipts()
        : Column(
            children: [
              const DailySalesHeaderReceipt(),
              Divider(
                color: context.primaryColor,
              ),
              receiptController.receiptsListByDay.isEmpty
                  ? const Center(
                      child: Text(
                        "No Receipts yet",
                        style: TextStyle(color: Colors.grey, fontSize: 25),
                      ),
                    )
                  : Expanded(
                      child: Column(
                        children: [
                          Expanded(
                              child: ScrollConfiguration(
                            behavior: MyCustomScrollBehavior(),
                            child: Scrollbar(
                              controller: _scrollController,
                              trackVisibility: true,
                              thumbVisibility: true,
                              thickness: 10,
                              child: CustomScrollView(
                                controller: _scrollController,
                                cacheExtent: 45,
                                slivers: [
                                  SliverList(
                                    delegate: SliverChildBuilderDelegate(
                                      (context, index) {
                                        return Column(
                                          children: [
                                            kGap5,
                                            DailySalesReceiptItem(
                                              receiptController
                                                  .receiptsListByDay[index],
                                              key: ValueKey(receiptController
                                                  .receiptsListByDay[index].id),
                                            ),
                                            if (index !=
                                                receiptController
                                                        .receiptsListByDay
                                                        .length -
                                                    1) ...[
                                              kGap5,
                                              const Divider(
                                                height: 0.7,
                                                color: Pallete.greyColor,
                                              ), // Add the divider except for the last item
                                            ],
                                          ],
                                        );
                                      },
                                      childCount: receiptController
                                          .receiptsListByDay.length,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),
                          if (receiptController.getReceiptByDayRequestState ==
                              RequestState.loading)
                            const Center(
                              child: CoreCircularIndicator(),
                            ),
                        ],
                      ),
                    )
            ],
          );
  }
}
