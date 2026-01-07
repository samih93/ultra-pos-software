import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';

class ResponsiveWidget extends StatelessWidget {
  final Widget? mobileView;
  final Widget desktopView;

  // Constructor: tablet shares desktop view
  const ResponsiveWidget({
    super.key,
    this.mobileView,
    required this.desktopView,
  });

  @override
  Widget build(BuildContext context) {
    // Mobile (< 600px): Show custom mobile UI if provided
    // Tablet/Desktop (>= 600px): Always show desktop UI
    if (context.isMobile && mobileView != null) {
      return mobileView!;
    }
    return desktopView; // Tablet and desktop share same layout
  }
}
