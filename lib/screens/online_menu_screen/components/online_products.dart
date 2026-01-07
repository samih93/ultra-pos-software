import 'package:desktoppossystem/controller/menu_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/product_model.dart';
import 'package:desktoppossystem/screens/online_menu_screen/sub_sreens/add_edit_menu_product_screen.dart';
import 'package:desktoppossystem/shared/default%20components/app_squared_outlined_button.dart';
import 'package:desktoppossystem/shared/default%20components/app_text_title_section.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/default%20components/quiver_circular_indicator.dart';
import 'package:desktoppossystem/shared/services/scroll_behavior_service.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'online_product_item.dart';

class OnlineProducts extends ConsumerStatefulWidget {
  const OnlineProducts({Key? key}) : super(key: key);

  @override
  ConsumerState<OnlineProducts> createState() => _OnlineProductsState();
}

class _OnlineProductsState extends ConsumerState<OnlineProducts> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(menuControllerProvider.notifier).loadMoreProducts();
    }
  }

  @override
  Widget build(BuildContext context) {
    var menuController = ref.watch(menuControllerProvider);

    return Container(
      margin: kPaddH5,
      padding: defaultPadding,
      decoration: BoxDecoration(
        borderRadius: defaultRadius,
        color: context.cardColor,
        border: Border.all(color: Pallete.greyColor),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const AppTextTitleSection("Products"),
              kGap10,
              const Spacer(),
              if (menuController.selectedCategory != null)
                DefaultTextView(
                  text: '${menuController.products.length} items',
                ),
              kGap10,

              AppSquaredOutlinedButton(
                isDisabled:
                    ref.watch(menuControllerProvider).selectedCategory != null
                    ? false
                    : true,
                child: const Icon(Icons.add),
                onPressed: () {
                  context.to(
                    AddEditMenuProductScreen(
                      c: ref.watch(menuControllerProvider).selectedCategory!,
                    ),
                  );
                },
              ),
            ],
          ),
          kGap10,
          Expanded(
            child: menuController.selectedCategory == null
                ? Center(
                    child: Text(
                      'Select a category to view products',
                      style: context.textTheme.bodyLarge?.copyWith(
                        color: Pallete.greyColor,
                      ),
                    ),
                  )
                : menuController.getProductsState == RequestState.loading &&
                      menuController.products.isEmpty
                ? const Center(
                    child: CoreCircularIndicator(height: 60, coloredLogo: true),
                  )
                : menuController.products.isEmpty
                ? Center(
                    child: Text(
                      'No products found in this category',
                      style: context.textTheme.bodyLarge?.copyWith(
                        color: Pallete.greyColor,
                      ),
                    ),
                  )
                : ScrollConfiguration(
                    behavior: MyCustomScrollBehavior(),
                    child: ReorderableListView.builder(
                      scrollController: _scrollController,
                      buildDefaultDragHandles: true,
                      itemCount:
                          menuController.products.length +
                          (menuController.hasMoreProducts ? 1 : 0),
                      onReorder: (oldIndex, newIndex) {
                        // Update sort order locally first
                        if (oldIndex < newIndex) {
                          newIndex -= 1;
                        }

                        // Create a new list with updated order
                        final reorderedProducts = List<ProductModel>.from(
                          menuController.products,
                        );
                        final item = reorderedProducts.removeAt(oldIndex);
                        reorderedProducts.insert(newIndex, item);

                        // Update all sort values with new ProductModel instances
                        final updatedProducts = <ProductModel>[];
                        for (int i = 0; i < reorderedProducts.length; i++) {
                          final product = reorderedProducts[i];
                          updatedProducts.add(
                            ProductModel(
                              id: product.id,
                              name: product.name,
                              sellingPrice: product.sellingPrice,
                              description: product.description,
                              isOffer: product.isOffer,
                              categoryId: product.categoryId,
                              image: product.image,
                              isActive: product.isActive,
                              sortOrder: i,
                              selected: product.selected,
                            ),
                          );
                        }

                        // Then sync to server
                        ref
                            .read(menuControllerProvider.notifier)
                            .syncProductsOrder(updatedProducts);
                      },
                      itemBuilder: (context, index) {
                        if (index == menuController.products.length) {
                          return Container(
                            key: const ValueKey('loading_indicator'),
                            height: 70,
                            alignment: Alignment.center,
                            child: const CoreCircularIndicator(
                              height: 40,
                              coloredLogo: true,
                            ),
                          );
                        }

                        final product = menuController.products[index];
                        return Container(
                          key: ValueKey('online_product_${product.id}_$index'),
                          margin: const EdgeInsets.only(bottom: 5),
                          child: Slidable(
                            startActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              children: [
                                SlidableAction(
                                  spacing: 0,
                                  padding: const EdgeInsets.all(1),
                                  onPressed: (_) {
                                    ref
                                        .read(menuControllerProvider.notifier)
                                        .toggleProductActive(
                                          product.id!,
                                          !(product.isActive ?? true),
                                        );
                                  },
                                  label: product.isActive == true
                                      ? S.of(context).hide
                                      : S.of(context).show,
                                  backgroundColor: Pallete.primaryColor,
                                  foregroundColor: Colors.white,
                                  icon: product.isActive == true
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                              ],
                            ),
                            endActionPane: ActionPane(
                              motion: const ScrollMotion(),
                              children: [
                                SlidableAction(
                                  spacing: 0,
                                  padding: const EdgeInsets.all(1),
                                  onPressed: (_) {
                                    ref
                                        .read(menuControllerProvider.notifier)
                                        .deleteProduct(product.id!);
                                  },
                                  backgroundColor: const Color(0xFFFE4A49),
                                  foregroundColor: Colors.white,
                                  icon: Icons.delete,
                                ),
                              ],
                            ),
                            child: OnlineProductItem(product: product),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
