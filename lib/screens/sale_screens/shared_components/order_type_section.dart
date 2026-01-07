import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
import 'package:desktoppossystem/shared/default%20components/custom_toggle_button.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedOrderTypeProvider = StateProvider<OrderType>((ref) {
  return OrderType.dineIn;
});

class OrderTypeSection extends ConsumerWidget {
  const OrderTypeSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saleController = ref.watch(saleControllerProvider);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Badge(
              label: Text(saleController.totalItemQty.toStringAsFixed(0)),
              child: const Icon(Icons.shopping_cart),
            ),
          ],
        ),
        CustomToggleButton(
          text1: S.of(context).dineIn,
          text2: S.of(context).delivery,
          isSelected: ref.watch(selectedOrderTypeProvider) == OrderType.dineIn,
          onPressed: (index) {
            ref.read(selectedOrderTypeProvider.notifier).state = index == 0
                ? OrderType.dineIn
                : OrderType.delivery;
          },
        ),
      ],
    );
  }
}
