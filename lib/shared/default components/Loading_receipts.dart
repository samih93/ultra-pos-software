import 'package:desktoppossystem/models/receipt_model.dart';
import 'package:desktoppossystem/screens/daily%20sales/components/daily_sales_header_receipt.dart';
import 'package:desktoppossystem/screens/daily%20sales/components/daily_sales_receipt_item.dart';
import 'package:desktoppossystem/screens/shift_screen/components/shift_header_receipt.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

class LoadingReceipts extends ConsumerWidget {
  const LoadingReceipts({this.forShift, super.key});
  final bool? forShift;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        forShift != null
            ? const ShiftHeaderReceipt()
            : const DailySalesHeaderReceipt(),
        Divider(
          color: context.primaryColor,
        ),
        Expanded(
          child: RepaintBoundary(
            child: Skeletonizer(
                effect:
                    const PulseEffect(duration: Duration(milliseconds: 300)),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: 12,
                  itemBuilder: (context, index) {
                    return DailySalesReceiptItem(
                      ReceiptModel.fakeReceipt,
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const Divider();
                  },
                )),
          ),
        ),
      ],
    );
  }
}
