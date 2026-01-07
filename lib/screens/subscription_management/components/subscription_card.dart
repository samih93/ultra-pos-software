import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/subscription_model.dart';
import 'package:desktoppossystem/shared/default%20components/app_squared_outlined_button.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SubscriptionCard extends StatelessWidget {
  final SubscriptionModel subscription;
  final VoidCallback? onMakePayment;
  final VoidCallback? onEditPaymentDate;
  final VoidCallback? onEditMonthlyAmount;
  final VoidCallback? onCancelSubscription;
  final VoidCallback? onResumeSubscription;

  const SubscriptionCard({
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
      color: Pallete.whiteColor,
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: kRadius8,
        side: BorderSide(
          color: subscription.isOverdue
              ? Pallete.redColor
              : statusColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: kPadd10,
        child: Column(
          crossAxisAlignment: .start,
          children: [
            // Header with customer name and status
            Row(
              children: [
                Expanded(
                  child: DefaultTextView(
                    text: subscription.customerName ?? 'Unknown Customer',
                    fontSize: 18,
                    color: Pallete.blackColor,

                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: kRadius8,
                    border: Border.all(color: statusColor),
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
            kGap8,

            // Customer phone
            if (subscription.customerPhone != null &&
                subscription.customerPhone!.isNotEmpty)
              Row(
                children: [
                  const Icon(
                    FontAwesomeIcons.phone,
                    size: 14,
                    color: Pallete.blackColor,
                  ),
                  kGap8,
                  DefaultTextView(
                    color: Pallete.blackColor,

                    text: subscription.customerPhone!,
                    fontSize: 14,
                  ),
                ],
              ),

            kGap8,

            // Monthly amount and next payment
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      DefaultTextView(
                        text: S.of(context).monthlyAmount,
                        color: Pallete.blackColor,

                        fontSize: 12,
                      ),
                      kGap5,
                      Row(
                        children: [
                          DefaultTextView(
                            color: Pallete.blackColor,

                            text: subscription.monthlyAmount
                                .formatDouble()
                                .toString(),

                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          kGap5,
                          if (onEditMonthlyAmount != null)
                            InkWell(
                              onTap: onEditMonthlyAmount,
                              child: const Icon(
                                Icons.edit,
                                size: 16,
                                color: Pallete.blueColor,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      DefaultTextView(
                        text: S.of(context).nextPayment,
                        color: Pallete.blackColor,

                        fontSize: 12,
                      ),

                      kGap5,
                      Row(
                        children: [
                          DefaultTextView(
                            text: subscription.nextPaymentDate.split(' ').first,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: subscription.isOverdue
                                ? Pallete.redColor
                                : Pallete.blackColor,
                          ),
                          kGap5,
                          if (onEditPaymentDate != null)
                            InkWell(
                              onTap: onEditPaymentDate,
                              child: const Icon(
                                Icons.edit,
                                size: 16,
                                color: Pallete.blueColor,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Show months overdue if overdue
            if (subscription.isOverdue) ...[
              kGap10,
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Pallete.redColor.withValues(alpha: 0.1),
                  borderRadius: kRadius8,
                  border: Border.all(color: Pallete.redColor, width: 1.5),
                ),
                child: Row(
                  children: [
                    const Icon(
                      FontAwesomeIcons.triangleExclamation,
                      color: Pallete.redColor,
                      size: 16,
                    ),
                    kGap8,
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

            kGap10,

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Cancel/Resume button
                if (subscription.status == SubscriptionStatus.active &&
                    onCancelSubscription != null)
                  AppSquaredOutlinedButton(
                    onPressed: onCancelSubscription!,
                    borderColor: Pallete.redColor,
                    child: const Icon(
                      FontAwesomeIcons.ban,
                      size: 16,
                      color: Pallete.redColor,
                    ),
                  ),
                if (subscription.status == SubscriptionStatus.canceled &&
                    onResumeSubscription != null)
                  AppSquaredOutlinedButton(
                    onPressed: onResumeSubscription!,
                    borderColor: Pallete.greenColor,
                    child: const Icon(
                      FontAwesomeIcons.play,
                      size: 16,
                      color: Pallete.greenColor,
                    ),
                  ),
                if (subscription.isActive && onMakePayment != null) ...[
                  kGap8,
                  ElevatedButton.icon(
                    onPressed: onMakePayment,
                    icon: const Icon(FontAwesomeIcons.moneyBill, size: 14),
                    label: Text(S.of(context).makePayment),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Pallete.greenColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
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
