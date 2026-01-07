import 'package:desktoppossystem/controller/auth_controller.dart';
import 'package:desktoppossystem/controller/user_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/user_model.dart';
import 'package:desktoppossystem/screens/users/components/add_update_user_form.dart';
import 'package:desktoppossystem/shared/default%20components/app_squared_outlined_button.dart';
import 'package:desktoppossystem/shared/default%20components/are_you_sure_dialog.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

UserDataRow(UserModel userModel, BuildContext context, WidgetRef ref) {
  return DataRow(
    cells: [
      DataCell(DefaultTextView(text: '${userModel.name}')),
      DataCell(DefaultTextView(text: '${userModel.email}')),
      DataCell(DefaultTextView(text: userModel.role?.name ?? '')),
      DataCell(
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AppSquaredOutlinedButton(
              child: const Icon(FontAwesomeIcons.penToSquare),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return StatefulBuilder(
                      builder: (context, setState) {
                        return AlertDialog(
                          title: Center(child: Text(S.of(context).updateUser)),
                          content: AddUpdateUserForm(userModel),
                        );
                      },
                    );
                  },
                );
              },
            ),
            kGap10,
            if (ref.read(currentUserProvider)?.id != userModel.id)
              AppSquaredOutlinedButton(
                child: const Icon(Icons.delete, color: Pallete.redColor),
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
                            "${S.of(context).areYouSureDelete} '${userModel.name}' ?",
                            agreeState: deleteRequest,
                            onAgree: () async {
                              setState(() {
                                deleteRequest = RequestState.loading;
                              });
                              await ref
                                  .read(userControllerProvider)
                                  .deleteUser(userModel.id!, context)
                                  .whenComplete(() {
                                    setState(() {
                                      deleteRequest = RequestState.success;
                                    });
                                  });
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
    ],
  );
}
