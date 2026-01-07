import 'package:desktoppossystem/controller/restaurant_stock_controller.dart';
import 'package:desktoppossystem/screens/error_section.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/screens/restaurant_stock/components/add_edit_ingredient_dialog.dart';
import 'package:desktoppossystem/screens/restaurant_stock/components/ingredient_item.dart';
import 'package:desktoppossystem/screens/restaurant_stock/sections/ingredient_section/components/select_menu_ingredients_dialog.dart';
import 'package:desktoppossystem/shared/default%20components/app_squared_outlined_button.dart';
import 'package:desktoppossystem/shared/default%20components/app_text_title_section.dart';
import 'package:desktoppossystem/shared/default%20components/quiver_circular_indicator.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class IngredientsSection extends ConsumerWidget {
  const IngredientsSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var ingredients = ref.watch(ingredientsProvider);
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const AppTextTitleSection("Ingredients"),
            if (ref.read(mainControllerProvider).isSuperAdmin)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (ref.watch(selectedSandwichProvider) != null)
                    AppSquaredOutlinedButton(
                      child: const Icon(Icons.list),
                      onPressed: () async {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return const SelectMenuIngredientsDialog();
                          },
                        );
                      },
                    ),
                  kGap10,
                  AppSquaredOutlinedButton(
                    isDisabled:
                        ref.watch(selectedRestaurantStockProvider) == null,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AddEditIngredientDialog(
                          ref.read(selectedRestaurantStockProvider)!,
                        ),
                      );
                    },
                    child: const Icon(Icons.add),
                  ),
                ],
              ),
          ],
        ),
        ingredients.when(
          data: (data) {
            return data.isEmpty
                ? Expanded(
                    child: Center(
                      child: Text(
                        "No ingredients founds",
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 25,
                        ),
                      ),
                    ),
                  )
                : Expanded(
                    child: GridView.builder(
                      itemCount: data.length,
                      itemBuilder: (context, index) =>
                          IngredientItem(data[index]),
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            mainAxisSpacing: 5,
                            crossAxisSpacing: 5,
                            maxCrossAxisExtent: 130,
                          ),
                    ),
                  );
          },
          error: (error, stackTrace) =>
              ErrorSection(retry: () => ref.refresh(ingredientsProvider)),
          loading: () => const Center(child: CoreCircularIndicator()),
        ),
      ],
    );
  }
}
