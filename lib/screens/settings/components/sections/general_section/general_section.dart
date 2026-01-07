import 'package:desktoppossystem/controller/auth_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
import 'package:desktoppossystem/screens/settings/components/sections/general_section/components/backup_to_cloud_button.dart';
import 'package:desktoppossystem/screens/settings/components/sections/general_section/components/language_dialog.dart';
import 'package:desktoppossystem/screens/settings/components/sections/general_section/components/language_section.dart';
import 'package:desktoppossystem/screens/settings/components/sections/general_section/components/local_backup_section.dart';
import 'package:desktoppossystem/screens/settings/components/sections/general_section/components/quick_selection_setting.dart';
import 'package:desktoppossystem/screens/settings/components/sections/general_section/components/restore_section.dart';
import 'package:desktoppossystem/screens/settings/components/sections/general_section/components/restore_from_cloud_section.dart';
import 'package:desktoppossystem/screens/settings/components/sections/general_section/components/set_nb_of_table_dialog.dart';
import 'package:desktoppossystem/shared/config/secure_config.dart';
import 'package:desktoppossystem/shared/default%20components/custom_toggle_button.dart';
import 'package:desktoppossystem/shared/default%20components/default_list_tile.dart';
import 'package:desktoppossystem/shared/default%20components/elevated_button_widget.dart';
import 'package:desktoppossystem/shared/default%20components/quiver_circular_indicator.dart';
import 'package:desktoppossystem/shared/services/dependency_injection.dart';
import 'package:desktoppossystem/shared/services/windows_update_service.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/default components/default_text_view.dart';

final allowNegativeDiscountProvider = StateProvider<bool>((ref) {
  return false;
});

final showDeliverPackageProvider = StateProvider<bool>((ref) {
  return false;
});
final showTablesProvider = StateProvider<bool>((ref) {
  return false;
});
final isFullScreenStateProvider = StateProvider<bool>((ref) {
  return false;
});

class GeneralSection extends ConsumerWidget {
  const GeneralSection({super.key});

