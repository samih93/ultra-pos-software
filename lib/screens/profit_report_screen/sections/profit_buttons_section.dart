// import 'package:desktoppossystem/generated/l10n.dart';
// import 'package:desktoppossystem/screens/profit_report_screen/profit_controller.dart';
// import 'package:desktoppossystem/shared/default%20components/default_outline_button.dart';
// import 'package:desktoppossystem/shared/default%20components/default_text_form.dart';
//
// import 'package:desktoppossystem/shared/styles/sizes.dart';
// import 'package:desktoppossystem/shared/utils/extentions.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class ProfitButtonsSection extends ConsumerWidget {
//   const ProfitButtonsSection({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     var controller = ref.watch(profitControllerProvider);

//     return Row(
//       children: [
//         Text(
//           S.of(context).profitOverView,
//           style: TextStyle(
//               fontWeight: FontWeight.bold,
//               color: context.primaryColor,
//               fontSize: 20),
//         ),
//         kGap20,
//         Expanded(
//             child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//           children: [
//             ...controller.buttons.map((e) => DefaultOutlineButton(
//                 onpress: () async {
//                   controller.onchangeView(e.reportInterval, context);
//                 },
//                 name: e.reportInterval.name
//                     .toString()
//                     .arabicProfitStatus(context),
//                 textcolor: e.isselected ? Colors.white : context.primaryColor,
//                 backgroundColor:
//                     e.isselected ? context.primaryColor : Colors.white)),
//           ],
//         )),
//         SizedBox(
//           width: 300,
//           height: 60,
//           child: DefaultTextFormField(
//             prefixIcon: Icon(
//               Icons.search,
//               color: Pallete.greyColor,
//             ),
//             onfieldsubmit: (value) {
//               ref
//                   .read(profitControllerProvider)
//                   .onSearchInProfit(value.toString());
//             },
//             onchange: (value) {
//               ref
//                   .read(profitControllerProvider)
//                   .onSearchInProfit(value.toString());
//             },
//             border: OutlineInputBorder(
//               borderSide: BorderSide(color: context.primaryColor),
//             ),
//             enabledborder: OutlineInputBorder(
//               borderSide: BorderSide(color: context.primaryColor),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderSide: BorderSide(color: context.primaryColor),
//             ),
//             inputtype: TextInputType.name,
//             hinttext: S.of(context).searchByNameOrBarcode,
//           ),
//         ),
//       ],
//     );
//   }
// }
