import 'package:desktoppossystem/controller/global_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/purchases_screen/new_purchase_controller.dart';
import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
import 'package:desktoppossystem/shared/constances/app_constances.dart';
import 'package:desktoppossystem/shared/default%20components/app_text_form_field.dart';
import 'package:desktoppossystem/shared/default%20components/custom_toggle_button.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/default%20components/elevated_button_widget.dart';
import 'package:desktoppossystem/shared/default%20components/product_cost_by_supplier_chart.dart';
import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/services/scroll_behavior_service.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PurchasesProductList extends ConsumerStatefulWidget {
  const PurchasesProductList({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PurchasesProductListState();
}

class _PurchasesProductListState extends ConsumerState<PurchasesProductList> {
  late ScrollController _scrollController;
  late Map<int, TextEditingController> qtyControllers;
  late Map<int, FocusNode>
  qtyFocusNodes; // Map to hold FocusNode for each product

  @override
  void initState() {
    super.initState();
    qtyControllers = {};
    qtyFocusNodes = {};

    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    qtyControllers.forEach((key, controller) {
      controller.dispose();
    });
    qtyFocusNodes.forEach((key, focusNode) {
      focusNode.dispose();
    });
    super.dispose();
  }

  void animateListViewToEnd() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final invoiceState = ref.watch(newInvoiceProvider);
    final invoiceNotifier = ref.read(newInvoiceProvider.notifier);
    final dolarRate = ref.read(saleControllerProvider).dolarRate;

    ref.listen<PurchaseState>(newInvoiceProvider, (previous, next) {
      if (next.purchasesProducts.length >
          (previous?.purchasesProducts.length ?? 0)) {
        animateListViewToEnd();
      }
    });
    return ScrollConfiguration(
      behavior: MyCustomScrollBehavior(),
      child: ListView.builder(
        controller: _scrollController,
        itemCount: invoiceState.purchasesProducts.length,
        itemBuilder: (context, index) {
          final product = invoiceState.purchasesProducts[index];

          if (!qtyControllers.containsKey(product.id)) {
            qtyControllers[product.id] = TextEditingController(
              text: product.qty.toString(), // Set initial value to product.qty
            );

            qtyFocusNodes[product.id] =
                FocusNode(); // Initialize FocusNode for this product
          }
          return Card(
            elevation: 10,
            shadowColor: ref.read(isDarkModeProvider)
                ? Pallete.primaryColor
                : null,
            color: context.cardColor,
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
            child: ListTile(
              title: Row(
                children: [
                  DefaultTextView(text: "${index + 1} )"),
                  SizedBox(
                    width: 350,
                    child: AppTextFormField(
                      controller: product.nameController,
                      onchange: (val) {
                        invoiceNotifier.onChangeName(product.id, val);
                      },
                    ),
                  ),
                  DefaultTextView(
                    text:
                        "(old qty :${product.oldQty} - old cost :${product.oldCostPrice} ${AppConstance.primaryCurrency.currencyLocalization()})",
                  ),
                  kGap10,
                  ElevatedButtonWidget(
                    states: [
                      ref
                                  .watch(globalControllerProvider)
                                  .downloadProductHistoryId ==
                              product.id
                          ? ref
                                .watch(globalControllerProvider)
                                .openProductHistoryRequestState
                          : RequestState.success,
                    ],
                    text: "History",
                    height: 30,
                    icon: FontAwesomeIcons.fileExcel,
                    color: Pallete.greenColor,
                    onPressed: () async {
                      await ref
                          .read(globalControllerProvider)
                          .openProductHistoryInExcel(productId: product.id);
                    },
                  ),
                  kGap5,
                  Tooltip(
                    message: "history chart",
                    child: ElevatedButtonWidget(
                      width: 35,
                      icon: FontAwesomeIcons.chartLine,
                      color: Pallete.redColor,
                      onPressed: () async {
                        ref.refresh(productHistoryProvider(product.id));
                        openWidgetInLargeDialog(
                          context,
                          ProductCostBySupplierChart(productId: product.id),
                        );
                      },
                      text: null,
                    ),
                  ),
                  const Spacer(),
                  SelectableText("${product.barcode}"),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: .start,
                children: [
                  Row(
                    crossAxisAlignment: .start,
                    children: [
                      kGap15,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: .start,
                          children: [
                            Stack(
                              children: [
                                AppTextFormField(
                                  ontap: () {
                                    FocusScope.of(
                                      context,
                                    ).requestFocus(product.costPriceFocusNode);

                                    product.costPriceController?.selection =
                                        TextSelection(
                                          baseOffset: 0,
                                          extentOffset: product
                                              .costPriceController!
                                              .text
                                              .length,
                                        );
                                    // Explicitly request focus on the cost price field to prevent other fields from gaining focus
                                  },
                                  focusNode: product.costPriceFocusNode,
                                  format: numberTextFormatter,
                                  controller: product.costPriceController,
                                  inputtype: TextInputType.number,
                                  onchange: (value) {
                                    final newCost =
                                        double.tryParse(value.toString()) ??
                                        product.costPrice ??
                                        0;
                                    invoiceNotifier.onChangeCost(
                                      product.id,
                                      newCost,
                                    );
                                  },
                                ),
                                Positioned(
                                  right: isEnglishLanguage ? 5 : null,
                                  left: isEnglishLanguage ? null : 5,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 2,
                                        color: Pallete.greyColor,
                                        height: 48,
                                      ),
                                      kGap5,
                                      DefaultTextView(
                                        text: S.of(context).costPrice,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            if (product.newAverageCost != null)
                              DefaultTextView(
                                fontSize: 13,
                                text:
                                    "new avg cost : ${product.newAverageCost} (Saved to Stock)",
                                color: Pallete.redColor,
                              ).withTooltip(
                                msg:
                                    "new avg cost : ${product.newAverageCost} (Saved to Stock)",
                              ),
                          ],
                        ),
                      ),
                      kGap10,
                      Expanded(
                        child: AppTextFormField(
                          focusNode: product.profitFocusNode,
                          ontap: () {
                            product.profitRateController?.selection =
                                TextSelection(
                                  baseOffset: 0,
                                  extentOffset:
                                      product.profitRateController!.text.length,
                                );
                          },
                          suffixIcon: const Icon(Icons.percent),
                          format: numberTextFormatter,
                          hinttext: S.of(context).profitRate,
                          controller: product.profitRateController,
                          inputtype: TextInputType.number,
                          onchange: (value) {
                            final newRate =
                                double.tryParse(value.toString()) ??
                                product.profitRate ??
                                0;
                            invoiceNotifier.onChangeProfitRate(
                              product.id,
                              newRate,
                            );
                          },
                        ),
                      ),
                      kGap10,
                      Expanded(
                        child: Column(
                          crossAxisAlignment: .start,
                          children: [
                            Stack(
                              children: [
                                AppTextFormField(
                                  ontap: () {
                                    product.sellingPriceController?.selection =
                                        TextSelection(
                                          baseOffset: 0,
                                          extentOffset: product
                                              .sellingPriceController!
                                              .text
                                              .length,
                                        );
                                  },
                                  focusNode: product.sellingPriceFocusNode,
                                  format: numberTextFormatter,
                                  controller: product.sellingPriceController,
                                  inputtype: TextInputType.number,
                                  suffixIcon: CustomToggleButton(
                                    text1: AppConstance.primaryCurrency,
                                    text2: AppConstance.secondaryCurrency,
                                    isSelected: product.sellingInPrimary!,
                                    onPressed: (index) {
                                      invoiceNotifier.toggleSellingCurrency(
                                        product.id,
                                      );
                                    },
                                  ),
                                  onchange: (value) {
                                    final newSelling = double.tryParse(
                                      value.toString(),
                                    ).validateDouble();
                                    invoiceNotifier.onchangeSellingPrice(
                                      sellingPrice: newSelling,
                                      productId: product.id,
                                    );
                                  },
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                DefaultTextView(
                                  fontSize: 12,
                                  text: S.of(context).sellingPrice,
                                  color: Pallete.redColor,
                                ),
                                Flexible(
                                  child:
                                      DefaultTextView(
                                        fontSize: 12,
                                        color: Pallete.redColor,
                                        text:
                                            " => ${product.sellingInPrimary! ? (product.sellingPrice! * dolarRate).formatAmountNumber() : '${(product.sellingPrice!).formatDouble()}'} ${product.sellingInPrimary == true ? AppConstance.secondaryCurrency.currencyLocalization() : AppConstance.primaryCurrency.currencyLocalization()}",
                                      ).withTooltip(
                                        msg:
                                            "${product.sellingInPrimary! ? (product.sellingPrice! * dolarRate).formatAmountNumber() : '${(product.sellingPrice!).formatDouble()}'} ${product.sellingInPrimary == true ? AppConstance.secondaryCurrency.currencyLocalization() : AppConstance.primaryCurrency.currencyLocalization()}",
                                      ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      kGap10,
                      Expanded(
                        child: Stack(
                          children: [
                            AppTextFormField(
                              format: numberTextFormatter,
                              focusNode: qtyFocusNodes[product.id],
                              controller:
                                  qtyControllers[product
                                      .id], // Use the TextEditingController
                              ontap: () {
                                FocusScope.of(
                                  context,
                                ).requestFocus(qtyFocusNodes[product.id]);

                                qtyControllers[product.id]
                                    ?.selection = TextSelection(
                                  baseOffset: 0,
                                  extentOffset:
                                      qtyControllers[product.id]!.text.length,
                                );
                                // Explicitly request focus on the cost price field to prevent other fields from gaining focus
                              },
                              inputtype: TextInputType.number,
                              onchange: (value) {
                                final newQty =
                                    double.tryParse(value.toString()) ??
                                    product.qty;
                                invoiceNotifier.updateQuantity(
                                  productId: product.id,
                                  newQty: newQty ?? 0,
                                );
                              },
                            ),
                            Positioned(
                              right: isEnglishLanguage ? 5 : null,
                              left: isEnglishLanguage ? null : 5,
                              child: Row(
                                children: [
                                  Container(
                                    width: 2,
                                    color: Pallete.greyColor,
                                    height: 48,
                                  ),
                                  kGap5,
                                  DefaultTextView(text: S.of(context).qty),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  invoiceNotifier.removeProduct(product.id);
                  qtyControllers.remove(product.id);
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
