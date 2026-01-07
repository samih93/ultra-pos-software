import 'package:desktoppossystem/models/product_model.dart';
import 'package:desktoppossystem/screens/sale_screens/caffe_sale_screens/components/basket_list/basket_item.dart';
import 'package:desktoppossystem/screens/sale_screens/caffe_sale_screens/components/basket_list/header_basket.dart';
import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/default%20components/quiver_circular_indicator.dart';
import 'package:desktoppossystem/shared/services/scroll_behavior_service.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BasketList extends ConsumerStatefulWidget {
  const BasketList({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _BasketListState();
}

class _BasketListState extends ConsumerState<BasketList> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void animateListViewToEnd() {
    var saleController = ref.watch(saleControllerProvider);

    if (!saleController.shouldAnimateToEnd) return; // Respect the flag

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (saleController.basketItems.isNotEmpty) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var saleController = ref.watch(saleControllerProvider);
    if (saleController.shouldAnimateToEnd) {
      // Avoid calling animateListViewToEnd on every build
      SchedulerBinding.instance.addPostFrameCallback((_) {
        animateListViewToEnd();
      });
    }

    return saleController.fetchTableRequestState == RequestState.loading
        ? const Center(child: CoreCircularIndicator())
        : Column(
            children: [
              if (saleController.selectedTable != null)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: basketStatusWidget(
                        context,
                        list: saleController.basketItems
                            .where((element) => element.isNewToBasket == true)
                            .toList(),
                        status: "basket",
                      ),
                    ),
                    Expanded(
                      child: basketStatusWidget(
                        context,
                        list: saleController.basketItems
                            .where((element) => element.isJustOrdered == true)
                            .toList(),
                        status: "ordered",
                      ),
                    ),
                    Expanded(
                      child: basketStatusWidget(
                        context,
                        list: saleController.basketItems
                            .where(
                              (element) =>
                                  element.isJustOrdered == false &&
                                  element.isNewToBasket == false,
                            )
                            .toList(),
                        status: "old",
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 10),
              const HeaderBasket(),
              const SizedBox(height: 10),
              const Divider(color: Colors.grey, height: 0),
              Expanded(
                child: saleController.basketItems.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.shopping_basket,
                              color: Pallete.greyColor,
                              size: 45,
                            ),
                            DefaultTextView(
                              text: "Your cart is empty",
                              color: Pallete.greyColor,
                              fontSize: 16,
                            ),
                          ],
                        ),
                      )
                    : ScrollConfiguration(
                        behavior: MyCustomScrollBehavior(),
                        child: ListView(
                          controller: _scrollController,
                          children: [
                            ...List.generate(
                              saleController.basketItems.length,
                              (index) {
                                return BasketItem(
                                  saleController.basketItems[index],
                                  index,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          );
  }

  basketStatusWidget(
    BuildContext context, {
    required List<ProductModel> list,
    required String status,
  }) {
    Color color = status == "basket"
        ? Pallete.greenColor
        : status == "ordered"
        ? context.primaryColor
        : Pallete.blackColor;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        CircleAvatar(
          backgroundColor: color,
          radius: 10,
          child: DefaultTextView(text: "${list.length}", color: Colors.white),
        ),
        DefaultTextView(color: color, text: status),
      ],
    );
  }
}
