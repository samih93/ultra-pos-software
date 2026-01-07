import 'dart:io';

import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/login/components/login_form_using_email.dart';
import 'package:desktoppossystem/screens/login/components/number_pad.dart';
import 'package:desktoppossystem/shared/constances/asset_constant.dart';
import 'package:desktoppossystem/shared/default%20components/app_squared_outlined_button.dart';
import 'package:desktoppossystem/shared/default%20components/are_you_sure_dialog.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/services/dependency_injection.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:desktoppossystem/shared/utils/responsive_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_swipe_button/flutter_swipe_button.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final ValueNotifier<bool> _isWithEmail = ValueNotifier(false);

  @override
  void initState() {
    super.initState();

    _isWithEmail.value = ref
        .read(appPreferencesProvider)
        .getBool(key: "isWithEmail");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.cardColor,
      body: ValueListenableBuilder(
        valueListenable: _isWithEmail,
        builder: (context, isWithEmail, child) => ResponsiveWidget(
          mobileView: _buildMobileLayout(context, isWithEmail),
          desktopView: _buildDesktopLayout(context, isWithEmail),
        ),
      ),
    );
  }

  // Mobile Layout - Simple vertical layout with logo and form
  Widget _buildMobileLayout(BuildContext context, bool isWithEmail) {
    final isDarkMode = ref.read(isDarkModeProvider);
    return Center(
      child: SingleChildScrollView(
        padding: kPadd20,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            RepaintBoundary(
              child: Image.asset(
                context.coreImageWithName,
                width: context.width * 0.3,
              ),
            ),
            kGap20,
            // Title
            DefaultTextView(
              text: isWithEmail
                  ? S.of(context).signInUsingEmail
                  : S.of(context).signInUsingCode,
              fontWeight: FontWeight.bold,
              color: context.brightnessColor,
              fontSize: context.titleSize,
              textAlign: TextAlign.center,
            ),

            kGap10,
            // Form Area
            Container(
              constraints: BoxConstraints(maxHeight: context.height * 0.5),
              child: AnimatedCrossFade(
                firstCurve: Curves.linear,
                secondCurve: Curves.linear,
                duration: const Duration(milliseconds: 1000),
                firstChild: LoginFormUsingEmail(),
                secondChild: const NumberPad(),
                crossFadeState: isWithEmail
                    ? CrossFadeState.showFirst
                    : CrossFadeState.showSecond,
              ),
            ),
            kGap20,
            // Swipe Button
            SwipeButton.expand(
              thumb: const Icon(
                Icons.double_arrow_rounded,
                color: Pallete.whiteColor,
              ),
              activeThumbColor: context.primaryColor,
              activeTrackColor: Pallete.coreMist50Color,
              onSwipe: () {
                _isWithEmail.value = !_isWithEmail.value;
              },
              child: Text(
                isWithEmail
                    ? S.of(context).signInUsingCode
                    : S.of(context).signInUsingEmail,
                style: TextStyle(
                  color: isDarkMode ? Pallete.whiteColor : context.primaryColor,
                  fontSize: context.bodySize,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Desktop Layout - Original two-column layout
  Widget _buildDesktopLayout(BuildContext context, bool isWithEmail) {
    final isDarkMode = ref.read(isDarkModeProvider);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(100),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 30,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xff9333ea),
                      Color(0xff4f46e5),
                      Color(0xff2563eb),
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    RepaintBoundary(
                      child: Image.asset(
                        AssetConstant.coreWhiteLogoWithName,
                        width: 100,
                      ),
                    ),
                    kGap10,
                    DefaultTextView(
                      text: isWithEmail
                          ? S.of(context).signInUsingEmail
                          : S.of(context).signInUsingCode,
                      fontWeight: FontWeight.bold,
                      color: Pallete.whiteColor,
                      fontSize: 30,
                    ),
                    kGap5,
                    const DefaultTextView(
                      text: "Secure Access",
                      fontWeight: FontWeight.bold,
                      color: Pallete.yellowColor,
                      fontSize: 35,
                    ),
                    kGap10,
                    const DefaultTextView(
                      maxlines: 3,
                      text:
                          "Enter your secure access code to login to your account quickly and safely.",
                      fontWeight: FontWeight.w500,
                      fontSize: 20,
                      color: Pallete.greyColor,
                    ),
                    const Spacer(),
                    if (context.isWindows)
                      AppSquaredOutlinedButton(
                        size: const Size(80, 38),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) => AreYouSureDialog(
                              "${S.of(context).areYouSureToCloseProgram} ${S.of(context).quetionMark}",
                              agreeText: S.of(context).close,
                              onCancel: () => context.pop(),
                              onAgree: () async {
                                await ref
                                    .read(securePreferencesProvider)
                                    .removeByKey(key: "user");
                                exit(0);
                              },
                            ),
                          );
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Icon(Icons.exit_to_app),
                            DefaultTextView(
                              text: "Exit",
                              color: Pallete.blackColor,
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: context.cardColor,
                  borderRadius: isEnglishLanguage
                      ? const BorderRadius.only(
                          topRight: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                        )
                      : const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          bottomLeft: Radius.circular(10),
                        ),
                  border: Border.all(color: Pallete.greyColor),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 10,
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: SizedBox.expand(
                          child: AnimatedCrossFade(
                            firstCurve: Curves.linear,
                            secondCurve: Curves.linear,
                            duration: const Duration(milliseconds: 1000),
                            firstChild: LoginFormUsingEmail(),
                            secondChild: const NumberPad(),
                            crossFadeState: isWithEmail
                                ? CrossFadeState.showFirst
                                : CrossFadeState.showSecond,
                          ),
                        ),
                      ),
                      Padding(
                        padding: kPaddH50,
                        child: SwipeButton.expand(
                          thumb: const Icon(
                            Icons.double_arrow_rounded,
                            color: Colors.white,
                          ),
                          activeThumbColor: context.primaryColor,
                          activeTrackColor: Pallete.coreMist50Color,
                          onSwipe: () {
                            _isWithEmail.value = !_isWithEmail.value;
                          },
                          child: Text(
                            isWithEmail
                                ? S.of(context).signInUsingCode
                                : S.of(context).signInUsingEmail,
                            style: TextStyle(
                              color: isDarkMode
                                  ? Pallete.whiteColor
                                  : context.primaryColor,
                              fontSize: context.bodySize,
                            ),
                          ),
                        ),
                      ),
                      kGap10,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ).cornerRadiusWithClipRRect(),
      ),
    );
  }
}
