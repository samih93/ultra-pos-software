import 'package:desktoppossystem/controller/global_controller.dart';
import 'package:desktoppossystem/controller/printer_controller.dart';
import 'package:desktoppossystem/controller/receipt_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/details_receipt.dart';
import 'package:desktoppossystem/models/product_model.dart';
import 'package:desktoppossystem/models/receipt_model.dart';
import 'package:desktoppossystem/screens/daily%20sales/components/deliver_package_dialog.dart';
import 'package:desktoppossystem/screens/daily%20sales/components/details_Receipt_dialog/build_details_receipt_item.dart';
import 'package:desktoppossystem/screens/daily%20sales/components/details_Receipt_dialog/build_header.dart';
import 'package:desktoppossystem/screens/daily%20sales/components/details_Receipt_dialog/build_result.dart';
import 'package:desktoppossystem/screens/daily%20sales/components/receipt_details_dialog_mobile.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/screens/settings/components/sections/general_section/general_section.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/default%20components/elevated_button_widget.dart';
import 'package:desktoppossystem/shared/default%20components/quiver_circular_indicator.dart';
import 'package:desktoppossystem/shared/services/scroll_behavior_service.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:desktoppossystem/shared/utils/responsive_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/styles/pallete.dart';

class ReceiptDetailsDialog extends ConsumerWidget {
  const ReceiptDetailsDialog({required this.receiptModel, super.key});
  final ReceiptModel receiptModel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ResponsiveWidget(
      desktopView: ReceiptDetailsDialogDesktop(receiptModel: receiptModel),
      mobileView: ReceiptDetailsDialogMobile(receiptModel: receiptModel),
    );
  }
}

class ReceiptDetailsDialogDesktop extends ConsumerStatefulWidget {
  const ReceiptDetailsDialogDesktop({required this.receiptModel, super.key});
  final ReceiptModel receiptModel;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ReceiptDetailsDialogDesktopState();
}

