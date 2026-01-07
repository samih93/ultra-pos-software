import 'dart:async';

import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/shared/constances/asset_constant.dart';
import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

extension CacheForExtension on Ref<Object?> {
  /// Keeps the provider alive for [duration].
  void cacheFor(Duration duration) {
    // Immediately prevent the state from getting destroyed.
    final link = keepAlive();
    // After duration has elapsed, we re-enable automatic disposal.
    final timer = Timer(duration, link.close);

    // Optional: when the provider is recomputed (such as with ref.watch),
    // we cancel the pending timer.
    onDispose(timer.cancel);
  }
}

extension NavigatorExtension on BuildContext {
  to(Widget route) {
    if (mounted) {
      Navigator.push(this, PageScaleTransition(page: route));
    }
  }

  off(Widget route) {
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        this,
        PageScaleTransition(page: route),
        (route) => false,
      );
    }
  }

  pop({value}) {
    if (Navigator.canPop(this)) {
      value != null ? Navigator.pop(this, value) : Navigator.pop(this);
    }
  }

  // ! Device Size

  bool get isMobile => isSmallMobile || isBigMobile;
  bool get isSmallMobile => MediaQuery.sizeOf(this).width <= 500.0;

  bool get isTablet =>
      MediaQuery.sizeOf(this).width < 1024.0 &&
      MediaQuery.sizeOf(this).width >= 850.0;

  bool get isBigMobile =>
      MediaQuery.sizeOf(this).width < 850 &&
      MediaQuery.sizeOf(this).width > 500.0;

  bool get isDesktop => MediaQuery.sizeOf(this).width >= 1024.0;

  bool get isSmall =>
      MediaQuery.sizeOf(this).width < 850.0 &&
      MediaQuery.sizeOf(this).width >= 560.0;

  double get width => MediaQuery.sizeOf(this).width;

  double get height => MediaQuery.sizeOf(this).height;

  // Responsive Text Sizes
  double get headingSize => isTablet ? 28 : 32;
  double get titleSize => isTablet ? 22 : 26;
  double get subtitleSize => isTablet ? 18 : 20;
  double get bodySize => isTablet ? 14 : 16;
  double get smallSize => isTablet ? 10 : 12;

  // Theme Colors
  ThemeData get theme => Theme.of(this);

  Color get cardColor => theme.cardColor;
  Color get primaryColor => theme.primaryColor;
  Color get scaffoldBackgroundColor => theme.scaffoldBackgroundColor;
  TextTheme get textTheme => theme.textTheme;
  Color get disabledColor => theme.disabledColor;
  Color get selectedPrimaryColor => theme.brightness == Brightness.dark
      ? Pallete.primaryColorDark
      : Pallete.primaryColor;
  Color get selectedListColor => theme.brightness == Brightness.dark
      ? Pallete.primaryColorDark
      : Pallete.primaryColor.withValues(alpha: 0.5);
  Color get brightnessColor => theme.brightness == Brightness.dark
      ? Pallete.whiteColor
      : Pallete.blackColor;

  String get imageCoreButton => theme.brightness == Brightness.dark
      ? AssetConstant.coreWhiteColor
      : AssetConstant.coreColoredLogo;
  String get coreImageWithName => theme.brightness == Brightness.dark
      ? AssetConstant.coreWhiteLogoWithName
      : AssetConstant.coreLogoWithName;
  bool get isWindows => defaultTargetPlatform == TargetPlatform.windows;
}

extension GradientDisabledEffect on Gradient {
  Gradient getDisabledGradient(Color disabledColor) {
    // Check if gradient has colors
    if (this is LinearGradient) {
      final linearGradient = this as LinearGradient;
      return LinearGradient(
        colors: linearGradient.colors.map((color) {
          // Reduce the opacity to simulate a disabled effect
          return color.withValues(
            alpha: 0.5,
          ); // Adjust the opacity for the disabled state
        }).toList(),
      );
    } else {
      // If no gradient is provided, fallback to a solid color for the disabled state
      return LinearGradient(
        colors: [
          disabledColor.withValues(alpha: 0.5),
          disabledColor.withValues(alpha: 0.5),
        ], // Solid disabled color
      );
    }
  }
}

