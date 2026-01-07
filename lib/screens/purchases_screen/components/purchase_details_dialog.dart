import 'package:desktoppossystem/controller/invoices_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/invoice_model.dart';
import 'package:desktoppossystem/screens/error_section.dart';
import 'package:desktoppossystem/shared/constances/app_constances.dart';
import 'package:desktoppossystem/shared/default%20components/default_price_text.dart';
import 'package:desktoppossystem/shared/default%20components/default_prodgress_indicator.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/default%20components/elevated_button_widget.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PurchaseDetailsDialog extends ConsumerWidget {
  const PurchaseDetailsDialog({required this.invoice, super.key});
  final InvoiceModel invoice;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var invoiceDetails = ref.watch(invoiceDetailsProvider(invoice.id!));
    return AlertDialog(
      content: SizedBox(
        width: context.width * 0.9,
        height: context.height * 0.8,
        child: invoiceDetails.when(
          data: (data) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DefaultTextView(
                    text: "Invoice #${invoice.referenceId}",
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  Align(
                    alignment: Alignment.topRight,
                    child: Row(
                      children: [
                        AppPriceText(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          text: "${invoice.foreignPrice}",
                          unit: AppConstance.primaryCurrency
                              .currencyLocalization(),
                        ),
                        kGap10,
                        AppPriceText(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          text: invoice.localPrice.formatAmountNumber(),
                          unit: AppConstance.secondaryCurrency
                              .currencyLocalization(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(),

              // Table Header
              Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                color: Colors.blueGrey[100],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _tableHeader("seq"),
                    _tableHeader("Product", flex: 2),
                    _tableHeader("barcode"),
                    _tableHeader("Old Qty"),
                    _tableHeader("Qty"),
                    _tableHeader("Old Price"),
                    _tableHeader("Price"),
                    _tableHeader("Total"),
                  ],
                ),
              ),

              // List of Products in Invoice
              Expanded(
                child: ListView.builder(
                  itemCount: data.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) {
                    final item = data[index];
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _tableCell("${index + 1}"),
                          _tableCell("${item.productName}", flex: 2),
                          _tableCell("${item.barcode}"),
                          _tableCell("${item.oldQty}"),
                          _tableCell("${item.qty}"),
                          _tableCell("${item.oldCostPrice} "),
                          _tableCell("${item.costPrice} "),
                          _tableCell(
                            "\$${(item.costPrice! * item.qty!).formatDouble()} ${AppConstance.primaryCurrency.currencyLocalization()}",
                            isHighlighted: true,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              // Close Button
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButtonWidget(
                  text: S.of(context).close,
                  onPressed: () => context.pop(),
                ),
              ),
            ],
          ),
          error: (error, stackTrace) => ErrorSection(
            retry: () => ref.refresh(invoiceDetailsProvider(invoice.id!)),
          ),
          loading: () => const DefaultProgressIndicator(),
        ),
      ),
    );
  }

  // Helper function to create table header
  Widget _tableHeader(String title, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // Helper function to create table cell
  Widget _tableCell(String value, {int flex = 1, bool isHighlighted = false}) {
    return Expanded(
      flex: flex,
      child: Text(
        value,
        style: TextStyle(
          fontSize: 14,
          fontWeight: isHighlighted ? FontWeight.bold : FontWeight.normal,
          color: isHighlighted ? Colors.green : Colors.black87,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