class _ReceiptDetailsDialogDesktopState
    extends ConsumerState<ReceiptDetailsDialogDesktop> {
  @override
  void initState() {
    super.initState();
    fetchDetailsReceipt();
  }

  List<ProductModel> products = [];
  List<DetailsReceipt> listOfDetailsReceipt = [];
  bool isloading = true;
  Future fetchDetailsReceipt() async {
    listOfDetailsReceipt = await ref
        .read(receiptControllerProvider)
        .getDetailsReceiptById(widget.receiptModel.id!);
    listOfDetailsReceipt.sort(
      (a, b) => a.isRefunded.toString().compareTo(b.isRefunded.toString()),
    );

    double originalForeignPrice = widget.receiptModel.foreignReceiptPrice!;
    for (var element in listOfDetailsReceipt) {
      var product = ProductModel.second();
      product.id = element.productId;
      product.name = element.productName;
      product.qty = element.qty;
      product.sellingPrice = element.sellingPrice;
      product.originalSellingPrice = element.originalSellingPrice;
      originalForeignPrice +=
          element.qty! * (element.originalSellingPrice ?? 0);
      product.isRefunded = element.isRefunded;
      product.discount = element.discount;
      products.add(product);
    }

    // Filter non-refunded products
    products = products
        .where((element) => element.isRefunded == false)
        .toList();
    setState(() {
      isloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    String paymentType = widget.receiptModel.paymentType == PaymentType.cash
        ? S.of(context).cash
        : S.of(context).card;
    return AlertDialog(
      title: Center(
        child: DefaultTextView(
          text: "${S.of(context).invoice} ${widget.receiptModel.id}",
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      content: isloading
          ? const SizedBox(
              height: 150,
              width: 400,
              child: Center(child: CoreCircularIndicator()),
            )
          : Container(
              constraints: const BoxConstraints(maxHeight: 400, minHeight: 150),
              width: ref.read(mainControllerProvider).isSuperAdmin ? 600 : 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: ScrollConfiguration(
                      behavior: MyCustomScrollBehavior(),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: <Widget>[
                            // if (widget.receiptModel.transactionType != null)
                            //   DefaultTextView(
                            //       text:
                            //           "$paymentType :  ${widget.receiptModel.transactionType == TransactionType.withdraw ? "${widget.receiptModel.expensePurpose} ${widget.receiptModel.withDrawFromCash == true ? "(from cash)" : ""} " : S.of(context).deposit}"),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Expanded(
                                  child:
                                      widget.receiptModel.customerModel != null
                                      ? DefaultTextView(
                                          textAlign: TextAlign.right,
                                          text:
                                              "${widget.receiptModel.customerModel!.name} / ${widget.receiptModel.customerModel!.phoneNumber} ",
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        )
                                      : kEmptyWidget,
                                ),
                              ],
                            ),

                            const SizedBox(height: 20),
                            if (widget.receiptModel.transactionType
                                case TransactionType.salePayment ||
                                    TransactionType.pendingPayment) ...[
                              const BuildHeaderDialog(),
                              Divider(height: 1, color: context.primaryColor),
                              ...listOfDetailsReceipt.map(
                                (e) => BuildDetailsReceiptItem(e),
                              ),
                            ],
                            if (widget.receiptModel.invoiceDelivered == true)
                              const Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  DefaultTextView(
                                    text: "Delivered",
                                    fontWeight: FontWeight.bold,
                                    color: Pallete.greenColor,
                                  ),
                                  Icon(
                                    Icons.check_circle_outline,
                                    color: Pallete.greenColor,
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  kGap10,
                  Row(
                    children: [
                      Expanded(
                        child: BuildResult(
                          price: widget.receiptModel.foreignReceiptPrice!
                              .formatDouble()
                              .toString(),
                          lebanesePrice: widget.receiptModel.localReceiptPrice
                              .toString(),
                          remainingAmount: widget.receiptModel.remainingAmount,
                        ),
                      ),
                    ],
                  ),
                  kGap20,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButtonWidget(
                        text: S.of(context).cancel,
                        onPressed: () {
                          context.pop();
                        },
                      ),
                      if (!listOfDetailsReceipt.every(
                        (element) => element.isRefunded == true,
                      ))
                        ElevatedButtonWidget(
                          text: S.of(context).printReceipt,
                          icon: Icons.print,
                          onPressed: () async {
                            if (listOfDetailsReceipt.isNotEmpty) {
                              var nbOfImage = (listOfDetailsReceipt.length / 20)
                                  .ceil();
                              products = [];
                              double originalForeignPrice = 0;

                              for (var element in listOfDetailsReceipt) {
                                var product = ProductModel.second();
                                product.id = element.productId;
                                product.name = element.productName;
                                product.qty = element.qty;
                                product.sellingPrice = element.sellingPrice;
                                product.originalSellingPrice =
                                    element.originalSellingPrice;
                                originalForeignPrice +=
                                    element.qty! *
                                    (element.originalSellingPrice ?? 0);
                                product.isRefunded = element.isRefunded;
                                product.discount = element.discount;
                                products.add(product);
                              }
                              products = products
                                  .where(
                                    (element) => element.isRefunded == false,
                                  )
                                  .toList();

                              await ref
                                  .read(printerControllerProvider)
                                  .generateAndPrintReceipt(
                                    receiptDate:
                                        widget.receiptModel.receiptDate,
                                    dontOpenCash: true,
                                    nbOfImage: nbOfImage,
                                    products: products,
                                    dolarRate: widget.receiptModel.dollarRate!,
                                    context: context,
                                    originalTotalForeign: originalForeignPrice,
                                    totalForeign: widget
                                        .receiptModel
                                        .foreignReceiptPrice!,
                                    invoiceNumber: widget.receiptModel.id,
                                    customerModel:
                                        widget.receiptModel.customerModel,
                                    typeOfPrint: TypeOfPrint.Receipt,
                                  )
                                  .then((value) {
                                    context.pop();
                                  });
                            }
                          },
                          states: [
                            ref
                                .watch(printerControllerProvider)
                                .generateAndPrintRequestState,
                          ],
                        ),
                      if (ref.read(showDeliverPackageProvider) &&
                          ref.read(mainControllerProvider).screenUI ==
                              ScreenUI.market &&
                          widget.receiptModel.customerModel != null)
                        ElevatedButtonWidget(
                          text: S.of(context).deliverPackage,
                          onPressed: () {
                            //context.pop();
                            showDialog(
                              context: context,
                              builder: (context) {
                                return DeliverPackageDialog(
                                  receiptModel: widget.receiptModel,
                                );
                              },
                            );
                          },
                          color: Pallete.greenColor,
                        ),
                      if (widget.receiptModel.transactionType ==
                              TransactionType.salePayment &&
                          widget.receiptModel.foreignReceiptPrice! > 0)
                        ElevatedButtonWidget(
                          color: Pallete.redColor,
                          text: S.of(context).download,
                          icon: Icons.picture_as_pdf,
                          states: [
                            ref
                                .watch(globalControllerProvider)
                                .openInvoiceAsPdfRequestState,
                          ],
                          onPressed: () async {
                            await ref
                                .read(globalControllerProvider)
                                .openInvoiceAsPdf(widget.receiptModel, products)
                                .whenComplete(() {
                                  context.pop();
                                });
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
