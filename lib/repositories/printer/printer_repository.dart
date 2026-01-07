import 'dart:typed_data';

import 'package:desktoppossystem/controller/setting_controller.dart';
import 'package:desktoppossystem/models/customers_model.dart';
import 'package:desktoppossystem/models/expense_model.dart';
import 'package:desktoppossystem/models/printer_model.dart';
import 'package:desktoppossystem/models/reports/end_of_day_model.dart';
import 'package:desktoppossystem/models/setting_model.dart';
import 'package:desktoppossystem/repositories/printer/iprinter_repository.dart';
import 'package:desktoppossystem/shared/constances/app_constances.dart';
import 'package:desktoppossystem/shared/services/dependency_injection.dart';
import 'package:desktoppossystem/shared/services/printer_service/printer_service.dart';
import 'package:desktoppossystem/shared/services/printer_service/printer_service_factory.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:thermal_printer_plus/esc_pos_utils_platform/esc_pos_utils_platform.dart';

import '../../shared/constances/table_constant.dart';

final printerProviderRepository = Provider((ref) {
  return PrinterRepository(ref);
});

class PrinterRepository implements IPrinterRepository {
  final Ref ref;
  late final PrinterService _printerService;

  PrinterRepository(this.ref) {
    // Get platform-specific printer service (USB for Windows, Bluetooth for Android)
    _printerService = PrinterServiceFactory.getPrinterService();
  }

  @override
  Future<bool> connectToPrinter(String printerName) async {
    return await _printerService.connectToPrinter(printerName);
  }

  @override
  Stream<List<PrinterModel>> listenToPrinters() {
    return _printerService.listenToPrinters();
  }

  @override
  Future printReceipt(List<int> value) async {
    await _printerService.printReceipt(value);
  }

