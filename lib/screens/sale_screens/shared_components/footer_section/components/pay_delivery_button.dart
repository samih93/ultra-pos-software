import 'package:desktoppossystem/controller/auth_controller.dart';
import 'package:desktoppossystem/controller/receipt_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/receipt_model.dart';
import 'package:desktoppossystem/models/user_model.dart';
import 'package:desktoppossystem/screens/daily%20sales/components/deliver_package_dialog.dart';
import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
import 'package:desktoppossystem/screens/settings/components/sections/general_section/general_section.dart';
import 'package:desktoppossystem/shared/default%20components/elevated_button_widget.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PayDeliveryButton extends ConsumerWidget {
  const PayDeliveryButton({this.height, super.key});
  final double? height;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var saleController = ref.watch(saleControllerProvider);
    UserModel usermodel = ref.read(currentUserProvider) ?? UserModel.fakeUser();
    return ElevatedButtonWidget(
        onPressed: () async {
          ReceiptModel receiptModel = ReceiptModel(
              nbOfCustomers: saleController.nbOfCustomers,
              orderType: OrderType.delivery,
              foreignReceiptPrice: saleController.foreignTotalPrice,
              localReceiptPrice: saleController.localTotalPrice,
              receiptDate: DateTime.now().toString(),
              userId: usermodel.id,
              transactionType: TransactionType.pendingPayment,
              dollarRate: ref.read(saleControllerProvider).dolarRate,
              paymentType: PaymentType.cash,
              shiftId: ref.read(currentShiftProvider).id!,
              customerId: saleController.customerModel?.id,
              isPaid: false,
              isHasDiscount:
                  saleController.basketItems.any((e) => e.discount! > 0));
          receiptModel.customerModel = saleController.customerModel;
          await ref
              .read(receiptControllerProvider)
              .payAsDelivery(receiptModel, saleController.basketItems,
                  context: context)
              .whenComplete(() {
            Future.delayed(const Duration(seconds: 1)).whenComplete(() {
              if (ref.read(showDeliverPackageProvider)) {
                final lastInvoice = ref.watch(lastInvoiceProvider);
                lastInvoice.whenData((data) {
                  if (data != null && data.customerModel != null) {
                    showDialog(
                        context: context,
                        builder: (context) =>
                            DeliverPackageDialog(receiptModel: data));
                  }
                });
              }
            });
          });
        },
        text: S.of(context).payLater,
        icon: Icons.delivery_dining_outlined,
        states: [ref.watch(receiptControllerProvider).payDeliveryRequestState],
        isDisabled: saleController.basketItems.isEmpty ||
            saleController.selectedTable != null);
  }
}
