import 'package:desktoppossystem/controller/auth_controller.dart';
import 'package:desktoppossystem/controller/restaurant_stock_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
import 'package:desktoppossystem/shared/default%20components/are_you_sure_dialog.dart';
import 'package:desktoppossystem/shared/default%20components/elevated_button_widget.dart';
import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StaffWasteButton extends ConsumerWidget {
  const StaffWasteButton({super.key});

  makeWasteTransaction(WidgetRef ref) {
    // ref
    //                               .read(restaurantStockControllerProvider)
    //                               .makeStockTransaction(
    //                                   restaurantStockModel.mapToFoodWasteTracker(
    //                                       employeeId:
    //                                           ref.read(currentUserProvider)?.id ??
    //                                               0,
    //                                       transactionQty: wasteQty,
    //                                       transactionDate:
    //                                           DateTime.now().toString(),
    //                                       wasteType: WasteType.normal,
    //                                       transactionType:
    //                                           StockTransactionType.stockOut,
    //                                       transactionReason:
    //                                           wasteReasonTextController.text
    //                                               .trim()))
  }
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var saleController = ref.watch(saleControllerProvider);
    var isWorkWithInGredients =
        ref.watch(mainControllerProvider).isWorkWithIngredients;
    if (!isWorkWithInGredients) return kEmptyWidget;
    return ElevatedButtonWidget(
      isDisabled: saleController.basketItems.isEmpty,
      onPressed: () async {
        showDialog(
            context: context,
            builder: (context) => AreYouSureDialog(
                  "${S.of(context).markeThisOrderAsWasted} ${S.of(context).quetionMark}",
                  agreeText: S.of(context).yes,
                  onCancel: () => context.pop(),
                  onAgree: () async {
                    context.pop();
                    Future transactionsFuture =
                        Future.delayed(Duration.zero).then((val) async {
                      for (var product in saleController.basketItems) {
                        await ref
                            .read(restaurantStockControllerProvider)
                            .makeStockTransaction(isStaffWaste: true, [
                          ...product.ingredientsToBeAdded.map((e) {
                            return e.mapIngredientToStockTransaction(
                                employeeId:
                                    ref.read(currentUserProvider)?.id ?? 0,
                                transactionQty: product.qty!,
                                transactionDate: DateTime.now().toString(),
                                wasteType: WasteType.staff,
                                transactionType: StockTransactionType.stockOut,
                                ingredient: e,
                                transactionReason: product.name,
                                qtyAsGram:
                                    e.unitType == UnitType.kg ? e.qtyAsGram : 0,
                                qtyAsPortion: e.unitType == UnitType.portion
                                    ? e.qtyAsPortion
                                    : 0,
                                productId: product.id);
                          })
                        ]);
                      }
                    });

                    await Future.wait([
                      transactionsFuture,
                      ref
                          .read(restaurantStockControllerProvider)
                          .bulkWasteTransaction(saleController.basketItems)
                    ]).whenComplete(() {
                      ref.read(saleControllerProvider).resetSaleScreen();
                      globalAppContext.pop();
                    });
                  },
                ));
      },
      text: S.of(context).complementary,
    );
  }
}
