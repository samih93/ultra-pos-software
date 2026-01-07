import 'dart:async';
import 'dart:io';

import 'package:desktoppossystem/controller/product_controller.dart';
import 'package:desktoppossystem/controller/setting_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/product_model.dart';
import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
import 'package:desktoppossystem/shared/constances/app_constances.dart';
import 'package:desktoppossystem/shared/constances/asset_constant.dart';
import 'package:desktoppossystem/shared/default%20components/are_you_sure_dialog.dart';
import 'package:desktoppossystem/shared/default%20components/default_price_text.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/default%20components/elevated_button_widget.dart';
import 'package:desktoppossystem/shared/default%20components/quiver_widget.dart';
import 'package:desktoppossystem/shared/services/dependency_injection.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Define a StateNotifier that holds a ProductModel and manages a timer
class LatestCheckedItemNotifier extends StateNotifier<ProductModel?> {
  LatestCheckedItemNotifier(this.ref) : super(null);

  final Ref ref;
  Timer? _timer;

  // Method to update the state and restart the timer
  void updateItem(ProductModel? newItem) {
    // Update the state with the new item
    state = newItem;

    // Reset the timer
    _resetTimer();
  }

  // Private method to reset the timer
  void _resetTimer() {
    // Cancel any existing timer
    _timer?.cancel();

    // Start a new timer for 15 seconds
    _timer = Timer(const Duration(seconds: 15), () {
      // Invalidate this provider after 15 seconds of inactivity
      ref.invalidateSelf();
    });
  }

  // Dispose of the timer if the notifier itself is disposed
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// Create a StateNotifierProvider to provide LatestCheckedItemNotifier
final latestCheckedItemProvider =
    StateNotifierProvider.autoDispose<LatestCheckedItemNotifier, ProductModel?>(
      (ref) => LatestCheckedItemNotifier(ref),
    );

class PriceCheckScreen extends ConsumerWidget {
  const PriceCheckScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: BarcodeKeyboardListener(
        useKeyDownEvent: Platform.isWindows,
        bufferDuration: const Duration(milliseconds: 200),
        onBarcodeScanned: (barcode) {
          // Ignore empty barcode or invalid scan
          if (barcode.isEmpty || barcode == "V") {
            return;
          }

          ref
              .read(productControllerProvider)
              .fetchProductByBarcode(barcode.trim())
              .then((value) {
                if (value != null) {
                  ref
                      .read(latestCheckedItemProvider.notifier)
                      .updateItem(value);
                } else {
                  showDialog(
                    context: context,
                    builder: (_) {
                      // Automatically pop the dialog after 1 second
                      Future.delayed(const Duration(milliseconds: 800), () {
                        context.pop();
                      });
                      return AlertDialog(
                        title: const Center(
                          child: DefaultTextView(text: 'Not found !!!'),
                        ),
                        actions: [
                          TextButton(
                            child: const Text('Ok'),
                            onPressed: () {
                              ref
                                  .read(latestCheckedItemProvider.notifier)
                                  .updateItem(null);

                              context.pop();

                              //  mainController.clearSearch();
                            },
                          ),
                        ],
                      );
                    },
                  );
                }
              });
        },
        child: Stack(
          alignment: AlignmentDirectional.bottomEnd,
          children: [
            Center(
              child: Column(
                children: [
                  kGap30,
                  if (ref.watch(settingControllerProvider).photoBytes != null)
                    Image.memory(
                      ref.watch(settingControllerProvider).photoBytes!,
                      width: context.width * 0.35,
                      height: context.height * 0.3,
                    ),
                  ref.watch(latestCheckedItemProvider) != null
                      ? Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              DefaultTextView(
                                textAlign: TextAlign.center,
                                maxlines: 2,
                                text:
                                    "${ref.watch(latestCheckedItemProvider)!.name}",
                                fontSize: 60,
                                fontWeight: FontWeight.bold,
                              ),
                              if (ref
                                  .watch(saleControllerProvider)
                                  .isShowInDolarInSaleScreen)
                                AppPriceText(
                                  unit: AppConstance.primaryCurrency
                                      .currencyLocalization(),
                                  fontSize: 60,
                                  fontWeight: FontWeight.bold,
                                  text:
                                      '${ref.watch(latestCheckedItemProvider)!.sellingPrice}',
                                ),
                              AppPriceText(
                                unit: AppConstance.secondaryCurrency
                                    .currencyLocalization(),
                                fontSize: 60,
                                fontWeight: FontWeight.bold,
                                text:
                                    (ref
                                                .watch(
                                                  latestCheckedItemProvider,
                                                )!
                                                .sellingPrice! *
                                            ref
                                                .read(saleControllerProvider)
                                                .dolarRate)
                                        .formatAmountNumber(),
                              ),
                              if (ref.watch(latestCheckedItemProvider)!.image !=
                                  null)
                                Image.memory(
                                  width: context.width * .15,
                                  height: context.width * .15,
                                  ref.watch(latestCheckedItemProvider)!.image!,
                                ),
                            ],
                          ),
                        )
                      : Expanded(
                          child: Column(
                            children: [
                              const DefaultTextView(
                                text: "SCAN HERE",
                                fontSize: 60,
                                fontWeight: FontWeight.bold,
                              ),
                              kGap10,
                              Image.asset(
                                AssetConstant.barcodeImage,
                                width: context.width * 0.2,
                                height: context.height * 0.15,
                              ),
                              kGap10,
                              Image.asset(
                                AssetConstant.arrowDownImage,
                                width: context.width * 0.20,
                                height: context.height * 0.15,
                              ),
                            ],
                          ),
                        ),
                ],
              ),
            ),
            if (ref.watch(saleControllerProvider).isShowInDolarInSaleScreen)
              Padding(
                padding: kPadd10,
                child: Align(
                  alignment: AlignmentDirectional.bottomStart,
                  child: Row(
                    children: [
                      const DefaultTextView(
                        text: "Dollar Rate : ",
                        fontSize: 30,
                      ),
                      AppPriceText(
                        fontSize: 30,
                        color: Pallete.redColor,
                        text: ref
                            .watch(saleControllerProvider)
                            .dolarRate
                            .formatAmountNumber(),
                        unit: AppConstance.secondaryCurrency
                            .currencyLocalization(),
                      ),
                    ],
                  ),
                ),
              ),
            Padding(
              padding: kPadd10,
              child: Align(
                alignment: AlignmentDirectional.topEnd,
                child: ElevatedButtonWidget(
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
                  height: 60,
                  width: 100,
                  text: S.of(context).close,
                  color: Pallete.redColor,
                  icon: Icons.exit_to_app_outlined,
                ),
              ),
            ),
            const Padding(
              padding: kPadd10,
              child: Align(
                alignment: AlignmentDirectional.bottomEnd,
                child: CoreWidget(width: 100),
              ),
            ),
          ],
        ),
      ).baseContainer(context.cardColor),
    );
  }
}
