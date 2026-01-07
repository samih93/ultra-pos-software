import 'package:desktoppossystem/screens/sale_screens/market_sale_screen/components/market_basket_item.dart';
import 'package:desktoppossystem/screens/sale_screens/market_sale_screen/components/market_header_basket.dart';
import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
import 'package:desktoppossystem/shared/services/scroll_behavior_service.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MarketBasketList extends ConsumerStatefulWidget {
  const MarketBasketList({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _MarketBasketListState();
}

class _MarketBasketListState extends ConsumerState<MarketBasketList> {
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
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    var saleController = ref.watch(saleControllerProvider);
    animateListViewToEnd();

    return Column(
      crossAxisAlignment: .start,
      children: [
        kGap5,
        const MarketHeaderBasket(),
        kGap5,
        const Divider(thickness: 3, color: Colors.grey, height: 0),
        Expanded(
          child: ScrollConfiguration(
            behavior: MyCustomScrollBehavior(),
            child: ListView(
              controller: _scrollController,
              children: [
                ...List.generate(saleController.basketItems.length, (index) {
                  return MarketBasketItem(
                    saleController.basketItems[index],
                    index,
                  );
                }),
              ],
            ),
          ),
        ),
      ],
    ).paddingSymmetric(horizontal: 5);
  }
}
