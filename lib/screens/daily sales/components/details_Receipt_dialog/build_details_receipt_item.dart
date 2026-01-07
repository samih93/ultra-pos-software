import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../../../models/details_receipt.dart';
import '../../../main_screen.dart/main_controller.dart';

class BuildDetailsReceiptItem extends ConsumerWidget {
  const BuildDetailsReceiptItem(this.detailsReceipt, {super.key});
  final DetailsReceipt detailsReceipt;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: .start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if (detailsReceipt.isRefunded == true)
          const ColoredBox(
            color: Colors.red,
            child: DefaultTextView(
              fontSize: 12,
              text: "refunded",
              color: Colors.white,
            ),
          ),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: detailsReceipt.productName.toString(),
                      style: TextStyle(
                        color: context.brightnessColor,
                        fontSize: 13,
                        decoration: detailsReceipt.isRefunded == true
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    if (detailsReceipt.discount > 0)
                      TextSpan(
                        text: '  ${detailsReceipt.discount}%',
                        style: const TextStyle(
                          color: Pallete.redColor,
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: DefaultTextView(
                text: detailsReceipt.qty.toString(),
                fontSize: 12,
              ),
            ),
            if (ref.watch(mainControllerProvider).isSuperAdmin)
              Expanded(
                flex: 1,
                child: DefaultTextView(
                  text: detailsReceipt.costPrice
                      .validateDouble()
                      .formatDouble()
                      .toString(),
                  fontSize: 12,
                ),
              ),
            Expanded(
              flex: 1,
              child: DefaultTextView(
                text: detailsReceipt.sellingPrice
                    .validateDouble()
                    .formatDouble()
                    .toString(),
                fontSize: 12,
              ),
            ),
            Expanded(
              flex: 1,
              child: DefaultTextView(
                text:
                    (detailsReceipt.sellingPrice.validateDouble() *
                            detailsReceipt.qty.validateDouble())
                        .formatDouble()
                        .toString(),
                fontSize: 12,
              ),
            ),
          ],
        ),
        if (detailsReceipt.isRefunded == true &&
            detailsReceipt.refundReason != null &&
            detailsReceipt.refundReason!.isNotEmpty) ...[
          Row(
            children: [
              const DefaultTextView(
                text: "refund reason : ",
                color: Colors.red,
              ),
              kGap10,
              Expanded(
                child: DefaultTextView(text: "${detailsReceipt.refundReason}"),
              ),
            ],
          ),
          const Gap(2),
          Row(
            children: [
              const DefaultTextView(text: "refund date : ", color: Colors.red),
              kGap10,
              Expanded(
                child: DefaultTextView(
                  text: DateFormat("dd-MM-yyyy h:mm a").format(
                    DateTime.tryParse(detailsReceipt.refundDate.toString()) ??
                        DateTime.now(),
                  ),
                ),
              ),
            ],
          ),
        ],
        const Divider(color: Colors.grey, height: 1),
      ],
    );
  }
}
