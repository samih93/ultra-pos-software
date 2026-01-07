import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DashboardCard extends ConsumerWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final double? fonSize;

  const DashboardCard({
    Key? key,
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    this.fonSize,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMobile = context.isMobile;
    if (isMobile) {
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
            Icon(icon, size: 20.spMax, color: color),
            Expanded(
              child: Column(
                children: [
                  DefaultTextView(
                    text: title,
                    fontSize: 10,
                    color: Colors.grey,
                  ),

                  kGap5,
                  DefaultTextView(
                    text: value,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: kPaddH10,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.rectangle,
        borderRadius: kRadius8,
        border: Border.all(color: color),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 30, color: color),
          Expanded(
            child: Column(
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                kGap5,
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
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
