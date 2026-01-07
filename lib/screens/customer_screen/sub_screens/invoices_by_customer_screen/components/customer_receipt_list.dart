import 'package:desktoppossystem/controller/customer_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/customers_model.dart';
import 'package:desktoppossystem/models/receipt_model.dart';
import 'package:desktoppossystem/repositories/receipts/receiptrepository.dart';
import 'package:desktoppossystem/screens/customer_screen/sub_screens/invoices_by_customer_screen/components/customer_receipt_header.dart';
import 'package:desktoppossystem/screens/customer_screen/sub_screens/invoices_by_customer_screen/components/customer_receipt_item.dart';
import 'package:desktoppossystem/screens/error_section.dart';
import 'package:desktoppossystem/shared/constances/app_constances.dart';
import 'package:desktoppossystem/shared/default%20components/are_you_sure_dialog.dart';
import 'package:desktoppossystem/shared/default%20components/custom_toggle_button_new.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/default%20components/elevated_button_widget.dart';
import 'package:desktoppossystem/shared/default%20components/quiver_circular_indicator.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedReceiptStatusProvider = StateProvider<ReceiptStatus>((ref) {
  return ReceiptStatus.all; // Default value
});

class CustomerReceiptList extends ConsumerWidget {
  const CustomerReceiptList({required this.customer, super.key});

  final CustomerModel customer;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedStatus = ref.watch(selectedReceiptStatusProvider);

    final invoices = ref.watch(
      invoicesByCustomerProvider(
        ReceiptRequest(customerId: customer.id!, status: selectedStatus),
      ),
    );

    return invoices.when(
      data: (data) {
        final paidReceipts = data.fold(0.0, (sum, e) {
          if (e.isPaid == true) {
            return sum + (e.foreignReceiptPrice ?? 0);
          }
          return sum;
        });
        final unPaidReceipts = data.fold(0.0, (sum, e) {
          if (e.isPaid != true) {
            return sum + (e.remainingAmount ?? 0);
          }
          return sum;
        });

        return data.isNotEmpty
            ? Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      selectedStatus == ReceiptStatus.pending
                          ? ElevatedButtonWidget(
                              color: Pallete.redColor,
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AreYouSureDialog(
                                    "${S.of(context).areYouSurePayAllReceipts} ${S.of(context).quetionMark} ",
                                    onAgree: () {
                                      ref
                                          .read(receiptProviderRepository)
                                          .payAllReceiptsByCustomerId(
                                            customer,
                                            unPaidReceipts,
                                          )
                                          .whenComplete(() {
                                            context.pop();
                                            ref.refresh(
                                              invoicesByCustomerProvider(
                                                ReceiptRequest(
                                                  customerId: customer.id!,
                                                  status: ref.read(
                                                    selectedReceiptStatusProvider,
                                                  ),
                                                ),
                                              ),
                                            );
                                          });
                                    },
                                    onCancel: () => context.pop(),
                                    agreeText: S.of(context).pay,
                                  ),
                                );
                              },
                              text: "${S.of(context).pay} ${S.of(context).all}",
                            )
                          : kEmptyWidget,
                      CustomToggleButtonNew(
                        labels: [
                          S.of(context).all,
                          S.of(context).paid,
                          S.of(context).pending,
                        ],
                        selectedIndex: selectedStatus.index,
                        onPressed: (index) {
                          ref
                                  .read(selectedReceiptStatusProvider.notifier)
                                  .state =
                              ReceiptStatus.values[index];
                        },
                      ),
                    ],
                  ),
                  const CustomerReceiptHeader(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) {
                        final item = data[index];
                        return Column(
                          children: [
                            CustomerReceiptItem(
                              receiptModel: item,
                              key: ValueKey(item.id),
                            ),
                            if (index != data.length - 1) ...[
                              kGap5,
                              const Divider(
                                height: 0.7,
                                color: Pallete.greyColor,
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        padding: kPaddH5,
                        // width: 60,
                        width: 100,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Pallete.greenColor.withValues(alpha: 0.1),
                          shape: BoxShape.rectangle,
                          borderRadius: kRadius8,
                          border: Border.all(color: Pallete.greenColor),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.paid_outlined,
                                size: 25,
                                color: Pallete.greenColor,
                              ),
                              Text(
                                "${paidReceipts.formatDouble()} ${AppConstance.primaryCurrency.currencyLocalization()}",
                              ),
                            ],
                          ),
                        ),
                      ),
                      kGap10,
                      Container(
                        // width: 60,
                        width: 100,

                        height: 40,
                        padding: kPaddH5,
                        decoration: BoxDecoration(
                          color: Pallete.redColor.withValues(alpha: 0.1),
                          shape: BoxShape.rectangle,
                          borderRadius: kRadius8,
                          border: Border.all(color: Pallete.redColor),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.pending_actions,
                                size: 25,
                                color: Pallete.redColor,
                              ),
                              Text(
                                "${unPaidReceipts.formatDouble()} ${AppConstance.primaryCurrency.currencyLocalization()}",
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            : Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      kGap5,
                      CustomToggleButtonNew(
                        labels: [
                          S.of(context).all,
                          S.of(context).paid,
                          S.of(context).pending,
                        ],
                        selectedIndex: selectedStatus.index,
                        onPressed: (index) {
                          ref
                                  .read(selectedReceiptStatusProvider.notifier)
                                  .state =
                              ReceiptStatus.values[index];
                        },
                      ),
                    ],
                  ),
                  const Padding(
                    padding: kPadd15,
                    child: DefaultTextView(
                      text: "No invoices yet",
                      color: Pallete.greyColor,
                      fontSize: 20,
                    ),
                  ),
                ],
              );
      },
      error: (error, stackTrace) => ErrorSection(
        retry: () {
          ref.refresh(
            invoicesByCustomerProvider(
              ReceiptRequest(customerId: customer.id!, status: selectedStatus),
            ),
          );
        },
      ),
      loading: () {
        return const Center(child: CoreCircularIndicator());
      },
    );
  }
}
