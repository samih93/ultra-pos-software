import 'package:desktoppossystem/controller/global_controller.dart';
import 'package:desktoppossystem/controller/printer_controller.dart';
import 'package:desktoppossystem/controller/receipt_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/details_receipt.dart';
import 'package:desktoppossystem/models/product_model.dart';
import 'package:desktoppossystem/models/receipt_model.dart';
import 'package:desktoppossystem/screens/daily%20sales/components/deliver_package_dialog.dart';
import 'package:desktoppossystem/screens/daily%20sales/components/details_Receipt_dialog/build_details_receipt_item_mobile.dart';
import 'package:desktoppossystem/screens/daily%20sales/components/details_Receipt_dialog/build_result.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/screens/settings/components/sections/general_section/general_section.dart';
import 'package:desktoppossystem/shared/default%20components/app_squared_outlined_button.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/default%20components/quiver_circular_indicator.dart';
import 'package:desktoppossystem/shared/services/scroll_behavior_service.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ReceiptDetailsDialogMobile extends ConsumerStatefulWidget {
  const ReceiptDetailsDialogMobile({required this.receiptModel, super.key});
  final ReceiptModel receiptModel;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ReceiptDetailsDialogMobileState();
}

class _ReceiptDetailsDialogMobileState
    extends ConsumerState<ReceiptDetailsDialogMobile> {
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

    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: context.height * 0.4,
          maxHeight: context.height * 0.85,
          maxWidth: MediaQuery.of(context).size.width * 0.95,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: context.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8.r),
                  topRight: Radius.circular(8.r),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.receipt_long,
                    color: context.primaryColor,
                    size: 20.spMax,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: DefaultTextView(
                      text:
                          "${S.of(context).invoice} #${widget.receiptModel.id}",
                      fontWeight: FontWeight.bold,
                      fontSize: 16.spMax,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => context.pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // Content
            if (isloading)
              SizedBox(
                height: 150.h,
                child: const Center(child: CoreCircularIndicator()),
              )
            else
              Expanded(
                child: Column(
                  children: [
                    // Customer info if available
                    if (widget.receiptModel.customerModel != null)
                      Container(
                        margin: EdgeInsets.all(12.w),
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6.r),
                          border: Border.all(color: Colors.red),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.person,
                              color: Colors.red,
                              size: 18.spMax,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: DefaultTextView(
                                text:
                                    "${widget.receiptModel.customerModel!.name} / ${widget.receiptModel.customerModel!.phoneNumber}",
                                fontWeight: FontWeight.bold,
                                fontSize: 13.spMax,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Products list
                    if (widget.receiptModel.transactionType
                        case TransactionType.salePayment ||
                            TransactionType.pendingPayment)
                      Expanded(
                        child: ScrollConfiguration(
                          behavior: MyCustomScrollBehavior(),
                          child: ListView.builder(
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            itemCount: listOfDetailsReceipt.length,
                            itemBuilder: (context, index) {
                              return BuildDetailsReceiptItemMobile(
                                listOfDetailsReceipt[index],
                              );
                            },
                          ),
                        ),
                      ),

                    // Delivered badge
                    if (widget.receiptModel.invoiceDelivered == true)
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 12.w),
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: Pallete.greenColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.check_circle_outline,
                              color: Pallete.greenColor,
                            ),
                            SizedBox(width: 8.w),
                            const DefaultTextView(
                              text: "Delivered",
                              fontWeight: FontWeight.bold,
                              color: Pallete.greenColor,
                            ),
                          ],
                        ),
                      ),

                    // Result section
                    Container(
                      margin: EdgeInsets.all(12.w),
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
              ),

            // Action buttons
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.05),
                border: Border(
                  top: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Print button
                  if (!listOfDetailsReceipt.every(
                    (element) => element.isRefunded == true,
                  ))
                    AppSquaredOutlinedButton(
                      child: const Icon(Icons.print),
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
                              .where((element) => element.isRefunded == false)
                              .toList();

                          await ref
                              .read(printerControllerProvider)
                              .generateAndPrintReceipt(
                                receiptDate: widget.receiptModel.receiptDate,
                                dontOpenCash: true,
                                nbOfImage: nbOfImage,
                                products: products,
                                dolarRate: widget.receiptModel.dollarRate!,
                                context: context,
                                originalTotalForeign: originalForeignPrice,
                                totalForeign:
                                    widget.receiptModel.foreignReceiptPrice!,
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
                    ),

                  // Deliver package button
                  if (ref.read(showDeliverPackageProvider) &&
                      ref.read(mainControllerProvider).screenUI ==
                          ScreenUI.market &&
                      widget.receiptModel.customerModel != null)
                    AppSquaredOutlinedButton(
                      child: const Icon(
                        Icons.local_shipping,
                        color: Pallete.greenColor,
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return DeliverPackageDialog(
                              receiptModel: widget.receiptModel,
                            );
                          },
                        );
                      },
                    ),

                  // Download PDF button
                  if (widget.receiptModel.transactionType ==
                          TransactionType.salePayment &&
                      widget.receiptModel.foreignReceiptPrice! > 0)
                    AppSquaredOutlinedButton(
                      child: const Icon(
                        Icons.picture_as_pdf,
                        color: Pallete.redColor,
                      ),
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
            ),
          ],
        ),
      ),
    );
  }
}