extension ColorToStringCoverter on Color {
  //! used for color picker to only hex code
  String getStringColorFromHex() {
    try {
      String hexString = value.toRadixString(16).padLeft(8, '0');
      return '0x$hexString';
    } catch (e) {
      debugPrint("Error: $e");
      return ""; // Return empty string if there's an error
    }
  }

  Color getTextColorBasedOnBackground() {
    // Compute the luminance of the background color
    double luminance = computeLuminance();

    // If luminance is greater than 0.5, the background is light, so return a dark color for the text
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  Color adjustFocusColorBasedOnCurrent() {
    // If the luminance is < 0.5 (dark color), lighten it
    if (computeLuminance() < 0.5) {
      return withValues(alpha: 0.7).withRed((red + 15).clamp(0, 255));
    }
    // If the luminance is >= 0.5 (light this), darken it
    else {
      return withValues(alpha: 0.8).withRed((red - 20).clamp(0, 255));
    }
  }

  MaterialColor createMaterialColor() {
    final r = (this.r * 255).round();
    final g = (this.g * 255).round();
    final b = (this.b * 255).round();

    final strengths = <double>[.05];
    final swatch = <int, Color>{};

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }

    for (var strength in strengths) {
      final ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }

    return MaterialColor(value, swatch);
  }
}

extension NullableIntExtensions on int? {
  int validateInt({int value = 0}) {
    if (this == null) {
      return value;
    } else {
      return this!;
    }
  }
}

extension NullableStringExtensions on String? {
  String validateString({String value = ''}) {
    if (this == null) {
      return value;
    } else {
      return this!;
    }
  }
}

extension ConvertCurrency on String {
  LabelSize toLabelSize() {
    return LabelSize.values.firstWhere(
      (e) => e.name == this,
      orElse: () => LabelSize.normal, // fallback if invalid or unknown
    );
  }

  String? validateDate() {
    if (isEmpty) {
      return "Date cannot be empty"; // Handle empty input
    }

    // Split the date into year, month, and day
    final dateParts = split('-');
    if (dateParts.length != 3) {
      return "Invalid date format. Use YYYY-MM-DD."; // Ensure correct format
    }

    // Parse year, month, and day
    final year = int.tryParse(dateParts[0]);
    final month = int.tryParse(dateParts[1]);
    final day = int.tryParse(dateParts[2]);

    // Validate year, month, and day
    if (year == null || month == null || day == null) {
      return "Invalid date. Use numbers only."; // Ensure valid numbers
    }

    // Validate month
    if (month < 1 || month > 12) {
      return "Invalid month. Month must be between 1 and 12.";
    }

    // Validate day
    final maxDays = getMaxDaysInMonth(month, year);
    if (day < 1 || day > maxDays) {
      return "Invalid day. Day must be between 1 and $maxDays for this month.";
    }

    // If all checks pass, the date is valid
    return null;
  }

  double validateDouble() {
    return double.tryParse(this) ?? 0.0;
  }

  int validateInteger() {
    return int.tryParse(this) ?? 0;
  }

  bool validateBool() {
    return toLowerCase() == 'true' || this == '1';
  }

