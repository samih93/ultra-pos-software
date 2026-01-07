import 'package:desktoppossystem/controller/auth_controller.dart';
import 'package:desktoppossystem/controller/global_controller.dart';
import 'package:desktoppossystem/controller/receipt_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/receipt_model.dart';
import 'package:desktoppossystem/models/user_model.dart';
import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
import 'package:desktoppossystem/screens/sale_screens/shared_components/order_type_section.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/default%20components/elevated_button_widget.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuotationDialog extends ConsumerWidget {
  const QuotationDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var saleController = ref.watch(saleControllerProvider);
    UserModel usermodel =
        ref.watch(currentUserProvider) ?? UserModel.fakeUser();
    ReceiptModel receiptModel = ReceiptModel(
      orderType: ref.read(selectedOrderTypeProvider),
      foreignReceiptPrice: saleController.foreignTotalPrice,
      localReceiptPrice: saleController.localTotalPrice,
      receiptDate: DateTime.now().toString(),
      userId: usermodel.id,
      dollarRate: ref.read(saleControllerProvider).dolarRate,
      paymentType: PaymentType.cash,
      shiftId: ref.read(currentShiftProvider).id!,
      customerId: saleController.customerModel?.id,
      isHasDiscount: saleController.basketItems.any((e) => e.discount! > 0),
    );
    receiptModel.customerModel = saleController.customerModel;

    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300),
        child: IntrinsicHeight(
          child: AlertDialog(
            title: Center(
              child: DefaultTextView(
                text: S.of(context).quotation,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButtonWidget(
                  text: S.of(context).download,
                  height: 60,
                  color: Pallete.redColor,
                  states: [
                    ref
                        .watch(globalControllerProvider)
                        .openInvoiceAsPdfRequestState,
                  ],
                  icon: Icons.picture_as_pdf,
                  onPressed: () async {
                    await ref
                        .read(globalControllerProvider)
                        .openInvoiceAsPdf(
                          isQuotation: true,
                          receiptModel,
                          saleController.basketItems,
                        )
                        .whenComplete(() {
                          context.pop();
                        });
                  },
                ),
                kGap10,
                ElevatedButtonWidget(
                  text: S.of(context).print,
                  height: 60,
                  states: [
                    ref
                        .watch(receiptControllerProvider)
                        .printQuotationRequestState,
                  ],
                  icon: Icons.print,
                  onPressed: () async {
                    await ref
                        .read(receiptControllerProvider)
                        .printQuotation(
                          receiptModel,
                          saleController.basketItems,
                          context: context,
                        )
                        .whenComplete(() {
                          context.pop();
                        });
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
