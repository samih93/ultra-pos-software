import 'package:desktoppossystem/controller/invoices_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/error_section.dart';
import 'package:desktoppossystem/screens/purchases_screen/components/purchase_details_dialog.dart';
import 'package:desktoppossystem/shared/constances/app_constances.dart';
import 'package:desktoppossystem/shared/default%20components/auto_complete_supplier.dart';
import 'package:desktoppossystem/shared/default%20components/default_price_text.dart';
import 'package:desktoppossystem/shared/default%20components/default_prodgress_indicator.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/default%20components/elevated_button_widget.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PurchasesSection extends ConsumerWidget {
  const PurchasesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var futureInvoices = ref.watch(invoicesProvider);
    return Column(
      children: [
        Row(
          children: [
            const Spacer(),
            Row(
              children: [
                ElevatedButtonWidget(
                  icon: Icons.calendar_month,
                  onPressed: () {
                    showDatePicker(
                      context: context,
                      currentDate:
                          ref.watch(selectedDateInvoicesProvider) ??
                          DateTime.now(),
                      initialDate:
                          ref.watch(selectedDateInvoicesProvider) ??
                          DateTime.now(),
                      firstDate: DateTime.parse('2023-01-01'),
                      lastDate: DateTime.parse('2050-01-01'),
                    ).then((value) {
                      if (value != null) {
                        ref.read(selectedDateInvoicesProvider.notifier).state =
                            value;
                      }
                    });
                  },
                  text:
                      "${ref.watch(selectedDateInvoicesProvider) == null ? S.of(context).lastTwoMonths : ref.watch(selectedDateInvoicesProvider)!.mMMddyyyyFormat()}",
                ),
                Row(
                  children: [
                    if (ref.watch(selectedDateInvoicesProvider) != null)
                      IconButton(
                        onPressed: () {
                          ref
                                  .read(selectedDateInvoicesProvider.notifier)
                                  .state =
                              null;
                        },
                        icon: const Icon(Icons.close),
                      ),
                  ],
                ),
              ],
            ),
            if (ref.watch(selectedSupplierProvider) != null) ...[
              kGap15,
              Row(
                children: [
                  ElevatedButtonWidget(
                    text: ref.watch(selectedSupplierProvider)!.name,
                    icon: Icons.person_search_sharp,
                  ),
                  if (ref.watch(selectedSupplierProvider) != null)
                    IconButton(
                      onPressed: () {
                        ref.read(selectedSupplierProvider.notifier).state =
                            null;
                      },
                      icon: const Icon(Icons.close),
                    ),
                ],
              ),
            ],
            if (ref.watch(selectedSupplierProvider) == null) ...[
              kGap10,
              ElevatedButtonWidget(
                text: S.of(context).supplier,
                icon: Icons.search,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Center(
                        child: DefaultTextView(
                          text: S.of(context).searchForASupplier,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AutoCompleteSupplier(
                            onSelectSupplier: (supplier) {
                              ref
                                      .read(selectedSupplierProvider.notifier)
                                      .state =
                                  supplier;
                              context.pop();
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        futureInvoices.when(
          data: (data) {
            final invoices = data;
            return Expanded(
              child: ListView.builder(
                itemCount: invoices.length, // Replace with actual invoice count
                itemBuilder: (context, index) {
                  return Card(
                    child: ListTile(
                      title: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: .start,
                              children: [
                                DefaultTextView(
                                  text:
                                      '${S.of(context).refId} : ${invoices[index].referenceId}',
                                ),
                                DefaultTextView(
                                  text:
                                      '${S.of(context).date} : ${DateTime.parse(invoices[index].receiptDate.toString()).toNormalDate()}',
                                ),
                              ],
                            ),
                          ),
                          DefaultTextView(
                            text:
                                "${S.of(context).supplier} : ${invoices[index].supplierName}",
                            fontWeight: FontWeight.bold,
                          ),
                        ],
                      ),
                      subtitle: Row(
                        children: [
                          AppPriceText(
                            fontSize: 20,
                            color: Pallete.redColor,
                            text:
                                "${S.of(context).totalCost}: ${invoices[index].foreignPrice}",
                            unit: AppConstance.primaryCurrency,
                          ),
                          AppPriceText(
                            fontSize: 20,
                            color: Pallete.redColor,
                            text:
                                "  /  ${invoices[index].localPrice.formatAmountNumber()}",
                            unit: AppConstance.secondaryCurrency,
                          ),
                        ],
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () async {
                        final invoiceDetailsList = ref.read(
                          invoiceDetailsProvider(invoices[index].id!),
                        );

                        showDialog(
                          context: context,
                          builder: (context) =>
                              PurchaseDetailsDialog(invoice: invoices[index]),
                        );
                      },
                    ),
                  );
                },
              ),
            );
          },
          error: (error, stackTrace) => ErrorSection(
            retry: () {
              ref.refresh(invoicesProvider);
            },
          ),
          loading: () => const Center(child: DefaultProgressIndicator()),
        ),
      ],
    );
  }
}
