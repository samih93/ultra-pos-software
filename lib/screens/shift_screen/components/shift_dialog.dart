// import 'package:desktoppossystem/controller/receipt_controller.dart';
// import 'package:desktoppossystem/generated/l10n.dart';
// import 'package:desktoppossystem/models/shift_model.dart';
// import 'package:desktoppossystem/screens/shift_screen/shift_screen.dart';
// import 'package:desktoppossystem/shared/default%20components/default_list_tile.dart';
// import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
// import 'package:desktoppossystem/shared/utils/extentions.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class ShiftDialog extends ConsumerWidget {
//   const ShiftDialog(this.shifts, {super.key});

//   final List<ShiftModel> shifts;
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     return AlertDialog(
//       title: DefaultTextView(
//         textAlign: TextAlign.center,
//         text: S.of(context).selectShift,
//         fontsize: 16,
//       ),
//       content: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           ...shifts.map((e) {
//             return DefaultListTile(
//               tileColor: e == ref.watch(selectedShiftProvider)
//                   ? context.primaryColor.withValues(alpha: 0.5)
//                   : null,
//               title: DefaultTextView(
//                   text:
//                       " ${S.of(context).shift} : ${e.id} -  ${DateTime.parse(e.startShiftDate.toString()).formatDateTime12Hours()}"),
//               onTap: () {
//                 ref.read(selectedShiftProvider.notifier).state = e;
//                 ref.read(shiftSelectedUserProvider.notifier).state = ref
//                     .read(receiptControllerProvider)
//                     .users
//                     .where((element) => element.role!.name == "All")
//                     .first;
//                 ref
//                     .read(receiptControllerProvider)
//                     .fetchPaginatedReceiptsByShift(resetPagination: true);

//                 context.pop();
//               },
//             );
//           })
//         ],
//       ),
//     );
//   }
// }
