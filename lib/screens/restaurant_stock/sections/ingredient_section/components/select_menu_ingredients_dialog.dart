import 'dart:ui';

import 'package:desktoppossystem/controller/category_controller.dart';
import 'package:desktoppossystem/controller/product_controller.dart';
import 'package:desktoppossystem/screens/restaurant_stock/sections/ingredient_section/components/selected_items_section.dart';
import 'package:desktoppossystem/screens/sale_screens/caffe_sale_screens/components/categories/components/category_item.dart';
import 'package:desktoppossystem/screens/sale_screens/caffe_sale_screens/components/categories/cateogries_settings_controller.dart';
import 'package:desktoppossystem/screens/sale_screens/caffe_sale_screens/components/products/componenets/product_item.dart';
import 'package:desktoppossystem/screens/sale_screens/caffe_sale_screens/components/products/products_settings_controller.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectMenuIngredientsDialog extends ConsumerWidget {
  const SelectMenuIngredientsDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoryController = ref.watch(categoryControllerProvider);
    final productController = ref.watch(productControllerProvider);
    return AlertDialog(
      title: const Center(
        child: DefaultTextView(
          fontSize: 18,
          text: "Select Item to Add Its Ingredients",
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SizedBox(
        height: context.height * 0.7,
        width: context.width * 0.8,
        child: Row(
          children: [
            Expanded(
              flex: 5,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: kPadd3,
                    height: ref
                        .read(categoriesSettingsControllerProvider)
                        .categoriesSectionHeight,
                    child: ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context).copyWith(
                        dragDevices: {
                          PointerDeviceKind.mouse,
                          PointerDeviceKind.touch,
                        },
                      ),
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          //     childAspectRatio: 0.6,
                          mainAxisSpacing: 5,
                          crossAxisSpacing: 5,
                          mainAxisExtent: ref
                              .watch(categoriesSettingsControllerProvider)
                              .categoryWidth,
                          crossAxisCount: ref
                              .watch(categoriesSettingsControllerProvider)
                              .nbOfLines,
                        ),
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (_, index) {
                          categoryController.categories.sort(
                            (a, b) => a.id!.compareTo(b.id!),
                          );
                          return CategoryItem(
                            categoryController.categories[index],
                          );
                        },
                        itemCount: categoryController.categories.length,
                      ),
                    ),
                  ),
                  kGap20,
                  Expanded(
                    child: GridView.builder(
                      itemCount: productController.products.length,
                      itemBuilder: (context, index) {
                        final product = productController.products[index];

                        return ProductItem(
                          product,
                          onTap: () async {
                            ref
                                .read(selectedMenuItemsProvider.notifier)
                                .update((state) => [...state, product]);
                          },
                        );
                      },
                      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                        mainAxisSpacing: 5,
                        crossAxisSpacing: 5,
                        maxCrossAxisExtent: ref
                            .read(productsSettingsControllerProvider)
                            .productWidth,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            kGap5,
            const VerticalDivider(color: Pallete.primaryColorDark),
            kGap5,
            const Expanded(flex: 2, child: SelectedItemsSection()),
          ],
        ),
      ),
    );
  }
}
