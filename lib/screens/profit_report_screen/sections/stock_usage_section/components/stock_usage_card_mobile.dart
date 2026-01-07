import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/reports/restaurant_stock_usage_model.dart';
import 'package:desktoppossystem/shared/constances/app_constances.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StockUsageCardMobile extends StatelessWidget {
  const StockUsageCardMobile({required this.stockUsage, super.key});

  final RestaurantStockUsageModel stockUsage;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Pallete.whiteColor,
      margin: EdgeInsets.symmetric(vertical: 4.h),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stock name
            DefaultTextView(
              color: Pallete.blackColor,

              text: stockUsage.name.toString(),
              fontWeight: FontWeight.bold,
              fontSize: 14.spMax,
              maxlines: 2,
            ),
            SizedBox(height: 8.h),

            // Details in grid
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    context,
                    label: S.of(context).unit,
                    value: stockUsage.unitType!.name.toString(),
                    icon: Icons.category_outlined,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    context,
                    label: UnitType.kg.uniteTypeToString(),
                    value: stockUsage.qtyAsKilo.formatDouble().toString(),
                    icon: Icons.scale_outlined,
                  ),
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    context,
                    label: UnitType.portion.uniteTypeToString(),
                    value: stockUsage.qtyAsPortion.formatDouble().toString(),
                    icon: Icons.restaurant_outlined,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    context,
                    label: S.of(context).totalCost,
                    value:
                        '${stockUsage.totalPrice!.formatDouble()} ${AppConstance.primaryCurrency.currencyLocalization()}',
                    icon: Icons.attach_money,
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
            Icon(icon, size: 12.spMax, color: Pallete.blackColor),
            SizedBox(width: 3.w),
            DefaultTextView(
              text: label,
              fontSize: 10.spMax,
              color: Pallete.blackColor,
            ),
          ],
        ),
        SizedBox(height: 2.h),
        DefaultTextView(
          text: value,
          fontSize: 12.spMax,
          fontWeight: FontWeight.w600,
          color: valueColor ?? Pallete.blackColor,
        ),
      ],
    );
  }
}
