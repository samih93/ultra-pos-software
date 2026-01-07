// import 'package:desktoppossystem/models/restaurant_stock_model.dart';
// import 'package:desktoppossystem/screens/restaurant_stock/components/restaurant_stock_item.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:skeletonizer/skeletonizer.dart';

// class LoadingRestaurantStockItems extends ConsumerWidget {
//   const LoadingRestaurantStockItems({super.key});
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final fakeStockItems =
//         List.generate(15, (index) => RestaurantStockModel.fake());

//     return RepaintBoundary(
//       child: Skeletonizer(
//         effect: const PulseEffect(duration: Duration(milliseconds: 300)),
//         child: ConstrainedBox(
//           constraints: const BoxConstraints(maxHeight: 200),
//           child: Row(
//             children: [
//               Expanded(
//                 child: GridView.builder(
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                       //     childAspectRatio: 0.6,
//                       mainAxisSpacing: 5,
//                       crossAxisSpacing: 5,
//                       mainAxisExtent: 130,
//                       crossAxisCount: 2),
//                   scrollDirection: Axis.horizontal,
//                   itemBuilder: (_, index) =>
//                       RestaurantStockItem(fakeStockItems[index]),
//                   itemCount: fakeStockItems.length,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
