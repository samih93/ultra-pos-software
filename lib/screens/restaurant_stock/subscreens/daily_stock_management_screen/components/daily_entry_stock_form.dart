import 'package:desktoppossystem/controller/auth_controller.dart';
import 'package:desktoppossystem/controller/restaurant_stock_controller.dart';
import 'package:desktoppossystem/models/restaurant_stock_model.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
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
import '../../../../../shared/constances/app_constances.dart';
import '../../../../../shared/global.dart';
import '../../../../../shared/utils/enum.dart';

class DailyEntryStockForm extends ConsumerStatefulWidget {
  const DailyEntryStockForm(this.model, {super.key});
  final RestaurantStockModel? model;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DailyEntryStockFormState();
}

class _DailyEntryStockFormState extends ConsumerState<DailyEntryStockForm> {
  late TextEditingController qtyTextController;
  late TextEditingController pricePerUnitTextController;
  late TextEditingController nbOfPacketsTextController;
  late TextEditingController qtyPerPacketTextController;
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    qtyTextController = TextEditingController();
    pricePerUnitTextController = TextEditingController();
    nbOfPacketsTextController = TextEditingController();
    qtyPerPacketTextController = TextEditingController();
    _initializeQtyAndPrice();
  }

  _initializeQtyAndPrice() {
    if (widget.model != null) {
      qtyTextController.text = "";
      pricePerUnitTextController.text = widget.model!.pricePerUnit.toString();
      onchangeQty(0);
      onchangePrice(widget.model!.pricePerUnit);
    }
  }

  @override
  void didUpdateWidget(DailyEntryStockForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      _initializeQtyAndPrice();
      qtyPerPacketTextController.clear();
      nbOfPacketsTextController.clear();
    }
  }

  @override
  void dispose() {
    qtyTextController.dispose();
    pricePerUnitTextController.dispose();
    nbOfPacketsTextController.dispose();
    qtyPerPacketTextController.dispose();
    super.dispose();
  }

  double updateQty = 0;
  double updatedPrice = 0;
  double wastePerQty = 0;

  onchangeQty(double qty) {
    setState(() {
      // Get old quantity and price per unit
      double oldQty = widget.model?.qty ?? 0;
      double oldPricePerUnit = widget.model?.pricePerUnit ?? 0;
      final newPrice = double.tryParse(pricePerUnitTextController.text) ?? 0;
      // Compute new quantity
      double updatedQty = oldQty + qty;

      // Calculate new average cost price
      double newAverageCost = (oldQty + qty) > 0
          ? ((oldQty * oldPricePerUnit) + (qty * newPrice)) / (oldQty + qty)
          : updatedPrice;

      updateQty = updatedQty;
      updatedPrice = newAverageCost;
      if (widget.model!.unitType == UnitType.kg) {
        wastePerQty = (qty * widget.model!.wastePerKg).formatDouble();
      }
    });
  }

  void onchangePrice(double price) {
    setState(() {
      // Get old quantity and price per unit
      double oldQty = widget.model?.qty ?? 0;
      double oldPricePerUnit = widget.model?.pricePerUnit ?? 0;

      // Calculate new average cost price (without changing quantity)
      double newAverageCost = (oldQty > 0)
          ? ((oldQty * oldPricePerUnit) + (oldQty * price)) / (oldQty + oldQty)
          : price;

      updatedPrice = newAverageCost;
    });
  }

  generateQtyInPortions({
    required double packets,
    required double qtyPerPacket,
  }) {
    qtyTextController.text = (packets * qtyPerPacket).toString();
    onchangeQty(packets * qtyPerPacket);
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
            kGap5,
            if (widget.model!.unitType == UnitType.portion) ...[
              Row(
                children: [
                  Expanded(
                    child: AppTextFormField(
                      showText: true,
                      format: numberTextFormatter,
                      inputtype: TextInputType.number,
                      hinttext: S.of(context).nbOfPackets,
                      onchange: (value) {
                        final newValue =
                            double.tryParse(value.toString()) ?? 0.0;
                        final qtyPerPacket =
                            double.tryParse(
                              qtyPerPacketTextController.text.toString(),
                            ) ??
                            0.0;

                        generateQtyInPortions(
                          packets: newValue,
                          qtyPerPacket: qtyPerPacket,
                        );
                      },
                      controller: nbOfPacketsTextController,
                    ),
                  ),
                  kGap10,
                  Expanded(
                    child: AppTextFormField(
                      showText: true,
                      format: numberTextFormatter,
                      inputtype: TextInputType.number,
                      hinttext: S.of(context).qtyPerPacket,
                      onchange: (value) {
                        final newValue =
                            double.tryParse(value.toString()) ?? 0.0;
                        final packets =
                            double.tryParse(
                              nbOfPacketsTextController.text.toString(),
                            ) ??
                            0.0;
                        generateQtyInPortions(
                          packets: packets,
                          qtyPerPacket: newValue,
                        );
                      },
                      controller: qtyPerPacketTextController,
                    ),
                  ),
                ],
              ),
            ],
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
            if (widget.model?.unitType == UnitType.kg && wastePerQty > 0)
              Row(
                children: [
                  const DefaultTextView(
                    text: "total waste :",
                    color: Pallete.redColor,
                  ),
                  kGap5,
                  AppPriceText(
                    text: "$wastePerQty ",
                    color: Pallete.redColor,
                    fontWeight: FontWeight.w600,
                    unit: UnitType.kg.uniteTypeToString(),
                  ),
                ],
              ),
            if (ref.read(mainControllerProvider).isSuperAdmin)
              AppTextFormField(
                showText: true,
                onchange: (value) {
                  final newValue = double.tryParse(value.toString()) ?? 0.0;
                  onchangePrice(newValue);
                },
                controller: pricePerUnitTextController,
                format: numberTextFormatter,
                inputtype: TextInputType.number,
                hinttext:
                    "${widget.model!.unitType == UnitType.kg ? S.of(context).pricePerKg : S.of(context).pricePerPortion} (${AppConstance.primaryCurrency})",
              ),
            kGap20,
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
            if (ref.read(mainControllerProvider).isSuperAdmin) ...[
              Row(
                children: [
                  DefaultTextView(text: "${S.of(context).oldCost} => "),
                  AppPriceText(
                    fontWeight: FontWeight.bold,
                    text: "${widget.model?.pricePerUnit.formatDouble()}",
                    unit: AppConstance.primaryCurrency,
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
                          text: "${updateQty.formatDouble()}",
                          unit: widget.model!.unitType.uniteTypeToString(),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Pallete.redColor,
                        ),
                        kGap5,
                        DefaultTextView(
                          text: "${S.of(context).newAvgCost} => ",
                        ),
                        AppPriceText(
                          fontWeight: FontWeight.bold,
                          text: "${updatedPrice.formatDouble()}",
                          unit: AppConstance.primaryCurrency,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
            kGap20,
            Row(
              children: [
                Expanded(
                  child: ElevatedButtonWidget(
                    states: [
                      ref
                          .watch(restaurantStockControllerProvider)
                          .updateRequestState,
                      ref
                          .watch(restaurantStockControllerProvider)
                          .makeWasteRequestState,
                    ],
                    text: S.of(context).save,
                    isDisabled:
                        double.tryParse(qtyTextController.text.trim()) ==
                            null ||
                        (double.tryParse(qtyTextController.text.trim()) !=
                                null &&
                            double.tryParse(qtyTextController.text.trim()) ==
                                0),
                    icon: Icons.save,
                    onPressed: () {
                      onStockIn(context);
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

  Future onStockIn(BuildContext context) async {
    double? stockInQty = double.tryParse(qtyTextController.text.trim());
    // entered price per unit
    double pricePerUnit =
        double.tryParse(pricePerUnitTextController.text.trim()) ?? 0;
    qtyTextController.clear();
    pricePerUnitTextController.clear();
    if (stockInQty != null && stockInQty > 0) {
      if (widget.model != null) {
        RestaurantStockModel restaurantStockModel = widget.model!;
        restaurantStockModel = restaurantStockModel.copyWith(
          qty: updateQty.formatDouble(),
          pricePerUnit: updatedPrice.formatDouble(),
        );

        await Future.wait([
          ref
              .read(restaurantStockControllerProvider)
              .editItem(restaurantStockModel, context, isInDailyEntry: true),
          ref.read(restaurantStockControllerProvider).makeStockTransaction([
            restaurantStockModel.mapToFoodTracker(
              oldQty: widget.model!.qty,
              employeeId: ref.read(currentUserProvider)?.id ?? 0,
              transactionDate: DateTime.now().toString(),
              wasteType: WasteType.normal,
              pricePerUnit: pricePerUnit,
              transactionType: StockTransactionType.stockIn,
              transactionQty: stockInQty,
            ),
          ]),
          if (wastePerQty > 0)
            ref.read(restaurantStockControllerProvider).makeStockTransaction([
              restaurantStockModel.mapToFoodTracker(
                employeeId: ref.read(currentUserProvider)?.id ?? 0,
                transactionDate: DateTime.now().toString(),
                wasteType: WasteType.normal,
                transactionReason: "Loss Calculation",
                pricePerUnit: pricePerUnit,
                transactionType: StockTransactionType.stockOut,
                transactionQty: wastePerQty,
              ),
            ]),
        ]);
      }
    } else {
      ToastUtils.showToast(message: "qty not valid ", type: RequestState.error);
    }
  }
}
