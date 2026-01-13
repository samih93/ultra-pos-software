import 'package:cached_network_image/cached_network_image.dart';
import 'package:desktoppossystem/shared/constances/asset_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CachedNetworkImageWidget extends ConsumerWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final String? errorAsset;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final bool enableMemoryCache;
  final bool enableDiskCache;
  final Duration? fadeInDuration;
  final Duration? fadeOutDuration;
  final Curve fadeInCurve;
  final Curve fadeOutCurve;
  final Alignment alignment;
  final ImageRepeat repeat;
  final bool matchTextDirection;
  final Map<String, String>? httpHeaders;
  final int? memCacheWidth;
  final int? memCacheHeight;
  final String? cacheKey;
  final int? maxWidthDiskCache;
  final int? maxHeightDiskCache;
  final String? heroTag;

  const CachedNetworkImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.errorAsset,
    this.borderRadius,
    this.margin,
    this.padding,
    this.backgroundColor,
    this.enableMemoryCache = true,
    this.enableDiskCache = true,
    this.fadeInDuration,
    this.fadeOutDuration,
    this.fadeInCurve = Curves.easeIn,
    this.fadeOutCurve = Curves.easeOut,
    this.alignment = Alignment.center,
    this.repeat = ImageRepeat.noRepeat,
    this.matchTextDirection = false,
    this.httpHeaders,
    this.memCacheWidth,
    this.memCacheHeight,
    this.cacheKey,
    this.maxWidthDiskCache,
    this.maxHeightDiskCache,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget imageWidget = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      matchTextDirection: matchTextDirection,
      httpHeaders: httpHeaders,
      cacheKey: cacheKey,
      fadeInDuration: fadeInDuration ?? const Duration(milliseconds: 500),
      fadeOutDuration: fadeOutDuration ?? const Duration(milliseconds: 300),
      fadeInCurve: fadeInCurve,
      fadeOutCurve: fadeOutCurve,
      memCacheWidth: memCacheWidth,
      memCacheHeight: memCacheHeight,
      maxWidthDiskCache: maxWidthDiskCache,
      maxHeightDiskCache: maxHeightDiskCache,
      useOldImageOnUrlChange: true,
      placeholder: placeholder != null
          ? (context, url) => placeholder!
          : (context, url) => _buildDefaultPlaceholder(),
      errorWidget: errorWidget != null
          ? (context, url, error) => errorWidget!
          : (context, url, error) => _buildDefaultErrorWidget(),
    );

    // Apply border radius if provided
    if (borderRadius != null) {
      imageWidget = ClipRRect(borderRadius: borderRadius!, child: imageWidget);
    }

    // Apply background color if provided
    if (backgroundColor != null) {
      imageWidget = Container(color: backgroundColor, child: imageWidget);
    }

    // Apply padding if provided
    if (padding != null) {
      imageWidget = Padding(padding: padding!, child: imageWidget);
    }

    // Apply margin if provided
    if (margin != null) {
      imageWidget = Container(margin: margin, child: imageWidget);
    }

    // Apply Hero wrapper if heroTag is provided
    if (heroTag != null) {
      imageWidget = Hero(tag: heroTag!, child: imageWidget);
    }

    return imageWidget;
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[200],
      child: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildDefaultErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey[100],
      child: errorAsset != null
          ? Image.asset(errorAsset!, fit: fit, width: width, height: height)
          : Icon(Icons.error_outline, color: Colors.grey[400], size: 32),
    );
  }

  // Named constructors for common use cases

  // Avatar variant - circular image
  factory CachedNetworkImageWidget.avatar({
    Key? key,
    required String imageUrl,
    double radius = 35,
    Widget? placeholder,
    Widget? errorWidget,
    Color? backgroundColor,
    Map<String, String>? httpHeaders,
    String? heroTag,
  }) {
    return CachedNetworkImageWidget(
      key: key,
      imageUrl: imageUrl,
      width: radius * 2,
      height: radius * 2,
      borderRadius: BorderRadius.circular(radius),
      fit: BoxFit.cover,
      errorAsset: AssetConstant.coreColoredLogo,
      placeholder: placeholder,
      errorWidget: errorWidget,
      backgroundColor: backgroundColor,
      httpHeaders: httpHeaders,
      heroTag: heroTag,
    );
  }

  // Card variant - rounded rectangle
  factory CachedNetworkImageWidget.card({
    Key? key,
    required String imageUrl,
    double? width,
    double? height,
    double borderRadius = 12,
    Widget? placeholder,
    Widget? errorWidget,
    Color? backgroundColor,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    Map<String, String>? httpHeaders,
    String? heroTag,
  }) {
    return CachedNetworkImageWidget(
      key: key,
      imageUrl: imageUrl,
      width: width,
      height: height,
      borderRadius: BorderRadius.circular(borderRadius),
      fit: BoxFit.cover,
      placeholder: placeholder,
      errorWidget: errorWidget ?? Image.asset(AssetConstant.coreColoredLogo),
      backgroundColor: backgroundColor,
      margin: margin,
      padding: padding,
      httpHeaders: httpHeaders,
      heroTag: heroTag,
    );
  }

  // Banner variant - full width with aspect ratio
  factory CachedNetworkImageWidget.banner({
    Key? key,
    required String imageUrl,
    double? width,
    double aspectRatio = 16 / 9,
    double borderRadius = 0,
    Widget? placeholder,
    Widget? errorWidget,
    Color? backgroundColor,
    EdgeInsetsGeometry? margin,
    EdgeInsetsGeometry? padding,
    Map<String, String>? httpHeaders,
    String? heroTag,
  }) {
    return CachedNetworkImageWidget(
      key: key,
      imageUrl: imageUrl,
      width: width,
      height: width != null ? width / aspectRatio : null,
      borderRadius: borderRadius > 0
          ? BorderRadius.circular(borderRadius)
          : null,
      fit: BoxFit.cover,
      placeholder: placeholder,
      errorWidget: errorWidget,
      backgroundColor: backgroundColor,
      margin: margin,
      padding: padding,
      httpHeaders: httpHeaders,
      heroTag: heroTag,
    );
  }

  // Thumbnail variant - small square image
  factory CachedNetworkImageWidget.thumbnail({
    Key? key,
    required String imageUrl,
    double size = 60,
    double borderRadius = 8,
    Widget? placeholder,
    Widget? errorWidget,
    Color? backgroundColor,
    Map<String, String>? httpHeaders,
    String? heroTag,
  }) {
    return CachedNetworkImageWidget(
      key: key,
      imageUrl: imageUrl,
      width: size,
      height: size,
      borderRadius: BorderRadius.circular(borderRadius),
      fit: BoxFit.cover,
      placeholder: placeholder,
      errorWidget: errorWidget,
      backgroundColor: backgroundColor,
      httpHeaders: httpHeaders,
      heroTag: heroTag,
    );
  }

  // Icon variant - small circular image for icons
  factory CachedNetworkImageWidget.icon({
    Key? key,
    required String imageUrl,
    double size = 24,
    Widget? placeholder,
    Widget? errorWidget,
    Color? backgroundColor,
    Map<String, String>? httpHeaders,
    String? heroTag,
  }) {
    return CachedNetworkImageWidget(
      key: key,
      imageUrl: imageUrl,
      width: size,
      height: size,
      borderRadius: BorderRadius.circular(size / 2),
      fit: BoxFit.cover,
      placeholder: placeholder,
      errorWidget: errorWidget,
      backgroundColor: backgroundColor,
      httpHeaders: httpHeaders,
      heroTag: heroTag,
    );
  }
}
