import 'dart:async';

import 'package:desktoppossystem/controller/global_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/add_edit_product/add_edit_product_screen.dart';
import 'package:desktoppossystem/screens/import_data_to_stock/import_data_to_stock.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/screens/notifications_screen/notification_controller.dart';
import 'package:desktoppossystem/screens/sale_screens/caffe_sale_screens/components/products/componenets/product_setting_screen.dart';
import 'package:desktoppossystem/screens/stock_screen/components/download_stock_button.dart';
import 'package:desktoppossystem/screens/stock_screen/components/download_weighted_products_button.dart';
import 'package:desktoppossystem/screens/stock_screen/components/product_stats_widget.dart';
import 'package:desktoppossystem/screens/stock_screen/components/stock_category_section.dart';
import 'package:desktoppossystem/screens/stock_screen/components/stock_item.dart';
import 'package:desktoppossystem/screens/stock_screen/stock_controller.dart';
import 'package:desktoppossystem/screens/stock_screen/stock_screen_mobile.dart';
import 'package:desktoppossystem/shared/default%20components/app_squared_outlined_button.dart';
import 'package:desktoppossystem/shared/default%20components/custom_toggle_button.dart';
import 'package:desktoppossystem/shared/default%20components/debounced_text_form.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/default%20components/quiver_circular_indicator.dart';
import 'package:desktoppossystem/shared/services/scroll_behavior_service.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:desktoppossystem/shared/utils/responsive_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class StockScreen extends ConsumerWidget {
  const StockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const ResponsiveWidget(
      mobileView: StockScreenMobile(),
      desktopView: StockScreenDesktop(),
    );
  }
}