  bool isValidDate() {
    if (length != 10) {
      return false; // Ensure the input is exactly 10 characters (YYYY-MM-DD)
    }

    // Split the date into year, month, and day
    final dateParts = split('-');
    if (dateParts.length != 3) {
      return false; // Ensure correct format
    }

    // Parse year, month, and day
    final year = int.tryParse(dateParts[0]);
    final month = int.tryParse(dateParts[1]);
    final day = int.tryParse(dateParts[2]);

    // Validate year, month, and day
    if (year == null || month == null || day == null) {
      return false; // Ensure valid numbers
    }

    // Validate month
    if (month < 1 || month > 12) {
      return false; // Month must be between 1 and 12
    }

    // Validate day
    final maxDays = getMaxDaysInMonth(month, year); // Helper function
    if (day < 1 || day > maxDays) {
      return false; // Day must be between 1 and maxDays for this month
    }

    // If all checks pass, the date is valid
    return true;
  }

  toEnumLanguage() {
    switch (this) {
      case "en":
        return Language.en;
      case "fr":
        return Language.fr;
      case "ar":
        return Language.ar;
      default:
        return Language.en;
    }
  }

  String removePrefix() {
    if (startsWith('0x')) {
      return substring(
        2,
      ); // Returns a new string without modifying the original
    } else {
      return this; // Returns the original string unchanged
    }
  }

  Color getColorFromHex() {
    try {
      if (isEmpty) {
        throw const FormatException('Color string is empty.');
      }
      return Color(int.parse(this));
    } catch (e) {
      debugPrint("Error: $e");
      // Return black color if there's an error
      return const Color(0xffb287fd);
    }
  }

  PaymentType paymentToEnum() {
    switch (this) {
      case "cash":
        return PaymentType.cash;
      case "card":
        return PaymentType.card;
      case "bankTransfer":
        return PaymentType.bankTransfer;

      default:
        return PaymentType.cash;
    }
  }

  TransactionFlow transactionFlowToEnum() {
    switch (this) {
      case "IN":
        return TransactionFlow.IN;
      case "OUT":
        return TransactionFlow.OUT;

      default:
        return TransactionFlow.IN;
    }
  }

  OrderType orderToEnum() {
    switch (this) {
      case "delivery":
        return OrderType.delivery;
      case "dineIn":
        return OrderType.dineIn;

      default:
        return OrderType.dineIn;
    }
  }

  UnitType unitTypeToEnum() {
    switch (this) {
      case "kg":
        return UnitType.kg;
      case "portion":
        return UnitType.portion;

      default:
        return UnitType.portion;
    }
  }

  WasteType wasteTypeToEnum() {
    switch (this) {
      case "normal":
        return WasteType.normal;
      case "staff":
        return WasteType.staff;

      default:
        return WasteType.normal;
    }
  }

  SectionType sectionTypeToEnum() {
    switch (this) {
      case "kitchen":
        return SectionType.kitchen;
      case "bar":
        return SectionType.bar;
      case "tobacco":
        return SectionType.tobacco;

      default:
        return SectionType.kitchen;
    }
  }

  StockTransactionType stockTransactionTypeToEnum() {
    switch (this) {
      case "stockIn":
        return StockTransactionType.stockIn;
      case "stockOut":
        return StockTransactionType.stockOut;
      default:
        return StockTransactionType.stockIn;
    }
  }

  TransactionType transactionToEnum() {
    switch (this) {
      case "deposit":
        return TransactionType.deposit;
      case "withdraw":
        return TransactionType.withdraw;
      case "salePayment":
        return TransactionType.salePayment;
      case "pendingPayment":
        return TransactionType.pendingPayment;
      case "refund":
        return TransactionType.refund;
      case "adjustment":
        return TransactionType.adjustment;
      case "purchase":
        return TransactionType.purchase;

      default:
        return TransactionType.salePayment;
    }
  }

  Currency currencyToEnum() {
    switch (this) {
      case "LBP":
        return Currency.LBP;
      case "USD":
        return Currency.USD;
      case "EGP":
        return Currency.EGP;
      case "ILS":
        return Currency.ILS;
      case "SAR":
        return Currency.SAR;
      case "SYP":
        return Currency.SYP;
      case "QAR":
        return Currency.QAR;
      default:
        return Currency.LBP;
    }
  }