  @override
  Future<List<int>> buildReceiptTicket({
    required List<Uint8List> images,
    required double originalTotalForeign,
    required double totalForeign,
    required double dolarRate,
    bool? dontOpenCash,
    String? receiptNumber,
    String? tableNumber,
    int? invoiceNumber,
    required bool printReceiptInLebanon,
    required bool printReceiptInDolar,
    CustomerModel? customerModel,
    bool? isHasDiscount,
    bool? isQuotaion,
    String? receiptDate,
    String? receiptDiscount, // used if all products same discount
  }) async {
    List<int> bytes = [];

    CapabilityProfile profile = await CapabilityProfile.load();

    final generator = Generator(PaperSize.mm80, profile);

    int nbofDashInPaper = 22;

    SettingModel settingModel = ref
        .read(settingControllerProvider)
        .settingModel;
    if (settingModel.printLogoOnInvoice == true) {
      if (settingModel.logo != null) {
        img.Image? image = img.decodeImage(settingModel.logo!);
        if (image != null) {
          img.Image resizedImage = img.copyResize(
            image,
            width: 384,
          ); // Adjust width to match printer
          bytes += generator.imageRaster(resizedImage);
        } else {
          throw Exception("Failed to decode the logo image.");
        }
      }
    } else {
      if (settingModel.storeQrCode.validateString().isNotEmpty) {
        bytes += generator.qrcode(
          settingModel.storeQrCode.validateString(),
          size: QRSize.Size8,
        );
      }
    }

    bytes += generator.text("", linesAfter: 1);
    // ! hedaer Section
    if (settingModel.printLogoOnInvoice != true) {
      if (settingModel.storeName.validateString().isNotEmpty) {
        bytes += generator.text(
          settingModel.storeName.validateString(),
          styles: const PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          ),
        );
      }
    }
    if (settingModel.storeLocation.validateString().isNotEmpty) {
      bytes += generator.text(
        settingModel.storeLocation.validateString(),
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ),
      );
    }
    if (settingModel.storePhone.validateString().isNotEmpty) {
      bytes += generator.text(
        settingModel.storePhone.validateString(),
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ),
        linesAfter: 1,
      );
    }

    DateTime currentDate =
        DateTime.tryParse(receiptDate.toString()) ?? DateTime.now();
    var time = currentDate.toString().split(' ')[1].toString().split(":");
    if (customerModel != null) {
      bytes += generator.text(
        "Customer : ${customerModel.name} - ${customerModel.phoneNumber}",
        styles: const PosStyles(
          align: PosAlign.left,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ),
      );

      bytes += generator.row([
        PosColumn(
          text: "Address : ${customerModel.address}",
          width: 12,
          styles: const PosStyles(
            align: PosAlign.left,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          ),
        ),
      ]);
    }
    bytes += generator.row([
      PosColumn(
        text:
            "Date : ${currentDate.toString().split(' ').first} ${time[0]}:${time[1]}",
        width: 8,
        styles: const PosStyles(
          align: PosAlign.left,
          height: PosTextSize.size1,
        ),
      ),
      PosColumn(
        text: isQuotaion == true
            ? "Quotation"
            : "Inv nb ${invoiceNumber ?? '-'}",
        width: 4,
        styles: const PosStyles(
          align: PosAlign.left,
          height: PosTextSize.size1,
        ),
      ),
    ]);

    if (isQuotaion == null) {
      if (tableNumber != null) {
        bytes += generator.text(
          "Table : -( $tableNumber )-",
          styles: const PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          ),
          linesAfter: 1,
        );
      } else if (receiptNumber != null) {
        bytes += generator.text(
          "- $receiptNumber -",
          styles: const PosStyles(
            align: PosAlign.center,
            height: PosTextSize.size2,
            width: PosTextSize.size2,
          ),
          linesAfter: 1,
        );
      }
    }

    for (var e in images) {
      img.Image? image = img.decodeImage(e);
      //        bytes += generator.imageRaster(image!);

      bytes += generator.imageRaster(image!);
      // bytes += generator.imageRaster(image, imageFn: PosImageFn.graphics);
    }

    //! TOTAL Section
    bytes += generator.text(
      "- " * nbofDashInPaper,
      styles: const PosStyles(align: PosAlign.center),
    );

    if (isHasDiscount == true) {
      if (printReceiptInDolar == true) {
        bytes += generator.row([
          PosColumn(
            text: "Before Discount",
            width: 6,
            styles: const PosStyles(
              align: PosAlign.left,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
            ),
          ),
          PosColumn(
            text:
                "${originalTotalForeign.formatDouble()} ${AppConstance.primaryCurrency.currencyLocalization()}",
            width: 6,
            styles: const PosStyles(
              align: PosAlign.right,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
            ),
          ),
        ]);
      }
      if (printReceiptInLebanon == true || printReceiptInDolar == false) {
        bytes += generator.row([
          PosColumn(
            text: "Before Discount",
            width: 6,
            styles: const PosStyles(
              align: PosAlign.left,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
            ),
          ),
          PosColumn(
            text:
                "${(originalTotalForeign * dolarRate).formatAmountNumber()} ${AppConstance.secondaryCurrency.currencyLocalization()}",
            width: 6,
            styles: const PosStyles(
              align: PosAlign.right,
              height: PosTextSize.size1,
              width: PosTextSize.size1,
            ),
          ),
        ]);

        if (receiptDiscount != null) {
          bytes += generator.row([
            PosColumn(
              text: "Discount",
              width: 6,
              styles: const PosStyles(
                align: PosAlign.left,
                height: PosTextSize.size1,
                width: PosTextSize.size1,
              ),
            ),
            PosColumn(
              text: receiptDiscount,
              width: 6,
              styles: const PosStyles(
                align: PosAlign.right,
                height: PosTextSize.size1,
                width: PosTextSize.size1,
              ),
            ),
          ]);
        }
      }
    }

    if (printReceiptInDolar == true) {
      bytes += generator.row([
        PosColumn(
          text: "Total ",
          width: 4,
          styles: const PosStyles(
            align: PosAlign.left,
            height: PosTextSize.size1,
            width: PosTextSize.size2,
          ),
        ),
        PosColumn(
          text:
              "${totalForeign.formatDouble()} ${AppConstance.primaryCurrency.currencyLocalization()}",
          width: 8,
          styles: const PosStyles(
            align: PosAlign.right,
            height: PosTextSize.size1,
            width: PosTextSize.size2,
          ),
        ),
        // if false dont add the lebanese in the same ligne of total
      ]);
    }
    if (printReceiptInDolar == false || printReceiptInLebanon == true) {
      bytes += generator.row([
        PosColumn(
          text: "Total ",
          width: 3,
          styles: const PosStyles(
            align: PosAlign.left,
            height: PosTextSize.size1,
            width: PosTextSize.size2,
          ),
        ),
        PosColumn(
          text:
              "${(totalForeign * dolarRate).formatAmountNumber()} ${AppConstance.secondaryCurrency.currencyLocalization()}",
          width: 9,
          styles: const PosStyles(
            align: PosAlign.right,
            height: PosTextSize.size1,
            width: PosTextSize.size2,
          ),
        ),
      ]);
    }
    bytes += generator.text(
      "- " * nbofDashInPaper,
      styles: const PosStyles(align: PosAlign.center),
    );

    bytes += generator.row([
      PosColumn(
        text: "Thank you for purchasing from  ",
        width: 12,
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ),
      ),
    ]);

    bytes += generator.text(
      settingModel.storeName.validateString(),
      styles: const PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size1,
        width: PosTextSize.size1,
      ),
      linesAfter: 1,
    );

    final String? note = ref.read(settingControllerProvider).settingModel.note;
    if (note != null && note.isNotEmpty) {
      bytes += generator.row([
        PosColumn(
          text: "*$note*",
          width: 12,
          styles: const PosStyles(
            bold: true,
            align: PosAlign.center,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          ),
        ),
      ]);
    }
    bytes += generator.row([
      PosColumn(
        text: "",
        width: 12,
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: "",
        width: 12,
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ),
      ),
    ]);
    bytes += generator.row([
      PosColumn(
        text: "Powered by CoreManager - 81851852",
        width: 12,
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ),
      ),
    ]);

    bytes += generator.cut();
    //if (dontOpenCash == null) bytes += generator.drawer();

    return bytes;
  }

  @override
  Future<List<int>> buildRestaurantStockTicket({
    required List<Uint8List> images,
  }) async {
    List<int> bytes = [];

    CapabilityProfile profile = await CapabilityProfile.load();

    final generator = Generator(PaperSize.mm80, profile);

    DateTime currentDate = DateTime.now();
    var time = currentDate.toString().split(' ')[1].toString().split(":");
    bytes += generator.row([
      PosColumn(
        text:
            "Date : ${currentDate.toString().split(' ').first} ${time[0]}:${time[1]}",
        width: 12,
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size1,
        ),
      ),
    ]);

    for (var e in images) {
      img.Image? image = img.decodeImage(e);
      //        bytes += generator.imageRaster(image!);

      bytes += generator.imageRaster(image!);
      // bytes += generator.imageRaster(image, imageFn: PosImageFn.graphics);
    }

    bytes += generator.cut();

    return bytes;
  }

  @override
  Future<List<int>> buildEndOfDayTicket(
    PageSize pageSize,
    EndOfDayModel endOfDayModel,
  ) async {
    List<int> bytes = [];
    CapabilityProfile profile = await CapabilityProfile.load();

    final generator = Generator(
      pageSize == PageSize.mm58 ? PaperSize.mm58 : PaperSize.mm80,
      profile,
    );
    SettingModel settingModel = ref
        .read(settingControllerProvider)
        .settingModel;
    bytes += generator.text(
      settingModel.storeName.validateString(),
      styles: const PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
      linesAfter: 1,
    );
    if (endOfDayModel.endOfShiftEmployeeModel != null) {
      bytes += generator.text(
        "shift : ${endOfDayModel.endOfShiftEmployeeModel?.shiftId} ",
        styles: const PosStyles(
          align: PosAlign.left,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ),
      );
    }
    // if end day is shift
    if (endOfDayModel.endOfShiftEmployeeModel != null) {
      bytes += generator.text(
        "start shift date :  ${endOfDayModel.endOfShiftEmployeeModel!.startShiftDate.split(".").first}",
        styles: const PosStyles(
          align: PosAlign.left,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ),
      );
      bytes += generator.text(
        "end shift date :  ${endOfDayModel.endOfShiftEmployeeModel!.endShiftDate?.split(".").first}",
        styles: const PosStyles(
          align: PosAlign.left,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ),
      );
    }
    //! if print report from daily sale
    if (endOfDayModel.endOfShiftEmployeeModel == null) {
      bytes += generator.text(
        "date :  ${endOfDayModel.date}",
        styles: const PosStyles(
          align: PosAlign.left,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ),
      );
    }

    bytes += generator.text(
      "Customers : ${endOfDayModel.nbCustomers} ",
      styles: const PosStyles(
        align: PosAlign.left,
        height: PosTextSize.size1,
        width: PosTextSize.size1,
      ),
    );
    if (endOfDayModel.employeeName != "All") {
      bytes += generator.text(
        "employee : ${endOfDayModel.employeeName} ",
        styles: const PosStyles(
          align: PosAlign.left,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ),
      );
    }

    for (var e in endOfDayModel.imageData) {
      img.Image? image = img.decodeImage(e);
      bytes += generator.imageRaster(image!);
    }

    bytes += generator.text(
      "- " * 22,
      styles: const PosStyles(align: PosAlign.center),
    );
    bytes += generator.text(
      "Total Amount ( ${AppConstance.primaryCurrency.currencyLocalization()} ): ${endOfDayModel.totalPrimary.formatDouble()} ${AppConstance.primaryCurrency.currencyLocalization()}",
      styles: const PosStyles(
        align: PosAlign.left,
        height: PosTextSize.size1,
        width: PosTextSize.size1,
      ),
    );
    bytes += generator.text(
      "Sales ( ${AppConstance.primaryCurrency.currencyLocalization()} ): ${endOfDayModel.salesPrimary.formatDouble()} ${AppConstance.primaryCurrency.currencyLocalization()}",
      styles: const PosStyles(
        align: PosAlign.left,
        height: PosTextSize.size1,
        width: PosTextSize.size1,
      ),
    );
    bytes += generator.text(
      "Sales ( ${AppConstance.secondaryCurrency.currencyLocalization()} ): ${endOfDayModel.salesSecondary.formatAmountNumber()} ${AppConstance.secondaryCurrency.currencyLocalization()}",
      styles: const PosStyles(
        align: PosAlign.left,
        height: PosTextSize.size1,
        width: PosTextSize.size1,
      ),
    );
    //! deposit
    bytes += generator.text(
      "deposit ( ${AppConstance.primaryCurrency.currencyLocalization()} ): ${endOfDayModel.depositDolar.formatDouble()}  ${AppConstance.primaryCurrency.currencyLocalization()}",
      styles: const PosStyles(
        align: PosAlign.left,
        height: PosTextSize.size1,
        width: PosTextSize.size1,
      ),
    );
    bytes += generator.text(
      "deposit (  ${AppConstance.secondaryCurrency.currencyLocalization()} ): ${endOfDayModel.depositLebanese.formatAmountNumber()}  ${AppConstance.secondaryCurrency.currencyLocalization()}",
      styles: const PosStyles(
        align: PosAlign.left,
        height: PosTextSize.size1,
        width: PosTextSize.size1,
      ),
    );

    //old collected pending

    bytes += generator.text(
      "collected from pending: ${endOfDayModel.totalCollectedPending.formatDouble()} ${AppConstance.primaryCurrency.currencyLocalization()}",
      styles: const PosStyles(
        align: PosAlign.left,
        height: PosTextSize.size1,
        width: PosTextSize.size1,
      ),
    );
    if (endOfDayModel.totalSubscriptions != null) {
      bytes += generator.text(
        "subscriptions: ${endOfDayModel.totalSubscriptions!.formatDouble()} ${AppConstance.primaryCurrency.currencyLocalization()}",
        styles: const PosStyles(
          align: PosAlign.left,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ),
      );
    }

    // !withdraw

    List<ExpenseModel> localExpenses = endOfDayModel.expenses!
        .where((element) => element.isTransactionInPrimary == false)
        .toList();
    List<ExpenseModel> forignExpenses = endOfDayModel.expenses!
        .where((element) => element.isTransactionInPrimary == true)
        .toList();

    bytes += generator.text(
      "expenses ( ${AppConstance.primaryCurrency} ): ${endOfDayModel.withdrawDolar.formatDouble()}  ${AppConstance.primaryCurrency.currencyLocalization()}",
      styles: const PosStyles(
        align: PosAlign.left,
        height: PosTextSize.size1,
        width: PosTextSize.size1,
      ),
    );
    for (var expense in forignExpenses) {
      bytes += generator.text(
        " - ${expense.expensePurpose} ${expense.withDrawFromCash == true ? "(from cash)" : ""}  => ${expense.expenseAmount} ${AppConstance.primaryCurrency}",
        styles: const PosStyles(
          align: PosAlign.left,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ),
      );
    }

    bytes += generator.text(
      "expenses ( ${AppConstance.secondaryCurrency.currencyLocalization()} ): ${endOfDayModel.withdrawLebanese.formatAmountNumber()}  ${AppConstance.secondaryCurrency.currencyLocalization()}",
      styles: const PosStyles(
        align: PosAlign.left,
        height: PosTextSize.size1,
        width: PosTextSize.size1,
      ),
    );
    for (var expense in localExpenses) {
      bytes += generator.text(
        " - ${expense.expensePurpose} ${expense.withDrawFromCash == true ? "(from cash)" : ""} => ${expense.expenseAmount} ${AppConstance.secondaryCurrency.currencyLocalization()}",
        styles: const PosStyles(
          align: PosAlign.left,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ),
      );
    }

    // Additional financial fields
    bytes += generator.text(
      "Withdraw from Cash ( ${AppConstance.primaryCurrency.currencyLocalization()} ): ${endOfDayModel.withdrawDolarFromCash.formatDouble()} ${AppConstance.primaryCurrency.currencyLocalization()}",
      styles: const PosStyles(
        align: PosAlign.left,
        height: PosTextSize.size1,
        width: PosTextSize.size1,
      ),
    );
    bytes += generator.text(
      "Withdraw from Cash ( ${AppConstance.secondaryCurrency.currencyLocalization()} ): ${endOfDayModel.withdrawLebaneseFromCash.formatAmountNumber()} ${AppConstance.secondaryCurrency.currencyLocalization()}",
      styles: const PosStyles(
        align: PosAlign.left,
        height: PosTextSize.size1,
        width: PosTextSize.size1,
      ),
    );
    bytes += generator.text(
      "Pending Amount: ${endOfDayModel.totalPendingAmount.formatDouble()} ${AppConstance.primaryCurrency.currencyLocalization()}",
      styles: const PosStyles(
        align: PosAlign.left,
        height: PosTextSize.size1,
        width: PosTextSize.size1,
      ),
    );
    bytes += generator.text(
      "Pending Receipts: ${endOfDayModel.totalPendingReceipts}",
      styles: const PosStyles(
        align: PosAlign.left,
        height: PosTextSize.size1,
        width: PosTextSize.size1,
      ),
    );
    bytes += generator.text(
      "Collected Pending: ${endOfDayModel.totalCollectedPending.formatDouble()} ${AppConstance.primaryCurrency.currencyLocalization()}",
      styles: const PosStyles(
        align: PosAlign.left,
        height: PosTextSize.size1,
        width: PosTextSize.size1,
      ),
    );
    bytes += generator.text(
      "Refunds: ${endOfDayModel.totalRefunds.formatDouble()} ${AppConstance.primaryCurrency.currencyLocalization()}",
      styles: const PosStyles(
        align: PosAlign.left,
        height: PosTextSize.size1,
        width: PosTextSize.size1,
      ),
    );
    bytes += generator.text(
      "Purchases : ${endOfDayModel.totalPurchasesPrimary.formatDouble()} ${AppConstance.primaryCurrency.currencyLocalization()}",
      styles: const PosStyles(
        align: PosAlign.left,
        height: PosTextSize.size1,
        width: PosTextSize.size1,
      ),
    );

    bytes += generator.cut();

    return bytes;
  }

  @override
  Future<PrinterModel?> getCurrentPrinterSettings() async {
    PrinterModel? p;
    await ref
        .read(posDbProvider)
        .database
        .query(TableConstant.printerTable, limit: 1)
        .then((value) {
          if (value.isNotEmpty) p = PrinterModel.fromJson(value[0]);
        })
        .catchError((error) {
          throw Exception(error);
        });
    return p;
  }

  @override
  Future<PrinterModel> updateCurrentPrinterSettings(
    PrinterModel printermodel,
  ) async {
    PrinterModel printer = PrinterModel();
    await ref
        .read(posDbProvider)
        .database
        .rawUpdate(
          "update ${TableConstant.printerTable} set modelName='${printermodel.modelName}' , isHasNetworkPrinter=${printermodel.isHasNetworkPrinter == true ? 1 : 0}, pageSize='${printermodel.pageSize}' , isprintReceipt='${printermodel.isprintReceipt == true ? 1 : 0}' where id=${printermodel.id}",
        )
        .then((value) {
          printer = printermodel;
        })
        .catchError((error) {
          debugPrint(error.toString());
          throw Exception(error);
        });
    return printer;
  }

  @override
  Future<PrinterModel> addPrinterSettings(PrinterModel printermodel) async {
    PrinterModel printer = PrinterModel();
    await ref
        .read(posDbProvider)
        .database
        .insert(TableConstant.printerTable, printermodel.toSpecificJson())
        .then((value) {
          printer = printermodel;
          printer.id = value;
        })
        .catchError((error) {
          debugPrint(error.toString());
          throw Exception(error);
        });
    return printer;
  }

  @override
  Future<List<int>> buildOrderTicket(
    PageSize pageSize,
    List<Uint8List> images,
    int receiptNumber,
    String tableNumber,
    String orderedBy,
  ) async {
    List<int> bytes = [];
    CapabilityProfile profile = await CapabilityProfile.load();

    final generator = Generator(
      pageSize == PageSize.mm58 ? PaperSize.mm58 : PaperSize.mm80,
      profile,
    );

    int nbofDashInPaper = pageSize == PageSize.mm58 ? 16 : 22;

    DateTime currentDate = DateTime.now();
    var time = currentDate.toString().split(' ')[1].toString().split(":");

    bytes += generator.text(
      "- $receiptNumber -",
      styles: const PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size2,
        width: PosTextSize.size2,
      ),
    );
    // ! Table header Section
    bytes += generator.row([
      PosColumn(
        text:
            "Date : ${currentDate.toString().split(' ').first} ${time[0]}:${time[1]}",
        width: 8,
        styles: const PosStyles(
          align: PosAlign.left,
          height: PosTextSize.size1,
        ),
      ),
      PosColumn(
        text: "Table : -( $tableNumber )-",
        width: 4,
        styles: const PosStyles(
          align: PosAlign.left,
          height: PosTextSize.size1,
        ),
      ),
    ]);
    // bytes += generator.text(
    //   "Date : ${currentDate.toString().split(' ').first} ${time[0]}:${time[1]}",
    //   styles: PosStyles(
    //     align: PosAlign.center,
    //     height: PosTextSize.size1,
    //     width: PosTextSize.size1,
    //   ),
    // );
    // bytes += generator.text(
    //   "Table : -( $tableNumber )-",
    //   styles: PosStyles(
    //     align: PosAlign.center,
    //     height: PosTextSize.size1,
    //     width: PosTextSize.size1,
    //   ),
    // );

    bytes += generator.text(
      "Ordered By : $orderedBy ",
      styles: const PosStyles(
        align: PosAlign.center,
        height: PosTextSize.size1,
        width: PosTextSize.size1,
      ),
      linesAfter: 1,
    );

    bytes += generator.text(
      "- " * nbofDashInPaper,
      styles: const PosStyles(align: PosAlign.center),
    );

    // ! Table header Section
    bytes += generator.row([
      PosColumn(text: " ", width: 1),
      PosColumn(
        text: "Item",
        width: 8,
        styles: const PosStyles(
          align: PosAlign.left,
          height: PosTextSize.size1,
        ),
      ),
      PosColumn(
        text: "Qty",
        width: 2,
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size1,
        ),
      ),
      PosColumn(text: " ", width: 1),
    ]);
    bytes += generator.text(
      "- " * nbofDashInPaper,
      styles: const PosStyles(align: PosAlign.center),
    );

    for (var e in images) {
      img.Image? image = img.decodeImage(e);
      bytes += generator.imageRaster(image!);
    }

    //! TOTAL Section
    bytes += generator.text(
      "- " * nbofDashInPaper,
      styles: const PosStyles(align: PosAlign.center),
    );

    bytes += generator.cut();

    return bytes;
  }

  @override
  Future openCashDrawer(PrinterModel printermodel) async {
    List<int> bytes = [];
    CapabilityProfile profile = await CapabilityProfile.load();

    final generator = Generator(PaperSize.mm80, profile);
    bytes += generator.drawer();

    printReceipt(bytes);
  }

  double roundUpToNearestHalf(double number) {
    // Calculate how many half steps (0.5) the number is from zero
    double halfSteps = number / 0.5;

    // Use ceil to round up the number to the nearest half step
    double roundedHalfSteps = halfSteps.ceil().toDouble();

    // Multiply the rounded half steps back by 0.5 to get the rounded number
    return roundedHalfSteps * 0.5;
  }
}