class StockScreenDesktop extends ConsumerStatefulWidget {
  const StockScreenDesktop({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _StockScreenState();
}

class _StockScreenState extends ConsumerState<StockScreenDesktop> {
  @override
  void initState() {
    super.initState();
    searchTextController = TextEditingController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        ref.read(stockControllerProvider).getStockByBatch();
      }
    });
  }

  late TextEditingController searchTextController;
  final FocusNode _searchFocusNode = FocusNode();

  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel(); // Properly cancel the timer

    searchTextController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    var stockController = ref.watch(stockControllerProvider);
    return Column(
      crossAxisAlignment: .start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            StockCategorySection(),
            Flexible(
              child: ScrollConfiguration(
                behavior: MyCustomScrollBehavior(),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    spacing: 5,
                    children: [
                      const DownloadWeightedProductsButton(),
                      CustomToggleButton(
                        height: 38,
                        text1: S.of(context).active,
                        text2: S.of(context).deleted,
                        isSelected: ref.watch(showActiveItemsProvider) == true,
                        onPressed: (index) {
                          ref.read(showActiveItemsProvider.notifier).state =
                              index == 0 ? true : false;
                          ref
                              .read(stockControllerProvider)
                              .getStockByBatch(batch: 30, offset: 0);
                          ref.refresh(marketNotificationCountProvider);
                        },
                      ),
                      const DownloadStockButton(),
                      AppSquaredOutlinedButton(
                        size: const Size(90, 38),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Icon(FontAwesomeIcons.fileImport, size: 20),
                            DefaultTextView(
                              text: S.of(context).import,
                              color: Pallete.blackColor,
                            ),
                          ],
                        ),
                        onPressed: () {
                          context.to(const ImportDataToStockScreen());
                        },
                      ),
                      AppSquaredOutlinedButton(
                        child: const Icon(Icons.settings),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => ProductSettingsScreen(),
                          );
                        },
                      ),
                      AppSquaredOutlinedButton(
                        child: const Icon(Icons.add),
                        onPressed: () {
                          context.to(
                            const AddEditProductScreen(
                              null,
                              null,
                              isFromStock: true,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        kGap5,
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: .start,
                      children: [
                        SizedBox(
                          width: context.width * 0.45,
                          // height: 60,
                          child: DebouncedTextFormField(
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Pallete.greyColor,
                            ),
                            controller: searchTextController,
                            focusNode: _searchFocusNode,
                            onFieldSubmitted: (value) async {
                              ref
                                  .read(stockControllerProvider)
                                  .searchForAProductInStock(value)
                                  .then((value) {
                                    FocusScope.of(
                                      context,
                                    ).requestFocus(_searchFocusNode);
                                  });
                            },
                            onDebouncedChange: (val) async {
                              await ref
                                  .read(stockControllerProvider)
                                  .searchForAProductInStock(val.toString());
                            },
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: context.primaryColor,
                              ),
                            ),
                            inputtype: TextInputType.name,
                            hinttext: S.of(context).searchByNameOrBarcode,
                          ),
                        ),
                        if (ref.watch(selectedStockCategoryProvider) != null)
                          DefaultTextView(
                            text:
                                "Search in '${ref.watch(selectedStockCategoryProvider)!.name}' category",
                            color: Colors.red,
                            fontSize: 11,
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            kGap5,
            const ProductStatsWidget(),
          ],
        ),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: InkWell(
                onTap: () {
                  ref.read(stockControllerProvider).sortProductsByName();
                },
                child: Row(
                  children: [
                    DefaultTextView(
                      text: S.of(context).product,
                      fontWeight: FontWeight.w600,
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, anim) => RotationTransition(
                        turns: stockController.isSortByName
                            ? Tween<double>(begin: 1, end: 0).animate(anim)
                            : Tween<double>(begin: 0, end: 1).animate(anim),
                        child: FadeTransition(opacity: anim, child: child),
                      ),
                      child: stockController.isSortByName
                          ? Icon(
                              Icons.arrow_upward_rounded,
                              color: context.primaryColor,
                              key: const ValueKey('icon1'),
                            )
                          : Icon(
                              color: context.primaryColor,
                              Icons.arrow_downward_rounded,
                              key: const ValueKey('icon2'),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: DefaultTextView(
                text: S.of(context).barcode,
                fontWeight: FontWeight.w600,
              ),
            ),
            Expanded(
              child: DefaultTextView(
                text: S.of(context).expiryDate,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (ref.read(mainControllerProvider).isSuperAdmin)
              Expanded(
                child: DefaultTextView(
                  text: S.of(context).costPrice,
                  fontWeight: FontWeight.w600,
                ),
              ),
            Expanded(
              flex: 2,
              child: InkWell(
                onTap: () {
                  ref.read(stockControllerProvider).sortProductsByPrice();
                },
                child: Row(
                  children: [
                    DefaultTextView(
                      text: '${S.of(context).sellingPrice}(\$)',
                      fontWeight: FontWeight.w600,
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, anim) => RotationTransition(
                        turns: stockController.isSortByPrice
                            ? Tween<double>(begin: 1, end: 0).animate(anim)
                            : Tween<double>(begin: 0, end: 1).animate(anim),
                        child: FadeTransition(opacity: anim, child: child),
                      ),
                      child: stockController.isSortByPrice
                          ? Icon(
                              Icons.arrow_upward_rounded,
                              color: context.primaryColor,
                              key: const ValueKey('icon1'),
                            )
                          : Icon(
                              color: context.primaryColor,
                              Icons.arrow_downward_rounded,
                              key: const ValueKey('icon2'),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: InkWell(
                onTap: () {
                  ref.read(stockControllerProvider).sortProductsByQty();
                },
                child: Row(
                  children: [
                    DefaultTextView(
                      text: S.of(context).qty,
                      fontWeight: FontWeight.w600,
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, anim) => RotationTransition(
                        turns: stockController.isSortByQty
                            ? Tween<double>(begin: 1, end: 0).animate(anim)
                            : Tween<double>(begin: 0, end: 1).animate(anim),
                        child: FadeTransition(opacity: anim, child: child),
                      ),
                      child: stockController.isSortByQty
                          ? Icon(
                              Icons.arrow_upward_rounded,
                              color: context.primaryColor,
                              key: const ValueKey('icon1'),
                            )
                          : Icon(
                              color: context.primaryColor,
                              Icons.arrow_downward_rounded,
                              key: const ValueKey('icon2'),
                            ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: DefaultTextView(
                text: S.of(context).printLabel,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        Divider(color: context.primaryColor),
        Expanded(
          child: ScrollConfiguration(
            behavior: MyCustomScrollBehavior(),
            child: CustomScrollView(
              controller: _scrollController,
              cacheExtent: 45,
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final item = stockController.stock[index];

                    return StockItem(
                      item,
                      index,
                      key: ValueKey(item.id.toString()),
                    );
                  }, childCount: stockController.stock.length),
                ),
              ],
            ),
          ),
        ),
        if (stockController.getStockByBatchRequestState == RequestState.loading)
          const Center(child: CoreCircularIndicator()),
      ],
    ).baseContainer(context.cardColor);
  }

  Future<void> downloadStock(WidgetRef ref) async {
    await ref.read(stockControllerProvider).getAllStock().then((
      products,
    ) async {
      await ref.read(globalControllerProvider).openStockInExcel(products);
    });
  }
}
