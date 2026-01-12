import 'dart:convert';
import 'dart:io';

import 'package:barcode_widget/barcode_widget.dart';
import 'package:desktoppossystem/controller/auth_controller.dart';
import 'package:desktoppossystem/controller/customer_controller.dart';
import 'package:desktoppossystem/controller/product_controller.dart';
import 'package:desktoppossystem/controller/receipt_controller.dart';
import 'package:desktoppossystem/controller/supplier_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/main.dart';
import 'package:desktoppossystem/models/customers_model.dart';
import 'package:desktoppossystem/models/expense_model.dart';
import 'package:desktoppossystem/models/notification_model.dart';
import 'package:desktoppossystem/models/product_model.dart';
import 'package:desktoppossystem/models/receipt_model.dart';
import 'package:desktoppossystem/models/reports/end_of_day_model.dart';
import 'package:desktoppossystem/models/reports/product_history_model.dart';
import 'package:desktoppossystem/models/reports/restaurant_stock_usage_model.dart';
import 'package:desktoppossystem/models/reports/sales_product_model.dart';
import 'package:desktoppossystem/models/reports/subscribtion_state_model.dart';
import 'package:desktoppossystem/models/reports/waste_by_stock_model.dart';
import 'package:desktoppossystem/models/restaurant_stock_model.dart';
import 'package:desktoppossystem/models/setting_model.dart';
import 'package:desktoppossystem/models/view_model/profit_report_model.dart';
import 'package:desktoppossystem/screens/add_edit_product/add_edit_product_screen.dart';
import 'package:desktoppossystem/screens/dashboard/dashboard_controller.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_screen.dart';
import 'package:desktoppossystem/screens/profit_report_screen/profit_controller.dart';
import 'package:desktoppossystem/screens/stock_screen/stock_controller.dart';
import 'package:desktoppossystem/shared/config/secure_config.dart';
import 'package:desktoppossystem/shared/constances/app_constances.dart';
import 'package:desktoppossystem/shared/constances/screens_title_constant.dart';
import 'package:desktoppossystem/shared/default%20components/are_you_sure_dialog.dart';
import 'package:desktoppossystem/shared/default%20components/default_prodgress_indicator.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_form.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/services/dependency_injection.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:desktoppossystem/shared/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:number_to_words_english/number_to_words_english.dart';
import 'package:open_file/open_file.dart' as open_file;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:rflutter_alert/rflutter_alert.dart';
import 'package:screenshot/screenshot.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' hide Column hide Row;

import '../controller/restaurant_stock_controller.dart';

String successRestoredStatusMessage = "restored successfully";
String successAddedStatusMessage = "added successfully";
String successDeletedStatusMessage = "deleted successfully";
String successUpdatedStatusMessage = "updated successfully";
String successrefundStatusMessage = "refunded successfully";

String app_Path = "";

Future<List<Uint8List>> buildLabelImage(
  ProductModel product,
  ScreenshotController screenshotController,
  int nbOfCopies,
  BuildContext context,
) async {
  List<Uint8List> images = [];
  while (nbOfCopies > 0) {
    await buildLabelContainerToImage(product).then((container) async {
      await screenshotController
          .captureFromWidget(
            InheritedTheme.captureAll(context, Material(child: container)),
          )
          .then((image) async {
            images.add(image);
          });
    });

    nbOfCopies--;
  }

  // ! containers to Print

  return images;
}
//! start Receipts in sale screen

Future buildLabelContainerToImage(ProductModel product) async {
  return Container(
    height: 151,
    width: 230,
    decoration: const BoxDecoration(color: Colors.white),
    // color: Colors.white,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        DefaultTextViewForPrinting(
          maxlines: 2,
          text: "${product.name} ",
          textAlign: TextAlign.center,
          fontWeight: FontWeight.bold,
          fontsize: 30,
        ),
        kGap5,
        if (product.barcode != null && product.barcode!.isNotEmpty)
          BarcodeWidget(
            height: 80,
            width: 200,
            style: const TextStyle(fontWeight: FontWeight.normal),
            barcode: Barcode.code128(),
            data: '${product.barcode}',
          ),
        kGap5,
        DefaultTextViewForPrinting(
          text: " ${product.sellingPrice} ${AppConstance.primaryCurrency}",
          textAlign: TextAlign.center,
          fontWeight: FontWeight.bold,
          fontsize: 30,
        ),
      ],
    ),
  );
}

bool get isEnglishLanguage =>
    (Intl.getCurrentLocale() == "en" || Intl.getCurrentLocale() == "fr");

// ! english arabic
String fetchScreenNameBasedByText(BuildContext context, String name) {
  switch (name) {
    case ScreenName.SaleScreen:
      return S.of(context).saleScreen;

    case ScreenName.DailyFinancials:
      return S.of(context).dailyFinancials;
    case ScreenName.ShiftScreen:
      return S.of(context).shiftScreen;
    case ScreenName.Dashboard:
      return S.of(context).dashboardScreen;
    case ScreenName.Expenses:
      return S.of(context).expenses;
    case ScreenName.ProfitReport:
      return S.of(context).profitReport;
    case ScreenName.UserScreen:
      return S.of(context).usersScreen;
    case ScreenName.CustomerScreen:
      return S.of(context).customers;
    case ScreenName.SubscriptionScreen:
      return S.of(context).subscriptions;
    case ScreenName.InventoryScreen:
      return S.of(context).stockScreen;
    case ScreenName.RestaurantInventoryScreen:
      return S.of(context).restaurantInventory;
    case ScreenName.SettingsScreen:
      return S.of(context).settingScreen;

    case ScreenName.Purchases:
      return S.of(context).purchases;
    case ScreenName.OnlineMenuScreen:
      return S.of(context).onlineMenuScreen;
  }
  return "";
}

class PageScaleTransition extends PageRouteBuilder {
  final dynamic page;
  PageScaleTransition({required this.page})
    : super(
        pageBuilder: (context, animation, secondaryAnimation) => page,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          // Animation for fading
          var fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          );

          // Animation for sliding from the bottom (lightweight)
          var slideAnimation =
              Tween<Offset>(
                begin: const Offset(0.0, 0.1), // Small slide from the bottom
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeInOut),
              );

          return FadeTransition(
            opacity: fadeAnimation,
            child: SlideTransition(position: slideAnimation, child: child),
          );
        },
        transitionDuration: const Duration(
          milliseconds: 400,
        ), // Shorter duration
      );
}

//! download customers

Future<void> generateCustomersExcel(List<CustomerModel> list) async {
  //Create a Excel document.

  //Creating a workbook.
  final Workbook workbook = Workbook();
  //Accessing via index
  final Worksheet sheet = workbook.worksheets[0];
  sheet.showGridlines = true;

  // Enable calculation for worksheet.
  // sheet.enableSheetCalculations();

  //Set data in the worksheet.
  sheet.getRangeByName('A1').columnWidth = 25;
  sheet.getRangeByName('B1').columnWidth = 25;
  sheet.getRangeByName('C1').columnWidth = 25;
  sheet.getRangeByName('D1').columnWidth = 25;

  sheet.getRangeByIndex(1, 1).setText('Customer Name');
  sheet.getRangeByIndex(1, 2).setText('Address');
  sheet.getRangeByIndex(1, 3).setText('Phone Number');
  sheet.getRangeByIndex(1, 4).setText('Discount');

  sheet.getRangeByName('A1:D1').cellStyle.vAlign = VAlignType.center;
  sheet.getRangeByName('A1:D1').cellStyle.hAlign = HAlignType.center;
  sheet.getRangeByName('A1:D1').cellStyle.fontSize = 15;
  sheet.getRangeByName('A1:D1').cellStyle.bold = true;

  var yIndex = 2;
  for (var element in list) {
    sheet.getRangeByIndex(yIndex, 1).setText(element.name.toString());
    sheet.getRangeByIndex(yIndex, 2).setText(element.address);
    sheet.getRangeByIndex(yIndex, 3).setText(element.phoneNumber);
    sheet
        .getRangeByIndex(yIndex, 4)
        .setText((element.discount ?? 0).toString());
    yIndex++;
  }

  //Save and launch the excel.
  final List<int> bytes = workbook.saveAsStream();
  //Dispose the document.
  //  workbook.dispose();

  //Save and launch the file.
  await saveAndLaunchFile(
    bytes,
    '${generateUniqueFileName("Customers")}.xlsx',
    "customers",
  );
}

//! dowaload stock
Future<void> generateStockExcel(List<ProductModel> list) async {
  //Create a Excel document.

  //Creating a workbook.
  final Workbook workbook = Workbook();
  //Accessing via index
  final Worksheet sheet = workbook.worksheets[0];
  sheet.showGridlines = true;

  // Enable calculation for worksheet.
  // sheet.enableSheetCalculations();

  //Set data in the worksheet.
  sheet.getRangeByName('A1').columnWidth = 5;
  sheet.getRangeByName('B1').columnWidth = 25;
  sheet.getRangeByName('C1').columnWidth = 20;
  sheet.getRangeByName('D1').columnWidth = 10;
  sheet.getRangeByName('E1').columnWidth = 15;
  sheet.getRangeByName('F1').columnWidth = 10;
  sheet.getRangeByName('G1').columnWidth = 15;
  sheet.getRangeByName('H1').columnWidth = 20;

  sheet.getRangeByIndex(1, 1).setText('Id');
  sheet.getRangeByIndex(1, 2).setText('Name');
  sheet.getRangeByIndex(1, 3).setText('Barcode');
  sheet.getRangeByIndex(1, 4).setText('Cost');
  sheet.getRangeByIndex(1, 5).setText('Selling price');
  sheet.getRangeByIndex(1, 6).setText('Qty');
  sheet.getRangeByIndex(1, 7).setText('Expiry Date');
  sheet.getRangeByIndex(1, 8).setText('Category');

  sheet.getRangeByName('A1:H1').cellStyle.vAlign = VAlignType.center;
  sheet.getRangeByName('A1:H1').cellStyle.hAlign = HAlignType.center;
  sheet.getRangeByName('A1:H1').cellStyle.fontSize = 15;
  sheet.getRangeByName('A1:H1').cellStyle.bold = true;

  var yIndex = 2;
  for (var element in list) {
    sheet.getRangeByIndex(yIndex, 1).setText(element.id.toString());
    sheet.getRangeByIndex(yIndex, 2).setText(element.name);
    sheet.getRangeByIndex(yIndex, 3).setText(element.barcode);
    sheet.getRangeByIndex(yIndex, 4).setText(element.costPrice.toString());
    sheet.getRangeByIndex(yIndex, 5).setText(element.sellingPrice.toString());
    sheet.getRangeByIndex(yIndex, 6).setText(element.qty.toString());
    sheet.getRangeByIndex(yIndex, 7).setText(element.expiryDate.toString());
    sheet.getRangeByIndex(yIndex, 8).setText(element.categoryName ?? "");
    yIndex++;
  }

  //Save and launch the excel.
  final List<int> bytes = workbook.saveAsStream();
  //Dispose the document.
  //  workbook.dispose();

  //Save and launch the file.
  await saveAndLaunchFile(
    bytes,
    '${generateUniqueFileName("Stock")}.xlsx',
    "stock",
  );
}

