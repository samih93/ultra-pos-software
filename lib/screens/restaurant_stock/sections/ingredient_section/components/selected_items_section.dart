import 'package:desktoppossystem/controller/category_controller.dart';
import 'package:desktoppossystem/controller/product_controller.dart';
import 'package:desktoppossystem/controller/restaurant_stock_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/product_model.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/default%20components/elevated_button_widget.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedMenuItemsProvider = StateProvider<List<ProductModel>>((ref) {
  return [];
});

class SelectedItemsSection extends ConsumerWidget {
  const SelectedItemsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(selectedMenuItemsProvider);
    return Column(
      children: [
        DefaultTextView(
          text: S.of(context).selectedItems,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        Expanded(
          child: ListView.separated(
            separatorBuilder: (context, index) =>
                const Divider(height: 1, color: Pallete.greyColor),
            itemCount: items.length,
            itemBuilder: (context, index) => ListTile(
              dense: true,
              title: DefaultTextView(
                text: "${index + 1}- ${items[index].name}",
                maxlines: 2,
              ),
              trailing: IconButton(
                onPressed: () {
                  //Riverpod uses reference equality by default, so when you modify
                  //the existing list and set it back, it sees the same list reference and doesn't trigger a rebuild.
                  final currentItems = ref.read(selectedMenuItemsProvider);
                  final newItems = List<ProductModel>.from(
                    currentItems,
                  ); // Create new list
                  newItems.removeAt(index);
                  ref.read(selectedMenuItemsProvider.notifier).state =
                      newItems; // New reference
                },
                icon: const Icon(Icons.close),
              ),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (items.isNotEmpty) ...[
              ElevatedButtonWidget(
                text: S.of(context).removeAll,
                onPressed: () async {
                  ref.read(selectedMenuItemsProvider.notifier).state = [];
                },
              ),
              ElevatedButtonWidget(
                text: S.of(context).add,
                icon: Icons.add,
                onPressed: () async {
                  for (var item in items) {
                    await extractIngredientByItem(ref, item, context);
                  }
                  ref.read(selectedMenuItemsProvider.notifier).state = [];
                  context.pop();
                },
              ),
            ],
          ],
        ),
      ],
    );
  }

  Future<void> extractIngredientByItem(
    WidgetRef ref,
    ProductModel product,
    BuildContext context,
  ) async {
    final list = await ref
        .read(restaurantStockControllerProvider)
        .fetchIngrdientsBySandwich(product.id!);
    ref
        .read(selectedIngredientsProvider.notifier)
        .update((state) => state.union(list.toSet()));
    ref.read(categoryControllerProvider).clearCategorySelection();
    ref.read(productControllerProvider).clearProductsSelection();
  }
}
