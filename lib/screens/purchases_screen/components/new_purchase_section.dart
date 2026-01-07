import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/add_edit_product/add_edit_product_screen.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/screens/purchases_screen/components/pruchases_product_list.dart';
import 'package:desktoppossystem/screens/purchases_screen/new_purchase_controller.dart';
import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
import 'package:desktoppossystem/shared/constances/app_constances.dart';
import 'package:desktoppossystem/shared/default%20components/are_you_sure_dialog.dart';
import 'package:desktoppossystem/shared/default%20components/auto_complete_product.dart';
import 'package:desktoppossystem/shared/default%20components/auto_complete_supplier.dart';
import 'package:desktoppossystem/shared/default%20components/default_price_text.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/default%20components/elevated_button_widget.dart';
import 'package:desktoppossystem/shared/default%20components/app_text_form_field.dart';
import 'package:desktoppossystem/shared/default%20components/short_toast_message.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NewPurchaseSection extends ConsumerStatefulWidget {
  const NewPurchaseSection({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NewPurchaseSectionState();
}

class _NewPurchaseSectionState extends ConsumerState<NewPurchaseSection> {
  late TextEditingController _invoiceIdController;

  @override
  void initState() {
    super.initState();
    // Initialize controller with current state
    final invoiceState = ref.read(newInvoiceProvider);
    _invoiceIdController = TextEditingController(text: invoiceState.refId);
  }

  @override
  void dispose() {
    _invoiceIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final invoiceState = ref.watch(newInvoiceProvider);
    final invoiceNotifier = ref.read(newInvoiceProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: FittedBox(
                  alignment: ref.watch(mainControllerProvider).isLtr
                      ? Alignment.centerLeft
                      : Alignment.centerRight,
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      AppPriceText(
                        fontSize: 20,
                        color: Pallete.redColor,
                        text:
                            "${S.of(context).totalAmount}:  ${invoiceState.totalCost.formatDouble()}",
                        unit: AppConstance.primaryCurrency,
                      ),
                      AppPriceText(
                        fontSize: 20,
                        color: Pallete.redColor,
                        text:
                            " / ${(invoiceState.totalCost.formatDouble() * ref.read(saleControllerProvider).dolarRate).formatAmountNumber()}",
                        unit: AppConstance.secondaryCurrency,
                      ),
                      kGap5,
                      DefaultTextView(
                        text:
                            ",  ${S.of(context).qty}: ${invoiceState.totalQty}",
                        fontSize: 20,
                      ),
                    ],
                  ),
                ),
              ),
              kGap10,
              Expanded(
                flex: 1,
                child: AppTextFormField(
                  controller: _invoiceIdController,
                  hinttext: S.of(context).refId,
                  onchange: (value) {
                    invoiceNotifier.setrefId(value.validateString());
                  },
                ),
              ),
              kGap10,
              DefaultTextView(
                text:
                    "${DateTime.parse(invoiceState.date.toString()).toNormalDate()}",
                fontWeight: FontWeight.bold,
              ),
              IconButton(
                onPressed: () {
                  showDatePicker(
                    context: context,
                    currentDate: DateTime.now(),
                    initialDate:
                        DateTime.tryParse(invoiceState.date.toString()) ??
                        DateTime.now(),
                    firstDate: DateTime.now().subtract(
                      const Duration(days: 365 * 10),
                    ),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  ).then((value) {
                    var tdate = value?.toString().split(' ');
                    if (tdate != null) {
                      invoiceNotifier.setInvoiceDate(tdate[0]);
                    }
                  });
                },
                icon: const Icon(Icons.edit_calendar_sharp),
              ),
              kGap10,
              invoiceState.supplier != null
                  ? Row(
                      children: [
                        DefaultTextView(
                          fontSize: 20,
                          text:
                              "${S.of(context).supplier} : ${invoiceState.supplier!.name}",
                        ),
                        IconButton(
                          onPressed: () {
                            invoiceNotifier.removeSupplier();
                          },
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    )
                  : ElevatedButtonWidget(
                      text: S.of(context).supplier,
                      icon: Icons.search,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Center(
                              child: DefaultTextView(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                text:
                                    "${S.of(context).searchForASupplier.capitalizeFirstLetter()} ",
                              ),
                            ),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AutoCompleteSupplier(
                                  onSelectSupplier: (supplier) {
                                    ref
                                        .read(newInvoiceProvider.notifier)
                                        .setSuplier(supplier);
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
          ),

          // Invoice ID Field
          kGap5,

          Row(
            children: [
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    Expanded(
                      child: AutoCompleteProduct(
                        onProductSelected: (product) {
                          invoiceNotifier.addProduct(product);
                        },
                        onFieldSubmit: (product) {
                          invoiceNotifier.addProduct(product);
                        },
                      ),
                    ),
                    kGap20,
                    ElevatedButtonWidget(
                      text: S.of(context).addProductButton,
                      icon: Icons.add,
                      onPressed: () {
                        context.to(const AddEditProductScreen(null, null));
                      },
                    ),
                    kGap10,
                    ElevatedButtonWidget(
                      isDisabled: invoiceState.purchasesProducts.isEmpty,
                      text: S.of(context).continueLater,
                      onPressed: () {
                        invoiceNotifier.saveCurrentState();
                        shortToastMessage(
                          context,
                          "purchase saved successfully",
                          duration: const Duration(seconds: 2),
                        );
                      },
                    ),
                    kGap10,
                    ElevatedButtonWidget(
                      text: S.of(context).restoreSavedPurchase,
                      onPressed: () async {
                        final state = invoiceNotifier.loadSavedPurchase();

                        showDialog(
                          context: context,
                          builder: (context) =>
                              PurchaseDetailsDialog(purchaseState: state),
                        );
                      },
                    ),
                    kGap30,
                    ElevatedButtonWidget(
                      isDisabled:
                          _invoiceIdController.text.isEmpty ||
                          invoiceState.supplier == null ||
                          invoiceState.purchasesProducts.isEmpty ||
                          invoiceState.purchasesProducts.any((e) => e.qty == 0),
                      color: ref.read(isDarkModeProvider)
                          ? Pallete.whiteColor
                          : Pallete.greenColor,
                      text: S.of(context).save,
                      icon: Icons.save,
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            bool payFromCash = false; // Local boolean state
                            bool isPrimary = true;

                            return StatefulBuilder(
                              builder: (context, setState) {
                                return AreYouSureDialog(
                                  textColor: ref.read(isDarkModeProvider)
                                      ? Pallete.whiteColor
                                      : Pallete.greenColor,
                                  agreeText: S.of(context).save,
                                  "Are you sure you want to submit invoice?",
                                  onCancel: () {
                                    context.pop();
                                  },
                                  content: Row(
                                    children: [
                                      Expanded(
                                        child: CheckboxListTile(
                                          value: payFromCash,
                                          onChanged: (value) {
                                            setState(() {
                                              payFromCash =
                                                  value ??
                                                  false; // Update state
                                            });
                                          },
                                          title: DefaultTextView(
                                            text: S.of(context).payFromCash,
                                          ),
                                          controlAffinity:
                                              ListTileControlAffinity.leading,
                                        ),
                                      ),
                                    ],
                                  ),
                                  agreeState: invoiceState.requestState,
                                  onAgree: () async {
                                    // Use the payFromCash boolean here
                                    await invoiceNotifier
                                        .addInvoice(
                                          payFromCash: payFromCash,
                                          payInPrimary: isPrimary,
                                        )
                                        .whenComplete(() {
                                          _invoiceIdController.clear();
                                          context.pop();
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
          kGap10,

          // Product List
          const Expanded(child: PurchasesProductList()),
        ],
      ),
    );
  }
}

class PurchaseDetailsDialog extends ConsumerWidget {
  const PurchaseDetailsDialog({required this.purchaseState, super.key});

  final PurchaseState purchaseState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      content: SizedBox(
        width: context.width * 0.9,
        height: context.height * 0.8,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Purchase #${purchaseState.refId}",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: Row(
                    children: [
                      Text(
                        "Total Cost: \$${purchaseState.totalCost}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Total Qty: ${purchaseState.totalQty}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
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
                  _tableHeader("Seq"),
                  _tableHeader("Product", flex: 2),
                  _tableHeader("Old Qty"),
                  _tableHeader("Qty"),
                  _tableHeader("Old Price"),
                  _tableHeader("Price"),
                  _tableHeader("Total"),
                ],
              ),
            ),

            // List of Products in PurchaseState
            Expanded(
              child: ListView.builder(
                itemCount: purchaseState.purchasesProducts.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final item = purchaseState.purchasesProducts[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _tableCell("${index + 1}"),
                        _tableCell("${item.productName}", flex: 2),
                        _tableCell("${item.oldQty}"),
                        _tableCell("${item.qty}"),
                        _tableCell("${item.oldCostPrice}"),
                        _tableCell("${item.costPrice}"),
                        _tableCell(
                          "\$${(item.costPrice! * item.qty!).toStringAsFixed(2)}",
                          isHighlighted: true,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // Restore / Close Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (purchaseState.purchasesProducts.isNotEmpty)
                  ElevatedButtonWidget(
                    onPressed: () {
                      ref.read(newInvoiceProvider.notifier).restorePurchase();
                      context.pop();
                    },
                    text: S.of(context).restore,
                  ),
                ElevatedButtonWidget(
                  onPressed: () {
                    context.pop();
                  },
                  text: S.of(context).close,
                ),
              ],
            ),
          ],
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
