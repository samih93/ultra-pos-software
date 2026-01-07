import 'package:desktoppossystem/controller/product_controller.dart';
import 'package:desktoppossystem/controller/setting_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/product_model.dart';
import 'package:desktoppossystem/screens/error_section.dart';
import 'package:desktoppossystem/screens/sale_screens/caffe_sale_screens/components/products/componenets/product_item.dart';
import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
import 'package:desktoppossystem/screens/search_and_select_product_screens/search_and_select_product_screen.dart';
import 'package:desktoppossystem/shared/default%20components/app_squared_outlined_button.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/default%20components/elevated_button_widget.dart';
import 'package:desktoppossystem/shared/services/scroll_behavior_service.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:skeletonizer/skeletonizer.dart';

// State provider to toggle between list and grid view
// true = grid view (show more), false = list view (reorderable)
final quickSelectionViewModeProvider = StateProvider<bool>((ref) => false);

class QuickSelectionProductSection extends ConsumerWidget {
  const QuickSelectionProductSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final futureProducts = ref.watch(quiverSelectionProductsProvider);
    final show = ref
        .watch(settingControllerProvider)
        .showQuickSelectionProducts;
    return !show
        ? kEmptyWidget
        : futureProducts.when(
            data: (data) {
              final isGridView = ref.watch(quickSelectionViewModeProvider);
              return Container(
                padding: defaultPadding,
                decoration: BoxDecoration(
                  border: Border.all(color: Pallete.greyColor),
                  borderRadius: defaultRadius,
                  color: context.cardColor,
                ),
                child: Column(
                  children: [
                    // Add the button at the top
                    Row(
                      children: [
                        Expanded(
                          child: Tooltip(
                            message: "add product shortcut",
                            child: ElevatedButtonWidget(
                              text: S.of(context).add,
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) =>
                                      SearchAndSelectProductDialog(
                                        onSelected: (p0) {
                                          ref
                                              .read(productControllerProvider)
                                              .addProductToQuickSelection(
                                                p0.id!,
                                              );
                                          context.pop();
                                        },
                                      ),
                                );
                              },
                              icon: Icons.add,
                            ),
                          ),
                        ),
                        const SizedBox(width: 5),
                        // Toggle button between list and grid view
                        Tooltip(
                          message: isGridView
                              ? "Switch to list view (reorderable)"
                              : "Switch to grid view (show more)",
                          child: AppSquaredOutlinedButton(
                            size: const Size(30, 30),
                            onPressed: () {
                              ref
                                      .read(
                                        quickSelectionViewModeProvider.notifier,
                                      )
                                      .state =
                                  !isGridView;
                            },
                            child: Icon(
                              isGridView ? Icons.view_list : Icons.grid_view,
                              color: Pallete.primaryColorDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    kGap5,
                    // Conditional rendering based on view mode
                    Expanded(
                      child: ScrollConfiguration(
                        behavior: MyCustomScrollBehavior(),
                        child: isGridView
                            ? _buildGridView(data, ref)
                            : _buildListView(data, ref),
                      ),
                    ),
                    kGap5,
                  ],
                ),
              );
            },
            error: (error, stackTrace) => ErrorSection(
              title: error.toString(),
              retry: () => ref.refresh(quiverSelectionProductsProvider),
            ),
            loading: () => Skeletonizer(
              child: Column(
                children: [
                  // Add the button at the top
                  Row(
                    children: [
                      Expanded(
                        child: Tooltip(
                          message: "add product shortcut",
                          child: ElevatedButtonWidget(
                            text: S.of(context).add,
                            icon: Icons.add,
                          ),
                        ),
                      ),
                    ],
                  ),
                  kGap5,
                  // GridView with 2 columns (loading state)
                  Expanded(
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 5,
                            mainAxisSpacing: 5,
                            childAspectRatio: 3,
                          ),
                      itemCount: 15,
                      itemBuilder: (context, index) {
                        return Slidable(
                          key: ValueKey('skeleton_$index'),
                          endActionPane: ActionPane(
                            motion: const ScrollMotion(),
                            children: [
                              SlidableAction(
                                spacing: 0,
                                padding: const EdgeInsets.all(6),
                                onPressed: (_) {},
                                backgroundColor: const Color(0xFFFE4A49),
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                              ),
                            ],
                          ),
                          child: ProductItem(
                            ProductModel.fake(),
                            onTap: () {
                              ref
                                  .read(saleControllerProvider)
                                  .addItemToBasket(ProductModel.fake());
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  kGap5,
                ],
              ),
            ),
          );
  }

  Widget _buildGridView(List<ProductModel> data, WidgetRef ref) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
        childAspectRatio: 3,
      ),
      itemCount: data.length,
      itemBuilder: (context, index) {
        return Slidable(
          key: ValueKey('quick_selection_grid_${data[index].id}_$index'),
          endActionPane: ActionPane(
            motion: const ScrollMotion(),
            children: [
              SlidableAction(
                spacing: 0,
                padding: const EdgeInsets.all(1),
                onPressed: (_) {
                  ref
                      .read(productControllerProvider)
                      .removeProductToQuickSelection(data[index].id!);
                },
                backgroundColor: const Color(0xFFFE4A49),
                foregroundColor: Colors.white,
                icon: Icons.delete,
              ),
            ],
          ),
          child: QuickSelectionItem(
            data[index],
            fontSize: 10, // Font size for grid view
            onTap: () {
              ref.read(saleControllerProvider).addItemToBasket(data[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildListView(List<ProductModel> data, WidgetRef ref) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: data.length,
      onReorder: (int oldIndex, int newIndex) {
        ref
            .read(productControllerProvider)
            .reorderQuickSelectionProducts(oldIndex, newIndex, data);
      },
      buildDefaultDragHandles: false,
      itemBuilder: (context, index) {
        return Container(
          key: ValueKey('quick_selection_list_${data[index].id}_$index'),
          margin: const EdgeInsets.only(bottom: 5),
          child: Slidable(
            endActionPane: ActionPane(
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                  spacing: 0,
                  padding: const EdgeInsets.all(1),
                  onPressed: (_) {
                    ref
                        .read(productControllerProvider)
                        .removeProductToQuickSelection(data[index].id!);
                  },
                  backgroundColor: const Color(0xFFFE4A49),
                  foregroundColor: Colors.white,
                  icon: Icons.delete,
                ),
              ],
            ),
            child: Stack(
              children: [
                QuickSelectionItem(
                  fontSize: 12,
                  data[index],
                  onTap: () {
                    ref
                        .read(saleControllerProvider)
                        .addItemToBasket(data[index]);
                  },
                ),
                Positioned(
                  right: 5,
                  top: 5,
                  child: ReorderableDragStartListener(
                    index: index,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: const Icon(
                        Icons.drag_handle,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class QuickSelectionItem extends ConsumerWidget {
  final ProductModel p;
  final VoidCallback onTap;
  final double fontSize;

  QuickSelectionItem(
    this.p, {
    required this.onTap,
    this.fontSize = 12, // Default font size
    super.key,
  });

  final ValueNotifier<bool> isMouseOver = ValueNotifier(false);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      alignment: AlignmentDirectional.topEnd,
      children: [
        ValueListenableBuilder(
          valueListenable: isMouseOver,
          builder: (context, value, child) => MouseRegion(
            onEnter: (_) => isMouseOver.value = true,
            onExit: (_) => isMouseOver.value = false,
            child: InkWell(
              borderRadius: kRadius5,
              onTap: onTap,
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  borderRadius: kRadius5,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isMouseOver.value
                        ? [
                            Pallete.primaryColorDark
                                .adjustFocusColorBasedOnCurrent(),
                            Pallete.primaryColorDark
                                .adjustFocusColorBasedOnCurrent(),
                            Pallete.primaryColorDark
                                .adjustFocusColorBasedOnCurrent(),
                          ]
                        : [
                            Pallete.primaryColorDark,
                            Pallete.primaryColorDark.withValues(alpha: 0.9),
                            Pallete.primaryColorDark.withValues(alpha: 0.6),
                          ],
                  ),
                ),
                padding: kPadd3,

                ///   width: psc.productWidth,
                //   height: psc.producHeight,
                child: Center(
                  child: Tooltip(
                    message: p.name,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DefaultTextView(
                        maxlines: 1,
                        overflow: TextOverflow.visible,
                        text: "${p.name}",
                        textAlign: TextAlign.center,
                        fontSize: fontSize,
                        color: Pallete.whiteColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
