import 'dart:typed_data';

import 'package:desktoppossystem/controller/category_controller.dart';
import 'package:desktoppossystem/models/product_model.dart';
import 'package:desktoppossystem/screens/sale_screens/caffe_sale_screens/components/products/products_settings_controller.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ignore: must_be_immutable
class ProductItem extends ConsumerWidget {
  final ProductModel p;
  ProductItem(this.p, {required this.onTap, super.key});

  ValueNotifier<bool> isMouseOver = ValueNotifier(false);
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoryControllerProvider).categories;
    final isDarkMode = ref.read(isDarkModeProvider);

    return Stack(
      alignment: AlignmentDirectional.topEnd,
      children: [
        ValueListenableBuilder(
          valueListenable: isMouseOver,
          builder: (context, value, child) => MouseRegion(
            onEnter: (_) => isMouseOver.value = true,
            onExit: (_) => isMouseOver.value = false,
            child: InkWell(
              borderRadius: kRadius5,
              onTap: onTap,

              // for delete and edit
              onLongPress: () {
                productAlertDialog(context, ref, p);
              },
              child:
                  (p.image != null &&
                      ref
                          .watch(productsSettingsControllerProvider)
                          .showProductImage)
                  ? Container(
                      decoration: BoxDecoration(borderRadius: kRadius5),
                      child: Stack(
                        children: [
                          // Image Background
                          Container(
                            decoration: BoxDecoration(
                              image: DecorationImage(
                                image: MemoryImage(p.image as Uint8List),
                                fit: BoxFit.cover,
                              ),
                              borderRadius: kRadius5,
                            ),
                          ),

                          // Black Shadow Overlay (only if showText is also true)
                          if (ref
                              .watch(productsSettingsControllerProvider)
                              .showText) ...[
                            // overlay
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(
                                  alpha: 0.5,
                                ), // Semi-transparent black
                                borderRadius: kRadius5,
                              ),
                            ),
                            Center(
                              child: DefaultTextView(
                                maxlines: 4,
                                text: "${p.name}",
                                textAlign: TextAlign.center,
                                fontSize:
                                    ref
                                        .watch(
                                          productsSettingsControllerProvider,
                                        )
                                        .productWidth /
                                    5.7,
                                fontWeight:
                                    ref
                                        .watch(
                                          productsSettingsControllerProvider,
                                        )
                                        .isBold
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                                color: Colors
                                    .white, // Ensures text is visible on black shadow
                              ),
                            ),
                          ],

                          // Text overlay (only if showText is also true)
                        ],
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        borderRadius: kRadius5,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: isMouseOver.value
                              ? [
                                  p.categoryColor!
                                      .adjustFocusColorBasedOnCurrent(),
                                  p.categoryColor!
                                      .adjustFocusColorBasedOnCurrent(),
                                  p.categoryColor!
                                      .adjustFocusColorBasedOnCurrent(),
                                ]
                              : isDarkMode
                              ? [
                                  // Less gradient in dark mode - more subtle effect
                                  p.categoryColor!,
                                  p.categoryColor!.withValues(alpha: 0.95),
                                  p.categoryColor!.withValues(alpha: 0.9),
                                ]
                              : [
                                  p.categoryColor!,
                                  p.categoryColor!.withValues(alpha: 0.9),
                                  p.categoryColor!.withValues(alpha: 0.8),
                                ],
                        ),
                      ),
                      padding: kPadd3,

                      ///   width: psc.productWidth,
                      //   height: psc.producHeight,
                      child: Center(
                        child: DefaultTextView(
                          maxlines: 3,
                          overflow: TextOverflow.ellipsis,
                          text: "${p.name}",
                          textAlign: TextAlign.center,
                          fontSize:
                              ref
                                  .watch(productsSettingsControllerProvider)
                                  .productWidth /
                              6,
                          fontWeight:
                              ref
                                  .watch(productsSettingsControllerProvider)
                                  .isBold
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: p.categoryColor!
                              .getTextColorBasedOnBackground(),
                        ),
                      ),
                    ),
            ),
          ),
        ),
        if ((ref.watch(productsSettingsControllerProvider).isShowQty &&
            p.isTracked == true))
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 1),
            decoration: BoxDecoration(
              color: p.qty != null && (p.qty! <= p.warningAlert!)
                  ? Colors.red.withValues(alpha: 0.7)
                  : Colors.green.withValues(alpha: 0.7),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(3),
              ),
            ),
            child: DefaultTextView(
              text: "${p.qty!.formatDouble()}",
              color: Colors.white,
              fontSize:
                  ref.watch(productsSettingsControllerProvider).productWidth /
                  5.5,
            ),
          ),
      ],
    );
  }
}
