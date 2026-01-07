import 'package:desktoppossystem/controller/auth_controller.dart';
import 'package:desktoppossystem/controller/product_controller.dart';
import 'package:desktoppossystem/controller/receipt_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/details_receipt.dart';
import 'package:desktoppossystem/models/product_model.dart';
import 'package:desktoppossystem/models/user_model.dart';
import 'package:desktoppossystem/repositories/restaurant_stock/restaurant_stock_repository.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/shared/default%20components/app_text_form_field.dart';
import 'package:desktoppossystem/shared/default%20components/default_outline_button.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/default%20components/info_dialog.dart';
import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:desktoppossystem/shared/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RefundDetailsReceipt extends ConsumerStatefulWidget {
  const RefundDetailsReceipt(this.listDetailsReceipt, {super.key});
  final List<DetailsReceipt> listDetailsReceipt;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _RefundDetailsReceiptState();
}

class _RefundDetailsReceiptState extends ConsumerState<RefundDetailsReceipt> {
  onselectItemInDetailsReceipt(DetailsReceipt dr) {
    for (var element in widget.listDetailsReceipt) {
      if (element.id == dr.id) {
        element.selected = !(element.selected!);
      }
    }
    setState(() {});
  }

  onchangeRefundQty({required int productId, required double value}) {
    for (var element in widget.listDetailsReceipt) {
      if (element.productId == productId) {
        element.refundedQty = value;
      }
    }
    setState(() {});
  }

  onchangeRefundReason({required int productId, required String value}) {
    for (var element in widget.listDetailsReceipt) {
      if (element.productId == productId) {
        element.refundReason = value;
      }
    }
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    UserModel userModel = ref.read(currentUserProvider)!;
    var receiptController = ref.read(receiptControllerProvider);

    final showIngredients =
        ref.read(mainControllerProvider).isShowRestaurantStock &&
        ref.read(mainControllerProvider).screenUI == ScreenUI.restaurant;

    return Scaffold(
      appBar: AppBar(
        actions: [
          DefaultOutlineButton(
            states: [
              ref.watch(receiptControllerProvider).refundItemsRequestState,
            ],
            name: S.of(context).refundButton,
            onpress: () async {
              var res = receiptController.detailsReceiptList
                  .where((element) => element.selected == true)
                  .toList();
              if (res.isNotEmpty) {
                if (res.every(
                  (element) => element.qty! >= element.refundedQty!,
                )) {
                  receiptController
                      .refundItems(list: res, context: context)
                      .then((value) {
                        List<ProductModel> products = [];
                        for (var element in res) {
                          products.add(
                            ProductModel(
                              id: element.productId,
                              name: null,
                              sellingPrice: null,
                              selected: null,
                              qty: element.qty,
                              isTracked: element.isTracked,
                              categoryId: null,
                            ),
                          );
                        }
                        ref
                            .read(productControllerProvider)
                            .increaseDecreaseListOfProducts(
                              list: products,
                              isForDecrease: false,
                            );
                      });
                } else {
                  ToastUtils.showToast(
                    message: "refunded items must be less than qty",
                    type: RequestState.error,
                  );
                }
              } else {
                ToastUtils.showToast(
                  message: "check Items to refund",
                  type: RequestState.error,
                );
              }
            },
            fontSize: 20,
          ),
        ],
      ),
      body: Column(
        children: [
          // Table Header
          Row(
            children: [
              const Expanded(
                flex: 2,
                child: Text(
                  'Name',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const Expanded(
                child: Text(
                  'Qty',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const Expanded(
                child: Text(
                  'Price',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const Expanded(
                child: Text(
                  'Total Price',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              if (showIngredients)
                const Expanded(
                  child: Text(
                    'Ingredients',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
          const Divider(),
          // Table Rows
          Expanded(
            child: ListView.builder(
              itemCount: widget.listDetailsReceipt.length,
              itemBuilder: (context, index) {
                final item = widget.listDetailsReceipt[index];
                return Column(
                  children: [
                    InkWell(
                      onTap: () => onselectItemInDetailsReceipt(item),
                      child: Row(
                        children: [
                          // Name
                          Expanded(
                            flex: 2,
                            child: Row(
                              children: [
                                Checkbox(
                                  value: item.selected ?? false,
                                  onChanged: (val) =>
                                      onselectItemInDetailsReceipt(item),
                                ),
                                Flexible(child: Text(item.productName ?? "")),
                              ],
                            ),
                          ),
                          // Qty
                          Expanded(child: Text("${item.qty ?? 0}")),
                          // Price
                          Expanded(
                            child: Text(item.sellingPrice?.toString() ?? ""),
                          ),
                          // Total Price
                          Expanded(
                            child: Text(
                              ((item.sellingPrice ?? 0) * (item.qty ?? 0))
                                  .formatDouble()
                                  .toString(),
                            ),
                          ),
                          // Ingredients
                          if (showIngredients)
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  await ref
                                      .read(restaurantProviderRepository)
                                      .fetchSaledIngredientByDetailsReceiptId(
                                        item.id!,
                                      )
                                      .then((value) {
                                        showDialog(
                                          context: context,
                                          builder: (context) => InfoDialog(
                                            title: S.of(context).ingredients,
                                            content: value.isEmpty
                                                ? DefaultTextView(
                                                    text: S
                                                        .of(context)
                                                        .noIngredientFound,
                                                  )
                                                : Column(
                                                    crossAxisAlignment: .start,
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      for (
                                                        int i = 0;
                                                        i < value.length;
                                                        i++
                                                      )
                                                        Text(
                                                          "${i + 1} - *${value[i].name}*",
                                                          style:
                                                              const TextStyle(
                                                                fontSize: 14,
                                                              ),
                                                        ),
                                                    ],
                                                  ),
                                          ),
                                        );
                                      });
                                },
                                child: DefaultTextView(
                                  text: "view",
                                  color: context.primaryColor,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    // Expanded Row for refund qty and reason
                    if (item.selected == true)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4.0,
                          horizontal: 16.0,
                        ),
                        child: Row(
                          children: [
                            if (item.qty! > 1)
                              Expanded(
                                child: AppTextFormField(
                                  initialValue: "1",
                                  onchange: (value) {
                                    double? enteredVal = double.tryParse(
                                      value.toString(),
                                    );
                                    if (enteredVal != null) {
                                      onchangeRefundQty(
                                        productId: item.productId!,
                                        value: enteredVal,
                                      );
                                    }
                                  },
                                  format: numberTextFormatter,
                                  textAlign: TextAlign.center,
                                  inputtype: TextInputType.number,
                                  hinttext: S.of(context).qty,
                                ),
                              ),
                            if (item.qty! > 1) const SizedBox(width: 10),
                            Expanded(
                              flex: 2,
                              child: AppTextFormField(
                                onchange: (value) {
                                  onchangeRefundReason(
                                    productId: item.productId!,
                                    value: value.toString(),
                                  );
                                },
                                textAlign: TextAlign.center,
                                inputtype: TextInputType.text,
                                hinttext: S.of(context).refundReason,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const Divider(),
                  ],
                );
              },
            ),
          ),
        ],
      ).baseContainer(context.cardColor),
    );
  }
}