  capitalizeFirstLetter() {
    return this[0].toUpperCase() + substring(1);
  }

  arabicProfitStatus(BuildContext context) {
    switch (this) {
      case "daily":
        return S.of(context).daily;
      case "monthly":
        return S.of(context).monthly;
      case "yearly":
        return S.of(context).yearly;
    }
  }

  orderTypeLocalization(BuildContext context) {
    switch (this) {
      case "delivery":
        return S.of(context).delivery;
      case "dineIn":
        return S.of(context).dineIn;
      default:
        return S.of(context).dineIn;
    }
  }

  stockFilterLocalization(BuildContext context) {
    switch (this) {
      case "all":
        return S.of(context).all;
      case "foodItems":
        return S.of(context).foodItems;
      case "packaging":
        return S.of(context).packaging;
      case "lowStock":
        return S.of(context).lowStock;
      default:
        return S.of(context).all;
    }
  }

  restaurantFilterICon() {
    switch (this) {
      case "all":
        return const Icon(FontAwesomeIcons.globe, size: 20);
      case "foodItems":
        return const Icon(FontAwesomeIcons.utensils, size: 20);
      case "packaging":
        return const Icon(FontAwesomeIcons.box, size: 20);
      case "lowStock":
        return const Icon(
          FontAwesomeIcons.triangleExclamation,
          size: 20,
          color: Pallete.orangeColor,
        );
      default:
        return const FaIcon(FontAwesomeIcons.globe, size: 20);
    }
  }

  currencyLocalization() {
    switch (this) {
      case "LBP":
        return isEnglishLanguage ? "L.L" : "ل.ل";
      case "USD":
        return isEnglishLanguage ? "\$" : "\$";
      case "EGP":
        return isEnglishLanguage ? Currency.EGP.name : "ج.م";
      case "ILS":
        return isEnglishLanguage ? Currency.ILS.name : "شيكل";
      case "SAR":
        return Currency.SAR.name;
      case "SYP":
        return isEnglishLanguage ? Currency.SYP.name : "ل.س";
      case "QAR":
        return Currency.QAR.name;
      default:
        return Currency.LBP.name;
    }
  }
}

extension FormatedToCustomDate on DateTime {
  mMMddyyyyFormat() {
    return DateFormat.yMMMd().format(this);
  }

  isToday() {
    DateTime currentDate = DateTime.now();

    return (year == currentDate.year &&
        month == currentDate.month &&
        day == currentDate.day);
  }

  isTomorrow() {
    DateTime currentDate = DateTime.now();

    return (year == currentDate.year &&
        month == currentDate.month &&
        day == currentDate.day + 1);
  }

  formatDateTimeToISO8601() {
    return DateFormat("yyyyMMdd'T'HHmmss'Z'").format(this);
  }

  toAmPmFormat() {
    return DateFormat("h:mm a").format(this);
  }

  toAmPmWithSecondsFormat() {
    return DateFormat("h:mm:ss a").format(this);
  }

  to24Format() {
    return DateFormat("HH:mm").format(this);
  }

  toNormalDate() {
    return DateFormat("dd-MM-yyyy").format(this);
  }

  formatDateTime12Hours() {
    return DateFormat("dd-MM-yyyy hh:mm a").format(this);
  }
}

extension DashboardFilterExtension on DashboardFilterEnum {
  String localizedName(BuildContext context) {
    switch (this) {
      case DashboardFilterEnum.lastYear:
        return S.of(context).lastYear.toLowerCase().capitalizeFirstLetter();
      case DashboardFilterEnum.lastMonth:
        return S.of(context).lastMonth.toLowerCase().capitalizeFirstLetter();
      case DashboardFilterEnum.yesterday:
        return S.of(context).yesterday.toLowerCase().capitalizeFirstLetter();
      case DashboardFilterEnum.today:
        return S.of(context).today.toLowerCase().capitalizeFirstLetter();
      case DashboardFilterEnum.thisWeek:
        return S.of(context).thisWeek.toLowerCase().capitalizeFirstLetter();
      case DashboardFilterEnum.thisMonth:
        return S.of(context).thisMonth.toLowerCase().capitalizeFirstLetter();
      case DashboardFilterEnum.thisYear:
        return S.of(context).thisYear.toLowerCase().capitalizeFirstLetter();
    }
  }
}

