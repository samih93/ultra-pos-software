import 'package:desktoppossystem/controller/auth_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/user_model.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/shared/config/secure_config.dart';
import 'package:desktoppossystem/shared/default%20components/custom_toggle_button.dart';
import 'package:desktoppossystem/shared/default%20components/default_list_tile.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MenuSection extends ConsumerWidget {
  const MenuSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userModel = ref.read(currentUserProvider) ?? UserModel.fakeUser();

    return userModel.id == int.tryParse(SecureConfig.quiverUserId)
        ? Container(
            padding: kPadd10,
            decoration: BoxDecoration(
              borderRadius: defaultRadius,
              border: Border.all(color: Colors.grey, width: 1),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DefaultTextView(
                      text: "Menu",
                      color: context.primaryColor,
                      fontSize: 20,
                    ),
                  ],
                ),
                const Divider(),
                DefaultListTile(
                  leading: const Icon(
                    Icons.local_police_outlined,
                    color: Colors.grey,
                  ),
                  trailing: CustomToggleButton(
                    text1: S.of(context).on.capitalizeFirstLetter(),
                    text2: S.of(context).off.capitalizeFirstLetter(),
                    isSelected: ref.watch(mainControllerProvider).menuActivated,
                    onPressed: (index) {
                      ref.read(mainControllerProvider).toggleMenuActivation();
                    },
                  ),
                  title: const DefaultTextView(text: "Activate Menu"),
                ),
                DefaultListTile(
                  onTap: () {
                    ref.read(mainControllerProvider).toggleOnlyActivatedMenu();
                  },
                  leading: const Icon(
                    Icons.local_police_outlined,
                    color: Colors.grey,
                  ),
                  trailing: CustomToggleButton(
                    text1: S.of(context).on.capitalizeFirstLetter(),
                    text2: S.of(context).off.capitalizeFirstLetter(),
                    isSelected: ref
                        .watch(mainControllerProvider)
                        .onlyActivatedMenu,
                    onPressed: (index) {
                      ref
                          .read(mainControllerProvider)
                          .toggleOnlyActivatedMenu();
                    },
                  ),
                  title: const DefaultTextView(text: " Only Activate Menu"),
                ),
              ],
            ),
          )
        : kEmptyWidget;
  }
}
