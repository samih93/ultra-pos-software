import 'package:desktoppossystem/controller/auth_controller.dart';
import 'package:desktoppossystem/controller/product_controller.dart';
import 'package:desktoppossystem/screens/sale_screens/caffe_sale_screens/components/products/componenets/product_buttons_section.dart';
import 'package:desktoppossystem/screens/sale_screens/caffe_sale_screens/components/products/componenets/product_item.dart';
import 'package:desktoppossystem/screens/sale_screens/caffe_sale_screens/components/products/products_settings_controller.dart';
import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
import 'package:desktoppossystem/shared/constances/auth_role.dart';
import 'package:desktoppossystem/shared/default%20components/quiver_circular_indicator.dart';
import 'package:desktoppossystem/shared/services/scroll_behavior_service.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductList extends ConsumerWidget {
  const ProductList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var productController = ref.watch(productControllerProvider);

    switch (productController.getProductsRequestState) {
      case RequestState.loading:
        return const Center(child: CoreCircularIndicator(height: 100));

      case RequestState.success:
        return Container(
          margin: kPaddH5,
          padding: defaultPadding,
          decoration: BoxDecoration(
            border: Border.all(color: Pallete.greyColor),
            color: context.cardColor,
            borderRadius: defaultRadius,
          ),
          child: Column(
            crossAxisAlignment: .start,
            children: [
              const ProductButtonsSection(),
              kGap5,
              productController.products.isEmpty
                  ? Expanded(
                      child: Center(
                        child: Text(
                          "No Products found...",
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 25,
                          ),
                        ),
                      ),
                    )
                  : Expanded(
                      child: ScrollConfiguration(
                        behavior: MyCustomScrollBehavior(),
                        child: GridView.builder(
                          itemCount: productController.products.length,
                          itemBuilder: (context, index) {
                            final product = productController.products[index];
                            return ProductItem(
                              key: Key(product.id.toString()),
                              product,
                              onTap: () {
                                if (ref.read(currentUserProvider)?.role!.name ==
                                        AuthRole.waiterRole &&
                                    ref
                                            .read(saleControllerProvider)
                                            .selectedTable ==
                                        null) {
                                  return;
                                }
                                ref
                                    .read(saleControllerProvider)
                                    .addItemToBasket(product);
                              },
                            );
                          },
                          gridDelegate:
                              SliverGridDelegateWithMaxCrossAxisExtent(
                                mainAxisSpacing: 5,
                                crossAxisSpacing: 5,
                                maxCrossAxisExtent: ref
                                    .watch(productsSettingsControllerProvider)
                                    .productWidth,
                              ),
                        ),
                      ),
                    ),
            ],
          ),
        );

      case RequestState.error:
        return Container();
    }
  }
}
