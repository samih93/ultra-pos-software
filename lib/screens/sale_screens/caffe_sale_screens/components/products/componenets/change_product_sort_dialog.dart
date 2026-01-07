import 'package:desktoppossystem/controller/product_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/sale_screens/caffe_sale_screens/components/products/componenets/sort_product_item.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/default%20components/elevated_button_widget.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChangeProductSortDialog extends ConsumerWidget {
  const ChangeProductSortDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productController = ref.watch(productControllerProvider);
    return AlertDialog(
      actions: [
        ElevatedButtonWidget(
          width: double.infinity,
          text: S.of(context).save,
          onPressed: () {
            ref.read(productControllerProvider).saveNewProductsSortOrder();
            context.pop();
          },
          icon: Icons.save,
        ),
      ],
      title: DefaultTextView(
        textAlign: TextAlign.center,
        fontSize: 16,
        text: S.of(context).changeProductOrder,
      ),
      content: SizedBox(
        height: context.height * 0.6,
        width: 300,
        child: Center(
          child: SingleChildScrollView(
            child: ReorderableListView(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              buildDefaultDragHandles: true,
              onReorder: (int oldIndex, int newIndex) {
                ref
                    .read(productControllerProvider)
                    .reSortList(oldIndex, newIndex);
              },
              children: productController.products.map((product) {
                return SortProductItem(
                  productModel: product,
                  key: ValueKey("sort_${product.id}"),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
