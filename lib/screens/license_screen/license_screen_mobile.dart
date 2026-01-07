import 'package:desktoppossystem/screens/license_screen/components/license_form.dart';
import 'package:desktoppossystem/shared/default%20components/app_bar_title.dart';
import 'package:desktoppossystem/shared/default%20components/quiver_widget.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LicenseScreenMobile extends StatelessWidget {
  const LicenseScreenMobile({this.isUsingQuiverTech, super.key});
  final bool? isUsingQuiverTech;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: isUsingQuiverTech != null && isUsingQuiverTech == true
          ? AppBar(title: const AppBarTitle(title: "Activation screen"))
          : null,
      body: SafeArea(
        child: SizedBox(
          height: context.height,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(16.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo at top - responsive height
                SizedBox(
                  height: 200.h, // Scales with screen height
                  child: const CoreWidget(),
                ),
                SizedBox(height: 24.h),
                // Form below
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Pallete.greyColor),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  padding: EdgeInsets.all(16.w),
                  child: const LicenseForm(),
                ),
                SizedBox(height: 80.h), // Space for scrolling
              ],
            ),
          ).baseContainer(context.cardColor),
        ),
      ),
    );
  }
}
