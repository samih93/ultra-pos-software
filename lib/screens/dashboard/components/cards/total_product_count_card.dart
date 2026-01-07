import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/stock_screen/stock_controller.dart';
import 'package:desktoppossystem/shared/default%20components/dashboard_card.dart';
import 'package:desktoppossystem/screens/error_section.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

class TotalProductCountCard extends ConsumerWidget {
  const TotalProductCountCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var futureCount = ref.watch(futureProductStatsProvider);
    return futureCount.when(
      data: (data) => DashboardCard(
        value: "${data.totalCount}",
        color: Pallete.primaryColor,
        icon: Icons.store_mall_directory_sharp,
        title: S.of(context).products,
      ),
      error: (error, stackTrace) => ErrorSection(
        retry: () {
          ref.refresh(futureProductStatsProvider);
        },
      ),
      loading: () => Skeletonizer(
        enabled: true,
        effect: const PulseEffect(duration: Duration(milliseconds: 300)),
        child: DashboardCard(
          value: "0",
          color: Pallete.greenColor,
          icon: Icons.store_mall_directory_sharp,
          title: S.of(context).products,
        ),
      ),
    );
  }
}