//!MARK: Weighted Stock
Future<void> generateWeightedStock(List<ProductModel> list) async {
  // 1. Get Windows Downloads directory
  final Workbook workbook = Workbook();
  //Accessing via index
  final Worksheet sheet = workbook.worksheets[0];
  sheet.showGridlines = true;

  sheet.getRangeByName('A1').columnWidth = 40;
  sheet.getRangeByName('B1').columnWidth = 20;
  sheet.getRangeByName('C1').columnWidth = 20;

  sheet.getRangeByIndex(1, 1).setText('Number');
  sheet.getRangeByIndex(1, 2).setText('Name');
  sheet.getRangeByIndex(1, 3).setText('Price');

  var yIndex = 2;
  for (var element in list) {
    sheet.getRangeByIndex(yIndex, 1).setText(element.plu.toString());
    sheet.getRangeByIndex(yIndex, 2).setText(element.name.toString());
    sheet.getRangeByIndex(yIndex, 3).setText(element.sellingPrice.toString());
    yIndex++;
  }
  //Save and launch the excel.
  final List<int> bytes = workbook.saveAsStream();
  //Dispose the document.
  workbook.dispose();

  //Save and launch the file.
  await saveAndLaunchFile(
    bytes,
    '${generateUniqueFileName("Weighted")}.xlsx',
    "Weighted",
  );
}

//!MARK: Notifications Excel (Low Stock / Out of Stock)
Future<void> generateNotificationsExcel(
  List<NotificationModel> list,
  String title,
) async {
  final Workbook workbook = Workbook();
  final Worksheet sheet = workbook.worksheets[0];
  sheet.showGridlines = true;

  // Set column widths
  sheet.getRangeByName('A1').columnWidth = 10;
  sheet.getRangeByName('B1').columnWidth = 40;
  sheet.getRangeByName('C1').columnWidth = 15;

  // Set headers
  sheet.getRangeByIndex(1, 1).setText('ID');
  sheet.getRangeByIndex(1, 2).setText('Name');
  sheet.getRangeByIndex(1, 3).setText('Qty');

  // Style headers
  sheet.getRangeByName('A1:C1').cellStyle.vAlign = VAlignType.center;
  sheet.getRangeByName('A1:C1').cellStyle.hAlign = HAlignType.center;
  sheet.getRangeByName('A1:C1').cellStyle.fontSize = 15;
  sheet.getRangeByName('A1:C1').cellStyle.bold = true;

  // Fill data
  var yIndex = 2;
  for (var element in list) {
    sheet.getRangeByIndex(yIndex, 1).setText(element.id.toString());
    sheet.getRangeByIndex(yIndex, 2).setText(element.title);
    sheet.getRangeByIndex(yIndex, 3).setText(element.qty.toString());
    yIndex++;
  }

  // Save and launch
  final List<int> bytes = workbook.saveAsStream();
  workbook.dispose();

  await saveAndLaunchFile(
    bytes,
    '${generateUniqueFileName(title)}.xlsx',
    title,
  );
}

//! dowaload Items with cost and selling price
Future<void> generateExcelItemsWithCost(
  List<ProductModel> list, {
  required bool isSuperAdmin,
}) async {
  //Create a Excel document.

  //Creating a workbook.
  final Workbook workbook = Workbook();
  //Accessing via index
  final Worksheet sheet = workbook.worksheets[0];
  sheet.showGridlines = true;

  // Enable calculation for worksheet.
  // sheet.enableSheetCalculations();

  //Set data in the worksheet.
  sheet.getRangeByName('A1').columnWidth = 30;
  sheet.getRangeByName('B1').columnWidth = 25;
  sheet.getRangeByName('C1').columnWidth = 20;
  sheet.getRangeByName('D1').columnWidth = 20;

  sheet.getRangeByIndex(1, 1).setText('Name');
  sheet.getRangeByIndex(1, 2).setText('Selling');
  if (isSuperAdmin) {
    sheet.getRangeByIndex(1, 3).setText('Cost');
    sheet.getRangeByIndex(1, 4).setText('Ingredients Cost');
  }

  sheet.getRangeByName('A1:D1').cellStyle.vAlign = VAlignType.center;
  sheet.getRangeByName('A1:D1').cellStyle.hAlign = HAlignType.center;
  sheet.getRangeByName('A1:D1').cellStyle.fontSize = 15;
  sheet.getRangeByName('A1:D1').cellStyle.bold = true;

  var yIndex = 2;
  for (var element in list) {
    sheet.getRangeByIndex(yIndex, 1).setText(element.name);
    sheet.getRangeByIndex(yIndex, 2).setText(element.sellingPrice.toString());
    if (isSuperAdmin) {
      sheet.getRangeByIndex(yIndex, 3).setText(element.costPrice.toString());
    }

    if (isSuperAdmin) {
      double ingredientsCost = 0;
      if (element.ingredients != null) {
        for (var i in element.ingredients!) {
          if (!i.forPackaging!) {
            ingredientsCost += (i.pricePerIngredient ?? 0);
          }
        }
      }
      ingredientsCost = ingredientsCost.formatDouble();

      sheet.getRangeByIndex(yIndex, 4).setText(ingredientsCost.toString());
      if (element.costPrice != ingredientsCost) {
        sheet.getRangeByIndex(yIndex, 4).cellStyle.backColor = "#ff0000";
        sheet.getRangeByIndex(yIndex, 4).cellStyle.fontColor = "#ffffff";
      }
    }

    yIndex++;
  }

  //Save and launch the excel.
  final List<int> bytes = workbook.saveAsStream();
  //Dispose the document.
  //  workbook.dispose();
  workbook.dispose();

  //Save and launch the file.
  await saveAndLaunchFile(
    bytes,
    '${generateUniqueFileName("Items")}.xlsx',
    "stock",
  );
}

//! dowaload Items with cost and selling price
Future<void> generateExcelItemsWithIngredients(
  List<ProductModel> list, {
  required bool isSuperAdmin,
}) async {
  // Create a new Excel document.
  final Workbook workbook = Workbook();
  final Worksheet sheet = workbook.worksheets[0];
  sheet.showGridlines = true;

  // Set initial column widths
  sheet.getRangeByName('A1').columnWidth = 40;
  sheet.getRangeByName('B1').columnWidth = 40;
  sheet.getRangeByName('C1').columnWidth = 40;

  // Variables for tracking column and row indexes.
  int colIndex = 1;
  int rowIndex = 1;
  int maxIngredientsInRow =
      0; // Track the maximum ingredients in a row set of three columns

  for (var product in list) {
    // Set the product name in the header row.
    sheet.getRangeByIndex(rowIndex, colIndex).setText(product.name);

    // Apply header style
    final cell = sheet.getRangeByIndex(rowIndex, colIndex);
    cell.cellStyle.bold = true;
    cell.cellStyle.fontSize = 15;
    cell.cellStyle.hAlign = HAlignType.center;
    cell.cellStyle.backColor = "#0000ff";
    cell.cellStyle.fontColor = "#ffffff";

    // Add ingredients below the dish name.
    int ingredientRow = rowIndex + 1;
    int ingredientCount = 0; // Count the ingredients for each product

    if (product.ingredients != null) {
      for (var ingredient in product.ingredients!) {
        sheet
            .getRangeByIndex(ingredientRow, colIndex)
            .setText(
              "${ingredient.nameWithQty} ${isSuperAdmin ? '/ ${ingredient.pricePerIngredient} ${AppConstance.primaryCurrency.currencyLocalization()}' : ""}",
            );
        ingredientRow++;
        ingredientCount++;
      }
    }

    // Update the maximum ingredients count in the current row set
    maxIngredientsInRow = ingredientCount > maxIngredientsInRow
        ? ingredientCount
        : maxIngredientsInRow;

    // Move to the next column.
    colIndex++;

    // If we filled 3 columns, reset to the first column and update the rowIndex based on maxIngredientsInRow
    if (colIndex > 3) {
      colIndex = 1;
      rowIndex +=
          maxIngredientsInRow +
          1; // Move to the row after the last ingredient row
      maxIngredientsInRow = 0; // Reset for the next set of three columns
    }
  }

  // Save and launch the Excel file.
  final List<int> bytes = workbook.saveAsStream();
  workbook.dispose();

  await saveAndLaunchFile(
    bytes,
    '${generateUniqueFileName("ItemsWithIngredients")}.xlsx',
    "stock",
  );
}

//! dowaload stock
Future<void> generateRestaurantStockExcel(
  List<RestaurantStockModel> list,
  Ref ref,
) async {
  //Create a Excel document.

  //Creating a workbook.
  final Workbook workbook = Workbook();
  //Accessing via index
  final Worksheet sheet = workbook.worksheets[0];
  sheet.showGridlines = true;

  // Enable calculation for worksheet.
  // sheet.enableSheetCalculations();

  //Set data in the worksheet.
  sheet.getRangeByName('A1').columnWidth = 40;
  sheet.getRangeByName('B1').columnWidth = 15;
  sheet.getRangeByName('C1').columnWidth = 15;
  sheet.getRangeByName('D1').columnWidth = 30;
  sheet.getRangeByName('E1').columnWidth = 30;

  sheet.getRangeByIndex(1, 1).setText('Name');
  sheet.getRangeByIndex(1, 2).setText('Unit Type');
  sheet.getRangeByIndex(1, 3).setText('Qty');
  if (ref.read(mainControllerProvider).isSuperAdmin) {
    sheet.getRangeByIndex(1, 4).setText('Cost per unit');
  }
  if (ref.read(mainControllerProvider).isSuperAdmin) {
    sheet.getRangeByIndex(1, 5).setText('Total Cost');
  }

  applyRowStyle(
    sheet,
    rowIndex: 1,
    endColumnIndex: ref.read(mainControllerProvider).isSuperAdmin ? 5 : 3,
  );

  var yIndex = 2;
  double totalCost = 0;
  for (var element in list) {
    sheet.getRangeByIndex(yIndex, 1).setText(element.name.toString());
    sheet.getRangeByIndex(yIndex, 2).setText(element.unitType.name);
    sheet
        .getRangeByIndex(yIndex, 3)
        .setText(
          '${element.qty.formatDouble()} ${element.unitType == UnitType.portion ? "po" : "kg"}',
        );
    if (element.qty <= element.warningAlert!) {
      sheet.getRangeByIndex(yIndex, 3).cellStyle.backColor = "#ff0000";
      sheet.getRangeByIndex(yIndex, 3).cellStyle.fontColor = "#ffffff";
    }
    if (ref.read(mainControllerProvider).isSuperAdmin) {
      sheet
          .getRangeByIndex(yIndex, 4)
          .setText("${element.pricePerUnit.formatDouble()}");
    }
    if (ref.read(mainControllerProvider).isSuperAdmin) {
      sheet
          .getRangeByIndex(yIndex, 5)
          .setText(
            "${(element.qty * element.pricePerUnit).formatDouble()}  ${AppConstance.primaryCurrency}",
          );
    }
    totalCost += element.qty * element.pricePerUnit;

    yIndex++;
  }
  if (ref.read(mainControllerProvider).isSuperAdmin) {
    sheet
        .getRangeByIndex(yIndex, 5)
        .setText(
          "${totalCost.formatDouble()}  ${AppConstance.primaryCurrency}",
        );
    sheet.getRangeByIndex(yIndex, 5).cellStyle.backColor = "#ff0000";
    sheet.getRangeByIndex(yIndex, 5).cellStyle.fontColor = "#ffffff";
    sheet.getRangeByIndex(yIndex, 5).cellStyle.vAlign = VAlignType.center;
    sheet.getRangeByIndex(yIndex, 5).cellStyle.hAlign = HAlignType.center;
  }

  //Save and launch the excel.
  final List<int> bytes = workbook.saveAsStream();
  //Dispose the document.
  //  workbook.dispose();

  //Save and launch the file.
  await saveAndLaunchFile(
    bytes,
    '${generateUniqueFileName("Restaruant_stock")}.xlsx',
    "stock",
  );
}

