import 'package:desktoppossystem/controller/auth_controller.dart';
import 'package:desktoppossystem/controller/category_controller.dart';
import 'package:desktoppossystem/controller/menu_controller.dart';
import 'package:desktoppossystem/controller/setting_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/repositories/menu_repository/menu_repository.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/screens/sale_screens/caffe_sale_screens/components/products/componenets/change_product_sort_dialog.dart';
import 'package:desktoppossystem/screens/sale_screens/caffe_sale_screens/components/products/products_settings_controller.dart';
import 'package:desktoppossystem/shared/config/secure_config.dart';
import 'package:desktoppossystem/shared/default%20components/app_squared_outlined_button.dart';
import 'package:desktoppossystem/shared/default%20components/custom_toggle_button.dart';
import 'package:desktoppossystem/shared/default%20components/default_list_tile.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/services/scroll_behavior_service.dart';
import 'package:desktoppossystem/shared/default%20components/elevated_button_widget.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductSettingsScreen extends ConsumerWidget {
  ProductSettingsScreen({super.key});

  final List<int> lowQtyList = [
    0,
    1,
    2,
    3,
    4,
    5,
    10,
    15,
    20,
    25,
    30,
    40,
    50,
    100,
  ];
  final List<double> profitRateList = [0, 5, 10, 15, 20, 25, 30, 40, 50, 100];
  final List<double> productWidthList = [50, 60, 70, 80, 90, 100, 110];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var controller = ref.watch(productsSettingsControllerProvider);
    return AlertDialog(
      title: Center(child: Text(S.of(context).settingProduct)),
      content: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: context.width * 0.5),
        child: ScrollConfiguration(
          behavior: MyCustomScrollBehavior(),
          child: SingleChildScrollView(
            child: Column(
              spacing: 10,

              mainAxisSize: MainAxisSize.min,
              children: [
                if (ref.read(mainControllerProvider).isAdmin &&
                    ref.read(categoryControllerProvider).selectedCategory !=
                        null)
                  DefaultListTile(
                    onTap: () {
                      context.pop();
                      showDialog(
                        context: context,
                        builder: (context) => const ChangeProductSortDialog(),
                      );
                    },
                    title: DefaultTextView(
                      text: S.of(context).changeProductOrder,
                    ),
                    leading: const Icon(
                      Icons.sort_outlined,
                      color: Colors.grey,
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios_outlined,
                      color: Colors.grey,
                    ),
                  ),
                if (ref.watch(mainControllerProvider).screenUI ==
                    ScreenUI.restaurant) ...[
                  DefaultListTile(
                    leading: const Icon(
                      Icons.font_download,
                      color: Colors.grey,
                    ),
                    trailing: CustomToggleButton(
                      text1: S.of(context).on.capitalizeFirstLetter(),
                      text2: S.of(context).off.capitalizeFirstLetter(),
                      isSelected: controller.isBold,
                      onPressed: (index) {
                        ref
                            .read(productsSettingsControllerProvider)
                            .onchangeFontWeight();
                      },
                    ),
                    title: DefaultTextView(
                      text:
                          "${S.of(context).fontWeight} ${S.of(context).quetionMark}",
                    ),
                  ),
                  DefaultListTile(
                    leading: const Icon(
                      Icons.production_quantity_limits,
                      color: Colors.grey,
                    ),
                    trailing: CustomToggleButton(
                      text1: S.of(context).on.capitalizeFirstLetter(),
                      text2: S.of(context).off.capitalizeFirstLetter(),
                      isSelected: controller.isShowQty,
                      onPressed: (index) {
                        ref
                            .read(productsSettingsControllerProvider)
                            .onchangeQtyVisibility();
                      },
                    ),
                    title: DefaultTextView(
                      text:
                          "${S.of(context).showQty} ${S.of(context).quetionMark}",
                    ),
                  ),
                  DefaultListTile(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: DefaultTextView(
                            textAlign: TextAlign.center,
                            fontSize: 16,
                            text: "${S.of(context).productWidth}  ",
                          ),
                          content: SizedBox(
                            height: 300,
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  kGap5,
                                  ...productWidthList.map((e) {
                                    return ListTile(
                                      trailing:
                                          controller.productWidth ==
                                              productWidthList[productWidthList
                                                  .indexOf(e)]
                                          ? Icon(
                                              Icons.check_circle,
                                              color: context.primaryColor,
                                            )
                                          : kEmptyWidget,
                                      title: DefaultTextView(
                                        text: e.toString(),
                                      ),
                                      onTap: () async {
                                        controller.onchangeProductWidth(e);

                                        context.pop();
                                      },
                                    );
                                  }),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    title: DefaultTextView(text: S.of(context).productWidth),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        DefaultTextView(
                          text: controller.productWidth.toString(),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_outlined,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                    leading: const Icon(Icons.width_normal, color: Colors.grey),
                  ),
                  DefaultListTile(
                    leading: const Icon(Icons.visibility, color: Colors.grey),
                    trailing: CustomToggleButton(
                      text1: S.of(context).on.capitalizeFirstLetter(),
                      text2: S.of(context).off.capitalizeFirstLetter(),
                      isSelected: controller.showText,
                      onPressed: (index) {
                        ref
                            .read(productsSettingsControllerProvider)
                            .onchangeTextVisibility();
                      },
                    ),
                    subtitle: DefaultTextView(
                      text: S.of(context).pressHideToHide,
                      maxlines: 2,
                      color: Colors.grey,
                      fontSize: 11,
                    ),
                    title: DefaultTextView(text: S.of(context).hideShowText),
                  ),
                  DefaultListTile(
                    leading: const Icon(Icons.visibility, color: Colors.grey),
                    trailing: CustomToggleButton(
                      text1: S.of(context).on.capitalizeFirstLetter(),
                      text2: S.of(context).off.capitalizeFirstLetter(),
                      isSelected: controller.showProductImage,
                      onPressed: (index) {
                        ref
                            .read(productsSettingsControllerProvider)
                            .toggleProductImage();
                      },
                    ),
                    title: DefaultTextView(
                      text: S.of(context).showProductImage,
                    ),
                  ),
                ],
                DefaultListTile(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: DefaultTextView(
                          textAlign: TextAlign.center,
                          fontSize: 16,
                          text: "${S.of(context).defaultProfitRate}  ",
                        ),
                        content: SizedBox(
                          height: 300,
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                kGap5,
                                ...profitRateList.map((e) {
                                  return ListTile(
                                    trailing:
                                        controller.profitRate ==
                                            profitRateList[profitRateList
                                                .indexOf(e)]
                                        ? Icon(
                                            Icons.check_circle,
                                            color: context.primaryColor,
                                          )
                                        : kEmptyWidget,
                                    title: DefaultTextView(text: e.toString()),
                                    onTap: () async {
                                      controller.onchangeProfitRate(e);

                                      context.pop();
                                    },
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  title: DefaultTextView(text: S.of(context).defaultProfitRate),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      DefaultTextView(text: controller.profitRate.toString()),
                      const Icon(
                        Icons.arrow_forward_ios_outlined,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                  leading: const Icon(Icons.width_normal, color: Colors.grey),
                ),
                DefaultListTile(
                  title: DefaultTextView(
                    text:
                        "${S.of(context).show} ${S.of(context).minSellingPrice}",
                  ),
                  leading: const Icon(Icons.remove_red_eye),
                  trailing: CustomToggleButton(
                    text1: S.of(context).on.capitalizeFirstLetter(),
                    text2: S.of(context).off.capitalizeFirstLetter(),
                    isSelected: controller.showMinSellingPrice,
                    onPressed: (index) {
                      ref
                          .read(productsSettingsControllerProvider)
                          .onchangeMinSellingPrice();
                    },
                  ),
                ),
                if (!context.isMobile)
                  DefaultListTile(
                    title: DefaultTextView(
                      text:
                          "${S.of(context).show} ${S.of(context).weightedProduct}",
                    ),
                    leading: const Icon(Icons.remove_red_eye),
                    trailing: CustomToggleButton(
                      text1: S.of(context).on.capitalizeFirstLetter(),
                      text2: S.of(context).off.capitalizeFirstLetter(),
                      isSelected: controller.isUsingScale,
                      onPressed: (index) {
                        ref
                            .read(productsSettingsControllerProvider)
                            .onChangeUsingScale();
                      },
                    ),
                  ),
                DefaultListTile(
                  title: DefaultTextView(
                    text: "${S.of(context).quickAddProduct} ",
                  ),
                  leading: const Icon(Icons.copy),
                  subtitle: DefaultTextView(
                    text: S.of(context).quickAddSubtitle,
                    maxlines: 2,
                    color: Colors.grey,
                    fontSize: 11,
                  ),
                  trailing: CustomToggleButton(
                    text1: S.of(context).on.capitalizeFirstLetter(),
                    text2: S.of(context).off.capitalizeFirstLetter(),
                    isSelected: controller.duplicateLatestProductOnAdd,
                    onPressed: (index) {
                      ref
                          .read(productsSettingsControllerProvider)
                          .toggleQuickAdd();
                    },
                  ),
                ),
                if (ref.read(mainControllerProvider).menuActivated &&
                    ref.read(currentUserProvider)?.id ==
                        int.tryParse(SecureConfig.quiverUserId)) ...[
                  DefaultListTile(
                    title: DefaultTextView(
                      text: S.of(context).syncProductsDataOnly,
                    ),
                    subtitle: DefaultTextView(
                      text: S.of(context).syncProductsDataOnlyDescription,
                      color: Colors.grey,
                      maxlines: 2,
                      fontSize: 11,
                    ),
                    leading: const Icon(
                      Icons.cloud_outlined,
                      color: Colors.grey,
                    ),
                    trailing: AppSquaredOutlinedButton(
                      states: [
                        ref
                            .watch(menuControllerProvider)
                            .generateProductsSyncState,
                      ],
                      size: const Size(60, 38),
                      onPressed: () async {
                        await ref
                            .read(menuControllerProvider.notifier)
                            .syncProductsToCloudWithoutImages();
                      },
                      child: const DefaultTextView(
                        text: "sync",
                        color: Pallete.blackColor,
                      ),
                    ),
                  ),
                  if (ref.read(mainControllerProvider).menuActivated &&
                      ref.read(currentUserProvider)?.id ==
                          int.tryParse(SecureConfig.quiverUserId))
                    DefaultListTile(
                      title: DefaultTextView(
                        text:
                            "${S.of(context).syncProductsWithImages} ${ref.watch(syncProgressProvider)}",
                      ),
                      subtitle: DefaultTextView(
                        text: S.of(context).syncProductsWithImagesDescription,
                        color: Colors.grey,
                        maxlines: 2,
                        fontSize: 12,
                      ),
                      leading: const Icon(
                        Icons.cloud_outlined,
                        color: Colors.grey,
                      ),
                      trailing: Column(
                        children: [
                          AppSquaredOutlinedButton(
                            states: [
                              ref
                                  .watch(menuControllerProvider)
                                  .generateProductsWithImagesRequestState,
                            ],
                            size: const Size(60, 38),
                            onPressed: () async {
                              await ref
                                  .read(menuControllerProvider.notifier)
                                  .syncProductsToCloud();
                            },
                            child: const DefaultTextView(
                              text: "sync",
                              color: Pallete.blackColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
                ElevatedButtonWidget(
                  icon: Icons.save,
                  radius: 3,
                  width: double.infinity,
                  text: S.of(context).save,
                  onPressed: () {
                    context.pop();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
