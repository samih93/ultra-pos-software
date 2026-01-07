import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/reports/subscribtion_state_model.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SubscriptionCardMobile extends StatelessWidget {
  const SubscriptionCardMobile({required this.subscriptionModel, super.key});

  final SubscribtionStateModel subscriptionModel;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer name
            Row(
              children: [
                Expanded(
                  child: DefaultTextView(
                    text: subscriptionModel.customerName,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.spMax,
                    maxlines: 1,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),

            // Details in grid
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    context,
                    label: S.of(context).paymentCount,
                    value: subscriptionModel.paymentCount.toString(),
                    icon: Icons.payment,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    context,
                    label: S.of(context).totalPaid,
                    value: subscriptionModel.totalPaid
                        .formatDouble()
                        .toString(),
                    icon: Icons.attach_money,
                    valueColor: Pallete.greenColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14.spMax, color: Colors.grey),
            SizedBox(width: 4.w),
            DefaultTextView(
              text: label,
              fontSize: 11.spMax,
              color: Colors.grey,
            ),
          ],
        ),
        SizedBox(height: 2.h),
        DefaultTextView(
          text: value,
          fontSize: 13.spMax,
          fontWeight: FontWeight.w600,
          color: valueColor,
        ),
      ],
    );
  }
}
