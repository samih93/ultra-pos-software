import 'package:desktoppossystem/screens/error_section.dart';
import 'package:desktoppossystem/screens/license_screen/licenses_controller.dart';
import 'package:desktoppossystem/shared/default%20components/default_price_text.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CoreLicenseInfo extends ConsumerWidget {
  const CoreLicenseInfo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final futureDays = ref.watch(remainingLicenseDaysProvider);
    return futureDays.when(
        data: (data) => Container(
              constraints: const BoxConstraints(maxWidth: 70),
              color: Pallete.redColor.withValues(alpha: 0.8),
              padding: defaultPadding,
              child: AppPriceText(
                fontSize: context.smallSize,
                text: "$data",
                color: Pallete.whiteColor,
                unit: "Day${data > 1 ? "s" : ""}",
                fontWeight: FontWeight.bold,
              ),
            ).cornerRadiusWithClipRRect(),
        error: (Object error, StackTrace stackTrace) {
          return ErrorSection(
            title: error.toString(),
          );
        },
        loading: () {
          return const Skeletonizer(
            child: Padding(
              padding: EdgeInsets.only(bottom: 65),
              child: AppPriceText(
                text: "22",
                color: Pallete.redColor,
                fontSize: 45,
                unit: "Days",
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        });
  }
}
