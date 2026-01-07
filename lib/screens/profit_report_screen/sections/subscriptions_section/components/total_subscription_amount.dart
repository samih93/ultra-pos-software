import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TotalSubscriptionAmount extends ConsumerWidget {
  const TotalSubscriptionAmount({super.key, required this.totalSubscriptions});

  final double totalSubscriptions;

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
        color: Pallete.greenColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Pallete.greenColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.monetization_on,
            size: 20.spMax,
            color: Pallete.greenColor,
          ),
          SizedBox(width: 8.w),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DefaultTextView(
                text: S.of(context).totalSubscriptionIncome,
                fontSize: 11.spMax,
                color: Colors.grey,
              ),
              SizedBox(height: 2.h),
              DefaultTextView(
                text: totalSubscriptions.formatDouble().toString(),
                fontSize: 16.spMax,
                fontWeight: FontWeight.bold,
                color: Pallete.greenColor,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopView(BuildContext context, bool isLtr) {
    return Column(
      children: [
        Row(
          children: [
            const Expanded(flex: 3, child: kEmptyWidget),
            const Expanded(flex: 3, child: kEmptyWidget),
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Pallete.greenColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Pallete.greenColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.monetization_on,
                      color: Pallete.greenColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        DefaultTextView(
                          text: S.of(context).totalSubscriptionIncome,
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        DefaultTextView(
                          text: totalSubscriptions.formatDouble().toString(),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Pallete.greenColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