Future<void> generateProductHistoryReport(
  List<ProductHistoryModel> histories,
  Ref ref,
) async {
  if (histories.isEmpty) return;

  final Workbook workbook = Workbook();
  final Worksheet sheet = workbook.worksheets[0];
  sheet.showGridlines = true;

  // Set column widths
  sheet.getRangeByName('A1').columnWidth = 30; // Product Name
  sheet.getRangeByName('B1').columnWidth = 20; // Barcode
  sheet.getRangeByName('C1').columnWidth = 15; // Supplier
  sheet.getRangeByName('D1').columnWidth = 15; // Date
  sheet.getRangeByName('E1').columnWidth = 12; // Old Qty
  sheet.getRangeByName('F1').columnWidth = 12; // New Qty
  sheet.getRangeByName('G1').columnWidth = 15; // Total Qty
  sheet.getRangeByName('H1').columnWidth = 20; // Old Cost

  final firstProduct = histories.first;
  sheet
      .getRangeByIndex(1, 1)
      .setText(
        'Product: ${firstProduct.productName} / barcode :${firstProduct.productBarcode}',
      );
  sheet.getRangeByIndex(1, 1, 1, 8).merge(); // Only up to H (column 8)
  applyRowStyle(
    sheet,
    rowIndex: 1,
    endColumnIndex: 8,
    backColor: "#ff0000",
    fontSize: 16,
  );

  // Headers (Row 2)
  sheet.getRangeByIndex(2, 1).setText('Supplier Name');
  sheet.getRangeByIndex(2, 2).setText('Purchase Date');
  sheet.getRangeByIndex(2, 3).setText('Old Qty');
  sheet.getRangeByIndex(2, 4).setText('New Qty');
  sheet.getRangeByIndex(2, 5).setText('Total Qty');
  sheet.getRangeByIndex(2, 6).setText('Old Cost');
  sheet.getRangeByIndex(2, 7).setText('Cost Price');
  sheet.getRangeByIndex(2, 8).setText('Average Cost');
  applyRowStyle(sheet, rowIndex: 2, endColumnIndex: 8);

  // Data Rows
  int rowIndex = 3;
  for (final history in histories) {
    sheet.getRangeByIndex(rowIndex, 1).setText(history.supplierName);

    final date = DateTime.tryParse(history.puchaseDate);
    final formattedDate = date != null
        ? date.toNormalDate().toString()
        : history.puchaseDate;
    sheet.getRangeByIndex(rowIndex, 2).setText(formattedDate);

    sheet.getRangeByIndex(rowIndex, 3).setNumber(history.oldQty);
    sheet.getRangeByIndex(rowIndex, 4).setNumber(history.newQty);
    sheet.getRangeByIndex(rowIndex, 5).setNumber(history.totalQty);
    sheet.getRangeByIndex(rowIndex, 6).setNumber(history.oldCost);
    sheet.getRangeByIndex(rowIndex, 7).setNumber(history.cost.formatDouble());
    sheet
        .getRangeByIndex(rowIndex, 8)
        .setNumber(history.averageCost.formatDouble());

    if (rowIndex % 2 == 1) {
      sheet.getRangeByIndex(rowIndex, 1, rowIndex, 8).cellStyle.backColor =
          '#f2f2f2';
    }

    rowIndex++;
  }

  // Format Cost columns (Cost Price and Average Cost)
  final costRange = sheet.getRangeByName('G3:H${rowIndex - 1}');
  costRange.numberFormat = '#,##0.00';

  // Summary Row (only for cost columns)
  if (histories.length > 1) {
    sheet.getRangeByIndex(rowIndex, 1).setText('Summary');
    sheet.getRangeByIndex(rowIndex, 1).cellStyle.bold = true;

    sheet.getRangeByIndex(rowIndex, 7).formula =
        '=AVERAGE(G3:G${rowIndex - 1})';
    sheet.getRangeByIndex(rowIndex, 8).formula =
        '=AVERAGE(H3:H${rowIndex - 1})';

    sheet.getRangeByIndex(rowIndex, 7).numberFormat = '#,##0.000';
    sheet.getRangeByIndex(rowIndex, 8).numberFormat = '#,##0.000';
    sheet.getRangeByIndex(rowIndex, 1, rowIndex, 8).cellStyle
      ..backColor = '#d9d9d9'
      ..bold = true;
  }

  final List<int> bytes = workbook.saveAsStream();

  await saveAndLaunchFile(
    bytes,
    '${generateUniqueFileName("p_history")}.xlsx',
    "product_history",
  );

  workbook.dispose();
}

