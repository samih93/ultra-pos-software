import 'package:desktoppossystem/controller/customer_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/shared/default%20components/dashboard_card.dart';
import 'package:desktoppossystem/screens/error_section.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

class TotalCutomersCountCard extends ConsumerWidget {
  const TotalCutomersCountCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var futureCount = ref.watch(customerCountsProvider);
    return futureCount.when(
      data: (data) => DashboardCard(
        value: data.toString(),
        color: Pallete.redColor,
        icon: Icons.groups,
        title: S.of(context).customers,
      ),
      error: (error, stackTrace) => ErrorSection(
        retry: () {
          ref.refresh(customerCountsProvider);
        },
      ),
      loading: () => Skeletonizer(
        enabled: true,
        effect: const PulseEffect(duration: Duration(milliseconds: 300)),
        child: DashboardCard(
          value: "0",
          color: Pallete.redColor,
          icon: Icons.groups,
          title: S.of(context).customers,
        ),
      ),
    );
  }
}
