import 'package:desktoppossystem/controller/restaurant_stock_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/ingrendient_model.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/screens/restaurant_stock/components/add_edit_ingredient_dialog.dart';
import 'package:desktoppossystem/shared/constances/app_constances.dart';
import 'package:desktoppossystem/shared/default%20components/are_you_sure_dialog.dart';
import 'package:desktoppossystem/shared/default%20components/default_price_text.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/default components/default_text_view.dart';
import '../../../shared/utils/enum.dart';

class IngredientItem extends ConsumerWidget {
  const IngredientItem(this.ingredientModel, {super.key});

  final IngredientModel ingredientModel;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Color currentcolor = ingredientModel.color!.getColorFromHex();

    Color textColor = currentcolor.getTextColorBasedOnBackground();
    final selectedIngredients = ref.watch(selectedIngredientsProvider);
    final isSelected = selectedIngredients.any(
      (element) => element.id == ingredientModel.id,
    );

    return Stack(
      alignment: AlignmentDirectional.topEnd,
      children: [
        InkWell(
          onTap: () {
            ref
                .read(restaurantStockControllerProvider)
                .onIngredientPressed(ingredientModel);
          },
          onDoubleTap: () {
            showDialog(
              context: context,
              builder: (context) => AddEditIngredientDialog(
                ref.read(selectedRestaurantStockProvider)!,
                ingredientModel: ingredientModel,
              ),
            );
          },
          onLongPress: () {
            showDialog(
              context: context,
              builder: (context) => AreYouSureDialog(
                agreeText: S.of(context).delete,
                "Are you sure you want to delete '${ingredientModel.name}'",
                onCancel: () => context.pop(),
                onAgree: () async {
                  await ref
                      .read(restaurantStockControllerProvider)
                      .deleteIngredient(ingredientModel.id!, context);
                },
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                borderRadius: kRadius5,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    currentcolor,
                    currentcolor.withValues(alpha: 0.9),
                    currentcolor.withValues(alpha: 0.6),
                  ],
                ),
              ),
              padding: kPadd3,

              ///   width: psc.productWidth,
              //   height: psc.producHeight,
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: DefaultTextView(
                        maxlines: 3,
                        text: ingredientModel.nameWithQty,
                        textAlign: TextAlign.center,
                        color: textColor,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Divider(height: 1, color: textColor),
                  Row(
                    children: [
                      if (ingredientModel.unitType == UnitType.kg) ...[
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: AppPriceText(
                              text: "${ingredientModel.qtyAsGram}",
                              unit: "g",
                              color: textColor,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                          child: VerticalDivider(color: textColor, width: 0.4),
                        ),
                      ],
                      Expanded(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: AppPriceText(
                            text: "${ingredientModel.qtyAsPortion}",
                            unit: "po",
                            color: textColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (ref.read(mainControllerProvider).isSuperAdmin) ...[
                    Divider(height: 1, color: textColor),
                    AppPriceText(
                      fontWeight: FontWeight.bold,
                      text:
                          "${ingredientModel.pricePerIngredient?.formatDouble()}",
                      unit: AppConstance.primaryCurrency,
                      color: textColor,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        if (isSelected) Icon(Icons.check_circle, color: context.primaryColor),
      ],
    );
  }
}