// MARK: daily report excel
Future<void> generateDailyReport(
  List<ProductModel> list,
  EndOfDayModel endOfDayModel,
) async {
  //Create a Excel document.

  //Creating a workbook.
  final Workbook workbook = Workbook();
  //Accessing via index
  final Worksheet sheet = workbook.worksheets[0];
  sheet.showGridlines = true;

  // Enable calculation for worksheet.
  //sheet.enableSheetCalculations();

  //Set data in the worksheet.
  sheet.getRangeByName('A1').columnWidth = 45;
  sheet.getRangeByName('B1').columnWidth = 15;
  sheet.getRangeByName('C1').columnWidth = 15;

  sheet.getRangeByName('A1:C1').merge();
  sheet.getRangeByName('A1:C1').cellStyle.hAlign = HAlignType.center;
  sheet.getRangeByName('A1:C1').cellStyle.vAlign = VAlignType.center;
  sheet.getRangeByName('A1:C1').cellStyle.bold = true;
  sheet.getRangeByName('A1:C1').cellStyle.fontSize = 15;
  if (endOfDayModel.endOfShiftEmployeeModel == null) {
    sheet
        .getRangeByName('A1:C1')
        .setText('Daily Report - Date : ${endOfDayModel.date} ');
  } else {
    sheet
        .getRangeByName('A1:C1')
        .setText(
          'Shift Report Nb (${endOfDayModel.endOfShiftEmployeeModel!.shiftId}) - Employee : ${endOfDayModel.endOfShiftEmployeeModel!.employeeName} ',
        );
  }

  // Product Header
  sheet.getRangeByName('A2').setText("Product");
  sheet.getRangeByName('B2').setText("Qty");
  applyRowStyle(
    sheet,
    rowIndex: 2,
    endColumnIndex: 2,
    backColor: "#3498DB",
    textColor: "#ffffff",
  );

  // ==================== FINANCIAL SUMMARY HEADER ====================
  sheet.getRangeByName('D2:E2').merge();
  sheet.getRangeByName('D2').setText('FINANCIAL SUMMARY');
  sheet.getRangeByName('D2').columnWidth = 30;
  sheet.getRangeByName('E2').columnWidth = 18;
  applyRowStyle(
    sheet,
    rowIndex: 2,
    startColumnIndex: 4,
    endColumnIndex: 5,
    backColor: "#2C3E50",
    textColor: "#ffffff",
    fontSize: 14,
  );

  int financialRow = 4;

  // ==================== SALES SECTION ====================
  sheet.getRangeByName('D$financialRow').setText('SALES');
  applyRowStyle(
    sheet,
    rowIndex: financialRow,
    startColumnIndex: 4,
    endColumnIndex: 5,
    backColor: "#27AE60",
    textColor: "#ffffff",
  );
  financialRow++;

  sheet
      .getRangeByName('D$financialRow')
      .setText(
        'Sales (${AppConstance.primaryCurrency.currencyLocalization()}):',
      );
  sheet
      .getRangeByName('E$financialRow')
      .setText("${endOfDayModel.salesPrimary.formatDouble()}");
  financialRow++;

  sheet
      .getRangeByName('D$financialRow')
      .setText(
        'Sales (${AppConstance.secondaryCurrency.currencyLocalization()}):',
      );
  sheet
      .getRangeByName('E$financialRow')
      .setText(endOfDayModel.salesSecondary.formatAmountNumber());
  financialRow++;

  sheet.getRangeByName('D$financialRow').setText('Nb Of Customers:');
  sheet
      .getRangeByName('E$financialRow')
      .setText(endOfDayModel.nbCustomers.toString());
  financialRow += 2;

  // ==================== DEPOSIT SECTION ====================
  sheet.getRangeByName('D$financialRow').setText('DEPOSITS');
  applyRowStyle(
    sheet,
    rowIndex: financialRow,
    startColumnIndex: 4,
    endColumnIndex: 5,
    backColor: "#27AE60",
    textColor: "#ffffff",
  );
  financialRow++;

  sheet
      .getRangeByName('D$financialRow')
      .setText(
        'Deposits (${AppConstance.primaryCurrency.currencyLocalization()}):',
      );
  sheet
      .getRangeByName('E$financialRow')
      .setText("${endOfDayModel.depositDolar.formatDouble()}");
  financialRow++;

  sheet
      .getRangeByName('D$financialRow')
      .setText(
        'Deposits (${AppConstance.secondaryCurrency.currencyLocalization()}):',
      );
  sheet
      .getRangeByName('E$financialRow')
      .setText(endOfDayModel.depositLebanese.formatAmountNumber());
  financialRow += 2;

  // ==================== COLLECTED FROM PENDING SECTION ====================
  sheet.getRangeByName('D$financialRow').setText('COLLECTED FROM PENDING');
  applyRowStyle(
    sheet,
    rowIndex: financialRow,
    startColumnIndex: 4,
    endColumnIndex: 5,
    backColor: "#27AE60",
    textColor: "#ffffff",
  );
  financialRow++;

  sheet.getRangeByName('D$financialRow').setText('Collected from Pending:');
  sheet
      .getRangeByName('E$financialRow')
      .setText(endOfDayModel.totalCollectedPending.formatAmountNumber());
  financialRow += 2;

  // ==================== SUBSCRIPTIONS SECTION ====================
  if (endOfDayModel.totalSubscriptions != null) {
    sheet.getRangeByName('D$financialRow').setText('SUBSCRIPTIONS');
    applyRowStyle(
      sheet,
      rowIndex: financialRow,
      startColumnIndex: 4,
      endColumnIndex: 5,
      backColor: "#27AE60",
      textColor: "#ffffff",
    );
    financialRow++;

    sheet.getRangeByName('D$financialRow').setText('Subscription Payments:');
    sheet
        .getRangeByName('E$financialRow')
        .setText(endOfDayModel.totalSubscriptions!.formatAmountNumber());
    financialRow += 2;
  }

  // ==================== WITHDRAWALS FROM CASH SECTION ====================
  sheet.getRangeByName('D$financialRow').setText('WITHDRAWALS FROM CASH');
  applyRowStyle(
    sheet,
    rowIndex: financialRow,
    startColumnIndex: 4,
    endColumnIndex: 5,
    backColor: "#E74C3C",
    textColor: "#ffffff",
  );
  financialRow++;

  sheet
      .getRangeByName('D$financialRow')
      .setText(
        'Cash Withdrawals (${AppConstance.primaryCurrency.currencyLocalization()}):',
      );
  sheet
      .getRangeByName('E$financialRow')
      .setText(endOfDayModel.withdrawDolarFromCash.formatAmountNumber());
  financialRow++;

  sheet
      .getRangeByName('D$financialRow')
      .setText(
        'Cash Withdrawals (${AppConstance.secondaryCurrency.currencyLocalization()}):',
      );
  sheet
      .getRangeByName('E$financialRow')
      .setText(endOfDayModel.withdrawLebaneseFromCash.formatAmountNumber());
  financialRow += 2;

  // ==================== PURCHASES SECTION ====================
  sheet.getRangeByName('D$financialRow').setText('PURCHASES');
  applyRowStyle(
    sheet,
    rowIndex: financialRow,
    startColumnIndex: 4,
    endColumnIndex: 5,
    backColor: "#E74C3C",
    textColor: "#ffffff",
  );
  financialRow++;

  sheet
      .getRangeByName('D$financialRow')
      .setText(
        'Purchases (${AppConstance.primaryCurrency.currencyLocalization()}):',
      );
  sheet
      .getRangeByName('E$financialRow')
      .setText(endOfDayModel.totalPurchasesPrimary.formatAmountNumber());
  financialRow += 2;

  // ==================== REFUNDS SECTION ====================
  sheet.getRangeByName('D$financialRow').setText('REFUNDS');
  applyRowStyle(
    sheet,
    rowIndex: financialRow,
    startColumnIndex: 4,
    endColumnIndex: 5,
    backColor: "#E74C3C",
    textColor: "#ffffff",
  );
  financialRow++;

  sheet.getRangeByName('D$financialRow').setText('Total Refunds:');
  sheet
      .getRangeByName('E$financialRow')
      .setText(endOfDayModel.totalRefunds.formatAmountNumber());

  // ==================== TOTAL SECTION (Column G) ====================
  int totalRow = 4;

  sheet.getRangeByName('G$totalRow:H$totalRow').merge();
  sheet.getRangeByName('G$totalRow').setText('TOTAL BALANCE');
  sheet.getRangeByName('G$totalRow').columnWidth = 30;
  sheet.getRangeByName('H$totalRow').columnWidth = 20;
  applyRowStyle(
    sheet,
    rowIndex: totalRow,
    startColumnIndex: 7,
    endColumnIndex: 8,
    backColor: "#3498DB",
    textColor: "#ffffff",
    fontSize: 16,
  );
  totalRow++;

  sheet
      .getRangeByName('G$totalRow')
      .setText(
        'Total (${AppConstance.primaryCurrency.currencyLocalization()}):',
      );
  sheet
      .getRangeByName('H$totalRow')
      .setText(endOfDayModel.totalPrimary.formatAmountNumber());
  sheet.getRangeByName('H$totalRow').cellStyle.bold = true;
  sheet.getRangeByName('H$totalRow').cellStyle.fontSize = 14;
  sheet.getRangeByName('H$totalRow').cellStyle.backColor = "#D6EAF8";

  var yIndex = 3;
  for (var element in list) {
    sheet.getRangeByIndex(yIndex, 1).setText(element.name.toString());
    sheet.getRangeByIndex(yIndex, 2).setText(element.qty.toString());
    yIndex++;
  }

  // loop and write stock usage
  int stockUsageIndex = yIndex + 2;

  if (endOfDayModel.stockUsage != null &&
      endOfDayModel.stockUsage!.isNotEmpty) {
    sheet.getRangeByName('A$stockUsageIndex').setText("Sales Stock Item");
    sheet.getRangeByName('B$stockUsageIndex').setText("qty");
    applyRowStyle(sheet, rowIndex: stockUsageIndex, endColumnIndex: 2);

    stockUsageIndex = stockUsageIndex + 1;
    double totalCost = 0;
    for (var element in endOfDayModel.stockUsage!) {
      totalCost += element.totalPrice!;
      sheet
          .getRangeByIndex(stockUsageIndex, 1)
          .setText(element.name.toString());
      sheet
          .getRangeByIndex(stockUsageIndex, 2)
          .setText(
            element.unitType == UnitType.portion
                ? "${element.qtyAsPortion.formatDouble()} po"
                : "${element.qtyAsKilo.formatDouble()} kg",
          );
      if (element.forPackaging == true) {
        sheet.getRangeByIndex(stockUsageIndex, 3).setText("packaging");
      }
      stockUsageIndex++;
    }

    // set total cost

    sheet.getRangeByName('A$stockUsageIndex').setText("Total Cost");

    sheet
        .getRangeByName('B$stockUsageIndex')
        .setText("${totalCost.formatDouble()} ${AppConstance.primaryCurrency}");
    applyRowStyle(
      sheet,
      rowIndex: stockUsageIndex,
      endColumnIndex: 2,
      backColor: "#ff0000",
      textColor: "#ffffff",
    );
  }

  stockUsageIndex = stockUsageIndex + 2;

  if (endOfDayModel.stockItems != null &&
      endOfDayModel.stockItems!.isNotEmpty) {
    sheet.getRangeByName('A$stockUsageIndex:B$stockUsageIndex').merge();
    sheet
            .getRangeByName('A$stockUsageIndex:B$stockUsageIndex')
            .cellStyle
            .hAlign =
        HAlignType.center;
    sheet
            .getRangeByName('A$stockUsageIndex:B$stockUsageIndex')
            .cellStyle
            .vAlign =
        VAlignType.center;
    sheet.getRangeByName('A$stockUsageIndex:B$stockUsageIndex').cellStyle.bold =
        true;
    sheet
        .getRangeByName('A$stockUsageIndex:B$stockUsageIndex')
        .setText("Restaurant Stock");
    applyRowStyle(sheet, rowIndex: stockUsageIndex, endColumnIndex: 2);
    stockUsageIndex = stockUsageIndex + 1;
    for (var element in endOfDayModel.stockItems!) {
      sheet
          .getRangeByIndex(stockUsageIndex, 1)
          .setText(element.name.toString());
      sheet
          .getRangeByIndex(stockUsageIndex, 2)
          .setText(
            element.qty.toString() +
                (element.unitType == UnitType.portion ? " po" : " kg"),
          );
      if (element.qty <= element.warningAlert!) {
        sheet.getRangeByIndex(stockUsageIndex, 2).cellStyle.backColor =
            "#ff0000";
        sheet.getRangeByIndex(stockUsageIndex, 2).cellStyle.fontColor =
            "#ffffff";
      }
      stockUsageIndex++;
    }
  }

  // ==================== EXPENSES SECTION (Right Column) ====================
  financialRow += 2;

  sheet.getRangeByName('D$financialRow').setText('EXPENSES');
  applyRowStyle(
    sheet,
    rowIndex: financialRow,
    startColumnIndex: 4,
    endColumnIndex: 5,
    backColor: "#E67E22",
    textColor: "#ffffff",
  );
  financialRow++;

  sheet
      .getRangeByName('D$financialRow')
      .setText(
        'Total Expenses (${AppConstance.primaryCurrency.currencyLocalization()}):',
      );
  sheet
      .getRangeByName('E$financialRow')
      .setText(endOfDayModel.withdrawDolar.formatAmountNumber());
  financialRow++;

  sheet
      .getRangeByName('D$financialRow')
      .setText(
        'Total Expenses (${AppConstance.secondaryCurrency.currencyLocalization()}):',
      );
  sheet
      .getRangeByName('E$financialRow')
      .setText(endOfDayModel.withdrawLebanese.formatAmountNumber());
  financialRow++;

  // Expenses Details - list individual expenses
  if (endOfDayModel.expenses!.isNotEmpty) {
    sheet.getRangeByName('D$financialRow').setText('  Details:');
    sheet.getRangeByName('D$financialRow').cellStyle.italic = true;
    financialRow++;

    for (var element in endOfDayModel.expenses!) {
      String currency = element.isTransactionInPrimary == true
          ? AppConstance.primaryCurrency.currencyLocalization()
          : AppConstance.secondaryCurrency.currencyLocalization();
      String cashIndicator = element.withDrawFromCash == true
          ? " (from cash)"
          : "";

      sheet
          .getRangeByName('D$financialRow')
          .setText('    • ${element.expensePurpose}$cashIndicator');
      sheet
          .getRangeByName('E$financialRow')
          .setText('${element.expenseAmount} $currency');
      financialRow++;
    }
  }

  // ==================== PENDING RECEIPTS SECTION (Right Column) ====================
  financialRow += 2;

  sheet.getRangeByName('D$financialRow').setText('PENDING RECEIPTS');
  applyRowStyle(
    sheet,
    rowIndex: financialRow,
    startColumnIndex: 4,
    endColumnIndex: 5,
    backColor: "#F39C12",
    textColor: "#000000",
  );
  financialRow++;

  sheet.getRangeByName('D$financialRow').setText('Total Pending Amount:');
  sheet
      .getRangeByName('E$financialRow')
      .setText(endOfDayModel.totalPendingAmount.formatAmountNumber());
  financialRow++;

  sheet.getRangeByName('D$financialRow').setText('Number of Pending Receipts:');
  sheet
      .getRangeByName('E$financialRow')
      .setText(endOfDayModel.totalPendingReceipts.toString());

  //Save and launch the excel.
  final List<int> bytes = workbook.saveAsStream();
  //Dispose the document.
  // workbook.dispose();

  //Save and launch the file.

  await saveAndLaunchFile(
    bytes,
    '${generateUniqueFileName("Report")}.xlsx',
    "reports",
  );
  workbook.dispose();
}

