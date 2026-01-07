import 'dart:async';

import 'package:desktoppossystem/controller/global_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/add_edit_product/add_edit_product_screen.dart';
import 'package:desktoppossystem/screens/notifications_screen/notification_controller.dart';
import 'package:desktoppossystem/screens/sale_screens/caffe_sale_screens/components/products/componenets/product_setting_screen.dart';
import 'package:desktoppossystem/screens/stock_screen/components/product_stats_widget.dart';
import 'package:desktoppossystem/screens/stock_screen/components/stock_category_section.dart';
import 'package:desktoppossystem/screens/stock_screen/components/stock_item_mobile.dart';
import 'package:desktoppossystem/screens/stock_screen/stock_controller.dart';
import 'package:desktoppossystem/shared/default%20components/custom_toggle_button.dart';
import 'package:desktoppossystem/shared/default%20components/debounced_text_form.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/default%20components/quiver_circular_indicator.dart';
import 'package:desktoppossystem/shared/services/scroll_behavior_service.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StockScreenMobile extends ConsumerStatefulWidget {
  const StockScreenMobile({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _StockScreenMobileState();
}

class _StockScreenMobileState extends ConsumerState<StockScreenMobile> {
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
    _debounceTimer?.cancel();
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
        // Mobile Header with Category and Actions
        Row(
          children: [
            Expanded(child: StockCategorySection()),
            // PopupMenuButton(
            //   icon: const Icon(Icons.more_vert),
            //   itemBuilder: (context) => [
            //     PopupMenuItem(
            //       child: Row(
            //         children: [
            //           const Icon(Icons.settings, size: 20),
            //           kGap5,
            //           Text(S.of(context).settings),
            //         ],
            //       ),
            //       onTap: () {
            //         Future.delayed(Duration.zero, () {
            //           showDialog(
            //             context: context,
            //             builder: (context) => ProductSettingsScreen(),
            //           );
            //         });
            //       },
            //     ),
            //   ],
            // ),
          ],
        ),
        kGap5,

        // Search Field
        Row(
          children: [
            Expanded(
              child: DebouncedTextFormField(
                prefixIcon: const Icon(Icons.search, color: Pallete.greyColor),
                controller: searchTextController,
                focusNode: _searchFocusNode,
                onFieldSubmitted: (value) async {
                  ref
                      .read(stockControllerProvider)
                      .searchForAProductInStock(value)
                      .then((value) {
                        FocusScope.of(context).requestFocus(_searchFocusNode);
                      });
                },
                onDebouncedChange: (val) async {
                  await ref
                      .read(stockControllerProvider)
                      .searchForAProductInStock(val.toString());
                },
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: context.primaryColor),
                ),
                inputtype: TextInputType.name,
                hinttext: S.of(context).searchByNameOrBarcode,
              ),
            ),
            defaultGap,
            CustomToggleButton(
              height: 38,
              text1: S.of(context).active,
              text2: S.of(context).deleted,
              isSelected: ref.watch(showActiveItemsProvider) == true,
              onPressed: (index) {
                ref.read(showActiveItemsProvider.notifier).state = index == 0
                    ? true
                    : false;
                ref
                    .read(stockControllerProvider)
                    .getStockByBatch(batch: 30, offset: 0);
                ref.refresh(marketNotificationCountProvider);
              },
            ),
          ],
        ),
        if (ref.watch(selectedStockCategoryProvider) != null) ...[
          kGap5,
          DefaultTextView(
            text:
                "Search in '${ref.watch(selectedStockCategoryProvider)!.name}' category",
            color: Colors.red,
            fontSize: 11,
          ),
        ],

        const Row(
          children: [
            Expanded(child: ProductStatsWidget()),
            // FloatingActionButton(
            //   mini: true,
            //   child: const Icon(Icons.add),
            //   onPressed: () {
            //     context.to(
            //       const AddEditProductScreen(null, null, isFromStock: true),
            //     );
            //   },
            // ),
          ],
        ),
        kGap10,

        // Product List
        Expanded(
          child: ScrollConfiguration(
            behavior: MyCustomScrollBehavior(),
            child: stockController.stock.isEmpty
                ? const Center(
                    child: DefaultTextView(
                      text: "no products found",
                      fontSize: 16,
                      color: Pallete.greyColor,
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: stockController.stock.length,
                    itemBuilder: (context, index) {
                      final item = stockController.stock[index];
                      return StockItemMobile(
                        item,
                        key: ValueKey(item.id.toString()),
                      );
                    },
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
