import 'package:desktoppossystem/controller/restaurant_stock_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/ingrendient_model.dart';
import 'package:desktoppossystem/models/restaurant_stock_model.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/default%20components/elevated_button_widget.dart';
import 'package:desktoppossystem/shared/default%20components/app_text_form_field.dart';
import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddEditIngredientDialog extends ConsumerStatefulWidget {
  const AddEditIngredientDialog(this.restaurantStockModel,
      {this.ingredientModel, super.key});
  final RestaurantStockModel restaurantStockModel;
  final IngredientModel? ingredientModel;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddEditIngredientDialogState();
}

class _AddEditIngredientDialogState
    extends ConsumerState<AddEditIngredientDialog> {
  late TextEditingController nameTextController;
  late TextEditingController qtyAsGramTextCoontroller;
  late TextEditingController qtyAsPortionsTextCoontroller;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    nameTextController = TextEditingController();
    qtyAsGramTextCoontroller = TextEditingController();
    qtyAsPortionsTextCoontroller = TextEditingController();
    nameTextController.text = widget.restaurantStockModel.name;

    if (widget.ingredientModel != null) {
      nameTextController.text = widget.ingredientModel!.name;
      qtyAsPortionsTextCoontroller.text =
          "${widget.ingredientModel!.qtyAsPortion.formatDouble()}";
      // set as gram for kg unit type
      if (widget.ingredientModel!.unitType == UnitType.kg) {
        qtyAsGramTextCoontroller.text =
            "${widget.ingredientModel!.qtyAsGram.formatDouble()}";
      }
    }
  }

  @override
  void dispose() {
    nameTextController.dispose();
    qtyAsGramTextCoontroller.dispose();
    qtyAsPortionsTextCoontroller.dispose();
    super.dispose();
  }

  double convertPortionsToGrams(double portions, double portionsPerKg) {
    return portionsPerKg == 0 ? 0 : (portions / portionsPerKg) * 1000;
  }

  double convertGramsToPortions(double grams, double portionsPerKg) {
    return (grams / 1000) * portionsPerKg;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Center(
        child: DefaultTextView(
          text: S.of(context).add,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextFormField(
              showText: true,
              controller: nameTextController,
              hinttext: S.of(context).name,
            ),
            if (widget.restaurantStockModel.unitType == UnitType.kg) ...[
              kGap10,
              AppTextFormField(
                showText: true,
                format: numberTextFormatter,
                controller: qtyAsGramTextCoontroller,
                hinttext: S.of(context).qtyAsg,
                onchange: (value) {
                  double newValue =
                      double.tryParse(value.toString().trim()) ?? 0;
                  double portions = convertGramsToPortions(
                      newValue, widget.restaurantStockModel.portionsPerKg!);
                  qtyAsPortionsTextCoontroller.text =
                      "${portions.formatDouble()}";
                },
              ),
            ],
            kGap10,
            AppTextFormField(
              showText: true,
              format: numberTextFormatter,
              controller: qtyAsPortionsTextCoontroller,
              hinttext: S.of(context).qtyAsPortions,
              onchange: (value) {
                double newValue = double.tryParse(value.toString().trim()) ?? 0;
                if (widget.restaurantStockModel.unitType == UnitType.kg) {
                  double grams = convertPortionsToGrams(
                      newValue, widget.restaurantStockModel.portionsPerKg!);
                  qtyAsGramTextCoontroller.text = "${grams.formatDouble()}";
                }
              },
            ),
            kGap20,
            ElevatedButtonWidget(
              icon: Icons.add,
              width: double.infinity,
              states: [
                ref
                    .watch(restaurantStockControllerProvider)
                    .addIngredientRequestState,
                ref
                    .watch(restaurantStockControllerProvider)
                    .editIngredientRequestState
              ],
              text: widget.ingredientModel != null
                  ? S.of(context).edit
                  : S.of(context).add,
              onPressed: () {
                IngredientModel ingredientModel = IngredientModel(
                    id: widget.ingredientModel?.id,
                    name: nameTextController.text.trim(),
                    unitType: widget.restaurantStockModel.unitType,
                    restaurantStockId: widget.restaurantStockModel.id!,
                    qtyAsGram:
                        double.tryParse(qtyAsGramTextCoontroller.text) ?? 0,
                    qtyAsPortion:
                        double.tryParse(qtyAsPortionsTextCoontroller.text) ??
                            0);

                if (widget.ingredientModel != null) {
                  ref
                      .read(restaurantStockControllerProvider)
                      .editIngredient(ingredientModel, context);
                } else {
                  ref
                      .read(restaurantStockControllerProvider)
                      .addIngredient(ingredientModel, context);
                }
              },
            )
          ],
        ),
      ),
    );
  }
}
