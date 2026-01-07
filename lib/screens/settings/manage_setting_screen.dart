import 'package:desktoppossystem/screens/settings/components/sections/currency_sections/currency_section.dart';
import 'package:desktoppossystem/screens/settings/components/sections/general_section/general_section.dart';
import 'package:desktoppossystem/screens/settings/components/sections/owner_section/owner_section.dart';
import 'package:desktoppossystem/screens/settings/components/sections/printer%20section/printer_properties_section.dart';
import 'package:desktoppossystem/screens/settings/components/store_info_section.dart';
import 'package:desktoppossystem/screens/settings/manage_setting_screen_mobile.dart';
import 'package:desktoppossystem/shared/services/scroll_behavior_service.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:desktoppossystem/shared/utils/responsive_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

class ManageSettingScreen extends ConsumerStatefulWidget {
  const ManageSettingScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ManageSettingScreenState();
}

class _ManageSettingScreenState extends ConsumerState<ManageSettingScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(
      mobileView: const ManageSettingScreenMobile(),
      desktopView: ScrollConfiguration(
        behavior: MyCustomScrollBehavior(),
        child: SingleChildScrollView(
          key: const PageStorageKey("manageSettingScreen"),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: .start,
            children: [
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    PrinterPropertiesSection(),
                    kGap20,
                    const GeneralSection(),
                  ],
                ),
              ),
              kGap10,
              const Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    StoreInfoSection(),
                    Gap(20),
                    // ! Currencies
                    CurrencySection(),
                    Gap(20),
                    OwnerSection(),
                  ],
                ),
              ),
              kGap10,
            ],
          ),
        ),
      ).baseContainer(context.cardColor),
    );
  }
}
