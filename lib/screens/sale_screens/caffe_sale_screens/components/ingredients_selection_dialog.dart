import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/ingrendient_model.dart';
import 'package:desktoppossystem/models/product_model.dart';
import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/default%20components/elevated_button_widget.dart';
import 'package:desktoppossystem/shared/default%20components/app_text_form_field.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/my_linears_gradient.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class IngredientSelectionDialog extends ConsumerStatefulWidget {
  final ProductModel product;

  const IngredientSelectionDialog({super.key, required this.product});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _IngredientSelectionDialogState();
}

class _IngredientSelectionDialogState
    extends ConsumerState<IngredientSelectionDialog> {
  late List<IngredientModel> ingredients;
  late TextEditingController notesController;

  @override
  void initState() {
    super.initState();
    ingredients = widget.product.ingredients ?? []; // Clone the list

    for (var element in ingredients) {
      if (widget.product.withoutIngredients != null &&
          widget.product.withoutIngredients!.any((e) => e.id == element.id)) {
        element.isSelected = false;
      } else {
        element.isSelected = true;
      }
    }
    notesController = TextEditingController();
    notesController.text = widget.product.notes;
  }

  @override
  void dispose() {
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      alignment: AlignmentDirectional.center,
      buttonPadding: const EdgeInsets.only(bottom: 200),
      insetPadding: EdgeInsets.symmetric(
        horizontal: context.width * 0.1,
        vertical: context.height * 0.05,
      ),
      title: Align(
        alignment: AlignmentDirectional.topEnd,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButtonWidget(
              icon: Icons.clear,
              text: "clear",
              onPressed: () {
                notesController.clear();
                setState(() {
                  for (var element in ingredients) {
                    element.isSelected = true;
                  }
                });
              },
            ),
            const SizedBox(width: 10),
            ElevatedButtonWidget(
              icon: Icons.save,
              text: "Save",
              onPressed: () {
                ref
                    .read(saleControllerProvider)
                    .unSelectIngredients(
                      widget.product,
                      updatedIngredients: ingredients,
                      notes: notesController.text.trim(),
                    );
                context.pop();
              },
            ),
          ],
        ),
      ),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: SizedBox(
            height: context.height * 0.7,
            width: context.width,
            child: ingredients.isEmpty
                ? Center(
                    child: DefaultTextView(
                      text: S.of(context).noIngredientFound,
                      color: Pallete.greyColor,
                      fontSize: 20,
                    ),
                  )
                : Row(
                    crossAxisAlignment: .start,
                    children: [
                      Expanded(
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 10,
                              runSpacing: 10,
                              children: ingredients
                                  .where((e) => !e.forPackaging!)
                                  .map(
                                    (e) => GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          e.isSelected = !e.isSelected;
                                        });
                                      },
                                      child: Stack(
                                        alignment: AlignmentDirectional.center,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              gradient: e.isSelected
                                                  ? myLinearGradient(context)
                                                  : mydisabledLinearGradient(),
                                            ),
                                            padding: kPadd8,
                                            width: 100,
                                            height: 100,
                                            child: Center(
                                              child: Text(
                                                textAlign: TextAlign.center,
                                                e.name,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          if (!e.isSelected)
                                            Icon(
                                              Icons.close,
                                              size: 100,
                                              color: context.primaryColor
                                                  .getTextColorBasedOnBackground()
                                                  .withValues(alpha: 0.5),
                                            ),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: .start,
                          children: [
                            DefaultTextView(
                              text: S.of(context).notes,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            SingleChildScrollView(
                              child: Wrap(
                                spacing: 5,
                                runSpacing: 5,
                                direction: Axis.horizontal,
                                children: [
                                  ElevatedButtonWidget(
                                    text: "cut the sandwich",
                                    onPressed: _cutTheSandwich,
                                  ),
                                  kGap5,
                                  ElevatedButtonWidget(
                                    text: "Rare",
                                    onPressed: _rare,
                                  ),
                                  kGap5,
                                  ElevatedButtonWidget(
                                    text: "Medium rare",
                                    onPressed: _mediumRare,
                                  ),
                                  kGap5,
                                  ElevatedButtonWidget(
                                    text: "Medium",
                                    onPressed: _medium,
                                  ),
                                  kGap5,
                                  ElevatedButtonWidget(
                                    text: "Medium well",
                                    onPressed: _mediumWell,
                                  ),
                                  kGap5,
                                  ElevatedButtonWidget(
                                    text: "Well done",
                                    onPressed: _wellDone,
                                  ),
                                  kGap5,
                                  ElevatedButtonWidget(
                                    text: "extra cheese",
                                    onPressed: _extraCheese,
                                  ),
                                  kGap5,
                                ],
                              ),
                            ),
                            kGap10,
                            AppTextFormField(
                              height: 200,
                              contentPadding: kPadd10,
                              controller: notesController,
                              hinttext: "Write your note here",
                              minline: 5,
                              maxligne: 6,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  void _cutTheSandwich() {
    notesController.text = "Cut the sandwich in the half";
  }

  void _extraCheese() {
    notesController.text = "Extra cheese";
  }

  void _rare() {
    notesController.text = "Rare";
  }

  void _mediumRare() {
    notesController.text = "Medium rare";
  }

  void _medium() {
    notesController.text = "Medium";
  }

  void _mediumWell() {
    notesController.text = "Medium well";
  }

  void _wellDone() {
    notesController.text = "Well done";
  }
}
