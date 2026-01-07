import 'package:desktoppossystem/controller/auth_controller.dart';
import 'package:desktoppossystem/models/user_model.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/screens/sale_screens/shared_components/footer_section/components/close_table_button.dart';
import 'package:desktoppossystem/screens/sale_screens/shared_components/footer_section/components/last_invoice_button.dart';
import 'package:desktoppossystem/screens/sale_screens/shared_components/footer_section/components/open_cash_button.dart';
import 'package:desktoppossystem/screens/sale_screens/shared_components/footer_section/components/order_button.dart';
import 'package:desktoppossystem/screens/sale_screens/shared_components/footer_section/components/pay_delivery_button.dart';
import 'package:desktoppossystem/screens/sale_screens/shared_components/footer_section/components/print_table_button.dart';
import 'package:desktoppossystem/screens/sale_screens/shared_components/footer_section/components/re_open_table.dart';
import 'package:desktoppossystem/screens/sale_screens/shared_components/footer_section/components/staff_waste_button.dart';
import 'package:desktoppossystem/screens/sale_screens/shared_components/footer_section/components/table_button.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/constances/auth_role.dart';

class RestaurantBottomButtonsSection extends ConsumerWidget {
  const RestaurantBottomButtonsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    UserModel usermodel = ref.read(currentUserProvider) ?? UserModel.fakeUser();

    return Container(
      padding: defaultPadding,
      margin: kPaddH5,
      decoration: BoxDecoration(
        border: Border.all(color: Pallete.greyColor),
        color: context.cardColor,
        borderRadius: defaultRadius,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (ref.watch(mainControllerProvider).screenUI != ScreenUI.market)
            const Row(
              children: [
                TableButton(),

                //! check if basket contains new items
                OrderButton(),
                ReOpenTable(),
                PrintTableButton(),
                CloseTableButton(),
                kGap5,
                StaffWasteButton(),
              ],
            ),
          kGap10,
          if (usermodel.role?.name != AuthRole.waiterRole)
            const Expanded(
              child: Row(
                spacing: 5,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OpenCashButton(),
                  LastInvoiceButton(),
                  PayDeliveryButton(height: 32),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
