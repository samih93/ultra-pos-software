import 'package:desktoppossystem/controller/receipt_controller.dart';
import 'package:desktoppossystem/screens/shift_screen/components/shift_header_receipt.dart';
import 'package:desktoppossystem/screens/shift_screen/components/shift_receipt_item.dart';
import 'package:desktoppossystem/screens/shift_screen/shift_screen.dart';
import 'package:desktoppossystem/shared/default%20components/Loading_receipts.dart';
import 'package:desktoppossystem/shared/default%20components/quiver_circular_indicator.dart';
import 'package:desktoppossystem/shared/services/scroll_behavior_service.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShiftReceiptList extends ConsumerStatefulWidget {
  const ShiftReceiptList({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ShiftReceiptListState();
}

class _ShiftReceiptListState extends ConsumerState<ShiftReceiptList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100) {
        // Near the bottom (adjust offset if needed)
        final filterId = ref.read(shiftSelectedUserProvider)?.id;
        if (ref.read(receiptControllerProvider).isHasMoreReceiptsData) {
          ref
              .read(receiptControllerProvider)
              .fetchPaginatedReceiptsByShift(filterUserId: filterId);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var receiptController = ref.watch(receiptControllerProvider);

    return receiptController.getReceiptByShiftRequestState ==
                RequestState.loading &&
            receiptController.currentOffset == 0
        ? const LoadingReceipts(
            forShift: true,
          )
        : Column(
            children: [
              const ShiftHeaderReceipt(),
              Divider(
                color: context.primaryColor,
              ),
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
                                ShiftReceiptItem(
                                  receiptController.receiptsListByShift[index],
                                  key: ValueKey(receiptController
                                      .receiptsListByShift[index].id),
                                ),
                                if (index !=
                                    receiptController
                                            .receiptsListByShift.length -
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
                          childCount:
                              receiptController.receiptsListByShift.length,
                        ),
                      ),
                    ],
                  ),
                ),
              )),
              if (receiptController.getReceiptByShiftRequestState ==
                  RequestState.loading)
                const Center(
                  child: CoreCircularIndicator(),
                ),
            ],
          );
  }
}
