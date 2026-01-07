import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
import 'package:desktoppossystem/shared/default%20components/app_squared_outlined_button.dart';
import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/services/scroll_behavior_service.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChangeQtyWidget extends ConsumerWidget {
  final String qty;
  ChangeQtyWidget({super.key, this.axix, required this.qty});

  final List<String> _numbers = [
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "0",
    ".",
    "c",
  ];
  final Axis? axix;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHorizontal = (axix ?? Axis.vertical) == Axis.horizontal;
    final isRtl = !isEnglishLanguage;

    List<Widget> numberButtons = _numbers.map((e) {
      EdgeInsets padding;
      if (isHorizontal) {
        padding = isRtl
            ? const EdgeInsets.only(right: 3)
            : const EdgeInsets.only(left: 3);
      } else {
        padding = const EdgeInsets.only(bottom: 3);
      }
      return Padding(
        padding: padding,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return AppSquaredOutlinedButton(
              size: const Size(41, 41),
              onPressed: () {
                if (_numbers.indexOf(e) != 11) {
                  ref.read(saleControllerProvider).onchangeQty(e);
                } else {
                  ref.read(saleControllerProvider).resetQty();
                }
              },
              child: Text(
                e,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          },
        ),
      );
    }).toList();

    // Add the Del button
    Widget delButton = Padding(
      padding: isHorizontal
          ? (isRtl
                ? const EdgeInsets.only(right: 3)
                : const EdgeInsets.only(left: 3))
          : const EdgeInsets.only(bottom: 3),
      child: AppSquaredOutlinedButton(
        size: const Size(41, 41),
        child: const Text(style: TextStyle(color: Pallete.redColor), "Del"),
        onPressed: () {
          ref.read(saleControllerProvider).removeItemFromBasket(context);
        },
      ),
    );

    numberButtons.add(delButton);

    return Container(
      padding: defaultPadding,
      decoration: BoxDecoration(
        border: !isHorizontal ? Border.all(color: Pallete.greyColor) : null,
        borderRadius: !isHorizontal ? defaultRadius : null,
        color: context.cardColor,
      ),
      child: ScrollConfiguration(
        behavior: MyCustomScrollBehavior(),
        child: SingleChildScrollView(
          scrollDirection: axix ?? Axis.vertical,
          child: isHorizontal
              ? Row(children: numberButtons)
              : Column(children: numberButtons),
        ),
      ),
    );
  }

  buildIttemNumber(BuildContext context, String item) => Container(
    width: 60,
    decoration: BoxDecoration(
      color: item == "Del"
          ? Colors.red.shade100.withValues(alpha: 0.4)
          : Colors.transparent,
      border: Border.all(
        color: item == "Del" ? Colors.red.shade100 : Colors.grey.shade300,
      ),
    ),
    child: FittedBox(
      fit: BoxFit.scaleDown,
      child: Text(
        item == "Del" ? S.of(context).delete : item,
        style: TextStyle(
          color: item == "Del" ? Colors.red : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),
  );
}
