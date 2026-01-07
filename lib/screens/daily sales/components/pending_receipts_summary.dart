import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PendingReceiptsSummary extends ConsumerWidget {
  const PendingReceiptsSummary({
    required this.totalCount,
    required this.totalPendingAmount,
    super.key,
  });
  final int totalCount;
  final double totalPendingAmount;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            width: 120,
            child: DeliverySummaryCard(
              icon: Icons.pending_actions,
              title: '${S.of(context).pending} ($totalCount)',
              value: '${totalPendingAmount.formatDouble()}',
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
        border: Border.all(color: color),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 25, color: color),
          Expanded(
            child: Column(
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
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
