import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/subscription_model.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SubscriptionSummaryCardsMobile extends StatelessWidget {
  final SubscriptionStatsModel? stats;

  const SubscriptionSummaryCardsMobile({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    if (stats == null) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 60,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: kPaddH15,
        children: [
          _MobileSummaryCard(
            icon: FontAwesomeIcons.calendarCheck,
            title: S.of(context).totalActive,
            value: stats!.activeSubscriptions.toString(),
            color: Pallete.greenColor,
          ),
          kGap10,
          _MobileSummaryCard(
            icon: FontAwesomeIcons.triangleExclamation,
            title: S.of(context).totalOverdue,
            value: stats!.overdueSubscriptions.toString(),
            color: Pallete.redColor,
          ),
          kGap10,
          _MobileSummaryCard(
            icon: FontAwesomeIcons.dollarSign,
            title: S.of(context).monthlyRevenue,
            value: stats!.monthlyRevenue.formatAmountNumber(),
            color: Pallete.blueColor,
          ),
          kGap10,
          _MobileSummaryCard(
            icon: FontAwesomeIcons.ban,
            title: S.of(context).totalCancelled,
            value: stats!.canceledSubscriptions.toString(),
            color: Pallete.greyColor,
          ),
        ],
      ),
    );
  }
}

class _MobileSummaryCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _MobileSummaryCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: kPadd5,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: kRadius8,
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: .start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 24),
          Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              DefaultTextView(
                text: title,
                fontSize: 12,
                color: Colors.grey[700]!,
                fontWeight: FontWeight.w500,
              ),
              DefaultTextView(
                text: value,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
