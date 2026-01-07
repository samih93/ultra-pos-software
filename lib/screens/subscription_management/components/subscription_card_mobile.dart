import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/subscription_model.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SubscriptionCardMobile extends StatelessWidget {
  final SubscriptionModel subscription;
  final VoidCallback? onMakePayment;
  final VoidCallback? onEditPaymentDate;
  final VoidCallback? onEditMonthlyAmount;
  final VoidCallback? onCancelSubscription;
  final VoidCallback? onResumeSubscription;

  const SubscriptionCardMobile({
    super.key,
    required this.subscription,
    this.onMakePayment,
    this.onEditPaymentDate,
    this.onEditMonthlyAmount,
    this.onCancelSubscription,
    this.onResumeSubscription,
  });

  Color _getStatusColor() {
    if (subscription.isOverdue) return Pallete.redColor;
    switch (subscription.status) {
      case SubscriptionStatus.active:
        return Pallete.greenColor;
      case SubscriptionStatus.overdue:
        return Pallete.orangeColor;
      case SubscriptionStatus.canceled:
        return Pallete.greyColor;
    }
  }

  String _getStatusText(BuildContext context) {
    if (subscription.isOverdue) return S.of(context).overdue;
    switch (subscription.status) {
      case SubscriptionStatus.active:
        return S.of(context).active;
      case SubscriptionStatus.overdue:
        return S.of(context).overdue;
      case SubscriptionStatus.canceled:
        return S.of(context).cancelled;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();
    return Card(
      elevation: 3,
      color: Pallete.whiteColor,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: kRadius8,
        side: BorderSide(
          color: subscription.isOverdue
              ? Pallete.redColor
              : statusColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Padding(
        padding: kPadd15,
        child: Column(
          crossAxisAlignment: .start,
          children: [
            // Header with customer name and status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      DefaultTextView(
                        text: subscription.customerName ?? 'Unknown Customer',
                        fontSize: 18,
                        color: Pallete.blackColor,
                        fontWeight: FontWeight.bold,
                      ),
                      if (subscription.customerPhone != null &&
                          subscription.customerPhone!.isNotEmpty) ...[
                        kGap5,
                        Row(
                          children: [
                            const Icon(
                              FontAwesomeIcons.phone,
                              size: 12,
                              color: Pallete.blackColor,
                            ),
                            kGap5,
                            DefaultTextView(
                              text: subscription.customerPhone!,
                              fontSize: 13,
                              color: Pallete.blackColor,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                kGap10,
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.15),
                    borderRadius: kRadius8,
                    border: Border.all(color: statusColor, width: 1.5),
                  ),
                  child: DefaultTextView(
                    text: _getStatusText(context),
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),

            kGap15,

            // Monthly amount and next payment in column for better mobile layout
            Container(
              padding: kPadd10,
              decoration: BoxDecoration(
                color: Pallete.blackColor.withValues(alpha: 0.1),
                borderRadius: kRadius8,
              ),
              child: Column(
                children: [
                  // Monthly Amount
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DefaultTextView(
                        text: S.of(context).monthlyAmount,
                        fontSize: 13,
                        color: Pallete.blackColor,
                      ),
                      Row(
                        children: [
                          DefaultTextView(
                            text: subscription.monthlyAmount
                                .formatDouble()
                                .toString(),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Pallete.greenColor,
                          ),
                          if (onEditMonthlyAmount != null) ...[
                            kGap5,
                            InkWell(
                              onTap: onEditMonthlyAmount,
                              child: const Icon(
                                Icons.edit,
                                size: 16,
                                color: Pallete.blueColor,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                  kGap10,
                  const Divider(height: 1),
                  kGap10,
                  // Next Payment
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      DefaultTextView(
                        text: S.of(context).nextPayment,
                        fontSize: 13,
                        color: Pallete.blackColor,
                      ),
                      Row(
                        children: [
                          DefaultTextView(
                            text: subscription.nextPaymentDate.split(' ').first,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: subscription.isOverdue
                                ? Pallete.redColor
                                : Pallete.blueColor,
                          ),
                          if (onEditPaymentDate != null) ...[
                            kGap5,
                            InkWell(
                              onTap: onEditPaymentDate,
                              child: const Icon(
                                Icons.edit,
                                size: 16,
                                color: Pallete.blueColor,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Show months overdue if overdue
            if (subscription.isOverdue) ...[
              kGap10,
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Pallete.redColor.withValues(alpha: 0.1),
                  borderRadius: kRadius8,
                  border: Border.all(color: Pallete.redColor, width: 2),
                ),
                child: Row(
                  children: [
                    const Icon(
                      FontAwesomeIcons.triangleExclamation,
                      color: Pallete.redColor,
                      size: 18,
                    ),
                    kGap10,
                    Expanded(
                      child: DefaultTextView(
                        text: subscription.overdueDisplayText,
                        color: Pallete.redColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            kGap15,

            // Action buttons - full width on mobile
            Row(
              children: [
                // Cancel/Resume button
                if (subscription.status == SubscriptionStatus.active &&
                    onCancelSubscription != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onCancelSubscription!,
                      icon: const Icon(FontAwesomeIcons.ban, size: 14),
                      label: Text(S.of(context).cancel),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Pallete.redColor,
                        side: const BorderSide(color: Pallete.redColor),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                if (subscription.status == SubscriptionStatus.canceled &&
                    onResumeSubscription != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onResumeSubscription!,
                      icon: const Icon(FontAwesomeIcons.play, size: 14),
                      label: const Text("Resume"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Pallete.greenColor,
                        side: const BorderSide(color: Pallete.greenColor),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                if (subscription.isActive && onMakePayment != null) ...[
                  if (subscription.status == SubscriptionStatus.active &&
                      onCancelSubscription != null)
                    kGap10,
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onMakePayment,
                      icon: const Icon(FontAwesomeIcons.moneyBill, size: 14),
                      label: Text(S.of(context).makePayment),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Pallete.greenColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