extension ProfitFilterExtension on ReportInterval {
  String localizedName(BuildContext context) {
    switch (this) {
      case ReportInterval.daily:
        return S.of(context).daily;
      case ReportInterval.monthly:
        return S.of(context).monthly;
      case ReportInterval.yearly:
        return S.of(context).yearly;
    }
  }
}

extension UnitTypeExtension on UnitType {
  uniteTypeToString() {
    switch (this) {
      case UnitType.kg:
        return UnitType.kg.name;
      case UnitType.portion:
        return UnitType.portion.name.substring(0, 2);
    }
  }
}

extension SectionTypeExtension on SectionType {
  sectionTypeToString() {
    switch (this) {
      case SectionType.kitchen:
        return SectionType.kitchen.name;
      case SectionType.bar:
        return SectionType.bar.name;
      case SectionType.tobacco:
        return SectionType.tobacco.name;
      case SectionType.desserts:
        return SectionType.desserts.name;
    }
  }
}

extension DoubleExtensions on double? {
  String formatAmountNumber() {
    return NumberFormat("#,##0.0", "en_US").format(validateDouble());
  }

  double validateDouble({double value = 0}) {
    if (this == null) {
      return value;
    } else {
      return this!;
    }
  }

  double formatDouble() {
    // Convert to string with up to 5 decimal places for intermediate precision
    String valueStr = validateDouble().toStringAsFixed(5);

    // Find the index of the decimal point
    int decimalIndex = valueStr.indexOf('.');

    // If there's no decimal point, return the number as is
    if (decimalIndex == -1) {
      return double.parse(valueStr);
    }

    // Extract the integer and decimal parts
    String integerPart = valueStr.substring(0, decimalIndex);
    String decimalPart = valueStr.substring(decimalIndex + 1);

    // Limit decimal places to 3 and remove trailing zeros
    if (decimalPart.length > 3) {
      decimalPart = decimalPart.substring(0, 3);
    }

    // Remove trailing zeros from the decimal part
    decimalPart = decimalPart.replaceAll(RegExp(r'0+$'), '');

    // Combine the integer and decimal parts
    return decimalPart.isEmpty
        ? double.parse(integerPart)
        : double.parse('$integerPart.$decimalPart');
  }

  double formatDoubleWith6() {
    // Convert to string with 6 decimal places for maximum precision
    String valueStr = validateDouble().toStringAsFixed(6);

    // Find the index of the decimal point
    int decimalIndex = valueStr.indexOf('.');

    // If there's no decimal point, return the number as is
    if (decimalIndex == -1) {
      return double.parse(valueStr);
    }

    // Extract parts
    String integerPart = valueStr.substring(0, decimalIndex);
    String decimalPart = valueStr.substring(decimalIndex + 1);

    // Remove trailing zeros while preserving up to 6 significant decimal places
    decimalPart = decimalPart.replaceAll(RegExp(r'(0+)$'), '');

    // If all decimals were zeros, return just the integer part
    if (decimalPart.isEmpty) {
      return double.parse(integerPart);
    }

    // Ensure we don't exceed 6 decimal places
    if (decimalPart.length > 6) {
      decimalPart = decimalPart.substring(0, 6);
    }

    return double.parse('$integerPart.$decimalPart');
  }
}

extension WidgetExtension on Widget {
  /// With custom height and width
  SizedBox withSize({double width = 0.0, double height = 0.0}) {
    return SizedBox(height: height, width: width, child: this);
  }

