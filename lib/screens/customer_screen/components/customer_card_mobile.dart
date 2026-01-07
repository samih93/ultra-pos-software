// ignore_for_file: unused_result

import 'package:desktoppossystem/controller/subscription_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/customers_model.dart';
import 'package:desktoppossystem/screens/customer_screen/components/add_subscription_dialog.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../main_screen.dart/main_controller.dart';

class CustomerCardMobile extends ConsumerWidget {
  const CustomerCardMobile(this.customerModel, {super.key});

  final CustomerModel customerModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAdmin = ref.watch(mainControllerProvider).isAdmin;
    final subscriptionState = ref.watch(subscriptionControllerProvider).state;

    return Card(
      elevation: 2,
      color: Pallete.whiteColor,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: kRadius8,
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.3), width: 1),
      ),
      child: Padding(
        padding: kPadd15,
        child: Column(
          crossAxisAlignment: .start,
          children: [
            // Customer Name and Phone
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: .start,
                    children: [
                      DefaultTextView(
                        text: customerModel.name ?? 'N/A',
                        fontSize: 18,
                        color: Pallete.blackColor,
                        fontWeight: FontWeight.bold,
                      ),
                      if (customerModel.phoneNumber != null &&
                          customerModel.phoneNumber!.isNotEmpty) ...[
                        kGap5,
                        Row(
                          children: [
                            const Icon(
                              FontAwesomeIcons.phone,
                              size: 12,
                              color: Pallete.blackColor,
                            ),
                            kGap5,
                            DefaultTextView(
                              text: customerModel.phoneNumber!,
                              fontSize: 14,
                              color: Pallete.blackColor,
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                // Discount Badge
                if (customerModel.discount != null &&
                    customerModel.discount! > 0)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Pallete.greenColor.withValues(alpha: 0.15),
                      borderRadius: kRadius8,
                      border: Border.all(color: Pallete.greenColor, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          FontAwesomeIcons.percent,
                          size: 12,
                          color: Pallete.greenColor,
                        ),
                        kGap5,
                        DefaultTextView(
                          text: '${customerModel.discount}',
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Pallete.greenColor,
                        ),
                      ],
                    ),
                  ),
              ],
            ),

            // Address
            if (customerModel.address != null &&
                customerModel.address!.isNotEmpty) ...[
              kGap10,
              Row(
                children: [
                  const Icon(
                    FontAwesomeIcons.locationDot,
                    size: 12,
                    color: Pallete.blackColor,
                  ),
                  kGap8,
                  Expanded(
                    child: DefaultTextView(
                      text: customerModel.address!,
                      fontSize: 14,
                      color: Pallete.blackColor,
                    ),
                  ),
                ],
              ),
            ],

            kGap10,

            // Action Buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // // Invoices Button
                // _ActionButton(
                //   label: S.of(context).invoices,
                //   icon: FontAwesomeIcons.fileInvoice,
                //   color: Pallete.blueColor,
                //   onTap: () {
                //     ref.refresh(topSellingProductProvider(customerModel.id!));
                //     ref.refresh(
                //       invoicesByCustomerProvider(
                //         ReceiptRequest(
                //           customerId: customerModel.id!,
                //           status: ref.read(selectedReceiptStatusProvider),
                //         ),
                //       ),
                //     );
                //     ref.refresh(
                //       revenuAndProfitByCustomerProvider(customerModel.id!),
                //     );
                //     context.to(
                //       InvoicesByCustomerScreen(customer: customerModel),
                //     );
                //   },
                // ),

                // Add Subscription Button
                _ActionButton(
                  label: S.of(context).subscriptions,
                  icon: FontAwesomeIcons.plus,
                  color: Pallete.greenColor,
                  isLoading: subscriptionState == RequestState.loading,
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) =>
                          AddSubscriptionDialog(customerModel: customerModel),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isLoading;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: isLoading ? null : onTap,
      borderRadius: kRadius8,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: kRadius8,
          border: Border.all(color: color, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isLoading)
              SizedBox(
                width: 14,
                height: 14,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              )
            else
              Icon(icon, size: 14, color: color),
            kGap5,
            DefaultTextView(
              text: label,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ],
        ),
      ),
    );
  }
}
