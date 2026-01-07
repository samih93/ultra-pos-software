import 'package:desktoppossystem/controller/auth_controller.dart';
import 'package:desktoppossystem/controller/restaurant_stock_controller.dart';
import 'package:desktoppossystem/models/restaurant_stock_model.dart';
import 'package:desktoppossystem/shared/default%20components/default_price_text.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/default%20components/elevated_button_widget.dart';
import 'package:desktoppossystem/shared/default%20components/app_text_form_field.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:desktoppossystem/shared/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../generated/l10n.dart';
import '../../../../../shared/global.dart';
import '../../../../../shared/utils/enum.dart';

class StockWasteForm extends ConsumerStatefulWidget {
  const StockWasteForm(this.model, {super.key});
  final RestaurantStockModel? model;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DailyEntryStockFormState();
}

class _DailyEntryStockFormState extends ConsumerState<StockWasteForm> {
  late TextEditingController qtyTextController;
  late TextEditingController wasteReasonTextController;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    qtyTextController = TextEditingController();
    wasteReasonTextController = TextEditingController();

    _initializeQty();
  }

  _initializeQty() {
    if (widget.model != null) {
      qtyTextController.text = "";
      wasteReasonTextController.text = "";
      onchangeQty(0);
    }
  }

  @override
  void didUpdateWidget(StockWasteForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      _initializeQty();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  double updateQty = 0;

  onchangeQty(double qty) {
    setState(() {
      // Get old quantity and price per unit
      double oldQty = widget.model?.qty ?? 0;

      // Compute new quantity
      double updatedQty = oldQty - qty;

      updateQty = updatedQty.formatDouble();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: kPadd10,
      child: Form(
        key: _formkey,
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Center(
              child: DefaultTextView(
                text: widget.model!.name,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            kGap10,
            AppTextFormField(
              showText: true,
              format: numberTextFormatter,
              inputtype: TextInputType.number,
              hinttext: widget.model!.unitType == UnitType.kg
                  ? S.of(context).qtyAsKg
                  : S.of(context).qtyAsPortions,
              onchange: (value) {
                final newValue = double.tryParse(value.toString()) ?? 0.0;
                onchangeQty(newValue);
              },
              controller: qtyTextController,
            ),
            AppTextFormField(
              showText: true,
              inputtype: TextInputType.text,
              hinttext: S.of(context).wasteReason,
              controller: wasteReasonTextController,
            ),
            kGap10,
            Row(
              children: [
                DefaultTextView(text: "${S.of(context).oldQty} => "),
                AppPriceText(
                  fontWeight: FontWeight.bold,
                  text: "${widget.model?.qty}",
                  unit: widget.model!.unitType.uniteTypeToString(),
                ),
              ],
            ),
            kGap10,
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Pallete.primaryColor),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Pallete.redColor,
                      ),
                      kGap5,
                      DefaultTextView(text: "${S.of(context).newQty} => "),
                      AppPriceText(
                        fontWeight: FontWeight.bold,
                        text: "$updateQty",
                        unit: widget.model!.unitType.uniteTypeToString(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            kGap20,
            Row(
              children: [
                Expanded(
                  child: ElevatedButtonWidget(
                    color: Pallete.redColor,
                    states: [
                      ref
                          .watch(restaurantStockControllerProvider)
                          .updateRequestState,
                    ],
                    text: S.of(context).waste,
                    isDisabled:
                        double.tryParse(qtyTextController.text.trim()) ==
                            null ||
                        (double.tryParse(qtyTextController.text.trim()) !=
                                null &&
                            double.tryParse(qtyTextController.text.trim()) ==
                                0),
                    icon: Icons.recycling,
                    onPressed: () {
                      double? wasteQty = double.tryParse(
                        qtyTextController.text.trim(),
                      );
                      if (wasteQty != null && wasteQty > 0) {
                        if (widget.model != null) {
                          RestaurantStockModel restaurantStockModel =
                              widget.model!;
                          restaurantStockModel = restaurantStockModel.copyWith(
                            qty: updateQty,
                          );
                          ref
                              .read(restaurantStockControllerProvider)
                              .editItem(
                                isStockOut: true,
                                restaurantStockModel,
                                context,
                                isInDailyEntry: true,
                              );

                          ref
                              .read(restaurantStockControllerProvider)
                              .makeStockTransaction([
                                restaurantStockModel.mapToFoodTracker(
                                  employeeId:
                                      ref.read(currentUserProvider)?.id ?? 0,
                                  transactionQty: wasteQty,
                                  transactionDate: DateTime.now().toString(),
                                  wasteType: WasteType.normal,
                                  transactionType:
                                      StockTransactionType.stockOut,
                                  transactionReason: wasteReasonTextController
                                      .text
                                      .trim(),
                                ),
                              ])
                              .whenComplete(() {
                                qtyTextController.clear();
                                wasteReasonTextController.clear();
                              });
                        }
                      } else {
                        ToastUtils.showToast(
                          message: "qty not valid ",
                          type: RequestState.error,
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
