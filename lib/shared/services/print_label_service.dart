import 'package:desktoppossystem/controller/printer_controller.dart';
import 'package:desktoppossystem/controller/setting_controller.dart';
import 'package:desktoppossystem/models/product_model.dart';
import 'package:desktoppossystem/shared/constances/app_constances.dart';
import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:thermal_printer_plus/esc_pos_utils_platform/esc_pos_utils_platform.dart';

abstract interface class PrinterLabelService {
  Future<List<int>> buildLabel({required ProductModel productModel});
  factory PrinterLabelService(LabelSize size) {
    switch (size) {
      case LabelSize.normal:
        return NormalLabelPrinter();
      case LabelSize.mm20_30:
        return SmallLabelPrinter();
      case LabelSize.mm10G10:
        return TenMmLabelPrinter();
    }
  }
}

class NormalLabelPrinter implements PrinterLabelService {
  @override
  Future<List<int>> buildLabel({required ProductModel productModel}) async {
    List<int> commandBytes = [];
    final storeName = globalAppWidgetRef
        .read(settingControllerProvider)
        .settingModel
        .storeName
        .toString();
    final printStoreOnLabel = globalAppWidgetRef
        .read(printerControllerProvider)
        .printStoreNameOnLabel;
    final printOnLabelPrinter = globalAppWidgetRef
        .read(printerControllerProvider)
        .isPrintLabelOnLabelPrinter;

    if (printOnLabelPrinter) {
      // Define label width
      const double labelWidth = 400; // Adjust based on your label width

      // Define average character width
      const double avgCharWidth = 9; // Adjust based on your testing and font

      // Calculate the estimated width of the product name
      String productName = "${productModel.name}";
      double estimatedTextWidthMm = avgCharWidth * productName.length;

      // Calculate the starting X coordinate to center the product name
      double startingX = (labelWidth - estimatedTextWidthMm + 10) / 2;

      // Calculate positions for other elements
      String price = "\$${productModel.sellingPrice}";
      double priceWidth = avgCharWidth * price.length;
      double priceX = (labelWidth - priceWidth) / 2;

      double storeNameWidth = (avgCharWidth + 5) * storeName.length;
      double storeNameX = (labelWidth - storeNameWidth) / 2;

      double barcodeStartUp =
          (labelWidth - (productModel.barcode!.length * 12)) / 2;

      try {
        var tsplCommands =
            '''
SIZE 60 mm, 40 mm
GAP 3 mm, 0 mm
CLS
TEXT ${startingX.toInt()},35,"TSS24.BF2",0,1,1,"${productModel.name}"
TEXT ${priceX.toInt()},75,"TSS24.BF2",0,1,1,"$price"
BARCODE ${barcodeStartUp.toInt()},110,"128",100,1,0,2,2,"${productModel.barcode}"
${printStoreOnLabel ? 'TEXT ${storeNameX.toInt()},260,"TSS24.BF2",0,2,2,"$storeName"' : ''}
PRINT 1,1
''';
        commandBytes = tsplCommands.codeUnits;
      } catch (e) {
        debugPrint("label error $e");
      }
    } else {
      CapabilityProfile profile = await CapabilityProfile.load();
      final generator = Generator(PaperSize.mm58, profile);
      commandBytes += generator.text(
        productModel.name.toString(),
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
      );
      commandBytes += generator.text(
        "${productModel.sellingPrice} ${AppConstance.primaryCurrency.currencyLocalization()}",
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ),
        linesAfter: 1,
      );
      if (productModel.barcode.toString().isNotEmpty) {
        commandBytes += generator.barcode(
          Barcode.code39(productModel.barcode!.toUpperCase().split("")),
          height: 80,
          width: 80,
        );
      }

      commandBytes += generator.cut();
    }

    return commandBytes;
  }
}

class SmallLabelPrinter implements PrinterLabelService {
  @override
  Future<List<int>> buildLabel({required ProductModel productModel}) async {
    List<int> commandBytes = [];

    // Define the small label size (20mm x 30mm)
    const double labelWidth = 300; // 20mm in dots
    const double labelHeight = 200; // 30mm in dots

    // Define average character width for price
    const double avgCharWidth = 9;

    // Price formatting
    String price = "\$${productModel.sellingPrice}";
    double priceWidth = avgCharWidth * price.length;
    double priceX = (labelWidth - priceWidth) / 2; // Center price horizontally

    try {
      var tsplCommands =
          '''
SIZE 25 mm, 19 mm
GAP 0 mm, 0 mm
CLS
TEXT 10,50,"0",0,1,1,"${productModel.name}"
BARCODE 30,70,"128",30,1,0,1,1,"${productModel.barcode}"
TEXT 15,120,"0",0,1,1,"$price"

PRINT 1,1
''';

      commandBytes = tsplCommands.codeUnits;
    } catch (e) {
      debugPrint("label error $e");
    }

    return commandBytes;
  }
}

class TenMmLabelPrinter implements PrinterLabelService {
  @override
  Future<List<int>> buildLabel({required ProductModel productModel}) async {
    List<int> commandBytes = [];

    // Price formatting
    String price = "\$${productModel.sellingPrice}";

    try {
      var tsplCommands =
          '''
SIZE 25 mm, 10 mm
GAP 0 mm, 10 mm
CLS
TEXT 10,0,"0",0,1,1,"${productModel.name}"
TEXT 15,15,"0",0,1,1,"$price"
BARCODE 30,30,"128",30,1,0,1,1,"${productModel.barcode}"

PRINT 1,1
''';

      commandBytes = tsplCommands.codeUnits;
    } catch (e) {
      debugPrint("label error $e");
    }

    return commandBytes;
  }
}
