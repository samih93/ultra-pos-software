import 'package:desktoppossystem/controller/auth_controller.dart';
import 'package:desktoppossystem/models/table_model.dart';
import 'package:desktoppossystem/models/user_model.dart';
import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
import 'package:desktoppossystem/shared/utils/toast_utils.dart';

import 'package:desktoppossystem/shared/styles/my_linears_gradient.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../main_screen.dart/main_controller.dart';

class TableItem extends ConsumerWidget {
  const TableItem(this.tableModel, {super.key});
  final TableModel tableModel;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    UserModel? userModel = ref.read(currentUserProvider);
    return InkWell(
      onTap: () async {
        if (isCanAccessTable(userModel, tableModel, ref)) {
          context.pop();
          await ref
              .read(saleControllerProvider)
              .openTable(tableModel.tableName.toString(),
                  ref.read(currentUserProvider)!.id!)
              .then((value) {
            ref.read(saleControllerProvider).onSelectTable(tableModel);
          });
        } else {
          ToastUtils.showToast(
              duration: const Duration(seconds: 3),
              message: "this table is opened by other user",
              type: RequestState.error);
        }
      },
      child: Stack(
        alignment: AlignmentDirectional.topStart,
        children: [
          Container(
            decoration: BoxDecoration(
                borderRadius: kRadius5,
                gradient: isOpenedByOtherUser(userModel, tableModel)
                    ? myredLinearGradient()
                    : tableModel.isOpened
                        ? myLinearGradient(context)
                        : mydisabledLinearGradient()),
            padding: kPadd3,
            width: 70,
            height: 70,
            child: Center(
                child: Text(
              textAlign: TextAlign.center,
              "${tableModel.tableName}",
              style: const TextStyle(
                fontSize: 22,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            )),
          ),
          if (!isCanAccessTable(userModel, tableModel, ref) &&
              !ref.watch(mainControllerProvider).isAdmin)
            const Icon(Icons.lock)
        ],
      ),
    );
  }

  isOpenedByOtherUser(UserModel? userModel, TableModel tableModel) {
    if (userModel != null &&
        (userModel.id != tableModel.openedBy && tableModel.isOpened == true)) {
      return true;
    }
    return false;
  }

  isCanAccessTable(UserModel? userModel, TableModel tableModel, WidgetRef ref) {
    if (userModel != null && ref.watch(mainControllerProvider).isAdmin) {
      return true;
    }

    if (userModel != null &&
        tableModel.isOpened == true &&
        userModel.id == tableModel.openedBy) {
      return true;
    }

    if (tableModel.isOpened == false) return true;

    return false;
  }
}
