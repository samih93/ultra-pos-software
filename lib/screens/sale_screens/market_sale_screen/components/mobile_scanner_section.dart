import 'dart:io';
import 'package:audio_plus/audio_plus.dart';
import 'package:desktoppossystem/shared/constances/asset_constant.dart';
import 'package:desktoppossystem/shared/default%20components/mobile_scanner_widget.dart';
import 'package:desktoppossystem/shared/default%20components/elevated_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:desktoppossystem/controller/product_controller.dart';
import 'package:desktoppossystem/repositories/products/product_repository.dart';
import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';

// State providers for mobile scanner
final mobileScannerActiveProvider = StateProvider<bool>((ref) => false);
final isScanningProvider = StateProvider<bool>((ref) => false);

class MobileScannerSection extends ConsumerWidget {
  const MobileScannerSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only show on non-Windows platforms
    if (Platform.isWindows) {
      return const SizedBox.shrink();
    }

    final isScannerActive = ref.watch(mobileScannerActiveProvider);
    final isScanning = ref.watch(isScanningProvider);

    return Container(
      padding: defaultPadding,
      decoration: BoxDecoration(
        border: Border.all(color: Pallete.greyColor),
        borderRadius: defaultRadius,
        color: context.cardColor,
      ),
      child: Column(
        children: [
          // Toggle button
          if (!context.isMobile)
            Row(
              children: [
                Expanded(
                  child: ElevatedButtonWidget(
                    onPressed: () {
                      ref.read(mobileScannerActiveProvider.notifier).state =
                          !isScannerActive;
                    },
                    icon: isScannerActive ? Icons.close : Icons.qr_code_scanner,

                    text: isScannerActive ? 'Close' : 'Open',
                  ),
                ),
              ],
            ),

          // Scanner widget (conditional)
          if (isScannerActive) ...[
            kGap8,
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: defaultRadius,
                  border: Border.all(color: Pallete.greyColor),
                ),
                child: ClipRRect(
                  borderRadius: defaultRadius,
                  child: Stack(
                    children: [
                      // Mobile scanner widget
                      MobileScannerWidget(
                        onBarcodeDetected: (barcode) =>
                            _handleBarcodeDetected(barcode, ref, context),
                      ),

                      // Scanning overlay
                      if (isScanning)
                        Container(
                          color: Colors.black.withValues(alpha: 0.3),
                          child: const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(color: Colors.white),
                                kGap8,
                                DefaultTextView(
                                  text: 'Processing scan...',
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ] else ...[
            kGap8,
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.qr_code_scanner,
                      size: 48,
                      color: Pallete.greyColor,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _handleBarcodeDetected(
    String barcode,
    WidgetRef ref,
    BuildContext context,
  ) async {
    // Prevent multiple concurrent scans
    if (ref.read(isScanningProvider)) return;

    ref.read(isScanningProvider.notifier).state = true;

    try {
      barcode = barcode.trim();

      // Handle weighted products (same logic as barcode listener)
      if (barcode.startsWith('27') && barcode.length == 13) {
        await _handleWeightedProduct(barcode, ref);
        return;
      }

      // Fetch product by barcode and add to basket
      final product = await ref
          .read(productControllerProvider)
          .fetchProductByBarcode(barcode);

      if (product != null) {
        ref.read(saleControllerProvider).addItemToBasket(product);
        if (Platform.isAndroid || Platform.isIOS) {
          AudioPlus.play(AssetConstant.beepSound);
        }
      } else {
        // Show not found dialog
        if (context.mounted) {
          _showNotFoundDialog(context);
        }
      }
    } catch (e) {
      debugPrint('Error handling barcode: $e');
    } finally {
      // Reset scanning state after delay
      await Future.delayed(const Duration(milliseconds: 750));
      ref.read(isScanningProvider.notifier).state = false;
    }
  }

  Future<void> _handleWeightedProduct(String barcode, WidgetRef ref) async {
    String prefix = barcode.substring(0, 2);
    String plu = barcode.substring(2, 7);
    String weightDigits = barcode.substring(7, 12);
    int weightGrams = int.parse(weightDigits);
    double weightKg = weightGrams / 1000;

    final product = await ref
        .read(productProviderRepository)
        .fetchProductByPlu(int.parse(plu));

    if (product != null) {
      ref
          .read(saleControllerProvider)
          .addItemToBasket(product, weight: weightKg);
    }
  }

  void _showNotFoundDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        // Auto-close after 2 seconds
        Future.delayed(const Duration(seconds: 2), () {
          if (context.mounted) {
            context.pop();
          }
        });

        return AlertDialog(
          title: const Center(
            child: DefaultTextView(text: 'Product Not Found!'),
          ),
          content: const DefaultTextView(
            text: 'The scanned barcode was not found in the system.',
            fontSize: 14,
          ),
          actions: [
            TextButton(child: const Text('OK'), onPressed: () => context.pop()),
          ],
        );
      },
    );
  }
}
