import 'package:desktoppossystem/controller/category_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/add_edit_product/add_edit_product_screen.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_screen.dart';
import 'package:desktoppossystem/screens/sale_screens/caffe_sale_screens/components/products/componenets/product_setting_screen.dart';
import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
import 'package:desktoppossystem/screens/sale_screens/shared_components/hold_invoices_section.dart';
import 'package:desktoppossystem/shared/default%20components/app_squared_outlined_button.dart';
import 'package:desktoppossystem/shared/default%20components/app_text_title_section.dart';
import 'package:desktoppossystem/shared/services/scroll_behavior_service.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/utils/toast_utils.dart';

import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../main_screen.dart/main_controller.dart';

class ProductButtonsSection extends ConsumerWidget {
  const ProductButtonsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var saleController = ref.watch(saleControllerProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppTextTitleSection(S.of(context).products),
        Flexible(
          child: ScrollConfiguration(
            behavior: MyCustomScrollBehavior(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 2),
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppSquaredOutlinedButton(
                    child: const Icon(Icons.settings),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => ProductSettingsScreen(),
                      );
                    },
                  ),
                  if (saleController.selectedTable == null &&
                      ref.watch(mainControllerProvider).screenUI ==
                          ScreenUI.restaurant)
                    const HoldInvoicesSection(),
                  AppSquaredOutlinedButton(
                    borderColor: Pallete.redColor,
                    isDisabled: ref
                        .watch(saleControllerProvider)
                        .basketItems
                        .isEmpty,
                    onPressed: () {
                      ref.read(saleControllerProvider).resetSaleScreen();
                    },
                    child: const Icon(Icons.delete, color: Pallete.redColor),
                  ),
                  if (ref.watch(mainControllerProvider).isAdmin)
                    AppSquaredOutlinedButton(
                      isDisabled:
                          ref
                              .watch(categoryControllerProvider)
                              .selectedCategory ==
                          null,
                      onPressed: () {
                        if (ref
                                .watch(categoryControllerProvider)
                                .selectedCategory !=
                            null) {
                          ref
                                  .read(barcodeListenerEnabledProvider.notifier)
                                  .state =
                              false;

                          context.to(
                            AddEditProductScreen(
                              null,
                              ref
                                  .read(categoryControllerProvider)
                                  .selectedCategory,
                            ),
                          );
                        } else {
                          ToastUtils.showToast(
                            message: "Please Select Category",
                            type: RequestState.error,
                          );
                        }
                      },
                      child: const Icon(Icons.add),
                    ),
                ],
              ),
            ),
          ),
        ),
        //  const Spacer(),
      ],
    );
  }
}
