import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/settings/components/sections/general_section/components/language_section.dart';
import 'package:desktoppossystem/screens/settings/components/sections/general_section/components/restore_from_cloud_section.dart';
import 'package:desktoppossystem/screens/settings/components/sections/printer%20section/printer_properties_section.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ManageSettingScreenMobile extends ConsumerWidget {
  const ManageSettingScreenMobile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: defaultPadding,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Settings Section
            Container(
              padding: defaultPadding,
              decoration: BoxDecoration(
                borderRadius: defaultRadius,
                border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                color: context.cardColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // General Section Title
                  DefaultTextView(
                    text: S.of(context).generalSection,
                    fontSize: 18.spMax,
                    fontWeight: FontWeight.w600,
                  ),
                  Divider(height: 24.h),

                  const LanguageSection(),

                  // Restore from Cloud
                  const RestoreFromCloudSection(),

                  // Add more settings here as needed
                ],
              ),
            ),
            kGap10,
            PrinterPropertiesSection(),
          ],
        ),
      ),
    );
  }
}
