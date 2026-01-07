import 'dart:io';

import 'package:desktoppossystem/controller/printer_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/printer_model.dart';
import 'package:desktoppossystem/repositories/printer/printer_repository.dart';
import 'package:desktoppossystem/screens/error_section.dart';
import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
import 'package:desktoppossystem/screens/settings/components/sections/printer%20section/components/network_sections_printer.dart';
import 'package:desktoppossystem/shared/constances/app_constances.dart';
import 'package:desktoppossystem/shared/default%20components/custom_toggle_button.dart';
import 'package:desktoppossystem/shared/default%20components/custom_toggle_button_new.dart';
import 'package:desktoppossystem/shared/default%20components/default_list_tile.dart';
import 'package:desktoppossystem/shared/default%20components/default_prodgress_indicator.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/default%20components/elevated_button_widget.dart';
import 'package:desktoppossystem/shared/default%20components/app_text_form_field.dart';
import 'package:desktoppossystem/shared/default%20components/quiver_circular_indicator.dart';
import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:desktoppossystem/shared/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PrinterPropertiesSection extends ConsumerWidget {
  PrinterPropertiesSection({super.key});

  final List<double> basketFontSizeList = [
    13,
    14,
    15,
    16,
    17,
    18,
    19,
    20,
    22,
    24,
  ];
  final List<double> basketWidthList = [
    250,
    300,
    350,
    400,
    420,
    440,
    450,
    460,
    480,
    500,
    510,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var printercontroller = ref.watch(printerControllerProvider);
    return printercontroller.getPrinterSettingsRequestState ==
            RequestState.loading
        ? const SizedBox(width: 100, child: DefaultProgressIndicator())
        : Container(
            padding: kPadd10,
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: defaultRadius,
              border: Border.all(color: Colors.grey, width: 1),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DefaultTextView(
                      text: S.of(context).printerProperties,
                      color: context.primaryColor,
                      fontSize: 20,
                    ),
                    ElevatedButtonWidget(
                      icon: Icons.save,
                      text: S.of(context).save,
                      onPressed: () {
                        if (int.tryParse(
                              ref
                                  .read(printerControllerProvider)
                                  .receiptNumberTextController
                                  .text,
                            ) !=
                            null) {
                          ref
                              .read(saleControllerProvider)
                              .onSetReceiptNumber(
                                int.parse(
                                  ref
                                      .read(printerControllerProvider)
                                      .receiptNumberTextController
                                      .text,
                                ),
                              );
                        } else {
                          ToastUtils.showToast(
                            message: S.of(context).receiptMustBeNotEmpty,
                            type: RequestState.error,
                          );
                          return;
                        }

                        if (printercontroller.currentPrinterSettings.id !=
                            null) {
                          PrinterModel p = PrinterModel(
                            id: printercontroller.currentPrinterSettings.id,
                            modelName:
                                printercontroller.textPrinterController.text,
                            isprintReceipt: printercontroller.isprintReceipt,
                            isHasNetworkPrinter:
                                printercontroller.isHasNetworkPrinter,
                            pageSize: printercontroller.selectedSize.name
                                .toString(),
                          );
                          printercontroller.updatePrinter(p, context);
                        } else {
                          PrinterModel p = PrinterModel(
                            modelName:
                                printercontroller.textPrinterController.text,
                            isprintReceipt: printercontroller.isprintReceipt,
                            isHasNetworkPrinter:
                                printercontroller.isHasNetworkPrinter,
                            pageSize: printercontroller.selectedSize.name
                                .toString(),
                          );
                          printercontroller.addPrinter(p, context);
                        }
                      },
                    ),
                  ],
                ),
                const Divider(),
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        "${S.of(context).selectedPrinter} : ",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: AppTextFormField(
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () async {
                            showDialog(
                              context: context,
                              builder: (context) => PrinterSelectionDialog(
                                selectedSection: SectionType.bar,
                                onPrinterSelected: (String printerName) {
                                  printercontroller
                                      .connectToPrinter(printerName)
                                      .then((value) {
                                        globalAppContext.pop();
                                      });
                                },
                              ),
                            );
                          },
                        ),
                        hinttext:
                            "${S.of(context).printerModel.capitalizeFirstLetter()}",
                        inputtype: TextInputType.name,
                        controller: printercontroller.textPrinterController,
                        readonly: true,
                      ),
                    ),
                  ],
                ),
                if (Platform.isWindows)
                  DefaultListTile(
                    title: DefaultTextView(
                      text: "${S.of(context).networkPrinter} ",
                    ),
                    leading: const Icon(
                      Icons.print_rounded,
                      color: Colors.grey,
                    ),
                    trailing: CustomToggleButton(
                      text1: S.of(context).on.capitalizeFirstLetter(),
                      text2: S.of(context).off.capitalizeFirstLetter(),
                      isSelected:
                          printercontroller
                              .currentPrinterSettings
                              .isHasNetworkPrinter ==
                          true,
                      onPressed: (index) {
                        printercontroller.onchangeVisibilityNetworkPrinter();
                      },
                    ),
                  ),

                if (printercontroller
                        .currentPrinterSettings
                        .isHasNetworkPrinter ==
                    true)
                  const NetworkSectionsPrinter(),
                DefaultListTile(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: DefaultTextView(
                          textAlign: TextAlign.center,
                          fontSize: 16,
                          text: "${S.of(context).selectBasketFontSize} ",
                        ),
                        content: SizedBox(
                          height: 300,
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                kGap5,
                                ...basketFontSizeList.map((e) {
                                  return ListTile(
                                    trailing:
                                        printercontroller.basketFontSize ==
                                            basketFontSizeList[basketFontSizeList
                                                .indexOf(e)]
                                        ? Icon(
                                            Icons.check_circle,
                                            color: context.primaryColor,
                                          )
                                        : kEmptyWidget,
                                    title: DefaultTextView(text: e.toString()),
                                    onTap: () async {
                                      printercontroller.onchangeBasketFontSize(
                                        basketFontSizeList[basketFontSizeList
                                            .indexOf(e)],
                                      );

                                      context.pop();
                                    },
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  leading: const Icon(
                    Icons.font_download_sharp,
                    color: Colors.grey,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      DefaultTextView(
                        text: "${printercontroller.basketFontSize}",
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_outlined,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                  title: DefaultTextView(text: S.of(context).basketFontSize),
                ),
                DefaultListTile(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: DefaultTextView(
                          textAlign: TextAlign.center,
                          fontSize: 16,
                          text: S.of(context).selectBasketWidth,
                        ),
                        content: SizedBox(
                          height: 300,
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                kGap5,
                                ...basketWidthList.map((e) {
                                  return ListTile(
                                    trailing:
                                        printercontroller.basketWidth ==
                                            basketWidthList[basketWidthList
                                                .indexOf(e)]
                                        ? Icon(
                                            Icons.check_circle,
                                            color: context.primaryColor,
                                          )
                                        : kEmptyWidget,
                                    title: DefaultTextView(text: e.toString()),
                                    onTap: () async {
                                      printercontroller.onchangeBasketWidth(
                                        basketWidthList[basketWidthList.indexOf(
                                          e,
                                        )],
                                      );

                                      context.pop();
                                    },
                                  );
                                }),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  leading: const Icon(
                    Icons.font_download_sharp,
                    color: Colors.grey,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      DefaultTextView(text: "${printercontroller.basketWidth}"),
                      const Icon(
                        Icons.arrow_forward_ios_outlined,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                  title: DefaultTextView(text: S.of(context).basketwidth),
                ),
                if (Platform.isWindows)
                  DefaultListTile(
                    leading: const Icon(Icons.visibility, color: Colors.grey),
                    trailing: CustomToggleButton(
                      text1: S.of(context).on.capitalizeFirstLetter(),
                      text2: S.of(context).off.capitalizeFirstLetter(),
                      isSelected: printercontroller.showOpenCashButton,
                      onPressed: (index) {
                        printercontroller.onChangeButtonCashVisibility();
                      },
                    ),
                    title: DefaultTextView(
                      text: S.of(context).showOpenCashButton,
                    ),
                  ),

                DefaultListTile(
                  leading: const Icon(Icons.visibility, color: Colors.grey),
                  trailing: CustomToggleButton(
                    text1: S.of(context).on.capitalizeFirstLetter(),
                    text2: S.of(context).off.capitalizeFirstLetter(),
                    isSelected: printercontroller.openCashDialogOnPay,
                    onPressed: (index) {
                      printercontroller.onChangeOpenCashDialog();
                    },
                  ),
                  title: DefaultTextView(
                    text: S.of(context).openChangeDialogOnPay,
                  ),
                ),
                DefaultListTile(
                  leading: const Icon(Icons.print_rounded, color: Colors.grey),
                  trailing: CustomToggleButton(
                    text1: S.of(context).on.capitalizeFirstLetter(),
                    text2: S.of(context).off.capitalizeFirstLetter(),
                    isSelected:
                        printercontroller
                            .currentPrinterSettings
                            .isprintReceipt ==
                        true,
                    onPressed: (index) {
                      printercontroller.onchangePrintingStatus();
                    },
                  ),
                  title: DefaultTextView(
                    text:
                        "${S.of(context).printReceipt} ${S.of(context).quetionMark} ",
                  ),
                ),
                DefaultListTile(
                  leading: const Icon(Icons.print_rounded, color: Colors.grey),
                  trailing: CustomToggleButton(
                    text1: S.of(context).on.capitalizeFirstLetter(),
                    text2: S.of(context).off.capitalizeFirstLetter(),
                    isSelected:
                        ref
                            .watch(printerControllerProvider)
                            .isPrintBasketInDolar ==
                        true,
                    onPressed: (index) {
                      ref
                          .read(printerControllerProvider)
                          .togglePrintBasketInDolar();
                    },
                  ),
                  title: DefaultTextView(
                    text:
                        "${S.of(context).printBasketIn} ${AppConstance.primaryCurrency.currencyLocalization()} ${S.of(context).quetionMark} ",
                  ),
                ),

                //! print receipt usd
                DefaultListTile(
                  leading: const Icon(Icons.print_rounded, color: Colors.grey),
                  trailing: CustomToggleButton(
                    text1: S.of(context).on.capitalizeFirstLetter(),
                    text2: S.of(context).off.capitalizeFirstLetter(),
                    isSelected:
                        ref
                            .watch(printerControllerProvider)
                            .isPrintReceiptInDolar ==
                        true,
                    onPressed: (index) {
                      ref
                          .read(printerControllerProvider)
                          .togglePrintReceiptInDolar();
                    },
                  ),
                  title: DefaultTextView(
                    text:
                        "${S.of(context).printReceipt} ${AppConstance.primaryCurrency.currencyLocalization()} ${S.of(context).quetionMark} ",
                  ),
                ),

                //! print receipt local
                DefaultListTile(
                  leading: const Icon(Icons.print_rounded, color: Colors.grey),
                  trailing: CustomToggleButton(
                    text1: S.of(context).on.capitalizeFirstLetter(),
                    text2: S.of(context).off.capitalizeFirstLetter(),
                    isSelected:
                        ref
                            .watch(printerControllerProvider)
                            .isPrintReceiptInLebanon ==
                        true,
                    onPressed: (index) {
                      ref
                          .read(printerControllerProvider)
                          .onchangePrintReceiptInLocal();
                    },
                  ),
                  title: DefaultTextView(
                    text:
                        "${S.of(context).printReceipt} ${AppConstance.secondaryCurrency.currencyLocalization()} ${S.of(context).quetionMark} ",
                  ),
                ),

                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        S.of(context).receiptNumber,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: AppTextFormField(
                        format: numberTextFormatter,
                        controller:
                            printercontroller.receiptNumberTextController,
                        inputtype: TextInputType.name,
                        hinttext: S.of(context).receiptNumber,
                        onvalidate: (value) {
                          if (value!.isEmpty) {
                            return S.of(context).receiptMustBeNotEmpty;
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                //! print label on label printer
                //! print receipt local
                if (context.isWindows) ...[
                  DefaultListTile(
                    onTap: () {
                      printercontroller.togglePrintLabelOnInvoice();
                    },
                    leading: const Icon(
                      Icons.print_rounded,
                      color: Colors.grey,
                    ),
                    trailing: CustomToggleButton(
                      text1: S.of(context).on.capitalizeFirstLetter(),
                      text2: S.of(context).off.capitalizeFirstLetter(),
                      isSelected:
                          printercontroller.isPrintLabelOnLabelPrinter == true,
                      onPressed: (index) {
                        printercontroller.togglePrintLabelOnInvoice();
                      },
                    ),
                    title: DefaultTextView(
                      text:
                          "${S.of(context).printLabelOnLabelPrinter} ${S.of(context).quetionMark}",
                    ),
                  ),
                  DefaultListTile(
                    onTap: () {
                      printercontroller.togglePrintStoreNameOnLabel();
                    },
                    leading: const Icon(
                      Icons.print_rounded,
                      color: Colors.grey,
                    ),
                    trailing: CustomToggleButton(
                      text1: S.of(context).on.capitalizeFirstLetter(),
                      text2: S.of(context).off.capitalizeFirstLetter(),
                      isSelected:
                          printercontroller.printStoreNameOnLabel == true,
                      onPressed: (index) {
                        printercontroller.togglePrintStoreNameOnLabel();
                      },
                    ),
                    title: DefaultTextView(
                      text:
                          "${S.of(context).printStoreNameOnLabel} ${S.of(context).quetionMark}",
                    ),
                  ),
                  DefaultListTile(
                    leading: const Icon(Icons.label, color: Colors.grey),
                    trailing: CustomToggleButtonNew(
                      labels: const ['Normal', '20x30', '10x25'],
                      selectedIndex: LabelSize.values.indexOf(
                        printercontroller.currentLabelSize,
                      ),
                      onPressed: (index) {
                        final selected = LabelSize.values[index];
                        printercontroller.toggleLabelSize(selected);
                      },
                    ),
                    title: DefaultTextView(text: S.of(context).labelType),
                  ),
                ],
              ],
            ),
          );
  }
}

class PrinterSelectionDialog extends ConsumerWidget {
  final SectionType selectedSection;
  final Function(String printerName) onPrinterSelected;

  const PrinterSelectionDialog({
    super.key,
    required this.selectedSection,
    required this.onPrinterSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      scrollable: true,
      title: const Center(
        child: DefaultTextView(
          text: "Select Printer",
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 500,
            child: StreamBuilder<List<PrinterModel>>(
              stream: ref.read(printerProviderRepository).listenToPrinters(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return ErrorSection(title: 'Error: ${snapshot.error}');
                }

                if (!snapshot.hasData) {
                  return const Center(child: CoreCircularIndicator());
                }

                final printers = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    ...List.generate(
                      printers.length,
                      (index) => Column(
                        children: [
                          InkWell(
                            onTap: () {
                              final printer = printers[index];
                              onPrinterSelected(printer.modelName.toString());
                              context.pop();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: DefaultTextView(
                                text: printers[index].modelName.toString(),
                                fontSize: 18,
                              ),
                            ),
                          ),
                          Divider(color: context.primaryColor),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
