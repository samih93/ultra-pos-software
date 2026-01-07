import 'package:desktoppossystem/models/details_receipt.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BuildDetailsReceiptItemMobile extends ConsumerWidget {
  const BuildDetailsReceiptItemMobile(this.detailsReceipt, {super.key});
  final DetailsReceipt detailsReceipt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSuperAdmin = ref.watch(mainControllerProvider).isSuperAdmin;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      elevation: 1,
      color: context.cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.r)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product name with discount badge
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: DefaultTextView(
                    text: detailsReceipt.productName.toString(),
                    fontWeight: FontWeight.bold,
                    fontSize: 13.spMax,
                    maxlines: 2,
                    textDecoration: detailsReceipt.isRefunded == true
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
                if (detailsReceipt.discount > 0)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: Pallete.redColor,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: DefaultTextView(
                      text: '${detailsReceipt.discount}%',
                      color: Colors.white,
                      fontSize: 10.spMax,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                if (detailsReceipt.isRefunded == true)
                  Container(
                    margin: EdgeInsets.only(left: 4.w),
                    padding: EdgeInsets.symmetric(
                      horizontal: 6.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: Pallete.redColor,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: DefaultTextView(
                      text: 'Refunded',
                      color: Colors.white,
                      fontSize: 10.spMax,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8.h),

            // Product details in grid
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    label: 'Qty',
                    value: detailsReceipt.qty.toString(),
                    icon: Icons.inventory_2_outlined,
                  ),
                ),
                if (isSuperAdmin)
                  Expanded(
                    child: _buildInfoItem(
                      label: 'Cost',
                      value:
                          '\$${detailsReceipt.costPrice.validateDouble().formatDouble()}',
                      icon: Icons.attach_money,
                    ),
                  ),
                Expanded(
                  child: _buildInfoItem(
                    label: 'Price',
                    value:
                        '\$${detailsReceipt.sellingPrice.validateDouble().formatDouble()}',
                    icon: Icons.point_of_sale,
                    valueColor: Pallete.greenColor,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    label: 'Total',
                    value:
                        '\$${(detailsReceipt.sellingPrice.validateDouble() * detailsReceipt.qty.validateDouble()).formatDouble()}',
                    icon: Icons.calculate,
                    valueColor: Pallete.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
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
            Icon(icon, size: 11.spMax, color: Colors.grey),
            SizedBox(width: 2.w),
            Flexible(
              child: DefaultTextView(
                text: label,
                fontSize: 9.spMax,
                color: Colors.grey,
                maxlines: 1,
              ),
            ),
          ],
        ),
        SizedBox(height: 2.h),
        DefaultTextView(
          text: value,
          fontSize: 11.spMax,
          fontWeight: FontWeight.w600,
          color: valueColor,
        ),
      ],
    );
  }
}
