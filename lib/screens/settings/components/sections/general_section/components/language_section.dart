import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/screens/settings/components/sections/general_section/components/language_dialog.dart';
import 'package:desktoppossystem/shared/default%20components/default_list_tile.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LanguageSection extends ConsumerWidget {
  const LanguageSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultListTile(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => const LanguageDialog(),
        );
      },
      leading: const Icon(Icons.language, color: Colors.grey),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          DefaultTextView(
            text: ref
                .watch(mainControllerProvider)
                .selectedLanguage
                .name
                .capitalizeFirstLetter(),
          ),
          const Icon(Icons.arrow_forward_ios_outlined, color: Colors.grey),
        ],
      ),
      title: DefaultTextView(
        text: S.of(context).language.capitalizeFirstLetter(),
      ),
    );
  }
}
