// ignore_for_file: unused_result

import 'package:desktoppossystem/controller/customer_controller.dart';
import 'package:desktoppossystem/controller/subscription_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/customers_model.dart';
import 'package:desktoppossystem/models/receipt_model.dart';
import 'package:desktoppossystem/screens/customer_screen/components/add_subscription_dialog.dart';
import 'package:desktoppossystem/screens/customer_screen/components/edit_customer_dialog.dart';
import 'package:desktoppossystem/screens/customer_screen/sub_screens/invoices_by_customer_screen/components/customer_receipt_list.dart';
import 'package:desktoppossystem/screens/customer_screen/sub_screens/invoices_by_customer_screen/invoices_by_customer_screen.dart';
import 'package:desktoppossystem/shared/default%20components/app_squared_outlined_button.dart';
import 'package:desktoppossystem/shared/default%20components/are_you_sure_dialog.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../main_screen.dart/main_controller.dart';

class CustomerItem extends ConsumerWidget {
  const CustomerItem(this.customerModel, {super.key});

  final CustomerModel customerModel;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.only(bottom: 5),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(width: 0.5, color: Colors.grey)),
      ),
      margin: const EdgeInsets.only(bottom: 5),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: DefaultTextView(text: "${customerModel.name}"),
          ),
          Expanded(
            child: DefaultTextView(text: "${customerModel.phoneNumber}"),
          ),
          Expanded(
            flex: 2,
            child: DefaultTextView(text: "${customerModel.address}"),
          ),
          Expanded(child: DefaultTextView(text: "${customerModel.discount} %")),
          Expanded(
            flex: 3,
            child: Row(
              spacing: 10,
              children: [
                AppSquaredOutlinedButton(
                  size: const Size(70, 38),
                  child: DefaultTextView(
                    text: S.of(context).invoices,
                    color: Pallete.blackColor,
                  ),
                  onPressed: () {
                    ref.refresh(topSellingProductProvider(customerModel.id!));
                    ref.refresh(
                      invoicesByCustomerProvider(
                        ReceiptRequest(
                          customerId: customerModel.id!,
                          status: ref.read(selectedReceiptStatusProvider),
                        ),
                      ),
                    );
                    ref.refresh(
                      revenuAndProfitByCustomerProvider(customerModel.id!),
                    );
                    context.to(
                      InvoicesByCustomerScreen(customer: customerModel),
                    );
                  },
                ),
                AppSquaredOutlinedButton(
                  states: [ref.watch(subscriptionControllerProvider).state],
                  size: const Size(120, 38),
                  child: const Row(
                    children: [
                      Icon(Icons.add),
                      DefaultTextView(
                        color: Pallete.blackColor,
                        text: "subscription",
                      ),
                    ],
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) =>
                          AddSubscriptionDialog(customerModel: customerModel),
                    );
                  },
                ),
                AppSquaredOutlinedButton(
                  child: const Icon(FontAwesomeIcons.penToSquare),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => EditCustomerDialog(
                        customerModel,
                        isInCustomerScreen: true,
                      ),
                    );
                  },
                ),
                if (ref.watch(mainControllerProvider).isAdmin)
                  AppSquaredOutlinedButton(
                    child: const Icon(Icons.delete, color: Pallete.redColor),
                    onPressed: () async {
                      showDialog(
                        context: context,
                        builder: (context) {
                          RequestState deleteRequest = RequestState.success;
                          return StatefulBuilder(
                            builder: (context, setState) {
                              return AreYouSureDialog(
                                agreeText: S.of(context).delete,
                                onCancel: () => context.pop(),
                                "${S.of(context).areYouSureDelete} '${customerModel.name}' ${S.of(context).quetionMark}",
                                agreeState: deleteRequest,
                                onAgree: () async {
                                  setState(() {
                                    deleteRequest = RequestState.loading;
                                  });
                                  await ref
                                      .read(customerControllerProvider)
                                      .deleteCustomerByI(
                                        customerModel.id!,
                                        context,
                                      )
                                      .whenComplete(() {
                                        setState(() {
                                          deleteRequest = RequestState.success;
                                        });
                                      });
                                },
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
