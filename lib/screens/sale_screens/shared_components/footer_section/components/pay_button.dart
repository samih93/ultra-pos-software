import 'dart:io';

import 'package:desktoppossystem/controller/auth_controller.dart';
import 'package:desktoppossystem/controller/printer_controller.dart';
import 'package:desktoppossystem/controller/receipt_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/receipt_model.dart';
import 'package:desktoppossystem/models/user_model.dart';
import 'package:desktoppossystem/screens/sale_screens/market_sale_screen/components/mobile_scanner_section.dart';
import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
import 'package:desktoppossystem/screens/sale_screens/shared_components/footer_section/components/change_amount_dialog.dart';
import 'package:desktoppossystem/screens/sale_screens/shared_components/order_type_section.dart';
import 'package:desktoppossystem/shared/default%20components/new_default_button.dart';
import 'package:desktoppossystem/shared/styles/my_linears_gradient.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final isChangeDialogOpenProvider = StateProvider<bool>((ref) => false);

class PayButton extends ConsumerWidget {
  const PayButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var saleController = ref.watch(saleControllerProvider);
    UserModel usermodel = ref.read(currentUserProvider) ?? UserModel.fakeUser();
    return NewDefaultButton(
      width: 70,
      height: 50,
      gradient: coreGradient(),
      onpress: () async {
        final receiptController = ref.watch(receiptControllerProvider);
        if (ref.read(printerControllerProvider).openCashDialogOnPay) {
          ref.read(saleControllerProvider).onChangeEnteringAmountType(true);
          ref.read(isChangeDialogOpenProvider.notifier).state = true;
          // if cash drawer setting is enabled, open it
          if (ref.read(printerControllerProvider).showOpenCashButton) {
            ref.read(printerControllerProvider).openCashDrawer(context);
          }

          showDialog(
            context: context,
            builder: (context) => const ChangeAmountDialog(),
          ).whenComplete(() {
            ref.read(isChangeDialogOpenProvider.notifier).state = false;
          });
        } else {
          ReceiptModel receiptModel = ReceiptModel(
            nbOfCustomers: saleController.nbOfCustomers,
            orderType: ref.read(selectedOrderTypeProvider),
            foreignReceiptPrice: saleController.foreignTotalPrice,
            localReceiptPrice: saleController.localTotalPrice,
            receiptDate: DateTime.now().toString(),
            userId: usermodel.id,
            dollarRate: ref.read(saleControllerProvider).dolarRate,
            paymentType: PaymentType.cash,
            transactionType: TransactionType.salePayment,
            shiftId: ref.read(currentShiftProvider).id!,
            customerId: saleController.customerModel?.id,
            isPaid: true,
            isHasDiscount: saleController.basketItems.any(
              (e) => e.discount! > 0,
            ),
          );
          receiptModel.customerModel = saleController.customerModel;
          await ref
              .read(receiptControllerProvider)
              .pay(receiptModel, saleController.basketItems, context: context);

          // Close mobile scanner on payment (Android only)
          if (!Platform.isWindows) {
            ref.read(mobileScannerActiveProvider.notifier).state = false;
          }
        }
      },
      text: S.of(context).pay,
      state:
          !ref.read(printerControllerProvider).openCashDialogOnPay ||
              ref.watch(receiptControllerProvider).payUsingF12
          ? ref.watch(receiptControllerProvider).payRequestState
          : null,
      isDisabled:
          saleController.basketItems.isEmpty ||
          (saleController.basketItems.any(
            (element) =>
                element.isJustOrdered == true || element.isNewToBasket == true,
          )),
    );
  }
}
