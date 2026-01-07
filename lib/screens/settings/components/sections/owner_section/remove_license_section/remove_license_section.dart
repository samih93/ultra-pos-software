import 'package:desktoppossystem/screens/license_screen/license_screen.dart';
import 'package:desktoppossystem/shared/config/secure_config.dart';
import 'package:desktoppossystem/shared/default%20components/default_list_tile.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/services/dependency_injection.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RemoveLicenseSection extends ConsumerWidget {
  const RemoveLicenseSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultListTile(
      onTap: () {
        ref
            .read(securePreferencesProvider)
            .removeByKey(key: "isLicenseExpires");
        ref
            .read(appPreferencesProvider)
            .removeDatabykey(key: SecureConfig.licenseKey);
        context.off(const LicenseScreen());
      },
      leading: const Icon(Icons.query_builder_outlined),
      title: const DefaultTextView(text: "License Removal"),
      trailing: const Icon(Icons.arrow_forward_ios_rounded),
    );
  }
}
