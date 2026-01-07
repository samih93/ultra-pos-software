import 'package:desktoppossystem/screens/sale_screens/caffe_sale_screens/components/basket_list/basket_list.dart';
import 'package:desktoppossystem/screens/sale_screens/caffe_sale_screens/components/categories/components/cateogries.dart';
import 'package:desktoppossystem/screens/sale_screens/caffe_sale_screens/components/change_quatity_widget.dart';
import 'package:desktoppossystem/screens/sale_screens/caffe_sale_screens/components/products/products_list.dart';
import 'package:desktoppossystem/screens/sale_screens/caffe_sale_screens/components/table_section/table_section.dart';
import 'package:desktoppossystem/screens/sale_screens/caffe_sale_screens/mobile/restaurant_mobile_sales_screen.dart';
import 'package:desktoppossystem/screens/sale_screens/shared_components/customer_section.dart';
import 'package:desktoppossystem/screens/sale_screens/shared_components/discount_section.dart';
import 'package:desktoppossystem/screens/sale_screens/shared_components/order_type_section.dart';
import 'package:desktoppossystem/screens/sale_screens/shared_components/footer_section/restaurant_bottom_buttons_section.dart';
import 'package:desktoppossystem/screens/sale_screens/shared_components/total_amount_section.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// final showOrderSectionProvider = StateProvider<bool>((ref) {
//   return false;
// });

class RestaurantSaleScreen extends ConsumerWidget {
  const RestaurantSaleScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Mobile view
    if (context.isMobile) {
      return const RestaurantMobileSalesScreen();
    }

    // Desktop view
    return Padding(
      padding: defaultMargin,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 5,
            child: Container(
              decoration: BoxDecoration(borderRadius: defaultRadius),
              child: const Column(
                crossAxisAlignment: .start,
                children: [
                  Row(children: [Expanded(child: Categories())]),
                  defaultGap,
                  Expanded(child: ProductList()),
                  defaultGap,
                  RestaurantBottomButtonsSection(),
                ],
              ),
            ).cornerRadiusWithClipRRect(),
          ),
          ChangeQtyWidget(qty: "1"),
          // MARK:Basket
          Expanded(
            flex: 3,
            child: Container(
              margin: kPaddH5,
              padding: kPaddH5,
              decoration: BoxDecoration(
                borderRadius: defaultRadius,
                color: context.cardColor,
                border: Border.all(color: Pallete.greyColor),
              ),
              child: const Column(
                crossAxisAlignment: .start,
                children: [
                  OrderTypeSection(),
                  kGap3,
                  CustomerSection(),
                  kGap5,
                  DiscountSection(),
                  TableSection(),
                  Expanded(child: BasketList()),
                  Divider(height: 0, thickness: 1),
                  TotalAmountSection(),
                ],
              ),
            ).cornerRadiusWithClipRRect(),
          ),
        ],
      ),
    );
  }
}
