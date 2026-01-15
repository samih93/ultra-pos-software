import 'package:desktoppossystem/controller/global_controller.dart';
import 'package:desktoppossystem/controller/printer_controller.dart';
import 'package:desktoppossystem/controller/product_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/product_model.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/screens/stock_screen/stock_controller.dart';
import 'package:desktoppossystem/shared/default%20components/are_you_sure_dialog.dart';
import 'package:desktoppossystem/shared/default%20components/cached_network_image_widget.dart';
import 'package:desktoppossystem/shared/default%20components/default_prodgress_indicator.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_form.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/default%20components/elevated_button_widget.dart';
import 'package:desktoppossystem/shared/default%20components/product_cost_by_supplier_chart.dart';
import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class StockItem extends ConsumerWidget {
  const StockItem(this.stockItem, this.index, {super.key});

  final ProductModel stockItem;
  final int index;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () async {
        if (stockItem.isActive == true) {
          await productAlertDialog(context, ref, stockItem, isFromStock: true);
        } else {
          showDialog(
            context: context,
            builder: (context) => AreYouSureDialog(
              textColor: Pallete.greenColor,
              agreeText: S.of(context).restore,
              agreeState: ref
                  .watch(productControllerProvider)
                  .restoreProductRequestState,
              onAgree: () async {
                await ref
                    .read(productControllerProvider)
                    .restoreProduct(stockItem.id!)
                    .whenComplete(() {
                      context.pop();
                    });
              },
              onCancel: () => context.pop(),
              "${S.of(context).areYouSureRestore} '${stockItem.name}'${S.of(context).quetionMark}",
            ),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 2.5),
        decoration: BoxDecoration(
          color: stockItem.isLowStock == true
              ? Colors.red.withValues(alpha: 0.2)
              : Colors.transparent,
          border: const Border(
            bottom: BorderSide(width: 0.5, color: Colors.grey),
          ),
        ),
        //margin: const EdgeInsets.only(bottom: 5),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  stockItem.image != null
                      ? Row(
                          children: [
                            CachedNetworkImageWidget(
                              imageUrl: stockItem.image!,
                              height: 40,
                              width: 40,
                            ),
                            kGap10,
                          ],
                        )
                      : kEmptyWidget,
                  Expanded(child: SelectableText("${stockItem.name}")),
                ],
              ),
            ),
            Expanded(child: SelectableText("${stockItem.barcode}")),
            Expanded(child: Text("${stockItem.expiryDate}")),
            if (ref.read(mainControllerProvider).isSuperAdmin)
              Expanded(child: Text("${stockItem.costPrice}")),
            Expanded(flex: 2, child: Text("${stockItem.sellingPrice}")),
            Expanded(
              child: Text(
                stockItem.isTracked == true
                    ? "${stockItem.qty!.formatDouble()}"
                    : "-",
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Tooltip(
                    message: "history chart",
                    child: ElevatedButtonWidget(
                      width: 35,
                      icon: FontAwesomeIcons.chartLine,
                      color: Pallete.redColor,
                      onPressed: () async {
                        ref.refresh(productHistoryProvider(stockItem.id!));
                        openWidgetInLargeDialog(
                          context,
                          ProductCostBySupplierChart(productId: stockItem.id!),
                        );
                      },
                      text: null,
                    ),
                  ),
                  kGap5,
                  Tooltip(
                    message: "Download product history",
                    child: ElevatedButtonWidget(
                      width: 35,
                      states: [
                        ref
                                    .watch(globalControllerProvider)
                                    .downloadProductHistoryId ==
                                stockItem.id
                            ? ref
                                  .watch(globalControllerProvider)
                                  .openProductHistoryRequestState
                            : RequestState.success,
                      ],
                      icon: FontAwesomeIcons.fileExcel,
                      color: Pallete.greenColor,
                      onPressed: () async {
                        await ref
                            .read(globalControllerProvider)
                            .openProductHistoryInExcel(
                              productId: stockItem.id!,
                            );
                      },
                      text: null,
                    ),
                  ),
                  kGap5,
                  if (context.isWindows)
                    Tooltip(
                      message: "Print barcode",
                      child: ElevatedButtonWidget(
                        width: 35,
                        icon: Icons.print,
                        text: null,
                        onPressed: () async {
                          var nbOfCopiesController = TextEditingController();
                          bool isloading = false;
                          showDialog(
                            context: context,
                            builder: (context) => StatefulBuilder(
                              builder: (context, labelPrintState) {
                                return AlertDialog(
                                  title: const Center(
                                    child: DefaultTextView(
                                      text: "Number Of Copies",
                                    ),
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      DefaultTextFormField(
                                        format: numberDigitFormatter,
                                        controller: nbOfCopiesController,
                                        hinttext: "Number of copies",
                                        inputtype: TextInputType.number,
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    isloading
                                        ? const Center(
                                            child: SizedBox(
                                              width: 80,
                                              child: DefaultProgressIndicator(),
                                            ),
                                          )
                                        : ElevatedButtonWidget(
                                            icon: Icons.print,
                                            states: [
                                              isloading
                                                  ? RequestState.loading
                                                  : RequestState.success,
                                            ],
                                            text: "Print",
                                            onPressed: () async {
                                              labelPrintState(() {
                                                isloading = true;
                                              });
                                              await printLabel(
                                                index: index,
                                                nbOfCopies:
                                                    int.tryParse(
                                                      nbOfCopiesController.text,
                                                    ) ??
                                                    1,
                                                context: context,
                                                ref: ref,
                                              ).then((value) {
                                                labelPrintState(() {
                                                  isloading = false;
                                                });
                                                context.pop();
                                              });
                                            },
                                          ),
                                  ],
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> printLabel({
    required int index,
    required int nbOfCopies,
    required BuildContext context,
    required WidgetRef ref,
  }) async {
    while (nbOfCopies > 0) {
      await ref
          .read(printerControllerProvider)
          .buildLabelTicket(
            productModel: ref.read(stockControllerProvider).stock[index],
          )
          .then((value) {
            //! send the bytes to the printer
            ref.read(printerControllerProvider).printReceipt(value);
          });
      nbOfCopies--;
    }

    // ! build ticket and return the bytes
  }
}
