import 'package:desktoppossystem/screens/restaurant_stock/sections/ingredient_section/ingredients_section.dart';
import 'package:desktoppossystem/screens/restaurant_stock/sections/product_section.dart';
import 'package:desktoppossystem/screens/restaurant_stock/sections/stock_sections/stock_section.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RestaurantStockScreen extends ConsumerWidget {
  const RestaurantStockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Column(
            crossAxisAlignment: .start,
            children: [
              const StockSection().baseContainer(context.cardColor),
              Expanded(
                child: const IngredientsSection().baseContainer(
                  context.cardColor,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 2,
          child: const ProductSection().baseContainer(context.cardColor),
        ),
      ],
    );
  }
}
