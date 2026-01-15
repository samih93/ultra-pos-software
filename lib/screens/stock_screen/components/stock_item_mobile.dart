import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/product_model.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/shared/default%20components/cached_network_image_widget.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StockItemMobile extends ConsumerWidget {
  const StockItemMobile(this.stockItem, {super.key});

  final ProductModel stockItem;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSuperAdmin = ref.watch(mainControllerProvider).isSuperAdmin;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      elevation: 1,
      color: stockItem.isLowStock == true
          ? Colors.red.withValues(alpha: 0.1)
          : null,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product name with image
            Row(
              children: [
                if (stockItem.image != null) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4.r),
                    child: CachedNetworkImageWidget(
                      imageUrl: stockItem.image!,
                      height: 50.h,
                      width: 50.w,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: 12.w),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DefaultTextView(
                        text: stockItem.name ?? '',
                        fontWeight: FontWeight.bold,
                        fontSize: 14.spMax,
                        maxlines: 2,
                      ),
                      if (stockItem.barcode?.isNotEmpty == true) ...[
                        SizedBox(height: 2.h),
                        Row(
                          children: [
                            Icon(
                              Icons.qr_code,
                              size: 12.spMax,
                              color: Colors.grey,
                            ),
                            SizedBox(width: 4.w),
                            DefaultTextView(
                              text: stockItem.barcode ?? '',
                              fontSize: 11.spMax,
                              color: Colors.grey,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                if (stockItem.isLowStock == true)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: DefaultTextView(
                      text: S.of(context).lowStock,
                      fontSize: 10.spMax,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 12.h),

            // Details in grid
            Row(
              children: [
                if (isSuperAdmin)
                  Expanded(
                    child: _buildInfoItem(
                      context,
                      label: S.of(context).costPrice,
                      value: '\$${stockItem.costPrice?.formatDouble() ?? '0'}',
                      icon: Icons.attach_money,
                    ),
                  ),
                Expanded(
                  child: _buildInfoItem(
                    context,
                    label: S.of(context).sellingPrice,
                    value: '\$${stockItem.sellingPrice?.formatDouble() ?? '0'}',
                    icon: Icons.point_of_sale,
                    valueColor: Pallete.greenColor,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    context,
                    label: S.of(context).qty,
                    value: stockItem.isTracked == true
                        ? stockItem.qty?.formatDouble().toString() ?? '0'
                        : '-',
                    icon: Icons.inventory_2_outlined,
                  ),
                ),
              ],
            ),

            // Expiry date if available
            if (stockItem.expiryDate != null &&
                stockItem.expiryDate!.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 12.spMax,
                    color: Colors.grey,
                  ),
                  SizedBox(width: 4.w),
                  DefaultTextView(
                    text:
                        '${S.of(context).expiryDate}: ${stockItem.expiryDate}',
                    fontSize: 11.spMax,
                    color: Colors.grey,
                  ),
                ],
              ),
            ],
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
            Icon(icon, size: 12.spMax, color: Colors.grey),
            SizedBox(width: 3.w),
            DefaultTextView(
              text: label,
              fontSize: 10.spMax,
              color: Colors.grey,
            ),
          ],
        ),
        SizedBox(height: 2.h),
        DefaultTextView(
          text: value,
          fontSize: 12.spMax,
          fontWeight: FontWeight.w600,
          color: valueColor,
        ),
      ],
    );
  }
}
