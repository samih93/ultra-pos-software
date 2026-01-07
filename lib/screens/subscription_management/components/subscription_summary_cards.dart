import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/subscription_model.dart';
import 'package:desktoppossystem/shared/default%20components/dashboard_card.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SubscriptionSummaryCards extends StatelessWidget {
  final SubscriptionStatsModel? stats;

  const SubscriptionSummaryCards({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    if (stats == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: kPadd10,
      child: Row(
        children: [
          Expanded(
            child: DashboardCard(
              icon: FontAwesomeIcons.calendarCheck,
              title: S.of(context).totalActive,
              value: stats!.activeSubscriptions.toString(),
              color: Pallete.greenColor,
            ),
          ),
          kGap10,
          Expanded(
            child: DashboardCard(
              icon: FontAwesomeIcons.triangleExclamation,
              title: S.of(context).totalOverdue,
              value: stats!.overdueSubscriptions.toString(),
              color: Pallete.redColor,
            ),
          ),
          kGap10,
          Expanded(
            child: DashboardCard(
              icon: FontAwesomeIcons.dollarSign,
              title: S.of(context).monthlyRevenue,
              value: stats!.monthlyRevenue.formatAmountNumber(),
              color: Pallete.blueColor,
            ),
          ),
          kGap10,
          Expanded(
            child: DashboardCard(
              icon: FontAwesomeIcons.ban,
              title: S.of(context).totalCancelled,
              value: stats!.canceledSubscriptions.toString(),
              color: Pallete.greyColor,
            ),
          ),
        ],
      ),
    );
  }
}
