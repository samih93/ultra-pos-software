// import 'package:desktoppossystem/generated/l10n.dart';
// import 'package:desktoppossystem/screens/dashboard/dashboard_controller.dart';
// import 'package:desktoppossystem/screens/error_section.dart';
// import 'package:desktoppossystem/screens/sale_screens/caffe_sale_screens/restaurant_sale_screen.dart';
// import 'package:desktoppossystem/shared/styles/pallete.dart';
// import 'package:desktoppossystem/shared/styles/sizes.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class PayLaterReceiptsCard extends ConsumerWidget {
//   const PayLaterReceiptsCard({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final showDelivery = ref.read(showOrderSectionProvider);
//     final futureCounts = ref.watch(futureDeliveryReceiptsCounts);
//     return !showDelivery
//         ? kEmptyWidget
//         : futureCounts.when(
//             data: (data) {
//               return Expanded(
//                 flex: 2,
//                 child: Container(
//                   padding: kPaddH5,
//                   decoration: BoxDecoration(
//                       color: Pallete.primaryColor.withValues(alpha: 0.1),
//                       shape: BoxShape.rectangle,
//                       borderRadius: kRadius8,
//                       border: Border.all(
//                         color: Pallete.primaryColor,
//                       )),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       Text(
//                         S.of(context).payLaterReceits,
//                         style: const TextStyle(
//                           fontSize: 16,
//                           color: Colors.grey,
//                         ),
//                       ),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 const Icon(
//                                   Icons.paid_outlined,
//                                   color: Pallete.greenColor,
//                                   size: 22,
//                                 ),
//                                 Text(
//                                   "${data["paid"]}",
//                                   style: const TextStyle(
//                                     fontSize: 22,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                           Expanded(
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               children: [
//                                 const Icon(
//                                   Icons.pending_actions_outlined,
//                                   color: Pallete.redColor,
//                                   size: 22,
//                                 ),
//                                 Text(
//                                   "${data["pending"]}",
//                                   style: const TextStyle(
//                                     fontSize: 24,
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               );
//             },
//             error: (error, stackTrace) => ErrorSection(
//               retry: () => ref.refresh(futureDeliveryReceiptsCounts),
//             ),
//             loading: () => Expanded(
//               flex: 2,
//               child: Container(
//                 padding: kPaddH5,
//                 decoration: BoxDecoration(
//                     color: Pallete.primaryColor.withValues(alpha: 0.1),
//                     shape: BoxShape.rectangle,
//                     borderRadius: kRadius8,
//                     border: Border.all(
//                       color: Pallete.primaryColor,
//                     )),
//                 child: const Column(
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   children: [
//                     Text(
//                       "Delivery",
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: Colors.grey,
//                       ),
//                     ),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(
//                                 Icons.paid_outlined,
//                                 color: Pallete.greenColor,
//                                 size: 22,
//                               ),
//                               Text(
//                                 "",
//                                 style: TextStyle(
//                                   fontSize: 22,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                         Expanded(
//                           child: Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Icon(
//                                 Icons.pending_actions_outlined,
//                                 color: Pallete.redColor,
//                                 size: 22,
//                               ),
//                               Text(
//                                 "",
//                                 style: TextStyle(
//                                   fontSize: 24,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//   }
// }