String generateUniqueFileName(String name) {
  DateTime currentDate = DateTime.now();
  String uniqueTime =
      "${currentDate.year}-${currentDate.month}-${currentDate.day}_${currentDate.hour}-${currentDate.minute}-${currentDate.second}";
  return "${name}_$uniqueTime";
}

// Future<void> deleteAllgeneratedExcelAndPdfFiles() async {
//   // Get the directory
//   final Directory directory =
//       await path_provider.getApplicationSupportDirectory();

//   List<Directory> directories = [];

//   directories.add(Directory(path.join(directory.path, "customers")));
//   directories.add(Directory(path.join(directory.path, "Invoices")));
//   directories.add(Directory(path.join(directory.path, "reports")));
//   directories.add(Directory(path.join(directory.path, "stock")));
//   directories.add(Directory(path.join(directory.path, "template")));
//   directories.add(Directory(path.join(directory.path, "ProfitReports")));

//   for (var folder in directories) {
//     // Check if the directory exists
//     if (await folder.exists()) {
//       // List all files and directories in the folder
//       await for (final FileSystemEntity entity in folder.list()) {
//         // Check if the entity is a file
//         if (entity is File) {
//           // Delete the file
//           entity.delete().catchError((error) {
//             // Handle the error here if needed
//             // Print the error or log it
//             return entity; // Return null to satisfy the Future<void> type requirement
//           });
//         }
//       }
//     }
//   }
// }

void applyRowStyle(
  Worksheet sheet, {
  required int rowIndex,
  required int endColumnIndex,
  int startColumnIndex = 1,
  String? backColor,
  String? textColor,
  double? fontSize,
}) {
  // Loop through each column in the specified row and apply the style
  for (
    int colIndex = startColumnIndex;
    colIndex <= endColumnIndex;
    colIndex++
  ) {
    final cellRange = sheet.getRangeByIndex(rowIndex, colIndex);
    final cellStyle = cellRange.cellStyle;
    cellStyle.hAlign = HAlignType.center;
    cellStyle.vAlign = VAlignType.center;
    cellStyle.bold = true;
    cellStyle.backColor = backColor ?? "#0000ff";
    cellStyle.fontColor = textColor ?? "#ffffff";
    cellStyle.fontSize = fontSize ?? 14;

    // Apply the cloned style to the current cell
    cellRange.cellStyle = cellStyle;
  }
}

Future<void> saveAndLaunchFile(
  List<int> bytes,
  String fileName,
  String folderName, {
  bool? dontOpenFile,
}) async {
  String folderPath;

  // Handle Windows Downloads folder separately
  if (Platform.isWindows) {
    final Directory? downloadsDir = await getDownloadsDirectory();
    if (downloadsDir == null) {
      throw Exception('Could not find Downloads directory');
    }
    folderPath = p.join(downloadsDir.path, folderName);
  } else {
    // Original behavior for other platforms
    final Directory directory = await getApplicationSupportDirectory();
    folderPath = p.join(directory.path, folderName);
  }

  // Create folder if it doesn't exist
  final Directory folder = Directory(folderPath);
  if (!await folder.exists()) {
    await folder.create(recursive: true);
  }

  // Write file
  final String filePath = Platform.isWindows
      ? '$folderPath\\$fileName'
      : '$folderPath/$fileName';

  final File file = File(filePath);
  await file.writeAsBytes(bytes, flush: true);
  if (dontOpenFile == true) return;
  // Launch file based on platform
  if (Platform.isAndroid || Platform.isIOS) {
    await open_file.OpenFile.open(filePath);
  } else if (Platform.isWindows) {
    await Process.run('start', [filePath], runInShell: true);
  } else if (Platform.isMacOS) {
    await Process.run('open', [filePath], runInShell: true);
  } else if (Platform.isLinux) {
    await Process.run('xdg-open', [filePath], runInShell: true);
  }
}

