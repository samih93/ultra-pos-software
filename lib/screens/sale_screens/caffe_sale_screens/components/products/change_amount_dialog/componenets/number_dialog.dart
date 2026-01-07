// import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class NumberDialog extends StatelessWidget {
//   final String qty;
//   NumberDialog({super.key, required this.qty});

//   final List<String> _numbers = [
//     "1",
//     "2",
//     "3",
//     "4",
//     "5",
//     "6",
//     "7",
//     "8",
//     "9",
//     "0",
//     "00",
//     "c",
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         LayoutBuilder(
//           builder: (context, constraintsDashboarditem) => Column(
//             children: [
//               Wrap(
//                 children: [
//                   ..._numbers.map((e) => InkWell(
//                       onTap: () {
//                         if (_numbers.indexOf(e) == 11) {
//                           context.read<SaleController>().resetReceivedAmount();
//                         } else if (_numbers.indexOf(e) != 11) {
//                           context.read<SaleController>().onReceiveAmount(e);
//                         }
//                       },
//                       child: _build_item_number(
//                           e, constraintsDashboarditem.maxWidth))),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }

//   _build_item_number(String item, double maxWidth) => Container(
//       width: maxWidth / 3,
//       height: 50,
//       decoration:
//           BoxDecoration(border: Border.all(color: Colors.grey.shade300)),
//       child: Center(
//         child: Text(
//           item,
//           style: TextStyle(
//               color: item == "Delete" ? Colors.red : Colors.black,
//               fontWeight: FontWeight.bold),
//         ),
//       ));
// }
