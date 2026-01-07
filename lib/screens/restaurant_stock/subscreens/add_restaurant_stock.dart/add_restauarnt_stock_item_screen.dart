import 'package:desktoppossystem/controller/restaurant_stock_controller.dart';
import 'package:desktoppossystem/models/restaurant_stock_model.dart';
import 'package:desktoppossystem/screens/notifications_screen/notification_controller.dart';
import 'package:desktoppossystem/screens/restaurant_stock/subscreens/add_restaurant_stock.dart/components/waste_per_kg_widget.dart';
import 'package:desktoppossystem/shared/constances/app_constances.dart';
import 'package:desktoppossystem/shared/default%20components/app_squared_outlined_button.dart';
import 'package:desktoppossystem/shared/default%20components/app_text_form_field.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:desktoppossystem/shared/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../generated/l10n.dart';
import '../../../../shared/global.dart';

final selectedUnitTypeProvider = StateProvider<UnitType>((ref) {
  return UnitType.portion;
});
final forPackagingProvider = StateProvider<bool>((ref) {
  return false;
});

final stockBackColorProvider = StateProvider<Color>((ref) {
  return Pallete.redColor;
});
final stockTextColorProvider = StateProvider<Color>((ref) {
  return Pallete.whiteColor;
});

final wastePerKgProvider = StateProvider<double>((ref) {
  return 0;
});

class AddRestaurantStockItemScreen extends ConsumerStatefulWidget {
  const AddRestaurantStockItemScreen({this.restaurantStockModel, super.key});
  final RestaurantStockModel? restaurantStockModel;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddRestaurantStockItemScreenState();
}