Future generateProfitReportAsPdf(ProfitReportModel model) async {
  final fontData = await rootBundle.load('assets/fonts/arial.ttf');
  final ttf = pw.Font.ttf(fontData);
  final pdf = pw.Document();

  // Calculate percentages for each of these values
  double totalAmount = model.totalCost + model.totalPaid + model.profit;
  double costPercentage = totalAmount > 0
      ? (model.totalCost / totalAmount) * 100
      : 0.0;
  double sellingPercentage = totalAmount > 0
      ? (model.totalPaid / totalAmount) * 100
      : 0.0;
  double profitPercentage = totalAmount > 0
      ? (model.profit / totalAmount) * 100
      : 0.0;

  // ! sales products
  List<List<SalesProductModel>> salesPages = [];
  if (model.products.isNotEmpty) {
    int firstPageCount = model.products.length >= 23
        ? 23
        : model.products.length;
    salesPages.add(model.products.sublist(0, firstPageCount));
    for (int i = firstPageCount; i < model.products.length; i += 25) {
      salesPages.add(
        model.products.sublist(
          i,
          i + 25 > model.products.length ? model.products.length : i + 25,
        ),
      );
    }
  }
  for (var pageIndex = 0; pageIndex < salesPages.length; pageIndex++) {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20), // Page margin
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (pageIndex == 0) ...[
                pw.Directionality(
                  textDirection: isEnglishLanguage
                      ? pw.TextDirection.ltr
                      : pw.TextDirection.rtl,
                  child: pw.Text(
                    model.header,
                    style: pw.TextStyle(
                      fontSize: 22,
                      color: PdfColors.red,
                      font: ttf,
                    ),
                  ),
                ),
                pw.Divider(thickness: 2, color: PdfColors.black),
                pw.SizedBox(height: 10),
                pw.Text(
                  "Sales Product Financial Summary: Cost, Selling, and Profit",
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue,
                  ),
                  textAlign: pw.TextAlign.left,
                ),
                pw.SizedBox(height: 4),
                pw.Divider(thickness: 1, color: PdfColors.grey),
                pw.Text(
                  "Total Cost :  ${model.totalCost.formatDouble()} ${AppConstance.primaryCurrency.currencyLocalization()}",
                  style: const pw.TextStyle(fontSize: 14),
                ),
                pw.Text(
                  "Total Selling :  ${model.totalPaid.formatDouble()} ${AppConstance.primaryCurrency.currencyLocalization()}",
                  style: const pw.TextStyle(fontSize: 14),
                ),
                pw.Text(
                  "Profit :  ${model.profit.formatDouble()} ${AppConstance.primaryCurrency.currencyLocalization()}",
                  style: const pw.TextStyle(fontSize: 14),
                ),
              ],

              pw.SizedBox(height: 10), // Add space before the table starts
              pw.TableHelper.fromTextArray(
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey100,
                ),

                columnWidths: {
                  0: const pw.FlexColumnWidth(
                    2,
                  ), // Expand "Product Name" column
                  1: const pw.FixedColumnWidth(40), // qty column
                  2: const pw.FixedColumnWidth(60), // Cost Price column
                  3: const pw.FixedColumnWidth(60), // Selling Price column
                  4: const pw.FixedColumnWidth(80), // Profit column
                },
                tableDirection: pw
                    .TextDirection
                    .rtl, // Adjust the table direction as needed
                data: [
                  // Table header
                  ['Product Name', 'Qty', 'Cost', 'Selling', 'Profit'],
                  // Product rows
                  ...salesPages[pageIndex].map((product) {
                    final percentagePerItem = product.totalCost != 0
                        ? ((product.profit / product.totalCost) * 100).round()
                        : 0.0;
                    return [
                      "${product.name}",
                      '${product.qty.formatDouble()}',
                      '${product.totalCost.formatDouble()}',
                      '${product.paidCost.formatDouble()}',
                      '${product.profit.formatDouble()}($percentagePerItem%)',
                    ];
                  }).toList(),
                ],
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 12,
                ),
                cellStyle: pw.TextStyle(fontSize: 12, font: ttf),
                cellAlignments: {
                  0: pw.Alignment.center,
                  1: pw.Alignment.center,
                  2: pw.Alignment.center,
                  3: pw.Alignment.center,
                  4: pw.Alignment.center,
                },
              ),
            ],
          );
        },
      ),
    );
  }

  //! stock Usage
  List<List<RestaurantStockUsageModel>> stockPages = [];
  if (model.stockUsageList != null && model.stockUsageList!.isNotEmpty) {
    int firstPageCount = model.stockUsageList!.length >= 23
        ? 23
        : model.stockUsageList!.length;
    stockPages.add(model.stockUsageList!.sublist(0, firstPageCount));
    for (int i = firstPageCount; i < model.stockUsageList!.length; i += 25) {
      stockPages.add(
        model.stockUsageList!.sublist(
          i,
          i + 25 > model.stockUsageList!.length
              ? model.stockUsageList!.length
              : i + 25,
        ),
      );
    }
  }

  for (var pageIndex = 0; pageIndex < stockPages.length; pageIndex++) {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (pageIndex == 0) ...[
                pw.Text(
                  "Stock Usage Summary: Total Used and Costs",
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue,
                  ),
                  textAlign: pw.TextAlign.left,
                ),
                pw.SizedBox(height: 4),
                pw.Divider(thickness: 1, color: PdfColors.grey),
                pw.Text(
                  "Total Cost :  ${model.restaurantCost.formatDouble()} ${AppConstance.primaryCurrency.currencyLocalization()}",
                  style: const pw.TextStyle(fontSize: 14),
                ),
              ],
              pw.SizedBox(height: 10),
              pw.TableHelper.fromTextArray(
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey100,
                ),
                columnWidths: {
                  0: const pw.FlexColumnWidth(2), // Expand "Stock Item" column
                  1: const pw.FixedColumnWidth(70), // Quantity in kg
                  2: const pw.FixedColumnWidth(90), // Quantity in portion
                  3: const pw.FixedColumnWidth(70), // Total Cost
                },
                tableDirection: pw.TextDirection.rtl,
                data: [
                  // Table header
                  ['Stock Item', 'Qty (kg)', 'Qty (Portion)', 'Total Cost'],
                  // Stock usage rows
                  ...stockPages[pageIndex].map((stockItem) {
                    return [
                      (stockItem.name),
                      '${stockItem.qtyAsKilo.formatDouble()}',
                      '${stockItem.qtyAsPortion.formatDouble()}',
                      '${stockItem.totalPrice.formatDouble()}',
                    ];
                  }).toList(),
                ],
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 12,
                ),
                cellStyle: pw.TextStyle(fontSize: 12, font: ttf),
                cellAlignments: {
                  0: pw.Alignment.center,
                  1: pw.Alignment.center,
                  2: pw.Alignment.center,
                  3: pw.Alignment.center,
                },
              ),
            ],
          );
        },
      ),
    );
  }
  //! waste list

  List<List<WasteByStockModel>> wastePages = [];

  if (model.wasteList != null && model.wasteList!.isNotEmpty) {
    int firstPageCount = model.wasteList!.length >= 23
        ? 23
        : model.wasteList!.length;
    wastePages.add(model.wasteList!.sublist(0, firstPageCount));

    for (int i = firstPageCount; i < model.wasteList!.length; i += 25) {
      wastePages.add(
        model.wasteList!.sublist(
          i,
          i + 25 > model.wasteList!.length ? model.wasteList!.length : i + 25,
        ),
      );
    }

    for (var pageIndex = 0; pageIndex < wastePages.length; pageIndex++) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (pageIndex == 0) ...[
                  pw.Text(
                    "Waste By Stock Summary: Total Waste and Costs",
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue,
                    ),
                    textAlign: pw.TextAlign.left,
                  ),
                  pw.SizedBox(height: 4),
                  pw.Divider(thickness: 1, color: PdfColors.grey),
                  pw.Text(
                    "Total Waste Cost:  ${model.totalWaste.formatDouble()} ${AppConstance.primaryCurrency.currencyLocalization()}",
                    style: const pw.TextStyle(fontSize: 14),
                  ),
                ],
                pw.SizedBox(height: 10),
                pw.Table(
                  columnWidths: {
                    0: const pw.FlexColumnWidth(1),
                    1: const pw.FixedColumnWidth(40),
                    2: const pw.FixedColumnWidth(70),
                    3: const pw.FixedColumnWidth(50),
                    4: const pw.FlexColumnWidth(1),
                  },
                  border: pw.TableBorder.all(color: PdfColors.grey),
                  children: [
                    // Header row
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.grey300,
                      ),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            'Stock Item',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            'Unit Type',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            'Qty (kg)/(Portion)',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            'Total Cost',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            '%',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 12,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    // Data row
                    ...wastePages[pageIndex].map((wasteItem) {
                      double percentage = model.totalWaste! > 0
                          ? (wasteItem.totalPrice / model.totalWaste!) * 100
                          : 0.0;
                      String qtyText = "";
                      if (wasteItem.unitType == UnitType.portion) {
                        qtyText =
                            "${wasteItem.totalQtyAsPortions.formatDouble()}${UnitType.portion.uniteTypeToString()}";
                      } else {
                        qtyText =
                            "${wasteItem.totalQtyAsKg.formatDouble()}${UnitType.kg.uniteTypeToString()}";
                      }
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(
                              wasteItem.name,
                              style: pw.TextStyle(fontSize: 12, font: ttf),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(
                              wasteItem.unitType.uniteTypeToString(),
                              style: pw.TextStyle(fontSize: 12, font: ttf),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(
                              qtyText,
                              style: pw.TextStyle(fontSize: 12, font: ttf),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(
                              wasteItem.totalPrice.formatDouble().toString(),
                              style: pw.TextStyle(fontSize: 12, font: ttf),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Row(
                              mainAxisSize: pw.MainAxisSize.min,
                              children: [
                                // Percentage text above the progress bar

                                // Progress bar
                                pw.Expanded(
                                  flex: 5,
                                  child: pw.LinearProgressIndicator(
                                    value: percentage / 100,
                                    valueColor: PdfColors.green,
                                    backgroundColor: PdfColors.grey300,
                                    minHeight: 8,
                                  ),
                                ),
                                pw.SizedBox(width: 4),
                                pw.Expanded(
                                  flex: 2,
                                  child: pw.Text(
                                    "${percentage.toStringAsFixed(2)}%",
                                    style: pw.TextStyle(
                                      fontSize: 12,
                                      font: ttf,
                                    ),
                                    textAlign: pw.TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ],
            );
          },
        ),
      );
    }
  }

  // ! Expenses
  List<List<ExpenseModel>> expensePages = [];
  if (model.expenses.isNotEmpty) {
    int firstPageCount = model.expenses.length >= 23
        ? 23
        : model.expenses.length;
    expensePages.add(model.expenses.sublist(0, firstPageCount));
    for (int i = firstPageCount; i < model.expenses.length; i += 25) {
      expensePages.add(
        model.expenses.sublist(
          i,
          i + 25 > model.expenses.length ? model.expenses.length : i + 25,
        ),
      );
    }

    for (var pageIndex = 0; pageIndex < expensePages.length; pageIndex++) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header on the first page
                if (pageIndex == 0) ...[
                  pw.Text(
                    "Comprehensive Expense Financial Overview",
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue,
                    ),
                    textAlign: pw.TextAlign.left,
                  ),
                  pw.SizedBox(height: 4),
                  pw.Divider(thickness: 1, color: PdfColors.grey),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    "Total Expense: ${model.totalExpenses.formatDouble()} ${AppConstance.primaryCurrency.currencyLocalization()}",
                    style: const pw.TextStyle(fontSize: 14),
                  ),
                ],

                pw.SizedBox(height: 10),
                // Custom table with integrated progress bar in the % column
                pw.Table(
                  columnWidths: {
                    0: const pw.FlexColumnWidth(2),
                    1: const pw.FixedColumnWidth(60),
                    2: const pw.FlexColumnWidth(1),
                  },
                  border: pw.TableBorder.all(color: PdfColors.grey),
                  children: [
                    // Header row
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.grey300,
                      ),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            'Expense Name',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            'Amount',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 12,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            '%',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 12,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    // Data rows
                    ...expensePages[pageIndex].map((expense) {
                      double percentage = model.totalExpenses > 0
                          ? (expense.expenseAmount / model.totalExpenses) * 100
                          : 0.0;
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(
                              expense.expensePurpose,
                              style: pw.TextStyle(fontSize: 12, font: ttf),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(
                              expense.expenseAmount.formatDouble().toString(),
                              style: pw.TextStyle(fontSize: 12, font: ttf),
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Row(
                              mainAxisSize: pw.MainAxisSize.min,
                              children: [
                                // Percentage text above the progress bar

                                // Progress bar
                                pw.Expanded(
                                  flex: 5,
                                  child: pw.LinearProgressIndicator(
                                    value: percentage / 100,
                                    valueColor: PdfColors.green,
                                    backgroundColor: PdfColors.grey300,
                                    minHeight: 8,
                                  ),
                                ),
                                pw.SizedBox(width: 4),
                                pw.Expanded(
                                  flex: 2,
                                  child: pw.Text(
                                    "${percentage.toStringAsFixed(2)}%",
                                    style: pw.TextStyle(
                                      fontSize: 12,
                                      font: ttf,
                                    ),
                                    textAlign: pw.TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ],
            );
          },
        ),
      );
    }
  }

  //! subscriptions list
  List<List<SubscribtionStateModel>> subscriptionPages = [];

  if (model.subscriptionsStats.isNotEmpty) {
    int firstPageCount = model.subscriptionsStats.length >= 23
        ? 23
        : model.subscriptionsStats.length;
    subscriptionPages.add(model.subscriptionsStats.sublist(0, firstPageCount));

    for (int i = firstPageCount; i < model.subscriptionsStats.length; i += 25) {
      subscriptionPages.add(
        model.subscriptionsStats.sublist(
          i,
          i + 25 > model.subscriptionsStats.length
              ? model.subscriptionsStats.length
              : i + 25,
        ),
      );
    }

    for (var pageIndex = 0; pageIndex < subscriptionPages.length; pageIndex++) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(20),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (pageIndex == 0) ...[
                  pw.Text(
                    "Subscription Income Summary: Payments by Customer",
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Divider(thickness: 2, color: PdfColors.black),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    "Total Subscription Income: ${model.totalSubscriptionIncome.formatDouble()} ${AppConstance.primaryCurrency.currencyLocalization()}",
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.green,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                ],
                pw.Table(
                  border: pw.TableBorder.all(color: PdfColors.grey),
                  columnWidths: {
                    0: const pw.FlexColumnWidth(3),
                    1: const pw.FlexColumnWidth(2),
                    2: const pw.FlexColumnWidth(2),
                  },
                  children: [
                    // Header row
                    pw.TableRow(
                      decoration: const pw.BoxDecoration(
                        color: PdfColors.grey300,
                      ),
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            'Customer Name',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            'Payment Count',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 12,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            'Total Paid',
                            style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 12,
                            ),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    // Data rows
                    ...subscriptionPages[pageIndex].map((subscription) {
                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(
                              subscription.customerName,
                              style: pw.TextStyle(fontSize: 12, font: ttf),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(
                              subscription.paymentCount.toString(),
                              style: pw.TextStyle(fontSize: 12, font: ttf),
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(4),
                            child: pw.Text(
                              subscription.totalPaid.formatDouble().toString(),
                              style: pw.TextStyle(fontSize: 12, font: ttf),
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ],
                ),
              ],
            );
          },
        ),
      );
    }
  }

  var savedFile = await pdf.save();
  await saveAndLaunchFile(
    savedFile,
    '${generateUniqueFileName("Profit_report")}.pdf',
    'ProfitReports',
  );
}

//MARK: progress bar row
pw.Widget buildProgressBarRow(String title, double amount, double percentage) {
  return pw.Row(
    children: [
      pw.Expanded(
        child: pw.Text(title, style: const pw.TextStyle(fontSize: 14)),
      ),
      pw.Expanded(
        child: pw.Center(
          child: pw.Text(
            '${amount.formatDouble()} ${AppConstance.primaryCurrency.currencyLocalization()}',
            style: const pw.TextStyle(fontSize: 14),
          ),
        ),
      ),
      pw.Expanded(
        child: pw.LinearProgressIndicator(
          value: percentage / 100,
          valueColor: PdfColors.blue,
          backgroundColor: PdfColors.grey300,
          minHeight: 8,
        ),
      ),
    ],
  );
}

//!MARK:  invoice pdf
Future generateInvoiceAsPdf({
  required SettingModel settingModel,
  required ReceiptModel receipt,
  required List<ProductModel> products,
  bool? isQuotation,
}) async {
  final fontData = await rootBundle.load('assets/fonts/arial.ttf');
  final ttf = pw.Font.ttf(fontData);
  final pdf = pw.Document();

  // Set the items per page to 22
  const int itemsPerPage = 22;
  final List<List<ProductModel>> productChunks = [];

  // Split the products into chunks of 22 items
  for (int i = 0; i < products.length; i += itemsPerPage) {
    productChunks.add(
      products.sublist(
        i,
        i + itemsPerPage > products.length ? products.length : i + itemsPerPage,
      ),
    );
  }

  int productIndex = 1; // Initialize the product index for sequence number

  // Function to build a single page with page number at the bottom center
  pw.Widget buildInvoicePage(
    List<ProductModel> pageProducts,
    bool isLastPage,
    int pageNumber,
  ) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(20),
      child: pw.Stack(
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Company Information
              pw.Row(
                children: [
                  if (settingModel.logo != null)
                    pw.Image(pw.MemoryImage(settingModel.logo!), height: 80),
                  pw.Spacer(),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text(
                        settingModel.storeName.validateString(),
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      pw.Text(
                        settingModel.storeLocation.validateString(),
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                      pw.Text(
                        settingModel.storePhone.validateString(),
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 5),

              // Invoice Title
              pw.Row(
                children: [
                  pw.Expanded(child: pw.Divider()),
                  pw.SizedBox(width: 20),
                  pw.Text(
                    isQuotation == true
                        ? "Quotation".toUpperCase()
                        : "Invoice".toUpperCase(),
                    style: const pw.TextStyle(letterSpacing: 2, fontSize: 18),
                  ),
                ],
              ),

              pw.Row(
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      if (receipt.customerModel != null) ...[
                        pw.Text(
                          "Customer: ${receipt.customerModel!.name}",
                          style: const pw.TextStyle(fontSize: 12),
                        ),
                        pw.Text(
                          "Address: ${receipt.customerModel!.address}",
                          style: const pw.TextStyle(fontSize: 12),
                        ),
                        pw.Text(
                          "Phone: ${receipt.customerModel!.phoneNumber}",
                          style: const pw.TextStyle(fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                  pw.Spacer(),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      if (receipt.id != null)
                        pw.Text(
                          "Invoice Number: ${receipt.id}",
                          style: const pw.TextStyle(fontSize: 12),
                        ),
                      pw.Text(
                        "Date: ${DateTime.parse(receipt.receiptDate.toString()).formatDateTime12Hours()}",
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 20),

              // Products Table
              pw.TableHelper.fromTextArray(
                columnWidths: {
                  0: const pw.FixedColumnWidth(
                    30,
                  ), // Sequence number column (smaller width)
                  1: const pw.FlexColumnWidth(
                    2,
                  ), // Expand "Product Name" column
                  2: const pw.FixedColumnWidth(60), // Price column
                  3: const pw.FixedColumnWidth(40), // Quantity column
                  4: const pw.FixedColumnWidth(70), // Total column
                },
                tableDirection: pw.TextDirection.rtl,
                context: null,
                data: [
                  [
                    '',
                    'Product Name',
                    'Price',
                    'Qty',
                    'Total ${AppConstance.primaryCurrency.currencyLocalization()}',
                  ],
                  ...pageProducts.map((product) {
                    return [
                      productIndex++, // Increment sequence number
                      product.name,
                      '${product.sellingPrice.formatDouble()}',
                      product.qty.formatDouble(),
                      '${(product.sellingPrice.validateDouble() * product.qty.validateDouble()).formatDouble()}',
                    ];
                  }).toList(),
                ],
                headerStyle: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 12,
                ),
                cellStyle: pw.TextStyle(fontSize: 12, font: ttf),
                cellAlignments: {
                  0: pw.Alignment.center,
                  1: pw.Alignment.center,
                  2: pw.Alignment.centerRight,
                  3: pw.Alignment.centerRight,
                  4: pw.Alignment.centerRight,
                },
              ),

              // Add the total only on the last page
              if (isLastPage) ...[
                pw.SizedBox(height: 20),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Text(
                      "Total: ${receipt.foreignReceiptPrice.formatDouble()} ${AppConstance.primaryCurrency.currencyLocalization()}",
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Text(
                      "only ${receipt.foreignReceiptPrice!.toInt().toWords()} ${AppConstance.primaryCurrency.toLowerCase()}",
                      style: const pw.TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ],
            ],
          ),

          // Page number at the bottom center
          pw.Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: pw.Center(
              child: pw.Text(
                'Page $pageNumber',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Add a page for each chunk of products
  for (int i = 0; i < productChunks.length; i++) {
    bool isLastPage = (i == productChunks.length - 1);
    int pageNumber = i + 1; // Page number starts from 1

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20), // Page margin
        build: (context) => buildInvoicePage(
          productChunks[i],
          isLastPage,
          pageNumber,
        ), // Add page content
      ),
    );
  }

  // Save and launch the generated PDF file
  var savedFile = await pdf.save();
  await saveAndLaunchFile(
    savedFile,
    '${generateUniqueFileName("invoice")}.pdf',
    'Invoices',
  );
}

//!MARK:customers template

Future<void> generateCustomersImportTemplate() async {
  //Create a Excel document.

  //Creating a workbook.
  final Workbook workbook = Workbook();
  //Accessing via index
  final Worksheet sheet = workbook.worksheets[0];
  sheet.showGridlines = true;

  // Enable calculation for worksheet.
  sheet.enableSheetCalculations();

  //Set data in the worksheet.

  sheet.getRangeByName('A1').columnWidth = 25;
  sheet.getRangeByName('B1').columnWidth = 25;
  sheet.getRangeByName('C1').columnWidth = 25;

  sheet.getRangeByName('A1').setText('Customer name ');
  sheet.getRangeByName('B1').setText('Address');
  sheet.getRangeByName('C1').setText('Phone');

  sheet.getRangeByName('A1:C1').cellStyle.bold = true;

  //Save and launch the excel.
  final List<int> bytes = workbook.saveAsStream();

  // workbook.dispose();

  //Save and launch the file.
  await saveAndLaunchFile(
    bytes,
    '${generateUniqueFileName("CustomerTemplate")}.xlsx',
    "template",
  );
}

//!MARK:product template
Future<void> generateImportProductTemplate() async {
  //Create a Excel document.

  //Creating a workbook.
  final Workbook workbook = Workbook();
  //Accessing via index
  final Worksheet sheet = workbook.worksheets[0];
  sheet.showGridlines = true;

  // Enable calculation for worksheet.
  sheet.enableSheetCalculations();

  //Set data in the worksheet.

  sheet.getRangeByName('A1').columnWidth = 25;
  sheet.getRangeByName('B1').columnWidth = 15;
  sheet.getRangeByName('C1').columnWidth = 10;
  sheet.getRangeByName('D1').columnWidth = 10;
  sheet.getRangeByName('E1').columnWidth = 10;
  sheet.getRangeByName('F1').columnWidth = 15;
  sheet.getRangeByName('G1').columnWidth = 10;
  sheet.getRangeByName('A1').setText('product name ');
  sheet.getRangeByName('B1').setText('barcode');
  sheet.getRangeByName('C1').setText('cost');
  sheet.getRangeByName('D1').setText('selling');
  sheet.getRangeByName('E1').setText('qty');
  sheet.getRangeByName('F1').setText('tracked');
  sheet.getRangeByName('A1:F1').cellStyle.bold = true;

  sheet.getRangeByName('F2').setText('true');
  sheet.getRangeByName('F3').setText('false');

  //Save and launch the excel.
  final List<int> bytes = workbook.saveAsStream();

  // workbook.dispose();

  //Save and launch the file.
  await saveAndLaunchFile(
    bytes,
    '${generateUniqueFileName("Products")}.xlsx',
    "template",
  );
}

Future<bool> isValidLicense(WidgetRef ref) async {
  bool resLicense = true;
  const int maxRetries = 3;
  int retryCount = 0;

  try {
    // Fetch the validDate from secure storage
    String? validDate = await ref
        .read(securePreferencesProvider)
        .getData(key: "validDate");
    DateTime currentDate = DateTime.now();
    DateTime? v = DateTime.tryParse(validDate.toString());

    // Check if the license has expired based on the valid date
    if (v != null && v.isBefore(currentDate)) {
      resLicense = false; // License is expired
    }
  } catch (e) {
    // Retry if an error occurs and the retry count is less than maxRetries
    if (retryCount < maxRetries) {
      debugPrint("Error reading license, retrying... (${retryCount + 1})");
      return isValidLicense(ref);
    } else {
      debugPrint("Max retries reached. Error: $e");
    }
    retryCount++;
  }
  return resLicense;
}

class EnglishOnlyTextInputFormatter extends TextInputFormatter {
  final RegExp regex = RegExp(
    r'^[a-zA-Z0-9\s.,!?]*$',
  ); // Regular expression to allow only English letters, numbers, spaces, and common symbols.

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // If the new value matches the regular expression, return it as is.
    // Otherwise, return the old value to block the input.
    if (regex.hasMatch(newValue.text)) {
      return newValue;
    } else {
      return oldValue;
    }
  }
}

// MARK: product dialog
Future<void> productAlertDialog(
  BuildContext context,
  WidgetRef ref,
  ProductModel productModel, {
  bool? hideDelete,
  bool? isFromStock,
}) async {
  if (ref.read(currentUserProvider) != null &&
      ref.watch(mainControllerProvider).isAdmin) {
    var alertStyle = AlertStyle(
      isOverlayTapDismiss: false,
      titleStyle: TextStyle(
        color: context.brightnessColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      descStyle: TextStyle(color: context.brightnessColor, fontSize: 16),
      animationDuration: const Duration(milliseconds: 1),
    );
    await ref
        .read(productControllerProvider)
        .fetchProductById(productModel.id ?? 0)
        .then((product) {
          if (product == null) {
            ToastUtils.showToast(
              message: "product not found",
              type: RequestState.error,
            );
            return;
          }
          Alert(
            style: alertStyle,
            context: context,
            type: AlertType.info,
            title: "${product.name}",
            desc:
                "${S.of(context).whatDoYouWantToDo} ${S.of(context).quetionMark}",
            buttons: [
              DialogButton(
                onPressed: () {
                  context.pop();
                },
                color: Colors.grey.shade800,
                child: Text(
                  S.of(context).cancel,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.isMobile ? 14 : 18,
                  ),
                ),
              ),
              DialogButton(
                onPressed: () {
                  ref.read(barcodeListenerEnabledProvider.notifier).state =
                      false;

                  context.pop();

                  context.to(
                    AddEditProductScreen(
                      product,
                      isFromStock: isFromStock,
                      null,
                    ),
                  );
                },
                color: Colors.green.shade400,
                child: Text(
                  S.of(context).edit,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: context.isMobile ? 14 : 18,
                  ),
                ),
              ),
              if (product.isActive == true && hideDelete != true)
                DialogButton(
                  onPressed: () {
                    // remove previous alert
                    context.pop();

                    // add confirmatiom for delete
                    showDialog(
                      context: context,
                      builder: (context) {
                        RequestState deleteRequest = RequestState.success;
                        return StatefulBuilder(
                          builder: (context, setState) {
                            return AreYouSureDialog(
                              agreeText: S.of(context).delete,
                              "${S.of(context).areYouSureDelete} '${product.name}' ${S.of(context).quetionMark}",
                              onCancel: () => context.pop(),
                              agreeState: deleteRequest,
                              onAgree: () async {
                                setState(() {
                                  deleteRequest = RequestState.loading;
                                });
                                await ref
                                    .read(productControllerProvider)
                                    .deleteProduct(
                                      product.id ?? 0,
                                      context,
                                      isFromStock: isFromStock,
                                    )
                                    .whenComplete(() {
                                      setState(() {
                                        deleteRequest = RequestState.success;
                                        context.pop();
                                      });
                                    });
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                  color: Colors.red.shade400,
                  child: Text(
                    S.of(context).delete,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: context.isMobile ? 14 : 18,
                    ),
                  ),
                ),
              if (product.isActive == false)
                DialogButton(onPressed: () {}, child: null),
              if (isFromStock == true && product.isTracked == true)
                DialogButton(
                  onPressed: () {
                    var qtyTextController = TextEditingController();

                    showDialog(
                      context: context,
                      builder: (context) {
                        bool isloadingAddQty = false;
                        return StatefulBuilder(
                          builder: (context, setState) {
                            return AlertDialog(
                              title: Center(
                                child: Text(
                                  "${S.of(context).add} ${S.of(context).qty}",
                                ),
                              ),
                              content: SizedBox(
                                width: 300,
                                height: 120,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    DefaultTextViewForPrinting(
                                      text: "Current Qty : ${product.qty}",
                                      color: Colors.red,
                                    ),
                                    DefaultTextFormField(
                                      format: <TextInputFormatter>[
                                        FilteringTextInputFormatter.allow(
                                          RegExp(r'^\d+\.?\d{0,2}'),
                                        ),
                                      ],
                                      controller: qtyTextController,
                                      inputtype: TextInputType.name,
                                      border: const UnderlineInputBorder(),
                                      text: S.of(context).qty,
                                    ),
                                  ],
                                ),
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    qtyTextController.clear();

                                    isloadingAddQty = false;
                                    context.pop();
                                  },
                                  child: Text(S.of(context).cancel),
                                ),
                                isloadingAddQty
                                    ? const SizedBox(
                                        width: 60,
                                        child: DefaultProgressIndicator(),
                                      )
                                    : TextButton(
                                        onPressed: () async {
                                          double qty =
                                              double.tryParse(
                                                qtyTextController.text.trim(),
                                              ) ??
                                              0;

                                          if (qty > 0) {
                                            productModel.qty =
                                                productModel.qty! + qty;
                                            ref
                                                .read(productControllerProvider)
                                                .updateProduct(
                                                  p: productModel,
                                                  trackedRelatedProductModel:
                                                      [],
                                                  context: context,
                                                  isFromStock: isFromStock,
                                                )
                                                .then((value) => context.pop());
                                          } else {
                                            ToastUtils.showToast(
                                              message: "invalid qty",
                                              type: RequestState.error,
                                            );
                                          }
                                        },
                                        child: Text(S.of(context).add),
                                      ),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                  color: Colors.blue.shade400,
                  child: Text(
                    "${S.of(context).add} ${S.of(context).qty}",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: context.isMobile ? 14 : 18,
                    ),
                  ),
                ),
              if (ref.read(mainControllerProvider).isShowRestaurantStock &&
                  ref.read(mainControllerProvider).screenUI ==
                      ScreenUI.restaurant &&
                  ref.read(mainControllerProvider).isAdmin)
                DialogButton(
                  onPressed: () {
                    context.pop();

                    ref
                        .read(currentMainScreenProvider.notifier)
                        .update(
                          (state) => ScreenName.RestaurantInventoryScreen,
                        );
                    ref.read(selectedSandwichProvider.notifier).state =
                        productModel;
                    ref.invalidate(selectedIngredientsProvider);
                    ref
                        .read(restaurantStockControllerProvider)
                        .fetchAllStockItems();
                  },
                  color: context.primaryColor,
                  child: Text(
                    S.of(context).ingredients,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: context.isMobile ? 12 : 18,
                    ),
                  ),
                ),
            ],
          ).show();
          return null;
        });
  }
}

List<TextInputFormatter> numberTextFormatter = <TextInputFormatter>[
  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,3}')),
];
List<TextInputFormatter> numberWithNegativeTextFormatter = <TextInputFormatter>[
  FilteringTextInputFormatter.allow(RegExp(r'^-?\d*\.?\d{0,3}')),
];
List<TextInputFormatter> currencyRateTextFormatter = <TextInputFormatter>[
  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,8}')),
];
List<TextInputFormatter> numberDigitFormatter = <TextInputFormatter>[
  FilteringTextInputFormatter.digitsOnly,
];

class DateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;

    // Automatically insert '-' after year and month
    if (text.length == 4 && oldValue.text.length == 3) {
      return TextEditingValue(
        text: '$text-',
        selection: TextSelection.collapsed(offset: text.length + 1),
      );
    }
    if (text.length == 7 && oldValue.text.length == 6) {
      return TextEditingValue(
        text: '$text-',
        selection: TextSelection.collapsed(offset: text.length + 1),
      );
    }

    // Limit the input length to 10 characters (YYYY-MM-DD)
    if (text.length > 10) {
      return TextEditingValue(
        text: oldValue.text,
        selection: oldValue.selection,
      );
    }

    return newValue;
  }
}

int getMaxDaysInMonth(int month, int year) {
  if (month == 2) {
    // Check for leap year
    if ((year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)) {
      return 29; // February in a leap year
    } else {
      return 28; // February in a non-leap year
    }
  } else if ([4, 6, 9, 11].contains(month)) {
    return 30; // April, June, September, November
  } else {
    return 31; // All other months
  }
}

Future<AuthResponse> signInSilently() async {
  final AuthResponse res = await globalAppWidgetRef
      .read(supaBaseProvider)
      .auth
      .signInWithPassword(
        email: SecureConfig.supaEmail,
        password: SecureConfig.supaPass,
      );

  return res;
}

BuildContext get globalAppContext =>
    MyApp.appRef.read(navigationKeyProvider).currentContext!;

get globalAppWidgetRef => MyApp.appRef;

//MARK: widget in large dialog
void openWidgetInLargeDialog(BuildContext context, Widget widget) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.8,
          child: widget,
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Close'),
            onPressed: () {
              context.pop();
            },
          ),
        ],
      );
    },
  );
}

clearUnusedData(WidgetRef ref, String pageScreen) {
  // If the current screen is the same as the last screen, skip invalidation

  try {
    // Invalidate stock controller if the screen is not StockScreen
    if (pageScreen != ScreenName.InventoryScreen &&
        ref.exists(stockControllerProvider)) {
      ref.invalidate(stockControllerProvider);
    }
    // Invalidate customer controller if the screen is not CustomerScreen
    if (pageScreen != ScreenName.CustomerScreen &&
        ref.exists(customerControllerProvider)) {
      ref.invalidate(customerControllerProvider);
    }
    // Invalidate dashboard controller if the screen is not Dashboard
    if (pageScreen != ScreenName.Dashboard &&
        ref.exists(dashboardControllerProvider)) {
      ref.invalidate(dashboardControllerProvider);
    }
    // Invalidate receipt controller if the screen is not ShiftScreen or DailySalesScreen
    if ((pageScreen != ScreenName.ShiftScreen &&
            pageScreen != ScreenName.DailyFinancials) &&
        ref.exists(receiptControllerProvider)) {
      ref.invalidate(receiptControllerProvider);
    }
    // Invalidate profit controller if the screen is not ProfitReport
    if (pageScreen != ScreenName.ProfitReport &&
        ref.exists(profitControllerProvider)) {
      ref.invalidate(profitControllerProvider);
    }
    // Invalidate restaurant stock controller if the screen is not RestaurantStockScreen
    if (pageScreen != ScreenName.RestaurantInventoryScreen &&
        ref.exists(restaurantStockControllerProvider)) {
      ref.invalidate(restaurantStockControllerProvider);
    }
    if (pageScreen != ScreenName.Purchases &&
        ref.exists(supplierControllerProvider)) {
      ref.invalidate(supplierControllerProvider);
    }
  } catch (e) {
    // If an error occurs, recreate the necessary controllers
    print("Exception during invalidation: $e");
    if (!ref.context.mounted) return; // Only proceed if the widget is mounted

    // Recreate controllers based on the current screen using switch
    switch (pageScreen) {
      case ScreenName.InventoryScreen:
        ref.read(stockControllerProvider);
        break;
      case ScreenName.CustomerScreen:
        ref.read(customerControllerProvider);
        break;
      case ScreenName.Dashboard:
        ref.read(dashboardControllerProvider);
        break;
      case ScreenName.ShiftScreen:
      case ScreenName.DailyFinancials:
        ref.read(receiptControllerProvider);
        break;
      case ScreenName.ProfitReport:
        ref.read(profitControllerProvider);
        break;
      case ScreenName.RestaurantInventoryScreen:
        ref.read(restaurantStockControllerProvider);
        break;
      default:
        // You can handle cases where the screen is not recognized, if necessary
        break;
    }
  }
}

Uint8List? convertImageData(dynamic imageData) {
  if (imageData == null) return null;

  try {
    // Handle base64 data URL (e.g., "data:image/png;base64,...")
    if (imageData is String) {
      if (imageData.startsWith('data:image')) {
        // Extract the base64 part after the comma
        final base64String = imageData.split(',')[1];
        return base64Decode(base64String);
      } else {
        // Try to decode as plain base64 string
        return base64Decode(imageData);
      }
    }

    // Check if it's the Buffer format from your API
    if (imageData is Map<String, dynamic> &&
        imageData['type'] == 'Buffer' &&
        imageData['data'] is List) {
      // Convert List<dynamic> to List<int> then to Uint8List
      final List<dynamic> dataList = imageData['data'];
      final List<int> intList = dataList.cast<int>();
      return Uint8List.fromList(intList);
    }

    // Handle other potential formats
    if (imageData is List) {
      final List<int> intList = imageData.cast<int>();
      return Uint8List.fromList(intList);
    }

    return null;
  } catch (e) {
    print('Error converting image data: $e');
    return null;
  }
}

//MARK: app version
String appVersion = "";
defaultVersionWidget(Color color) => DefaultTextView(
  text: "v$appVersion",
  color: color,
  fontSize: 13.spMax,
  fontWeight: FontWeight.bold,
);
