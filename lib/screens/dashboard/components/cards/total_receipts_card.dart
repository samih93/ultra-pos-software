import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/dashboard/dashboard_controller.dart';
import 'package:desktoppossystem/screens/error_section.dart';
import 'package:desktoppossystem/shared/default%20components/dashboard_card.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

class TotalReceiptsCard extends ConsumerWidget {
  const TotalReceiptsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var futureCount = ref.watch(futureNbOfReceipts);

    return futureCount.when(
        data: (data) => DashboardCard(
              value: "$data",
              color: Pallete.greenColor,
              icon: Icons.receipt,
              title: S.of(context).receipts,
            ),
        error: (error, stackTrace) => ErrorSection(
              retry: () {
                ref.refresh(usersCountProvider);
              },
            ),
        loading: () => Skeletonizer(
              enabled: true,
              effect: const PulseEffect(duration: Duration(milliseconds: 300)),
              child: DashboardCard(
                value: "0",
                color: Pallete.blueColor,
                icon: Icons.supervised_user_circle_sharp,
                title: S.of(context).users,
              ),
            ));
  }
}
