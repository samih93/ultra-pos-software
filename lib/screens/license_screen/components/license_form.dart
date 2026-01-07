import 'package:desktoppossystem/controller/auth_controller.dart';
import 'package:desktoppossystem/screens/license_screen/licenses_controller.dart';
import 'package:desktoppossystem/shared/config/secure_config.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/default%20components/new_default_button.dart';
import 'package:desktoppossystem/shared/default%20components/app_text_form_field.dart';
import 'package:desktoppossystem/shared/default%20components/quiver_social_media_widget.dart';
import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/services/dependency_injection.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/my_linears_gradient.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LicenseForm extends ConsumerStatefulWidget {
  const LicenseForm({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LicenseFormState();
}

class _LicenseFormState extends ConsumerState<LicenseForm> {
  late TextEditingController activationTextController;

  final GlobalKey<FormState> _formkey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    activationTextController = TextEditingController();
    Future.wait([
      ref.read(securePreferencesProvider).getData(key: "validDate"),
      ref.read(securePreferencesProvider).getData(key: "registrationUserId"),
    ]).then((values) {
      setState(() {
        validDateTill = values[0];
        registrationUserId = values[1];
      });
    });
  }

  @override
  void dispose() {
    activationTextController.dispose();
    super.dispose();
  }

  String? validDateTill;
  String? registrationUserId;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formkey,
      child: Padding(
        padding: kPadd15,
        child: Stack(
          alignment: AlignmentDirectional.bottomStart,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const DefaultTextView(
                  text: "Activation Screen",
                  fontSize: 25,
                  color: Pallete.primaryColorDark,
                  fontWeight: FontWeight.bold,
                ),
                kGap20,
                Row(
                  children: [
                    Expanded(
                      child: AppTextFormField(
                        obscure: true,
                        backColor: Pallete.coreMistColor,
                        cursorColor: Pallete.primaryColorDark,
                        textColor: Pallete.primaryColorDark,
                        controller: activationTextController,
                        inputtype: TextInputType.text,
                        hinttext: "Activation Code",
                        onvalidate: (value) {
                          if (value!.isEmpty ||
                              (value.isNotEmpty && value.trim().length < 10)) {
                            return "Activation Code must not be empty";
                          }

                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                kGap20,
                NewDefaultButton(
                  state: ref
                      .watch(licenseControllerProvider)
                      .activateRequestState,
                  text: "Activate",
                  gradient: coreGradient(),
                  height: 50,
                  onpress: () async {
                    if (_formkey.currentState!.validate()) {
                      ref
                          .read(licenseControllerProvider)
                          .activateApp(
                            activationTextController.text.trim(),
                            context,
                          );
                    }
                  },
                ),
                kGap10,
                const CoreSocialMediaWidget(),
                kGap20,
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        defaultVersionWidget(Pallete.primaryColorDark),
                        if (registrationUserId != null && !context.isMobile)
                          DefaultTextView(
                            text: "-$registrationUserId",
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Pallete.primaryColorDark,
                          ),
                      ],
                    ),
                    const Spacer(),
                    if (validDateTill != null &&
                        ref.read(currentUserProvider)?.id ==
                            int.tryParse(SecureConfig.quiverUserId))
                      DefaultTextView(
                        fontSize: 14,

                        text: "valid till $validDateTill",
                        color: Pallete.primaryColorDark,
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
