import 'package:desktoppossystem/controller/receipt_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/daily%20sales/daily_financial_screen.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DeliverySummarySection extends ConsumerWidget {
  const DeliverySummarySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showAllReceipts = ref.watch(selectedFinancialFilterIndex) == 0;
    final receiptController = ref.watch(receiptControllerProvider);
    final paidReceipts = receiptController.receiptsListByDay
        .where((e) => e.isPaid == true)
        .toList();
    final pendingReceipts = receiptController.receiptsListByDay
        .where((e) => e.isPaid != true)
        .toList();
    final totalPaid = paidReceipts.fold<double>(
      0,
      (sum, e) => sum + (e.foreignReceiptPrice ?? 0),
    );
    final totalPending = pendingReceipts.fold<double>(
      0,
      (sum, e) => sum + (e.foreignReceiptPrice ?? 0),
    );
    return showAllReceipts
        ? kEmptyWidget
        : SizedBox(
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 120,
                  child: DeliverySummaryCard(
                    icon: Icons.paid_outlined,
                    title: '${S.of(context).paid} (${paidReceipts.length})',
                    value: '${totalPaid.formatDouble()}',
                    color: Pallete.greenColor,
                  ),
                ),
                kGap10,
                SizedBox(
                  width: 120,
                  child: DeliverySummaryCard(
                    icon: Icons.pending_actions,
                    title:
                        '${S.of(context).pending} (${pendingReceipts.length})',
                    value: '${totalPending.formatDouble()}',
                    color: Pallete.redColor,
                  ),
                ),
              ],
            ),
          );
  }
}

class DeliverySummaryCard extends ConsumerWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const DeliverySummaryCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: kPaddH5,
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.rectangle,
          borderRadius: kRadius8,
          border: Border.all(
            color: color,
          )),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 25, color: color),
          Expanded(
            child: Column(
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                kGap3,
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
