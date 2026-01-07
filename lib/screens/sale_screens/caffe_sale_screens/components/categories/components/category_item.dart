import 'package:desktoppossystem/controller/category_controller.dart';
import 'package:desktoppossystem/controller/product_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/category_model.dart';
import 'package:desktoppossystem/screens/add_edit_category/add_edit_category_screen.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/screens/sale_screens/caffe_sale_screens/components/categories/cateogries_settings_controller.dart';
import 'package:desktoppossystem/shared/default%20components/are_you_sure_dialog.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

class CategoryItem extends ConsumerWidget {
  final CategoryModel c;
  final double? width;
  final double? height;

  CategoryItem(this.c, {super.key, this.width, this.height});

  final nameController = TextEditingController();
  final colorController = TextEditingController();

  final ValueNotifier<bool> isMouseOver = ValueNotifier(false);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    //! just used to access methods
    var categorycontroller = ref.read(categoryControllerProvider);
    var productcontroller = ref.read(productControllerProvider);

    // Read category width once and cache it to avoid rebuilds
    final categoryWidth = ref
        .read(categoriesSettingsControllerProvider)
        .categoryWidth;

    Color? currentBackroundColor = Color(
      c.color != null ? int.parse(c.color!) : 0xFF0000,
    );
    final isDarkMode = ref.read(isDarkModeProvider);

    return ValueListenableBuilder(
      valueListenable: isMouseOver,
      builder: (context, value, child) => MouseRegion(
        onEnter: (_) => isMouseOver.value = true,
        onExit: (_) => isMouseOver.value = false,
        child: GestureDetector(
          onTap: () {
            productcontroller.onselectcategory(c);
            categorycontroller.onselectcategory(c);
          },
          onLongPress: () {
            if (ref.read(mainControllerProvider).isAdmin) {
              var alertStyle = AlertStyle(
                isOverlayTapDismiss: false,
                titleStyle: TextStyle(
                  color: context.brightnessColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                descStyle: TextStyle(
                  color: context.brightnessColor,
                  fontSize: 16,
                ),
                animationDuration: const Duration(milliseconds: 1),
              );
              Alert(
                style: alertStyle,
                context: context,
                type: AlertType.warning,
                title: "${c.name}",
                desc:
                    "${S.of(context).whatDoYouWantToDo} ${S.of(context).quetionMark}",
                buttons: [
                  DialogButton(
                    onPressed: () {
                      context.pop();
                    },
                    color: Colors.blue.shade400,
                    child: Text(
                      S.of(context).cancel,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                  DialogButton(
                    onPressed: () {
                      //! get notes then navigate

                      context.pop();
                      context.to(AddEditCategoryScreen(c));
                    },
                    color: Colors.green.shade400,
                    child: Text(
                      S.of(context).edit,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                  DialogButton(
                    onPressed: () {
                      context.pop();
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AreYouSureDialog(
                            "${S.of(context).areYouSureDelete} '${c.name}' ${S.of(context).quetionMark}",
                            agreeText: S.of(context).delete,
                            onCancel: () => context.pop(),
                            agreeState: ref
                                .watch(categoryControllerProvider)
                                .deleteCategoryRequestState,
                            onAgree: () {
                              categorycontroller.deleteCategory(c.id!, context);
                            },
                          );
                        },
                      );
                    },
                    color: Colors.red.shade400,
                    child: Text(
                      S.of(context).delete,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ],
              ).show();
            }
          },
          child: Container(
            width: width ?? categoryWidth,
            height: height,
            decoration: BoxDecoration(
              borderRadius: kRadius5,
              border: c.selected!
                  ? Border.all(
                      color: isDarkMode
                          ? Pallete.whiteColor
                          : context.primaryColor.withValues(alpha: 0.8),
                      width: 2,
                    )
                  : const Border(
                      top: BorderSide.none,
                      bottom: BorderSide.none,
                      left: BorderSide.none,
                      right: BorderSide.none,
                    ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isMouseOver.value
                    ? [
                        currentBackroundColor.adjustFocusColorBasedOnCurrent(),
                        currentBackroundColor.adjustFocusColorBasedOnCurrent(),
                        currentBackroundColor.adjustFocusColorBasedOnCurrent(),
                      ]
                    : isDarkMode
                    ? [
                        // Less gradient in dark mode - more subtle effect
                        currentBackroundColor,
                        currentBackroundColor.withValues(alpha: 0.95),
                        currentBackroundColor.withValues(alpha: 0.9),
                      ]
                    : [
                        // Original gradient for light mode
                        currentBackroundColor,
                        currentBackroundColor.withValues(alpha: 0.9),
                        currentBackroundColor.withValues(alpha: 0.6),
                      ],
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 1),
            child: Center(
              child: DefaultTextView(
                text: c.name ?? '',
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxlines: 4,
                color: currentBackroundColor.getTextColorBasedOnBackground(),
                fontSize: calculateFontSize(width ?? categoryWidth),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Function to calculate font size based on width
  double calculateFontSize(double width) {
    // Clamp the width to be between 50 and 110
    double constrainedWidth = width.clamp(50.0, 110.0);

    // Define the minimum and maximum width
    double minWidth = 50.0;
    double maxWidth = 110.0;

    // Define the font size at the minimum and maximum width
    double minFontSize = 13.0; // Font size when width is 110
    double maxFontSize = 10.0; // Font size when width is 50

    // Calculate the font size using the linear interpolation formula
    double fontSize =
        maxFontSize -
        ((constrainedWidth - minWidth) / (maxWidth - minWidth)) *
            (maxFontSize - minFontSize);

    return fontSize;
  }
}
