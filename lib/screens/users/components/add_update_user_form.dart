import 'package:desktoppossystem/controller/user_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/role_model.dart';
import 'package:desktoppossystem/models/user_model.dart';
import 'package:desktoppossystem/shared/default%20components/default_prodgress_indicator.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/default%20components/app_text_form_field.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddUpdateUserForm extends ConsumerStatefulWidget {
  const AddUpdateUserForm(this.userModel, {super.key});
  final UserModel? userModel;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AddUpdateUserFormState();
}

class _AddUpdateUserFormState extends ConsumerState<AddUpdateUserForm> {
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  late TextEditingController userNameController;
  late TextEditingController emailController;
  late TextEditingController passController;

  late RoleModel _selectedRole;

  @override
  void initState() {
    super.initState();
    userNameController = TextEditingController();
    emailController = TextEditingController();
    passController = TextEditingController();
    _selectedRole = ref.read(userControllerProvider).roles.first;
    if (widget.userModel != null) {
      userNameController.text = widget.userModel!.name.toString();
      emailController.text = widget.userModel!.email.toString();
      passController.text = widget.userModel!.password.toString();
      _selectedRole = ref
          .read(userControllerProvider)
          .roles
          .where((e) => e.id == widget.userModel?.role?.id)
          .first;
    }
  }

  @override
  void dispose() {
    super.dispose();
    userNameController.dispose();
    emailController.dispose();
    passController.dispose();
  }

  onchangeRole(RoleModel role) {
    _selectedRole = role;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var userController = ref.watch(userControllerProvider);
    return SizedBox(
      width: 300,
      height: 350,
      child: Form(
        key: _formkey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              AppTextFormField(
                showText: true,
                autofocus: true,
                onvalidate: (value) {
                  if (value!.isEmpty) {
                    return S.of(context).nameMustBeNotEmpty;
                  }
                  return null;
                },
                maxligne: 2,
                controller: userNameController,
                inputtype: TextInputType.name,
                border: const UnderlineInputBorder(),
                hinttext: S.of(context).userName,
              ),
              AppTextFormField(
                showText: true,
                maxligne: 2,
                onvalidate: (value) {
                  if (value!.isEmpty) {
                    return S.of(context).emailMustBeNotEmpty;
                  }
                  return null;
                },
                controller: emailController,
                inputtype: TextInputType.name,
                border: const UnderlineInputBorder(),
                hinttext: S.of(context).email.capitalizeFirstLetter(),
              ),
              AppTextFormField(
                showText: true,
                maxligne: 2,
                onvalidate: (value) {
                  if (value!.isEmpty) {
                    return S.of(context).passwordMustBeNotEmpty;
                  }
                  return null;
                },
                controller: passController,
                inputtype: TextInputType.name,
                border: const UnderlineInputBorder(),
                hinttext: S.of(context).password.capitalizeFirstLetter(),
              ),
              Column(
                crossAxisAlignment: .start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(4),
                    child: DefaultTextView(
                      text: S.of(context).role.capitalizeFirstLetter(),
                    ),
                  ),
                  Container(
                    height: 38,
                    decoration: BoxDecoration(
                      borderRadius: kRadius15,
                      color: Pallete.whiteColor,
                      border: Border.all(width: 1, color: Pallete.greyColor),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: DropdownButton<RoleModel>(
                      isExpanded: true,
                      underline: kEmptyWidget,
                      borderRadius: kRadius15,
                      dropdownColor: Colors.white,
                      value: _selectedRole,
                      iconEnabledColor: Pallete.blackColor,
                      items: userController.roles
                          .map(
                            (e) => DropdownMenuItem<RoleModel>(
                              value: e,
                              child: DefaultTextView(
                                color: Pallete.blackColor,
                                maxlines: 2,
                                text: e.name.toString(),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        onchangeRole(value!);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      userNameController.clear();
                      emailController.clear();
                      passController.clear();
                      context.pop();
                    },
                    child: Text(S.of(context).cancel),
                  ),
                  userController.addUpdateUserRequestState ==
                          RequestState.loading
                      ? const SizedBox(
                          width: 60,
                          child: DefaultProgressIndicator(),
                        )
                      : TextButton(
                          onPressed: () async {
                            if (_formkey.currentState!.validate()) {
                              UserModel u = UserModel(
                                email: emailController.text.trim(),
                                name: userNameController.text.trim(),
                                password: passController.text.trim(),
                                role: _selectedRole,
                              );
                              if (widget.userModel != null) {
                                u = u.copyWith(id: widget.userModel!.id);
                              }
                              if (widget.userModel != null) {
                                await ref
                                    .read(userControllerProvider)
                                    .updateUser(u, context);
                              } else {
                                await ref
                                    .read(userControllerProvider)
                                    .addUser(u, context);
                              }
                            }
                          },
                          child: Text(
                            widget.userModel == null
                                ? S.of(context).add
                                : S.of(context).update,
                          ),
                        ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
