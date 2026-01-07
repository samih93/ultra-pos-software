import 'dart:io';

import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/license_screen/components/license_form.dart';
import 'package:desktoppossystem/screens/license_screen/license_screen_mobile.dart';
import 'package:desktoppossystem/shared/default%20components/app_bar_title.dart';
import 'package:desktoppossystem/shared/default%20components/are_you_sure_dialog.dart';
import 'package:desktoppossystem/shared/default%20components/elevated_button_widget.dart';
import 'package:desktoppossystem/shared/default%20components/quiver_widget.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:desktoppossystem/shared/utils/responsive_widget.dart';
import 'package:flutter/material.dart';

class LicenseScreen extends StatelessWidget {
  const LicenseScreen({this.isUsingQuiverTech, super.key});
  final bool? isUsingQuiverTech;

  @override
  Widget build(BuildContext context) {
    return ResponsiveWidget(
      mobileView: LicenseScreenMobile(isUsingQuiverTech: isUsingQuiverTech),
      desktopView: _LicenseScreenDesktop(isUsingQuiverTech: isUsingQuiverTech),
    );
  }
}

class _LicenseScreenDesktop extends StatelessWidget {
  const _LicenseScreenDesktop({this.isUsingQuiverTech});
  final bool? isUsingQuiverTech;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isUsingQuiverTech != null && isUsingQuiverTech == true
          ? AppBar(title: const AppBarTitle(title: "Activation screen"))
          : null,
      body: Stack(
        alignment: AlignmentDirectional.bottomEnd,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: context.width * 0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Expanded(child: Center(child: CoreWidget())),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Pallete.greyColor),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    height: context.height * .6,
                    width: context.width * .8,
                    //  padding: EdgeInsets.all(16),
                    child: const LicenseForm(),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: kPadd20,
            child: Align(
              alignment: AlignmentDirectional.bottomEnd,
              child: ElevatedButtonWidget(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AreYouSureDialog(
                      "${S.of(context).areYouSureToCloseProgram} ${S.of(context).quetionMark}",
                      agreeText: S.of(context).close,
                      onCancel: () => context.pop(),
                      onAgree: () async {
                        exit(0);
                      },
                    ),
                  );
                },
                height: 60,
                width: 100,
                text: S.of(context).close,
                color: Pallete.redColor,
                icon: Icons.exit_to_app_outlined,
              ),
            ),
          ),
        ],
      ).baseContainer(context.cardColor),
    );
  }
}
