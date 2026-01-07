import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/screens/profit_report_screen/profit_controller.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductsSalesHeader extends ConsumerWidget {
  const ProductsSalesHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isLtr = ref.read(mainControllerProvider).isLtr;
    bool isDescending = ref.watch(
      profitControllerProvider.select((controller) => controller.isDescending),
    );
    SortType selectedSortType = ref.watch(
      profitControllerProvider.select(
        (controller) => controller.selectedSortType,
      ),
    );

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: DefaultTextView(
            textAlign: isLtr ? TextAlign.left : TextAlign.right,
            text: S.of(context).product,
            fontWeight: FontWeight.bold,
          ),
        ),
        Expanded(
          flex: 2,
          child: Center(
            child: DefaultTextView(
              text: S.of(context).barcode,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              ref.read(profitControllerProvider).sortSalesOrderByQty();
            },
            child: Row(
              mainAxisAlignment: .spaceEvenly,
              children: [
                DefaultTextView(
                  text: S.of(context).qty,
                  fontWeight: FontWeight.bold,
                ),
                Icon(
                  selectedSortType == SortType.qty
                      ? (isDescending
                            ? Icons.arrow_drop_down
                            : Icons.arrow_drop_up)
                      : Icons.unfold_more,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: DefaultTextView(
              text: S.of(context).costPrice,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: Center(
            child: DefaultTextView(
              text: S.of(context).sellingPrice,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              ref
                  .read(profitControllerProvider)
                  .sortSalesOrderByProfitDescending();
            },
            child: Row(
              mainAxisAlignment: .spaceEvenly,
              children: [
                DefaultTextView(
                  text: S.of(context).profit,
                  fontWeight: FontWeight.bold,
                ),
                Icon(
                  selectedSortType == SortType.profit
                      ? (isDescending
                            ? Icons.arrow_drop_down
                            : Icons.arrow_drop_up)
                      : Icons.unfold_more,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
