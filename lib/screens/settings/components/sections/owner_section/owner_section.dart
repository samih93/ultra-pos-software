import 'package:desktoppossystem/controller/auth_controller.dart';
import 'package:desktoppossystem/screens/settings/components/sections/owner_section/menu_section/menu_section.dart';
import 'package:desktoppossystem/screens/settings/components/sections/owner_section/owner_query_screen/owner_query_section.dart';
import 'package:desktoppossystem/screens/settings/components/sections/owner_section/remove_license_section/remove_license_section.dart';
import 'package:desktoppossystem/screens/settings/components/sections/owner_section/subscription_section/subscription_section.dart';
import 'package:desktoppossystem/shared/config/secure_config.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OwnerSection extends ConsumerWidget {
  const OwnerSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOwner =
        ref.read(currentUserProvider)?.id ==
        int.tryParse(SecureConfig.quiverUserId);
    return isOwner
        ? const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MenuSection(),
              SubscriptionSection(),
              OwnerQuerySection(),
              RemoveLicenseSection(),
            ],
          )
        : kEmptyWidget;
  }
}
