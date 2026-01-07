import 'package:desktoppossystem/screens/online_menu_screen/components/online_categories.dart';
import 'package:desktoppossystem/screens/online_menu_screen/components/online_products.dart';
import 'package:desktoppossystem/screens/online_menu_screen/components/online_settings.dart';
import 'package:desktoppossystem/screens/online_menu_screen/online_menu_screen_mobile.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:desktoppossystem/shared/utils/responsive_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnlineMenuScreen extends ConsumerWidget {
  const OnlineMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ResponsiveWidget(
      mobileView: const OnlineMenuScreenMobile(),
      desktopView: Padding(
        padding: defaultMargin,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: defaultRadius,
            color: context.cardColor,
            border: Border.all(color: Pallete.greyColor),
          ),
          child: const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 2, child: OnlineCategories()),
              Expanded(flex: 3, child: OnlineProducts()),
              Expanded(flex: 2, child: OnlineSettings()),
            ],
          ),
        ),
      ),
    );
  }
}
