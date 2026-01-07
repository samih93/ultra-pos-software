import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LanguageDialog extends ConsumerWidget {
  const LanguageDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: DefaultTextView(
        textAlign: TextAlign.center,
        text: S.of(context).selectLanguage,
        fontSize: 16,
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...Language.values.map((e) {
            return ListTile(
              trailing: e == ref.watch(mainControllerProvider).selectedLanguage
                  ? Icon(Icons.check_circle, color: context.primaryColor)
                  : kEmptyWidget,
              title: DefaultTextView(text: e.name.capitalizeFirstLetter()),
              onTap: () {
                ref.read(mainControllerProvider).onchangeCurrentLanguage(e);
                context.pop();
              },
            );
          }),
        ],
      ),
    );
  }
}
