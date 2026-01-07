import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
import 'package:desktoppossystem/shared/default%20components/elevated_button_widget.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReOpenTable extends ConsumerWidget {
  const ReOpenTable({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saleController = ref.watch(saleControllerProvider);
    return saleController.basketItems.any(
              (element) => element.isJustOrdered == true,
            ) &&
            saleController.basketItems.every(
              (element) => element.isNewToBasket == false,
            )
        ? Row(
            children: [
              kGap10,
              ElevatedButtonWidget(
                text: "reOpen Table",
                onPressed: () {
                  ref
                      .read(saleControllerProvider)
                      .onSelectTable(saleController.selectedTable!);
                },
              ),
            ],
          )
        : kEmptyWidget;
  }
}