  Widget _buildUpdateTrailing(WidgetRef ref) {
    final isChecking = ref.watch(isCheckingUpdatesProvider);
    final isUpdating = ref.watch(isUpdatingProvider);
    final availableUpdate = ref.watch(availableUpdateProvider);
    if (isChecking) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CoreCircularIndicator(),
      );
    }

    if (availableUpdate != null) {
      return ElevatedButtonWidget(
        states: [isUpdating ? RequestState.loading : RequestState.success],
        onPressed: () async {
          await ref.read(windowsUpdateProvider).downloadAndInstallUpdate();
        },
        color: Pallete.greenColor,
        text: 'Update',
      );
    }

    return const Icon(Icons.arrow_forward_ios_outlined, color: Colors.grey);
  }

  VoidCallback? _handleUpdateTap(WidgetRef ref) {
    final isChecking = ref.watch(isCheckingUpdatesProvider);
    final isUpdating = ref.watch(isUpdatingProvider);
    final availableUpdate = ref.watch(availableUpdateProvider);

    // Disable tap if updating or checking
    if (isChecking || isUpdating) return null;

    // If update is available, the button in trailing handles the update
    if (availableUpdate != null) return null;

    // Otherwise, check for updates
    return () async {
      await ref.read(windowsUpdateProvider).checkForUpdates();
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
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
                text: S.of(context).generalSection,
                color: context.primaryColor,
                fontSize: 20,
              ),
            ],
          ),
          const Divider(),

          if (ref.watch(mainControllerProvider).isSuperAdmin &&
              context.isWindows) ...[
            DefaultListTile(
              leading: const Icon(Icons.fullscreen, color: Colors.grey),
              trailing: CustomToggleButton(
                text1: S.of(context).on.capitalizeFirstLetter(),
                text2: S.of(context).off.capitalizeFirstLetter(),
                isSelected: ref.watch(isFullScreenStateProvider),
                onPressed: (index) {
                  ref.read(isFullScreenStateProvider.notifier).update((state) {
                    ref.read(isFullScreenStateProvider.notifier).state = !state;
                    ref
                        .read(appPreferencesProvider)
                        .saveData(key: "isFullScreen", value: !state);
                    return !state;
                  });
                },
              ),
              title: DefaultTextView(text: S.of(context).openSystemFullScreen),
            ),
            DefaultListTile(
              leading: const Icon(
                Icons.table_restaurant_outlined,
                color: Colors.grey,
              ),
              trailing: CustomToggleButton(
                text1: S.of(context).on.capitalizeFirstLetter(),
                text2: S.of(context).off.capitalizeFirstLetter(),
                isSelected: ref.watch(showTablesProvider),
                onPressed: (index) {
                  ref.read(showTablesProvider.notifier).update((state) {
                    ref.read(showTablesProvider.notifier).state = !state;
                    ref
                        .read(appPreferencesProvider)
                        .saveData(key: "showTablesProvider", value: !state);
                    return !state;
                  });
                },
              ),
              title: DefaultTextView(text: S.of(context).showTableButton),
            ),
          ],
          const QuickSelectionSetting(),
          if (ref.watch(mainControllerProvider).isSuperAdmin &&
              ref.watch(showTablesProvider))
            DefaultListTile(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => SetNbOfTableDialog(),
                );
              },
              leading: const Icon(
                Icons.table_restaurant_outlined,
                color: Colors.grey,
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  DefaultTextView(
                    text: ref
                        .watch(saleControllerProvider)
                        .nbOfTables
                        .toString(),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_outlined,
                    color: Colors.grey,
                  ),
                ],
              ),
              title: DefaultTextView(text: S.of(context).nbOfTables),
            ),

          //! allow negative discount
          if (ref.watch(mainControllerProvider).isAdmin)
            DefaultListTile(
              leading: const Icon(Icons.discount_outlined, color: Colors.grey),
              subtitle: DefaultTextView(
                maxlines: 3,
                text: S.of(context).allowNegativeDiscountDescription,
                color: Colors.grey,
                fontSize: 12,
              ),
              trailing: CustomToggleButton(
                text1: S.of(context).on.capitalizeFirstLetter(),
                text2: S.of(context).off.capitalizeFirstLetter(),
                isSelected: ref.watch(allowNegativeDiscountProvider) == true,
                onPressed: (index) {
                  ref.read(allowNegativeDiscountProvider.notifier).update((
                    state,
                  ) {
                    ref.read(saleControllerProvider).onchangeDiscount(0);
                    ref
                        .read(appPreferencesProvider)
                        .saveData(key: "allowNegativeDiscount", value: !state);
                    return !state;
                  });
                },
              ),
              title: DefaultTextView(
                text: S
                    .of(context)
                    .allowNegativeDiscount
                    .capitalizeFirstLetter(),
              ),
            ),
          //! show shift screen
          if (ref.watch(currentUserProvider)?.id ==
              int.tryParse(SecureConfig.quiverUserId))
            DefaultListTile(
              leading: const Icon(
                Icons.remove_red_eye_sharp,
                color: Colors.grey,
              ),
              trailing: CustomToggleButton(
                text1: S.of(context).show.capitalizeFirstLetter(),
                text2: S.of(context).hide.capitalizeFirstLetter(),
                isSelected: ref.watch(mainControllerProvider).isShowShiftScreen,
                onPressed: (index) {
                  ref.read(mainControllerProvider).onchangeShowShiftScreen();
                },
              ),
              title: DefaultTextView(
                text:
                    "${S.of(context).showShiftScreen} ${S.of(context).quetionMark} ",
              ),
            ),

          // ! show select module
          DefaultListTile(
            leading: const Icon(Icons.remove_red_eye_sharp, color: Colors.grey),
            trailing: CustomToggleButton(
              text1: S.of(context).show.capitalizeFirstLetter(),
              text2: S.of(context).hide.capitalizeFirstLetter(),
              isSelected: ref.watch(mainControllerProvider).isShowSelectModule,
              onPressed: (index) {
                ref.read(mainControllerProvider).onchangeShowSelectModule();
              },
            ),
            title: DefaultTextView(text: S.of(context).showSelectModule),
          ),

          // !show order section
          // DefaultListTile(
          //   leading: const Icon(
          //     Icons.remove_red_eye_sharp,
          //     color: Colors.grey,
          //   ),
          //   trailing: CustomToggleButton(
          //       text1: S.of(context).show.captilizeFirstLetter(),
          //       text2: S.of(context).hide.captilizeFirstLetter(),
          //       isSelected: ref.watch(showOrderSectionProvider),
          //       onPressed: (index) {
          //         ref.read(appPreferencesProvider).saveData(
          //             key: "showOrderTypeSection",
          //             value: !ref.read(showOrderSectionProvider));
          //         ref
          //             .read(showOrderSectionProvider.notifier)
          //             .update((state) => !state);
          //       }),
          //   title: DefaultTextView(
          //     text:
          //         "${S.of(context).showOrderTypeSection} ${S.of(context).quetionMark} ",
          //   ),
          // ),

          //! show deliver package
          if (ref.watch(currentUserProvider)?.id ==
              int.tryParse(SecureConfig.quiverUserId))
            DefaultListTile(
              leading: const Icon(
                Icons.delivery_dining_outlined,
                color: Colors.grey,
              ),
              trailing: CustomToggleButton(
                text1: S.of(context).show.capitalizeFirstLetter(),
                text2: S.of(context).hide.capitalizeFirstLetter(),
                isSelected: ref.watch(showDeliverPackageProvider),
                onPressed: (index) {
                  ref
                      .read(appPreferencesProvider)
                      .saveData(
                        key: "showDeliverPackage",
                        value: !ref.read(showDeliverPackageProvider),
                      );
                  ref
                      .read(showDeliverPackageProvider.notifier)
                      .update((state) => !state);
                },
              ),
              title: DefaultTextView(
                text: S.of(context).showDeliverPackage.capitalizeFirstLetter(),
              ),
            ),

          if (ref.watch(currentUserProvider)?.id ==
              int.tryParse(SecureConfig.quiverUserId))
            //! show restaurant stock
            DefaultListTile(
              leading: const Icon(
                Icons.remove_red_eye_sharp,
                color: Colors.grey,
              ),
              trailing: CustomToggleButton(
                text1: S.of(context).show.capitalizeFirstLetter(),
                text2: S.of(context).hide.capitalizeFirstLetter(),
                isSelected: ref
                    .watch(mainControllerProvider)
                    .isShowRestaurantStock,
                onPressed: (index) {
                  ref
                      .read(mainControllerProvider)
                      .onchangeViewRestaurantStock();
                },
              ),
              title: DefaultTextView(
                text:
                    "${S.of(context).showRestaurantStock} ${S.of(context).quetionMark} ",
              ),
            ),

          // ! language section
          const LanguageSection(),

          const LocalBackupSection(),
          const RestoreSection(),
          const BackupToCloudButton(),
          const RestoreFromCloudSection(),

          // App Update Section
          if (ref.read(mainControllerProvider).isAdmin && context.isWindows)
            DefaultListTile(
              leading: const Icon(Icons.system_update_alt, color: Colors.grey),
              title: const DefaultTextView(text: "Check for updates"),
              subtitle: ref.watch(updateProgressProvider).isNotEmpty
                  ? DefaultTextView(
                      text: ref.watch(updateProgressProvider),
                      color: Colors.grey,
                      fontSize: 12,
                    )
                  : null,
              trailing: _buildUpdateTrailing(ref),
              onTap: _handleUpdateTap(ref),
            ),
        ],
      ),
    );
  }
}
