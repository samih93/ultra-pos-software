import 'package:desktoppossystem/shared/constances/asset_constant.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:flutter/material.dart';

void shortToastMessage(BuildContext context, String message,
    {Duration? duration}) {
  final overlay = Overlay.of(context);
  final overlayEntry = OverlayEntry(
    builder: (context) => Align(
      alignment: AlignmentDirectional.center,
      child: Material(
        color: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 300),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                AssetConstant.coreLogoWithName,
                height: 30,
              ),
              kGap5,
              Flexible(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  // Insert the overlay entry
  overlay.insert(overlayEntry);

  Future.delayed(duration ?? const Duration(milliseconds: 600), () {
    overlayEntry.remove();
  });
}
