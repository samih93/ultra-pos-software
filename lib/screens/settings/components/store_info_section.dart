import 'package:desktoppossystem/controller/setting_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/shared/default%20components/custom_toggle_button.dart';
import 'package:desktoppossystem/shared/default%20components/default_list_tile.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/default%20components/elevated_button_widget.dart';
import 'package:desktoppossystem/shared/default%20components/app_text_form_field.dart';
import 'package:desktoppossystem/shared/default%20components/quiver_circular_indicator.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StoreInfoSection extends ConsumerWidget {
  const StoreInfoSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var settingController = ref.watch(settingControllerProvider);
    return settingController.fetchSettingRequestState == RequestState.loading
        ? const Center(child: CoreCircularIndicator())
        : Container(
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
                      text: S.of(context).storeInfo,
                      color: context.primaryColor,
                      fontSize: 20,
                    ),
                    ElevatedButtonWidget(
                      icon: Icons.save,
                      text: S.of(context).save,
                      onPressed: () {
                        saveStoreInfo(ref);
                      },
                    ),
                  ],
                ),
                const Divider(),
                AppTextFormField(
                  showText: true,
                  controller: settingController.qrCodeTextController,
                  inputtype: TextInputType.name,
                  hinttext: S.of(context).storeQrCode,
                ),
                AppTextFormField(
                  showText: true,
                  controller: settingController.nameTextController,
                  inputtype: TextInputType.name,
                  hinttext: "${S.of(context).name.capitalizeFirstLetter()}",
                ),
                AppTextFormField(
                  showText: true,
                  controller: settingController.locationTextController,
                  inputtype: TextInputType.name,
                  hinttext: S.of(context).address.capitalizeFirstLetter(),
                ),
                AppTextFormField(
                  showText: true,
                  controller: settingController.phoneTextController,
                  inputtype: TextInputType.phone,
                  hinttext: S.of(context).phone.capitalizeFirstLetter(),
                ),
                AppTextFormField(
                  showText: true,
                  controller: settingController.noteTextController,
                  inputtype: TextInputType.name,
                  hinttext: S.of(context).note.capitalizeFirstLetter(),
                ),
                kGap20,
                //if (context.isWindows)
                ElevatedButtonWidget(
                  icon: Icons.image,
                  width: double.infinity,
                  text: S.of(context).pickLogo,
                  onPressed: () {
                    ref.read(settingControllerProvider).pickImage();
                  },
                ),
                if (ref.watch(settingControllerProvider).photoBytes !=
                    null) ...[
                  kGap20,
                  Image.memory(
                    width: 250,
                    height: 250,
                    cacheWidth: 250,
                    cacheHeight: 250,
                    ref.watch(settingControllerProvider).photoBytes!,
                  ),
                  DefaultListTile(
                    title: DefaultTextView(
                      text: S.of(context).printLogoOnInvoice,
                    ),
                    leading: const Icon(
                      Icons.print_rounded,
                      color: Colors.grey,
                    ),
                    subtitle: DefaultTextView(
                      maxlines: 2,
                      text: S.of(context).printLogoOnInvoiceDescription,
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                    trailing: CustomToggleButton(
                      text1: S.of(context).on.capitalizeFirstLetter(),
                      text2: S.of(context).off.capitalizeFirstLetter(),
                      isSelected:
                          ref
                              .watch(settingControllerProvider)
                              .printLogoOnInvoice ==
                          true,
                      onPressed: (index) {
                        ref
                            .read(settingControllerProvider)
                            .changePrintLogoStatus();
                      },
                    ),
                  ),
                ],
              ],
            ),
          );
  }

  void saveStoreInfo(WidgetRef ref) {
    ref.read(settingControllerProvider).saveStoreInfo();
  }
}
