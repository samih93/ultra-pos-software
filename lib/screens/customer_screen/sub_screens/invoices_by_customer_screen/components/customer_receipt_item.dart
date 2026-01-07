import 'package:desktoppossystem/controller/customer_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/receipt_model.dart';
import 'package:desktoppossystem/repositories/receipts/receiptrepository.dart';
import 'package:desktoppossystem/screens/customer_screen/sub_screens/invoices_by_customer_screen/components/customer_receipt_list.dart';
import 'package:desktoppossystem/screens/daily%20sales/components/receipt_details_dialog.dart';
import 'package:desktoppossystem/shared/default%20components/app_text_form_field.dart';
import 'package:desktoppossystem/shared/default%20components/are_you_sure_dialog.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/default%20components/elevated_button_widget.dart';
import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CustomerReceiptItem extends ConsumerStatefulWidget {
  const CustomerReceiptItem({required this.receiptModel, super.key});
  final ReceiptModel receiptModel;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CustomerReceiptItemState();
}

class _CustomerReceiptItemState extends ConsumerState<CustomerReceiptItem> {
  late TextEditingController remainingTextController;
  @override
  void initState() {
    super.initState();
    remainingTextController = TextEditingController();
    remainingTextController.text =
        widget.receiptModel.remainingAmount.toString();
  }

  @override
  void dispose() {
    remainingTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return ColoredBox(
      color: widget.receiptModel.isHasDiscount == true
          ? Colors.red.shade100
          : Colors.transparent,
      child: Stack(
        alignment: AlignmentDirectional.centerStart,
        children: [
          Row(
            children: [
              Expanded(
                  child: Center(
                      child: DefaultTextView(
                text: '#1-${widget.receiptModel.id.toString()}',
              ))),
              Expanded(
                  flex: 2,
                  child: Center(
                      child: DefaultTextView(
                          text: DateTime.parse(widget.receiptModel.receiptDate)
                              .formatDateTime12Hours()))),
              Expanded(
                  child: Center(
                child: DefaultTextView(
                  text: widget.receiptModel.foreignReceiptPrice
                      .validateDouble()
                      .formatDouble()
                      .toString(),
                ),
              )),
              Expanded(
                  child: Center(
                child: DefaultTextView(
                  text: widget.receiptModel.localReceiptPrice
                      .validateDouble()
                      .formatAmountNumber(),
                ),
              )),
              Expanded(
                  child: Center(
                child: DefaultTextView(
                  text: widget.receiptModel.remainingAmount
                      .formatDouble()
                      .toString(),
                ),
              )),
              SizedBox(
                width: 30,
                child: ElevatedButtonWidget(
                  onPressed: () async {
                    showDialog(
                      context: context,
                      builder: (context) => ReceiptDetailsDialog(
                          receiptModel: widget.receiptModel),
                    );
                  },
                  text: "",
                  icon: Icons.info_outline_rounded,
                ),
              )
            ],
          ),
          if (widget.receiptModel.isPaid != true &&
              widget.receiptModel.remainingAmount! > 0)
            ElevatedButtonWidget(
                width: 30,
                text: S.of(context).pay,
                color: Pallete.redColor,
                radius: 5,
                onPressed: () async {
                  showDialog(
                      context: context,
                      builder: (context) => AreYouSureDialog(
                          "${S.of(context).areYouSurePay}  ${widget.receiptModel.id}",
                          onAgree: () {
                            double remaining = double.tryParse(
                                    remainingTextController.text.trim()) ??
                                0;
                            final newRemainingAmount =
                                widget.receiptModel.remainingAmount! -
                                    remaining;
                            ref
                                .read(receiptProviderRepository)
                                .payRemainingAmount(
                                    receipt: widget.receiptModel,
                                    value: remaining)
                                .whenComplete(() {
                              ref.refresh(invoicesByCustomerProvider(
                                  ReceiptRequest(
                                      customerId:
                                          widget.receiptModel.customerId!,
                                      status: ref.read(
                                          selectedReceiptStatusProvider))));
                              remainingTextController.text =
                                  newRemainingAmount.toString();

                              context.pop();
                            });
                          },
                          content: Column(
                            children: [
                              DefaultTextView(
                                text:
                                    "${S.of(context).remaining} ${widget.receiptModel.remainingAmount}",
                                color: Pallete.redColor,
                              ),
                              AppTextFormField(
                                format: numberTextFormatter,
                                controller: remainingTextController,
                                hinttext: S.of(context).remaining,
                              ),
                            ],
                          ),
                          onCancel: () => context.pop(),
                          agreeText: S.of(context).pay));
                }),
        ],
      ),
    );
  }
}
