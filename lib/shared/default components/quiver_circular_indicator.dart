import 'package:desktoppossystem/shared/constances/asset_constant.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:flutter/material.dart';

class CoreCircularIndicator extends StatelessWidget {
  const CoreCircularIndicator({Key? key, this.height, this.coloredLogo = true})
      : super(key: key);
  final double? height;
  final bool? coloredLogo;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: (height ?? 45) - 5,
      width: (height ?? 45) - 5,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Circular Progress Indicator
          SizedBox(
            height: (height ?? 45) - 5,
            width: (height ?? 45) - 5,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(coloredLogo == true
                  ? Pallete.primaryColor
                  : Pallete
                      .whiteColor), // Optional: Change the color of the progress indicator
              strokeWidth:
                  1.5, // Optional: Change the thickness of the progress indicator
            ),
          ),
          // Image inside the Circular Progress Indicator
          Padding(
            padding: kPadd1,
            child: ClipOval(
              child: Image.asset(coloredLogo == true
                  ? AssetConstant.coreColoredLogo
                  : AssetConstant.coreWhiteColor),
            ),
          ),
        ],
      ),
    );
  }
}
