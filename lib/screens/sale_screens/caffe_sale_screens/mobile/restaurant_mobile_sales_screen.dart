import 'package:desktoppossystem/screens/sale_screens/caffe_sale_screens/components/products/products_list.dart';
import 'package:desktoppossystem/screens/sale_screens/caffe_sale_screens/mobile/components/cart_fab.dart';
import 'package:desktoppossystem/screens/sale_screens/caffe_sale_screens/mobile/components/categories_mobile.dart';
import 'package:desktoppossystem/screens/sale_screens/caffe_sale_screens/mobile/restaurant_cart_screen.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RestaurantMobileSalesScreen extends ConsumerWidget {
  const RestaurantMobileSalesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Padding(
        padding: defaultPadding,
        child: Column(
          children: [
            // Categories - horizontal scrollable tabs
            SizedBox(height: 100.h, child: const CategoriesMobile()),
            kGap8,
            // Products Grid
            const Expanded(child: ProductList()),
          ],
        ),
      ),
      floatingActionButton: CartFAB(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const RestaurantCartScreen(),
          );
        },
      ),
    );
  }
}
