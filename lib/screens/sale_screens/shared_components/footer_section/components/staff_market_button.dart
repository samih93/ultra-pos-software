import 'package:desktoppossystem/controller/auth_controller.dart';
import 'package:desktoppossystem/controller/category_controller.dart';
import 'package:desktoppossystem/controller/receipt_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/receipt_model.dart';
import 'package:desktoppossystem/models/user_model.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
import 'package:desktoppossystem/shared/default%20components/elevated_button_widget.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/toast_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StaffMarketButton extends ConsumerWidget {
  const StaffMarketButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    UserModel usermodel = ref.read(currentUserProvider) ?? UserModel.fakeUser();
    final saleController = ref.watch(saleControllerProvider);
    return ref.read(mainControllerProvider).screenUI == ScreenUI.market &&
            saleController.basketItems.isNotEmpty &&
            saleController.basketItems.every((e) => e.discount == 100)
        ? ElevatedButtonWidget(
            text: S.of(context).forStaff,
            isDisabled:
                saleController.basketItems.isEmpty &&
                saleController.basketItems.any((e) => e.discount != 100),
            onPressed: () {
              ReceiptModel receiptModel = ReceiptModel(
                foreignReceiptPrice: saleController.foreignTotalPrice,
                localReceiptPrice: saleController.localTotalPrice,
                receiptDate: DateTime.now().toString(),
                userId: usermodel.id,
                dollarRate: ref.read(saleControllerProvider).dolarRate,
                paymentType: PaymentType.cash,
                shiftId: ref.read(currentShiftProvider).id!,
                customerId: saleController.customerModel?.id,
                //   discount: saleController.discount
              );
              receiptModel.customerModel = saleController.customerModel;
              ref
                  .read(receiptControllerProvider)
                  .pay(
                    receiptModel,
                    saleController.basketItems,
                    isForStaff: true,
                    context: context,
                  )
                  .then((invoiceId) async {
                    ref
                        .read(categoryControllerProvider)
                        .clearCategorySelection();
                    ref.read(saleControllerProvider).resetSaleScreen();
                    ToastUtils.showToast(
                      message: "Receipt Add successfully",
                      type: RequestState.success,
                    );
                  });
            },
          )
        : kEmptyWidget;
  }
}