  /// With custom width
  SizedBox withWidth(double width) => SizedBox(width: width, child: this);

  /// With custom height
  SizedBox withHeight(double height) => SizedBox(height: height, child: this);

  /// return padding top
  Padding paddingTop(double top) {
    return Padding(
      padding: EdgeInsets.only(top: top),
      child: this,
    );
  }

  /// return padding left
  Padding paddingLeft(double left) {
    return Padding(
      padding: EdgeInsets.only(left: left),
      child: this,
    );
  }

  /// return padding right
  Padding paddingRight(double right) {
    return Padding(
      padding: EdgeInsets.only(right: right),
      child: this,
    );
  }

  /// return padding bottom
  Padding paddingBottom(double bottom) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: this,
    );
  }

  /// return padding all
  Padding paddingAll({double? padding}) {
    return Padding(
      padding: padding != null ? EdgeInsets.all(padding) : defaultPadding,
      child: this,
    );
  }

  /// return custom padding from each side
  Padding paddingOnly({
    double top = 0.0,
    double left = 0.0,
    double bottom = 0.0,
    double right = 0.0,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(left, top, right, bottom),
      child: this,
    );
  }

  /// return padding symmetric
  Padding paddingSymmetric({double vertical = 0.0, double horizontal = 0.0}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: vertical, horizontal: horizontal),
      child: this,
    );
  }

  /// set visibility
  Widget visible(bool visible, {Widget? defaultWidget}) {
    return visible ? this : (defaultWidget ?? const SizedBox());
  }

  /// add custom corner radius each side
  ClipRRect cornerRadiusWithClipRRectOnly({
    int bottomLeft = 0,
    int bottomRight = 0,
    int topLeft = 0,
    int topRight = 0,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(bottomLeft.toDouble()),
        bottomRight: Radius.circular(bottomRight.toDouble()),
        topLeft: Radius.circular(topLeft.toDouble()),
        topRight: Radius.circular(topRight.toDouble()),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: this,
    );
  }

  /// add corner radius
  ClipRRect cornerRadiusWithClipRRect({double? radius}) {
    return ClipRRect(
      borderRadius: radius == null
          ? defaultRadius
          : BorderRadius.all(Radius.circular(radius)),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: this,
    );
  }

  /// add opacity to parent widget
  Widget opacity({
    required double opacity,
    int durationInSecond = 1,
    Duration? duration,
  }) {
    return AnimatedOpacity(
      opacity: opacity,
      duration: duration ?? const Duration(milliseconds: 500),
      child: this,
    );
  }

  /// add rotation to parent widget
  Widget rotate({
    required double angle,
    bool transformHitTests = true,
    Offset? origin,
  }) {
    return Transform.rotate(
      origin: origin,
      angle: angle,
      transformHitTests: transformHitTests,
      child: this,
    );
  }

  /// add scaling to parent widget
  Widget scale({
    required double scale,
    Offset? origin,
    AlignmentGeometry? alignment,
    bool transformHitTests = true,
  }) {
    return Transform.scale(
      scale: scale,
      origin: origin,
      alignment: alignment,
      transformHitTests: transformHitTests,
      child: this,
    );
  }

  Widget withDirectionality({ui.TextDirection? textDirection}) {
    return Directionality(
      textDirection: textDirection ?? ui.TextDirection.rtl,
      child: this,
    );
  }

  /// set parent widget in center
  Widget center({double? heightFactor, double? widthFactor}) {
    return Center(
      heightFactor: heightFactor,
      widthFactor: widthFactor,
      child: this,
    );
  }

  // /// add tap to parent widget
  // Widget onTap(
  //   Function? function, {
  //   BorderRadius? borderRadius,
  //   Color? splashColor,
  //   Color? hoverColor,
  //   Color? highlightColor,
  //   Color? focusColor,
  //   WidgetStateProperty<Color?>? overlayColor,
  // }) {
  //   return InkWell(
  //     onTap: function as void Function()?,
  //     borderRadius: borderRadius ??
  //         (defaultInkWellRadius != null ? radius(defaultInkWellRadius) : null),
  //     child: this,
  //     splashColor: splashColor ?? defaultInkWellSplashColor,
  //     hoverColor: hoverColor ?? defaultInkWellHoverColor,
  //     highlightColor: highlightColor ?? defaultInkWellHighlightColor,
  //     focusColor: focusColor,
  //     overlayColor: overlayColor,
  //   );
  // }

  /// Wrap with ShaderMask widget
  Widget withShaderMask(
    List<Color> colors, {
    BlendMode blendMode = BlendMode.srcATop,
  }) {
    return withShaderMaskGradient(
      LinearGradient(colors: colors),
      blendMode: blendMode,
    );
  }

  /// Wrap with ShaderMask widget Gradient
  Widget withShaderMaskGradient(
    Gradient gradient, {
    BlendMode blendMode = BlendMode.srcATop,
  }) {
    return ShaderMask(
      shaderCallback: (rect) => gradient.createShader(rect),
      blendMode: blendMode,
      child: this,
    );
  }

  /// add Expanded to parent widget
  Widget expand({flex = 1}) => Expanded(flex: flex, child: this);

  /// add Flexible to parent widget
  Widget flexible({flex = 1, FlexFit? fit}) {
    return Flexible(flex: flex, fit: fit ?? FlexFit.loose, child: this);
  }

  /// add FittedBox to parent widget
  Widget fit({BoxFit? fit, AlignmentGeometry? alignment}) {
    return FittedBox(
      fit: fit ?? BoxFit.contain,
      alignment: alignment ?? Alignment.center,
      child: this,
    );
  }

  Widget baseContainer(Color color, {EdgeInsets? margin}) {
    return Container(
      padding: defaultPadding, // replace with defaultPadding
      margin: margin ?? defaultMargin, // replace with defaultMargin
      decoration: BoxDecoration(
        color: color,
        borderRadius: defaultRadius, // replace with defaultRadius
        border: Border.all(color: Pallete.greyColor),
      ),
      child: this, // The original widget is used as the child of the container
    );
  }

  /// Validate given widget is not null and returns given value if null.
  Widget validate({Widget value = const SizedBox()}) => this;

  @Deprecated('Use withTooltip() instead')
  Widget tooltip({required String msg}) {
    return Tooltip(message: msg, child: this);
  }

  /// Validate given widget is not null and returns given value if null.
  Widget withTooltip({required String msg}) {
    return Tooltip(message: msg, child: this);
  }
}

// Extension to convert string to SubscriptionStatus enum
extension SubscriptionStatusExtension on SubscriptionStatus {
  static SubscriptionStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return SubscriptionStatus.active;

      case 'canceled':
        return SubscriptionStatus.canceled;
      default:
        return SubscriptionStatus.active; // Default fallback
    }
  }

  String get displayName {
    switch (this) {
      case SubscriptionStatus.active:
        return 'Active';
      case SubscriptionStatus.overdue:
        return 'Overdue';
      case SubscriptionStatus.canceled:
        return 'Canceled';
    }
  }
}

// Extension to convert string to SubscriptionCycleStatus enum
extension SubscriptionCycleStatusExtension on SubscriptionCycleStatus {
  static SubscriptionCycleStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return SubscriptionCycleStatus.paid;
      case 'unpaid':
        return SubscriptionCycleStatus.unpaid;
      default:
        return SubscriptionCycleStatus.unpaid; // Default fallback
    }
  }

  String get displayName {
    switch (this) {
      case SubscriptionCycleStatus.paid:
        return 'Paid';
      case SubscriptionCycleStatus.unpaid:
        return 'Unpaid';
    }
  }
}
