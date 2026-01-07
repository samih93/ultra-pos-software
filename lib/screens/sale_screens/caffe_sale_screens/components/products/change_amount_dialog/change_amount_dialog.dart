// import 'package:desktoppossystem/screens/sale_screens/caffe_sale_screens/components/products/change_amount_dialog/componenets/number_dialog.dart';
// import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
// import 'package:desktoppossystem/shared/constances/app_constances.dart';
// import 'package:desktoppossystem/shared/default%20components/default_button.dart';
// import 'package:desktoppossystem/shared/global.dart';
// import 'package:desktoppossystem/shared/styles/my_linears_gradient.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class ChangeAmountDialog extends StatelessWidget {
//   const ChangeAmountDialog({super.key});
//   //var cashReceivedTextController = TextEditingController();
//   @override
//   Widget build(BuildContext context) {
//     var saleController = Provider.of<SaleController>(context);
//     return SizedBox(
//       height: !saleController.isShowInDolarInSaleScreen ? 400 : 420,
//       width: 300,
//       child: Padding(
//         padding: kPadd10,
//         child: Column(
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text("Total :", style: TextStyle(fontSize: 20)),
//                 Text(
//                     "${saleController.isShowInDolarInSaleScreen ? "${saleController.foreignTotalPrice.formatDouble()}${AppConstance.primaryCurrency}" : "${AmountFormat.format(saleController.localTotalPrice)} ${AppConstance.secondaryCurrency}"} ",
//                     style: const TextStyle(color: Colors.red, fontSize: 20)),
//               ],
//             ),
//             const SizedBox(
//               height: 10,
//             ),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text("Received :", style: TextStyle(fontSize: 20)),
//                 Text(
//                     "${saleController.isShowInDolarInSaleScreen ? "${double.parse(saleController.receivedAmount).formatDouble()}${AppConstance.primaryCurrency}" : "${AmountFormat.format(double.parse(saleController.receivedAmount))} ${AppConstance.secondaryCurrency}"} ",
//                     style:
//                         TextStyle(color: Colors.grey.shade700, fontSize: 20)),
//               ],
//             ),
//             const SizedBox(
//               height: 20,
//             ),
//             NumberDialog(qty: "1"),
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 const Text("Change :", style: TextStyle(fontSize: 20)),
//                 Text(
//                     saleController.isShowInDolarInSaleScreen
//                         ? "${saleController.cashReturns.formatDouble()} ${AppConstance.primaryCurrency}"
//                         : '${AmountFormat.format(saleController.cashReturns)} ${AppConstance.secondaryCurrency}',
//                     style: const TextStyle(color: Colors.red, fontSize: 20)),
//               ],
//             ),
//             const SizedBox(
//               height: 10,
//             ),
//             if (saleController.isShowInDolarInSaleScreen)
//               Row(
//                 children: [
//                   Switch(
//                       value: saleController.isShowInLebanonInCashDialog,
//                       onChanged: (value) {
//                         context.read<SaleController>().onchangeShowInLebanon();
//                       }),
//                   const Text("LB"),
//                   const Spacer(),
//                   if (saleController.isShowInLebanonInCashDialog)
//                     Text(
//                         '${AmountFormat.format(saleController.totalChangeInLebanonInDialog)} ${AppConstance.secondaryCurrency}',
//                         style:
//                             const TextStyle(color: Colors.red, fontSize: 20)),
//                 ],
//               ),
//             const Spacer(),
//             DefaultButton(
//                 text: "Ok",
//                 radius: 5,
//                 gradient: myredLinearGradient(),
//                 onpress: () {
//                   context.pop();
//                   context.read<SaleController>().resetReceivedAmount();
//                 })
//           ],
//         ),
//       ),
//     );
//   }
// }
