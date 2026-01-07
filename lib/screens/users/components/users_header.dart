import 'package:desktoppossystem/controller/user_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/users/components/add_update_user_form.dart';
import 'package:desktoppossystem/shared/default%20components/app_squared_outlined_button.dart';
import 'package:desktoppossystem/shared/default%20components/app_text_form_field.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UsersHeader extends ConsumerWidget {
  const UsersHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        SizedBox(
          width: 250,
          child: AppTextFormField(
            prefixIcon: const Icon(Icons.search, color: Pallete.greyColor),
            border: OutlineInputBorder(
              borderSide: BorderSide(color: context.primaryColor),
            ),
            onchange: (value) {
              ref.read(userControllerProvider).filterUsersByName(value);
            },
            inputtype: TextInputType.name,
            hinttext: S.of(context).search,
          ),
        ),
        const SizedBox(width: 10),
        AppSquaredOutlinedButton(
          size: const Size(42, 42),
          child: const Icon(Icons.add),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) {
                return StatefulBuilder(
                  builder: (context, setState) {
                    return AlertDialog(
                      title: Center(
                        child: Text(
                          "${S.of(context).newTitle} ${S.of(context).user}",
                        ),
                      ),
                      content: const AddUpdateUserForm(null),
                    );
                  },
                );
              },
            );
          },
        ),
      ],
    );
  }
}
