// import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
// import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
//
// import 'package:desktoppossystem/shared/styles/sizes.dart';
// import 'package:desktoppossystem/shared/utils/extentions.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class TotalProfitAmountByCategory extends ConsumerWidget {
//   const TotalProfitAmountByCategory(
//       {super.key,
//       required this.totalCost,
//       required this.totalPaid,
//       required this.profit});

//   final double totalCost;
//   final double totalPaid;
//   final double profit;

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final isLtr = ref.read(mainControllerProvider).isLtr;
//     return Column(
//       children: [
//         Row(
//           children: [
//             const Expanded(child: kEmptyWidget),
//             Expanded(
//               child: Container(
//                 padding: kPadd5,
//                 decoration: BoxDecoration(
//                     color: Pallete.limeColor,
//                     borderRadius: isLtr
//                         ? const BorderRadius.only(
//                             topLeft: Radius.circular(15),
//                             bottomLeft: Radius.circular(15))
//                         : const BorderRadius.only(
//                             topRight: Radius.circular(15),
//                             bottomRight: Radius.circular(15))),
//                 child: DefaultTextView(
//                   textAlign: TextAlign.center,
//                   text: "${totalCost.formatDouble()}",
//                   fontsize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             Expanded(
//               child: Container(
//                 padding: kPadd5,
//                 color: Pallete.limeColor,
//                 child: DefaultTextView(
//                   textAlign: TextAlign.center,
//                   text: "${totalPaid.formatDouble()}",
//                   fontsize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             Expanded(
//               child: Container(
//                 padding: kPadd5,
//                 decoration: BoxDecoration(
//                     color: Pallete.limeColor,
//                     borderRadius: isLtr
//                         ? const BorderRadius.only(
//                             topRight: Radius.circular(15),
//                             bottomRight: Radius.circular(15))
//                         : const BorderRadius.only(
//                             topLeft: Radius.circular(15),
//                             bottomLeft: Radius.circular(15))),
//                 child: DefaultTextView(
//                   textAlign: TextAlign.center,
//                   text: "${profit.formatDouble()}",
//                   fontsize: 18,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//             ),
//             const Expanded(child: kEmptyWidget),
//           ],
//         ),
//       ],
//     );
//   }
// }
