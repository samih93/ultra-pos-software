import 'package:desktoppossystem/models/product_model.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/screens/sale_screens/caffe_sale_screens/components/ingredients_selection_dialog.dart';
import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BasketItem extends ConsumerWidget {
  const BasketItem(this.p, this.index, {super.key});
  final ProductModel p;
  final int index;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool reachMinSelling = p.minSellingPrice == null || p.minSellingPrice == 0
        ? false
        : p.minSellingPrice! > p.costPrice! &&
              p.sellingPrice! <= p.minSellingPrice!
        ? true
        : false;
    bool tableSelected = ref.read(saleControllerProvider).selectedTable != null;

    return GestureDetector(
      onTap: () {
        ref.read(saleControllerProvider).onselectProduct(p);
      },
      onLongPress: () {
        showDialog(
          context: context,
          builder: (context) => IngredientSelectionDialog(product: p),
        );
      },
      child: Dismissible(
        key: UniqueKey(),
        direction: tableSelected
            ? DismissDirection.none
            : DismissDirection
                  .endToStart, // Disable swiping when tableSelected is true
        movementDuration: const Duration(seconds: 1),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Pallete.redColor,
                Colors.red.shade500,
              ], // Gradient effect
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          alignment: Alignment.centerRight,
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.delete, // Trash can icon
                color: Colors.white,
                size: 20,
              ),
              SizedBox(width: 10), // Spacer between icon and edge
              Text(
                'Delete', // Optional text to describe action
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        onDismissed: (direction) {
          ref
              .read(saleControllerProvider)
              .removeItemFromBasket(context, index: index);
        },
        child: Stack(
          alignment: AlignmentDirectional.topEnd,
          children: [
            Container(
              padding: kPadd5,
              decoration: BoxDecoration(
                color: p.selected!
                    ? context.selectedListColor
                    : context.cardColor,
                border: const Border(
                  bottom: BorderSide(color: Colors.grey, width: 1.0),
                ),
              ),
              child: Column(
                crossAxisAlignment: .start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: DefaultTextView(
                          maxlines: 2,
                          textAlign: ref.watch(mainControllerProvider).isLtr
                              ? TextAlign.left
                              : TextAlign.right,
                          text: "${p.name}",
                          fontSize: 16,
                        ),
                      ),
                      Expanded(child: Text(p.qty.toString())),
                      Expanded(
                        child: Text(
                          style: TextStyle(
                            color: reachMinSelling ? Pallete.redColor : null,
                          ),
                          "${p.sellingPrice!.formatDouble()}",
                        ),
                      ),
                    ],
                  ),
                  if (p.withoutIngredients != null &&
                      p.withoutIngredients!.isNotEmpty)
                    for (int i = 0; i < p.withoutIngredients!.length; i++)
                      Text(
                        "*without ${p.withoutIngredients![i].name}*",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                  if (p.notes.isNotEmpty)
                    Text(
                      "*Note: ${p.notes}*",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            if (p.discount != null && p.discount! > 0)
              DefaultTextView(
                color: Pallete.redColor,
                text: "${p.discount} %",
                fontWeight: FontWeight.bold,
              ),
            if (ref.read(saleControllerProvider).selectedTable != null)
              Align(
                alignment: AlignmentDirectional.topEnd,
                child: CircleAvatar(
                  radius: 6,
                  backgroundColor: p.isJustOrdered == true
                      ? context.primaryColor
                      : p.isNewToBasket == true
                      ? Pallete.greenColor
                      : Pallete.blackColor,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
