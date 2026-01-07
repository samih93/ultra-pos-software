// import 'package:desktoppossystem/models/product_model.dart';
// import 'package:desktoppossystem/screens/sale_screens/caffe_sale_screens/components/products/componenets/product_item.dart';
// import 'package:desktoppossystem/screens/sale_screens/caffe_sale_screens/components/products/products_settings_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:skeletonizer/skeletonizer.dart';

// class LoadingRestaurantProducts extends ConsumerWidget {
//   const LoadingRestaurantProducts({super.key});
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final fakeProducts = List.generate(60, (index) => ProductModel.fake());

//     return RepaintBoundary(
//       child: Skeletonizer(
//         effect: const PulseEffect(duration: Duration(milliseconds: 300)),
//         child: GridView.builder(
//           itemCount: fakeProducts.length,
//           itemBuilder: (context, index) =>
//               ProductItem(onTap: () {}, fakeProducts[index]),
//           gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
//               mainAxisSpacing: 5,
//               crossAxisSpacing: 5,
//               maxCrossAxisExtent:
//                   ref.watch(productsSettingsControllerProvider).productWidth),
//         ),
//       ),
//     );
//   }
// }
