// ignore_for_file: unused_result

import 'package:desktoppossystem/controller/supplier_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/supplier_model.dart';
import 'package:desktoppossystem/screens/purchases_screen/components/add_edit_supplier_dialog.dart';
import 'package:desktoppossystem/shared/default%20components/are_you_sure_dialog.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/default%20components/elevated_button_widget.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../main_screen.dart/main_controller.dart';

class SupplierItem extends ConsumerWidget {
  const SupplierItem(this.supplierModel, {super.key});

  final SupplierModel supplierModel;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.only(bottom: 5),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(width: 0.5, color: Colors.grey))),
      margin: const EdgeInsets.only(bottom: 5),
      child: Row(children: [
        Expanded(flex: 2, child: DefaultTextView(text: supplierModel.name)),
        Expanded(child: DefaultTextView(text: "${supplierModel.phoneNumber}")),
        Expanded(
            flex: 2,
            child: DefaultTextView(
              text: "${supplierModel.contactDetails}",
              maxlines: 2,
            )),
        Expanded(
            child: DefaultTextView(
                text: "${supplierModel.supplierAddress}", maxlines: 2)),
        Expanded(
            flex: 2,
            child: Row(
              children: [
                ElevatedButtonWidget(
                  width: 80,
                  text: null,
                  icon: Icons.edit_note_outlined,
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) => AddEditSupplierDialog(
                              supplier: supplierModel,
                            ));
                  },
                ),
                kGap10,
                if (ref.watch(mainControllerProvider).isAdmin)
                  ElevatedButtonWidget(
                    color: Pallete.redColor,
                    text: null,
                    icon: Icons.delete,
                    onPressed: () async {
                      showDialog(
                        context: context,
                        builder: (context) {
                          RequestState deleteRequest = RequestState.success;
                          return StatefulBuilder(
                            builder: (context, setState) {
                              return AreYouSureDialog(
                                  agreeText: S.of(context).delete,
                                  onCancel: () => context.pop(),
                                  "${S.of(context).areYouSureDelete} '${supplierModel.name}' ${S.of(context).quetionMark}",
                                  agreeState: deleteRequest,
                                  onAgree: () async {
                                    setState(() {
                                      deleteRequest = RequestState.loading;
                                    });
                                    await ref
                                        .read(supplierControllerProvider)
                                        .deleteSupplier(supplierModel.id!)
                                        .whenComplete(() {
                                      setState(() {
                                        deleteRequest = RequestState.success;
                                        context.pop();
                                      });
                                    });
                                  });
                            },
                          );
                        },
                      );
                    },
                  ),
                // kGap10,
                // ElevatedButtonWidget(
                //   text: S.of(context).purchases,
                //   icon: Icons.list,
                //   onPressed: () {},
                // ),
              ],
            ))
      ]),
    );
  }
}
