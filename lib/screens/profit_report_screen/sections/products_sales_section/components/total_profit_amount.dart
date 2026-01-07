import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TotalProfitAmount extends ConsumerWidget {
  const TotalProfitAmount({
    super.key,
    required this.totalCost,
    required this.totalPaid,
    required this.profit,
  });

  final double totalCost;
  final double totalPaid;
  final double profit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLtr = ref.read(mainControllerProvider).isLtr;

    return context.isMobile
        ? _buildMobileView(context)
        : _buildDesktopView(context, isLtr);
  }

  Widget _buildMobileView(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Pallete.coreMistColor.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Pallete.coreMistColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildMobileTotalItem(
            context,
            label: S.of(context).costPrice,
            value: totalCost.formatDouble().toString(),
            icon: Icons.money_off,
          ),
          Container(width: 1, height: 30.h, color: Pallete.coreMistColor),
          _buildMobileTotalItem(
            context,
            label: S.of(context).sellingPrice,
            value: totalPaid.formatDouble().toString(),
            icon: Icons.attach_money,
          ),
          Container(width: 1, height: 30.h, color: Pallete.coreMistColor),
          _buildMobileTotalItem(
            context,
            label: S.of(context).profit,
            value: profit.formatDouble().toString(),
            icon: Icons.trending_up,
            valueColor: Pallete.greenColor,
          ),
        ],
      ),
    );
  }

  Widget _buildMobileTotalItem(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    Color? valueColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16.spMax, color: Colors.grey),
        SizedBox(height: 2.h),
        DefaultTextView(text: label, fontSize: 10.spMax, color: Colors.grey),
        SizedBox(height: 2.h),
        DefaultTextView(
          text: value,
          fontSize: 13.spMax,
          fontWeight: FontWeight.bold,
          color: valueColor,
        ),
      ],
    );
  }

  Widget _buildDesktopView(BuildContext context, bool isLtr) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(flex: 2, child: kEmptyWidget),
            const Expanded(flex: 2, child: kEmptyWidget),
            const Expanded(child: kEmptyWidget),
            Expanded(
              child: Container(
                padding: kPadd5,
                decoration: BoxDecoration(
                  color: Pallete.coreMistColor,
                  borderRadius: isLtr
                      ? const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          bottomLeft: Radius.circular(15),
                        )
                      : const BorderRadius.only(
                          topRight: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        ),
                ),
                child: DefaultTextView(
                  textAlign: TextAlign.center,
                  text: "${totalCost.formatDouble()}",
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: kPadd5,
                color: Pallete.coreMistColor,
                child: DefaultTextView(
                  textAlign: TextAlign.center,
                  text: "${totalPaid.formatDouble()}",
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: kPadd5,
                decoration: BoxDecoration(
                  color: Pallete.coreMistColor,
                  borderRadius: isLtr
                      ? const BorderRadius.only(
                          topRight: Radius.circular(15),
                          bottomRight: Radius.circular(15),
                        )
                      : const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          bottomLeft: Radius.circular(15),
                        ),
                ),
                child: DefaultTextView(
                  textAlign: TextAlign.center,
                  text: "${profit.formatDouble()}",
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
