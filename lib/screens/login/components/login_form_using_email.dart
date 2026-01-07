import 'package:desktoppossystem/controller/auth_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_screen.dart';
import 'package:desktoppossystem/shared/default%20components/new_default_button.dart';
import 'package:desktoppossystem/shared/default%20components/app_text_form_field.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/my_linears_gradient.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:desktoppossystem/shared/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginFormUsingEmail extends ConsumerWidget {
  LoginFormUsingEmail({super.key});
  final textEmailcontroller = TextEditingController();
  final textPasswordcontroller = TextEditingController();
  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Form(
      key: _formkey,
      child: Column(
        crossAxisAlignment: .start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            S.of(context).signIn,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
          ),
          kGap20,
          Column(
            children: [
              SizedBox(
                child: AppTextFormField(
                  backColor: Pallete.coreMistColor,
                  prefixIcon: const Icon(Icons.person),
                  obscure: ref.watch(authControllerProvider).showEmail,
                  suffixIcon: IconButton(
                    onPressed: () {
                      ref
                          .read(authControllerProvider)
                          .onchangeEmailVisibility();
                    },
                    icon: Icon(
                      ref.watch(authControllerProvider).showEmail
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: Pallete.blackColor,
                    ),
                  ),
                  cursorColor: Pallete.primaryColorDark,
                  textColor: Pallete.primaryColorDark,
                  controller: textEmailcontroller,
                  inputtype: TextInputType.emailAddress,
                  hinttext: S.of(context).email,
                  onvalidate: (value) {
                    if (value!.isEmpty) {
                      return S.of(context).emailMustBeNotEmpty;
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                child: AppTextFormField(
                  backColor: Pallete.coreMistColor,
                  prefixIcon: const Icon(Icons.lock),
                  cursorColor: Pallete.primaryColorDark,

                  textColor: Pallete.primaryColorDark,
                  //! suffixIcon: InkWell(
                  //!   child: Icon(
                  //!     authcontroller.showpassword
                  //!         ? Icons.visibility
                  //!         : Icons.visibility_off,
                  //!   ),
                  //!   //! onTap: () {
                  //!   //!   authcontroller.onchangepasswordvisibility();
                  //!   //! },
                  //! ),
                  obscure: ref.watch(authControllerProvider).showPassword,
                  suffixIcon: IconButton(
                    onPressed: () {
                      ref
                          .read(authControllerProvider)
                          .onchangePasswordVisibility();
                    },
                    icon: Icon(
                      ref.watch(authControllerProvider).showPassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                  ),
                  controller: textPasswordcontroller,
                  inputtype: TextInputType.text,
                  hinttext: S.of(context).password,
                  onvalidate: (value) {
                    if (value!.isEmpty) {
                      return S.of(context).passwordMustBeNotEmpty;
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 30),
              NewDefaultButton(
                state: ref.watch(authControllerProvider).signInRequestState,
                text: S.of(context).signIn,
                gradient: coreGradient(),
                height: 50,
                onpress: () async {
                  if (_formkey.currentState!.validate()) {
                    ref
                        .read(authControllerProvider.notifier)
                        .signInWithEmailAndPassword(
                          textEmailcontroller.text.trim(),
                          textPasswordcontroller.text.toString(),
                        )
                        .then((value) {
                          if (ref
                                  .read(authControllerProvider.notifier)
                                  .signInRequestState ==
                              RequestState.success) {
                            _formkey.currentState!.reset();
                            context.off(MainScreen());
                          }
                          ToastUtils.showToast(
                            message: ref
                                .read(authControllerProvider.notifier)
                                .signInStatusMessage,
                            type: ref
                                .read(authControllerProvider.notifier)
                                .signInRequestState,
                          );
                        });
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