class _AddRestaurantStockItemScreenState
    extends ConsumerState<AddRestaurantStockItemScreen> {
  @override
  void dispose() {
    nameTextController.dispose();
    portionsPerKgTextController.dispose();
    qtyTextController.dispose();
    pricePerUnitTextController.dispose();
    expiryDateController.dispose();
    warningAlertTextController.dispose();
    totalWeightTextController.dispose();
    totalNetWeightTextController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    nameTextController = TextEditingController();
    portionsPerKgTextController = TextEditingController();
    qtyTextController = TextEditingController();
    pricePerUnitTextController = TextEditingController();
    warningAlertTextController = TextEditingController();
    expiryDateController = TextEditingController();

    totalWeightTextController = TextEditingController(text: "0");
    totalNetWeightTextController = TextEditingController(text: "0");
    if (widget.restaurantStockModel != null) {
      nameTextController.text = widget.restaurantStockModel!.name;
      portionsPerKgTextController.text = widget
          .restaurantStockModel!
          .portionsPerKg
          .toString();
      qtyTextController.text =
          "${widget.restaurantStockModel!.qty.formatDouble()}";
      pricePerUnitTextController.text = widget
          .restaurantStockModel!
          .pricePerUnit
          .toString();
      warningAlertTextController.text = widget
          .restaurantStockModel!
          .warningAlert
          .toString();
      expiryDateController.text = widget.restaurantStockModel!.expiryDate ?? "";
      totalWeightTextController.text = widget
          .restaurantStockModel!
          .totalWeightFromFormula
          .toString();
      totalNetWeightTextController.text = widget
          .restaurantStockModel!
          .netWeightFromFormula
          .toString();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(wastePerKgProvider.notifier).state =
            widget.restaurantStockModel!.wastePerKg;
      });
    }
  }

  Future addRestaurantStockItem(WidgetRef ref, BuildContext context) async {
    double totalWeight = double.tryParse(totalWeightTextController.text) ?? 0;
    double totalNetWeight =
        double.tryParse(totalNetWeightTextController.text) ?? 0;
    String? wasteFormula = totalWeight > 0 && totalNetWeight > 0
        ? "${totalWeight.formatDouble()}/${totalNetWeight.formatDouble()}"
        : null;
    RestaurantStockModel restaurantStockModel = RestaurantStockModel(
      id: widget.restaurantStockModel?.id,
      color: ref.read(stockBackColorProvider).getStringColorFromHex(),
      name: nameTextController.text.trim(),
      portionsPerKg:
          double.tryParse(portionsPerKgTextController.text.trim()) ?? 0,
      pricePerUnit:
          double.tryParse(pricePerUnitTextController.text.trim()) ?? 0,
      unitType: ref.read(selectedUnitTypeProvider),
      qty: double.tryParse(qtyTextController.text) ?? 0,
      forPackaging: ref.read(forPackagingProvider),
      warningAlert: double.tryParse(warningAlertTextController.text) ?? 0,
      expiryDate: expiryDateController.text.trim().isEmpty
          ? null
          : expiryDateController.text.trim(),
      wasteFormula: wasteFormula,
    );
    if (widget.restaurantStockModel != null) {
      ref
          .read(restaurantStockControllerProvider)
          .editItem(restaurantStockModel, context);
    } else {
      ref
          .read(restaurantStockControllerProvider)
          .addItem(restaurantStockModel, context);
    }
    ref.refresh(restaurantNotificationCountProvider);
  }

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();
  late TextEditingController nameTextController;
  late TextEditingController portionsPerKgTextController;
  late TextEditingController qtyTextController;
  late TextEditingController pricePerUnitTextController;
  late TextEditingController warningAlertTextController;
  late TextEditingController expiryDateController;
  late TextEditingController totalWeightTextController;
  late TextEditingController totalNetWeightTextController;

  onchangeWasteFormula(double value, {bool? isTotalWeight = true}) {
    double totalWeight = 0, totalNetWeight = 0;
    if (isTotalWeight!) {
      totalWeight = value;
      totalNetWeight = double.tryParse(totalNetWeightTextController.text) ?? 0;
    } else {
      totalNetWeight = value;
      totalWeight = double.tryParse(totalWeightTextController.text) ?? 0;
    }
    double waste = totalWeight - totalNetWeight;

    double wastePerKg = totalWeight > 0 ? waste / totalWeight : 0;

    ref.read(wastePerKgProvider.notifier).state = wastePerKg.formatDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: DefaultTextView(
          text: "${S.of(context).add} ${S.of(context).stockItem}",
        ),
        actions: [
          AppSquaredOutlinedButton(
            backgroundColor: Pallete.whiteColor,
            states: [
              ref.watch(restaurantStockControllerProvider).addRequestState,
            ],
            child: const Icon(FontAwesomeIcons.floppyDisk, size: 20),
            onPressed: () async {
              if (_formkey.currentState!.validate()) {
                await addRestaurantStockItem(ref, context);
              }
            },
          ),
          defaultGap,
        ],
      ),
      body: Form(
        key: _formkey,
        child: Column(
          children: [
            Row(
              children: [
                DefaultTextView(
                  text: "${S.of(context).unit.capitalizeFirstLetter()} : ",
                ),
                FilterChip(
                  backgroundColor: Colors.grey.shade700,
                  padding: kPadd8,
                  label: const DefaultTextView(
                    fontSize: 12,
                    text: "kg",
                    color: Colors.white,
                  ),
                  selectedColor: context.primaryColor.withValues(alpha: 0.8),
                  selected: ref.watch(selectedUnitTypeProvider) == UnitType.kg,
                  onSelected: (bool selected) {
                    ref
                        .read(selectedUnitTypeProvider.notifier)
                        .update((state) => UnitType.kg);
                  },
                ),
                kGap10,
                FilterChip(
                  backgroundColor: Colors.grey.shade700,
                  padding: kPadd8,
                  label: const DefaultTextView(
                    fontSize: 12,
                    text: "portion",
                    color: Colors.white,
                  ),
                  selectedColor: context.primaryColor.withValues(alpha: 0.8),
                  selected:
                      ref.watch(selectedUnitTypeProvider) == UnitType.portion,
                  onSelected: (bool selected) {
                    ref
                        .read(selectedUnitTypeProvider.notifier)
                        .update((state) => UnitType.portion);
                  },
                ),
                kGap20,
                const Spacer(),
                DefaultTextView(text: "${S.of(context).forPackagingSelect} =>"),
                kGap5,
                FilterChip(
                  backgroundColor: Colors.grey.shade700,
                  padding: kPadd8,
                  label: DefaultTextView(
                    fontSize: 12,
                    text: S.of(context).packaging,
                    color: Colors.white,
                  ),
                  selectedColor: context.primaryColor.withValues(alpha: 0.8),
                  selected: ref.watch(forPackagingProvider),
                  onSelected: (bool selected) {
                    ref
                        .read(forPackagingProvider.notifier)
                        .update((state) => !state);
                  },
                ),
              ],
            ),
            kGap20,
            Row(
              children: [
                Expanded(
                  child: AppTextFormField(
                    showText: true,
                    controller: nameTextController,
                    inputtype: TextInputType.name,
                    onvalidate: (value) {
                      if (value!.trim().isEmpty) {
                        return S.of(context).nameMustBeNotEmpty;
                      }
                      return null;
                    },
                    hinttext: S.of(context).name,
                  ),
                ),
                kGap20,
                ref.watch(selectedUnitTypeProvider) == UnitType.kg
                    ? Expanded(
                        child: AppTextFormField(
                          showText: true,
                          inputtype: TextInputType.number,
                          format: numberTextFormatter,
                          onchange: (value) {
                            // final newValue =
                            //     double.tryParse(value.toString()) ?? 0.0;
                            // setPortionsPerKg(newValue);
                          },
                          hinttext: S.of(context).nbOfPortionsPerKg,
                          controller: portionsPerKgTextController,
                        ),
                      )
                    : const Expanded(child: SizedBox()),
              ],
            ),
            kGap20,
            Row(
              children: [
                Expanded(
                  child: AppTextFormField(
                    showText: true,
                    format: numberTextFormatter,
                    inputtype: TextInputType.number,
                    hinttext: ref.watch(selectedUnitTypeProvider) == UnitType.kg
                        ? S.of(context).qtyAsKg
                        : S.of(context).qtyAsPortions,
                    onchange: (value) {
                      // final newValue =
                      //     double.tryParse(value.toString()) ?? 0.0;
                      // setQtyAsKg(newValue);
                    },
                    controller: qtyTextController,
                  ),
                ),
                kGap20,
                Expanded(
                  child: AppTextFormField(
                    showText: true,
                    controller: pricePerUnitTextController,
                    format: numberTextFormatter,
                    inputtype: TextInputType.number,
                    hinttext:
                        "${ref.watch(selectedUnitTypeProvider) == UnitType.kg ? S.of(context).pricePerKg : S.of(context).pricePerPortion} (${AppConstance.primaryCurrency})",
                  ),
                ),
              ],
            ),
            kGap20,
            Row(
              children: [
                Expanded(
                  child: AppTextFormField(
                    showText: true,
                    format: numberTextFormatter,
                    inputtype: TextInputType.number,
                    hinttext: S.of(context).warningAlert,
                    controller: warningAlertTextController,
                  ),
                ),
                kGap20,
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: AppTextFormField(
                          showText: true,
                          onvalidate: (expDate) {
                            if (expDate.toString().trim().isNotEmpty &&
                                expDate.toString().validateDate() != null) {
                              return expDate.toString().validateDate();
                            }
                            return null;
                          },
                          inputtype: TextInputType.text,
                          controller: expiryDateController,
                          hinttext: "${S.of(context).expiryDate} (yyyy-mm-dd)",
                          suffixIcon: IconButton(
                            onPressed: () async {
                              final selectedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now().subtract(
                                  const Duration(days: 90),
                                ),
                                lastDate: DateTime.parse('2050-01-01'),
                              );
                              if (selectedDate != null) {
                                // Format the selected date as YYYY-MM-DD
                                final formattedDate =
                                    "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";
                                expiryDateController.text = formattedDate;
                              }
                            },
                            icon: const Icon(Icons.calendar_month),
                          ),
                          readonly: false,
                          format: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9-]'),
                            ), // Allow only numbers and '/'
                            DateInputFormatter(), // Custom formatter to enforce date format
                          ],
                          onchange: (value) {
                            if (value.length > 10) return;
                            if (!value.isValidDate()) {
                              if (value.length == 10) {
                                ToastUtils.showToast(
                                  message:
                                      "Invalid date format. Please use yyyy-mm-dd",
                                  type: RequestState.error,
                                );
                              }
                            }
                          },
                        ),
                      ),
                      kGap20,
                      InkWell(
                        onTap: () {
                          //! raise the [showDialog]
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: DefaultTextView(
                                  text: S.of(context).selectColor,
                                  color: Colors.black,
                                ),
                                content: SizedBox(
                                  width: 300,
                                  child: MaterialColorPicker(
                                    alignment: WrapAlignment.center,
                                    onColorChange: (Color color) {
                                      ref
                                              .read(
                                                stockBackColorProvider.notifier,
                                              )
                                              .state =
                                          color;
                                    },
                                    selectedColor: ref.watch(
                                      stockBackColorProvider,
                                    ),
                                    colors: [
                                      Pallete.orangeColor.createMaterialColor(),
                                      Pallete.redColor.createMaterialColor(),
                                      Pallete.greenColor.createMaterialColor(),
                                      Pallete.yellowColor.createMaterialColor(),
                                      Pallete.blueColor.createMaterialColor(),
                                      Pallete.purpleColor.createMaterialColor(),
                                      Pallete.primaryColor
                                          .createMaterialColor(),
                                      Colors.grey,
                                    ],
                                  ),
                                ),
                                actions: <Widget>[
                                  ElevatedButton(
                                    child: Text(S.of(context).save),
                                    onPressed: () {
                                      //! setState(
                                      //!     () => currentColor = pickerColor);
                                      context.pop();
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Container(
                          width: 100,
                          height: 40,
                          decoration: BoxDecoration(
                            borderRadius: kRadius15,
                            color: ref.watch(stockBackColorProvider),
                            border: Border.all(color: Colors.grey, width: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (ref.watch(selectedUnitTypeProvider) == UnitType.kg) ...[
              kGap20,
              const WastePerKgWidget(),
              Row(
                children: [
                  Expanded(
                    child: AppTextFormField(
                      format: numberTextFormatter,
                      controller: totalWeightTextController,
                      hinttext:
                          "${S.of(context).totalWeight} (${UnitType.kg.uniteTypeToString()})",
                      showText: true,
                      onchange: (p0) => onchangeWasteFormula(
                        double.tryParse(p0.toString()) ?? 0,
                      ),
                    ),
                  ),
                  kGap20,
                  Expanded(
                    child: AppTextFormField(
                      format: numberTextFormatter,
                      controller: totalNetWeightTextController,
                      hinttext:
                          "${S.of(context).netWeight} (${UnitType.kg.uniteTypeToString()})",
                      showText: true,
                      onchange: (p0) => onchangeWasteFormula(
                        double.tryParse(p0.toString()) ?? 0,
                        isTotalWeight: false,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ).baseContainer(context.cardColor),
    );
  }
}
