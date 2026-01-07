import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/reports/sales_product_model.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfitSalesCardMobile extends StatelessWidget {
  const ProfitSalesCardMobile({required this.salesProductModel, super.key});

  final SalesProductModel salesProductModel;

  @override
  Widget build(BuildContext context) {
    final percentagePerItem = salesProductModel.totalCost != 0
        ? ((salesProductModel.profit / salesProductModel.totalCost) * 100)
              .round()
        : 0.0;

    return Card(
      color: Pallete.whiteColor,
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product name and barcode
            Row(
              children: [
                Expanded(
                  child: DefaultTextView(
                    color: Pallete.blackColor,
                    text: salesProductModel.name.validateString(),
                    fontWeight: FontWeight.bold,
                    fontSize: 14.spMax,
                    maxlines: 1,
                  ),
                ),
              ],
            ),
            if (salesProductModel.barcode.validateString().isNotEmpty) ...[
              SizedBox(height: 2.h),
              DefaultTextView(
                text: salesProductModel.barcode.validateString(),
                fontSize: 11.spMax,
                color: Pallete.blackColor,
              ),
            ],
            SizedBox(height: 8.h),

            // Details in grid
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    context,
                    label: S.of(context).qty,
                    value: salesProductModel.qty.toString(),
                    icon: Icons.inventory_2_outlined,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    context,
                    label: S.of(context).costPrice,
                    value: salesProductModel.totalCost
                        .formatDouble()
                        .toString(),
                    icon: Icons.attach_money,
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
                    label: S.of(context).sellingPrice,
                    value: salesProductModel.paidCost.formatDouble().toString(),
                    icon: Icons.point_of_sale,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    context,
                    label: S.of(context).profit,
                    value:
                        '${salesProductModel.profit.formatDouble()} ($percentagePerItem%)',
                    icon: Icons.trending_up,
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
