import 'package:desktoppossystem/controller/setting_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/shared/default%20components/custom_toggle_button.dart';
import 'package:desktoppossystem/shared/default%20components/default_list_tile.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuickSelectionSetting extends ConsumerWidget {
  const QuickSelectionSetting({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isMarket =
        ref.watch(mainControllerProvider).screenUI == ScreenUI.market;
    return !isMarket
        ? kEmptyWidget
        : DefaultListTile(
            leading: const Icon(Icons.add_link_sharp, color: Colors.grey),
            trailing: CustomToggleButton(
              text1: S.of(context).show.capitalizeFirstLetter(),
              text2: S.of(context).hide.capitalizeFirstLetter(),
              isSelected: ref
                  .watch(settingControllerProvider)
                  .showQuickSelectionProducts,
              onPressed: (index) {
                ref
                    .read(settingControllerProvider.notifier)
                    .onChangeQuickSelectionProducts();
              },
            ),
            title: DefaultTextView(
              text: S.of(context).showQuickSelectionProducts,
            ),
          );
  }
}
