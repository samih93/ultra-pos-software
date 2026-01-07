import 'package:desktoppossystem/controller/printer_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
import 'package:desktoppossystem/shared/default%20components/elevated_button_widget.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrderButton extends ConsumerWidget {
  const OrderButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saleController = ref.watch(saleControllerProvider);
    return saleController.selectedTable != null &&
            saleController.basketItems
                .any((element) => element.isNewToBasket == true)
        ? Row(
            children: [
              kGap10,
              ElevatedButtonWidget(
                states: [
                  ref.watch(printerControllerProvider).makeOrderRequestState
                ],
                text: S.of(context).order,
                onPressed: () async {
                  await ref.read(printerControllerProvider).makeOrder(context);
                },
              )
            ],
          )
        : kEmptyWidget;
  }
}
