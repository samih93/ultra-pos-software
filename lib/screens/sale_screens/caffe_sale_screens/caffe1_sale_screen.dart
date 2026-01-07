// import 'package:desktoppossystem/controller/category_controller.dart';
// import 'package:desktoppossystem/screens/sale_screens/caffe_sale_screens/components/basket_list/basket_list.dart';
// import 'package:desktoppossystem/screens/sale_screens/market_sale_screen/components/change_quantity_market.dart';
// import 'package:desktoppossystem/screens/sale_screens/caffe_sale_screens/components/pay_section.dart';
// import 'package:desktoppossystem/screens/sale_screens/caffe_sale_screens/components/products/products_list.dart';
// import 'package:desktoppossystem/screens/sale_screens/caffe_sale_screens/components/total_amount.dart';
// import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
// import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
// import 'package:desktoppossystem/shared/styles/themes.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class Caffe1SaleScreen extends StatelessWidget {
//   const Caffe1SaleScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // ! to avoid categories null cz in product list im getting the color based on categoryId
//     context.read<CategoryController>();
//     return Padding(
//       padding: kPadd8,
//       child: Column(
//         children: [
//           Expanded(
//             child: Row(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 Expanded(
//                   flex: 2,
//                   child: Column(
//                     children: [
//                       if (context.watch<SaleController>().selectedTable != null)
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             DefaultTextView(
//                                 text: "Table :  ",
//                                 fontWeight: FontWeight.bold,
//                                 fontsize: 30),
//                             DefaultTextView(
//                                 text:
//                                     "(${context.watch<SaleController>().selectedTable!.tableName})",
//                                 fontWeight: FontWeight.bold,
//                                 fontsize: 30,
//                                 color: context.primaryColor),
//                             const Spacer(),
//                             IconButton(
//                                 onPressed: () {
//                                   context
//                                       .read<SaleController>()
//                                       .unselectTable();
//                                 },
//                                 icon: const Icon(
//                                   Icons.remove,
//                                   color: Colors.red,
//                                 ))
//                           ],
//                         ),
//                       const Expanded(child: BasketList()),
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                     flex: 2,
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(horizontal: 8),
//                       child: Column(
//                         crossAxisAlignment: .start,
//                         children: [
//                           ChangeQtyScreen(
//                             qty: "1",
//                           ),
//                           const Padding(
//                             padding: EdgeInsets.all(8.0),
//                             child: Divider(
//                               height: 0,
//                               thickness: 2,
//                               color: context.primaryColor,
//                             ),
//                           ),
//                           const Expanded(flex: 2, child: ProductList()),
//                         ],
//                       ),
//                     )),
//               ],
//             ),
//           ),
//           const Divider(
//             height: 0,
//             thickness: 2,
//             color: context.primaryColor,
//           ),
//           Row(
//             children: [
//               const Expanded(flex: 2, child: TotalAmount()),
//               Expanded(
//                 flex: 3,
//                 child: Padding(
//                   padding: const EdgeInsets.only(top: 8),
//                   child: PaySection(),
//                 ),
//               )
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
