import 'package:desktoppossystem/controller/restaurant_stock_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/restaurant_stock_model.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/screens/restaurant_stock/subscreens/add_restaurant_stock.dart/add_restauarnt_stock_item_screen.dart';
import 'package:desktoppossystem/shared/constances/app_constances.dart';
import 'package:desktoppossystem/shared/default%20components/are_you_sure_dialog.dart';
import 'package:desktoppossystem/shared/default%20components/default_price_text.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RestaurantStockItem extends ConsumerWidget {
  const RestaurantStockItem(this.model, {super.key});
  final RestaurantStockModel model;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Color backColor = model.color!.getColorFromHex();
    Color textColor = backColor.getTextColorBasedOnBackground();
    final isDarkMode = ref.read(isDarkModeProvider);

    return InkWell(
      onTap: () {
        ref.read(restaurantStockControllerProvider).onSelectStockItem(model);
      },
      onDoubleTap: () {
        if (ref.read(mainControllerProvider).isSuperAdmin) {
          ref.read(selectedUnitTypeProvider.notifier).state = model.unitType;
          ref.read(stockBackColorProvider.notifier).state = model.color!
              .getColorFromHex();
          ref.read(stockTextColorProvider.notifier).state = textColor;
          ref.watch(forPackagingProvider.notifier).state =
              model.forPackaging ?? false;
          context.to(AddRestaurantStockItemScreen(restaurantStockModel: model));
        }
      },
      onLongPress: () {
        if (ref.read(mainControllerProvider).isSuperAdmin) {
          showDialog(
            context: context,
            builder: (context) {
              RequestState deleteRequestState = RequestState.success;
              return StatefulBuilder(
                builder: (context, setState) => AreYouSureDialog(
                  agreeText: S.of(context).delete,
                  agreeState: deleteRequestState,
                  "Are you sure you want to delete '${model.name}'",
                  onCancel: () => context.pop(),
                  onAgree: () async {
                    setState(() {
                      deleteRequestState = RequestState.loading;
                    });
                    await ref
                        .read(restaurantStockControllerProvider)
                        .deleteStockItem(model.id!, context)
                        .whenComplete(() {
                          setState(() {
                            deleteRequestState = RequestState.success;
                          });
                        });
                  },
                ),
              );
            },
          );
        }
      },
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          borderRadius: kRadius5,
          border: model.isSelected!
              ? Border.all(
                  color: context.primaryColor.withValues(alpha: 0.8),
                  width: 3,
                )
              : const Border(
                  top: BorderSide.none,
                  bottom: BorderSide.none,
                  left: BorderSide.none,
                  right: BorderSide.none,
                ),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [
                    // Less gradient in dark mode - more subtle effect
                    backColor,
                    backColor.withValues(alpha: 0.95),
                    backColor.withValues(alpha: 0.9),
                  ]
                : [
                    backColor,
                    backColor.withValues(alpha: 0.9),
                    backColor.withValues(alpha: 0.6),
                  ],
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
        child: Row(
          children: [
            Expanded(
              child: Column(
                //  mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    flex: 2,
                    child: DefaultTextView(
                      text: model.name,
                      maxlines: 2,
                      textHeight: 1.2,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      fontSize: 14,
                      color: textColor,
                    ),
                  ),
                  if (ref.read(mainControllerProvider).isSuperAdmin) ...[
                    Divider(color: textColor, height: 0.4),
                    AppPriceText(
                      text:
                          "${(model.pricePerUnit * model.qty).formatDouble()}",
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      unit: AppConstance.primaryCurrency,
                    ),
                    Divider(color: textColor, height: 0.4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppPriceText(
                          text: "1",
                          unit: model.unitType.uniteTypeToString(),
                          color: textColor,
                        ),
                        FittedBox(
                          child: AppPriceText(
                            text: "=>${model.pricePerUnit}",
                            unit: AppConstance.primaryCurrency,
                            color: textColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                  Divider(color: textColor, height: 0.4),
                  Expanded(
                    child: Row(
                      children: [
                        Expanded(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: AppPriceText(
                              text: "${model.qty.formatDouble()}",
                              unit: "${model.unitType.uniteTypeToString()}",
                              color: textColor,
                            ),
                          ),
                        ),
                        if (model.unitType == UnitType.kg) ...[
                          VerticalDivider(color: textColor, width: 0.4),
                          Expanded(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: AppPriceText(
                                text:
                                    "${(model.qty * model.portionsPerKg!).formatDouble()}",
                                color: textColor,
                                unit: "${UnitType.portion.uniteTypeToString()}",
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
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
