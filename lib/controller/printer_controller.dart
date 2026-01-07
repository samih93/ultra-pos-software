import 'dart:async';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:desktoppossystem/controller/auth_controller.dart';
import 'package:desktoppossystem/controller/category_controller.dart';
import 'package:desktoppossystem/controller/product_controller.dart';
import 'package:desktoppossystem/controller/receipt_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/customers_model.dart';
import 'package:desktoppossystem/models/printer_model.dart';
import 'package:desktoppossystem/models/product_model.dart';
import 'package:desktoppossystem/models/receipt_model.dart';
import 'package:desktoppossystem/models/reports/end_of_day_model.dart';
import 'package:desktoppossystem/models/reports/end_of_shift_employee_model.dart';
import 'package:desktoppossystem/models/reports/restaurant_stock_usage_model.dart';
import 'package:desktoppossystem/models/restaurant_stock_model.dart';
import 'package:desktoppossystem/models/section_printer_model.dart';
import 'package:desktoppossystem/repositories/printer/iprinter_repository.dart';
import 'package:desktoppossystem/repositories/printer/printer_repository.dart';
import 'package:desktoppossystem/screens/daily%20sales/daily_financial_screen.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
import 'package:desktoppossystem/screens/shift_screen/shift_screen.dart';
import 'package:desktoppossystem/shared/constances/app_constances.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/services/dependency_injection.dart';
import 'package:desktoppossystem/shared/services/print_label_service.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:desktoppossystem/shared/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:screenshot/screenshot.dart';

final printerControllerProvider = ChangeNotifierProvider<PrinterController>((
  ref,
) {
  return PrinterController(
    ref: ref,
    iPrinterRepository: ref.read(printerProviderRepository),
  );
});

class PrinterController extends ChangeNotifier {
  final Ref _ref;
  final IPrinterRepository _iPrinterRepository;

  PrinterController({
    required Ref ref,
    required IPrinterRepository iPrinterRepository,
  }) : _ref = ref,
       _iPrinterRepository = iPrinterRepository {
    _getCurrentPrinterSettings();
    _fetchPrintingConfiguration();
    _getPrintersSection();
  }

  var sectionsPrinters = <SectionPrinterModel>[];
  _getPrintersSection() {
    sectionsPrinters = _ref.read(appPreferencesProvider).getSectionPrinters();

    notifyListeners();
  }

  void addSectionPrinter(String name) {
    SectionPrinterModel sectionPrinterModel = SectionPrinterModel(
      sectionType: selectedPrinterSection,
      printerName: name,
    );
    if (!sectionsPrinters.any((e) => e.printerName == name)) {
      sectionsPrinters.add(sectionPrinterModel);
      _ref.read(appPreferencesProvider).saveSectionPrinters(sectionsPrinters);
    } else {
      ToastUtils.showToast(
        message: "Printer name already exist",
        type: RequestState.error,
        duration: const Duration(seconds: 2),
      );
    }
    notifyListeners();
  }

  void removeSectionPrinter(String name) {
    sectionsPrinters.removeWhere((e) => e.printerName == name);
    _ref.read(appPreferencesProvider).removeSectionPrinter(name);
    notifyListeners();
  }

  SectionType selectedPrinterSection = SectionType.kitchen;
  void onchangePrinterSection(SectionType section) {
    selectedPrinterSection = section;
    notifyListeners();
  }

  var textPrinterController = TextEditingController();
  var textNetworkPrinterController = TextEditingController();
  var pageSizeController = TextEditingController();
  PageSize selectedSize = PageSize.mm80;
  var receiptNumberTextController = TextEditingController();

  bool isprintReceipt = false;
  bool isHasNetworkPrinter = false;

  double basketFontSize = 20;
  double basketWidth = 500;

  onchangeBasketFontSize(double size) {
    basketFontSize = size;
    _ref
        .read(appPreferencesProvider)
        .saveData(key: "basketFontSize", value: basketFontSize);
    notifyListeners();
  }

  onchangeBasketWidth(double width) {
    basketWidth = width;
    _ref
        .read(appPreferencesProvider)
        .saveData(key: "basketWidth", value: basketWidth);
    notifyListeners();
  }

  Future<bool> connectToPrinter(String printerName) async {
    bool isConnected = false;
    if (printerName.toString().isNotEmpty) {
      await _iPrinterRepository.connectToPrinter(printerName).then((value) {
        if (value) textPrinterController.text = printerName;
        isConnected = value;
        currentPrinterSettings.modelName = printerName;
      });
    }
    return isConnected;
  }

  Future<bool> connectToPrinterByNetwork(String printerName) async {
    bool isConnected = false;
    if (printerName.isNotEmpty) {
      await _iPrinterRepository.connectToPrinter(printerName).then((value) {
        isConnected = value;
      });
    }

    return isConnected;
  }

  // Future onchangePageSize(PageSize pageSize) async {
  //   selectedSize = pageSize;
  //   pageSizeController.text = pageSize.name;
  //   notifyListeners();
  // }

  openCashDrawer(BuildContext context) async {
    if (currentPrinterSettings.modelName != null) {
      bool isconnected = await connectToPrinter(
        currentPrinterSettings.modelName!,
      );
      if (isconnected) {
        _iPrinterRepository.openCashDrawer(currentPrinterSettings);
      } else {
        if (context.mounted) {
          ToastUtils.showToast(
            type: RequestState.error,
            message: S.of(context).checkPrinterConnectionStatus,
          );
        }
      }
    }
  }

  Future printReceipt(List<int> value, {bool? isForPay}) async {
    if (currentPrinterSettings.modelName == null) {
      if (isForPay == null) {
        ToastUtils.showToast(
          type: RequestState.error,
          message: "No printer configured. Please select a printer first.",
        );
      }
      return;
    }

    await connectToPrinter(currentPrinterSettings.modelName!).then((
      isconnected,
    ) async {
      if (isconnected) {
        await _iPrinterRepository.printReceipt(value);
      } else {
        if (isForPay == null) {
          ToastUtils.showToast(
            type: RequestState.error,
            message: "you are not connected to the printer, try again later",
          );
        }
      }
    });
  }

  Future printReceiptByNetwork(
    List<int> value,
    BuildContext context,
    SectionPrinterModel printer,
  ) async {
    print("printer called ${printer.printerName}");
    bool isconnected = await connectToPrinterByNetwork(printer.printerName);
    if (isconnected) {
      await _iPrinterRepository.printReceipt(value);
    }
  }

  Future buildReceiptTicket({
    required List<Uint8List> images,
    required double originalTotalForeign,
    required double totalForeign,
    required double dolarRate,
    bool? dontOpenCash,
    int? receiptNumber,
    String? tableNumber,
    int? invoiceNumber,
    CustomerModel? customerModel,
    bool? isHasDiscount,
    bool? isQuotaion,
    String? receiptDate,
    String? receiptDiscount,
  }) async {
    if (currentPrinterSettings.modelName == null) {
      debugPrint('Cannot build receipt: No printer configured');
      return;
    }

    bool connected = await connectToPrinter(currentPrinterSettings.modelName!);
    if (connected) {
      await _iPrinterRepository
          .buildReceiptTicket(
            receiptDate: receiptDate,
            dontOpenCash: dontOpenCash,
            images: images,
            originalTotalForeign: originalTotalForeign,
            totalForeign: totalForeign,
            dolarRate: dolarRate,
            receiptNumber: tableNumber ?? (receiptNumber?.toString()),
            tableNumber: tableNumber,
            invoiceNumber: invoiceNumber,
            printReceiptInLebanon: isPrintReceiptInLebanon,
            printReceiptInDolar: isPrintReceiptInDolar,
            customerModel: customerModel,
            isHasDiscount: isHasDiscount,
            isQuotaion: isQuotaion,
          )
          .then((value) {
            printReceipt(value);
          });
    }
  }

  Future buildRestaurantStockReceiptTicket({
    required List<Uint8List> images,
  }) async {
    if (currentPrinterSettings.modelName == null) {
      debugPrint(
        'Cannot build restaurant stock receipt: No printer configured',
      );
      return;
    }

    bool connected = await connectToPrinter(currentPrinterSettings.modelName!);
    if (connected) {
      await _iPrinterRepository.buildRestaurantStockTicket(images: images).then(
        (value) {
          printReceipt(value);
        },
      );
    }
  }

  Future<List<int>> buildOrderTicket({
    required List<Uint8List> images,
    required int receiptNumber,
    required String tableNumber,
    required String orderedBy,
    required SectionPrinterModel printer,
  }) async {
    bool connected = await connectToPrinterByNetwork(
      printer.printerName.toString(),
    );
    if (connected) {
      return await _iPrinterRepository.buildOrderTicket(
        selectedSize,
        images,
        receiptNumber,
        tableNumber,
        orderedBy,
      );
    }
    return [];
  }

  Future<List<int>> buildLabelTicket({
    required ProductModel productModel,
  }) async {
    final labelService = PrinterLabelService(currentLabelSize);
    return await labelService.buildLabel(productModel: productModel);
  }

  Future<List<int>> buildEndOfDayTicket(EndOfDayModel endOfDayModel) async {
    return await _iPrinterRepository.buildEndOfDayTicket(
      selectedSize,
      endOfDayModel,
    );
  }

  void onchangePrintingStatus() {
    isprintReceipt = !isprintReceipt;
    currentPrinterSettings.isprintReceipt = isprintReceipt;
    notifyListeners();
  }

  void onchangeVisibilityNetworkPrinter() {
    isHasNetworkPrinter = !isHasNetworkPrinter;
    currentPrinterSettings.isHasNetworkPrinter = isHasNetworkPrinter;
    notifyListeners();
  }

  PrinterModel currentPrinterSettings = PrinterModel(isprintReceipt: false);

  RequestState getPrinterSettingsRequestState = RequestState.success;
  Future _getCurrentPrinterSettings() async {
    getPrinterSettingsRequestState = RequestState.loading;
    notifyListeners();
    final String? printerName = _ref
        .read(appPreferencesProvider)
        .getData(key: "printerName");

    await _iPrinterRepository
        .getCurrentPrinterSettings()
        .then((value) {
          if (value != null) {
            isHasNetworkPrinter = value.isHasNetworkPrinter!;
            currentPrinterSettings = value;
            currentPrinterSettings.modelName = printerName;
            if (printerName != null && printerName.trim() != "") {
              connectToPrinter(currentPrinterSettings.modelName.toString());
            }

            isprintReceipt = currentPrinterSettings.isprintReceipt!;
            selectedSize = currentPrinterSettings.pageSize == "mm58"
                ? PageSize.mm58
                : PageSize.mm80;
            pageSizeController.text = selectedSize.toString();
          }

          getPrinterSettingsRequestState = RequestState.success;
          notifyListeners();
        })
        .catchError((error) {
          debugPrint(error.toString());
          requestState = RequestState.error;
          statusMessage = error.toString();
          notifyListeners();
        });
  }

  //! update category
  RequestState requestState = RequestState.success;
  String statusMessage = "";
  Future<PrinterModel> updatePrinter(
    PrinterModel p,
    BuildContext context,
  ) async {
    try {
      var res = await _iPrinterRepository.updateCurrentPrinterSettings(p);
      currentPrinterSettings = res;
      _ref
          .read(appPreferencesProvider)
          .saveData(key: "printerName", value: p.modelName);
      ToastUtils.showToast(
        message: "Printer Updated Successfully",
        type: RequestState.success,
      );
    } catch (e) {
      ToastUtils.showToast(message: e.toString(), type: RequestState.error);
    }
    return currentPrinterSettings;
  }

  Future<PrinterModel> addPrinter(PrinterModel p, BuildContext context) async {
    try {
      var res = await _iPrinterRepository.addPrinterSettings(p);

      currentPrinterSettings = res;
      _ref
          .read(appPreferencesProvider)
          .saveData(key: "printerName", value: p.modelName);
      ToastUtils.showToast(
        message: "Printer Added Successfully",
        type: RequestState.success,
      );
    } catch (e) {
      ToastUtils.showToast(message: e.toString(), type: RequestState.error);
    }
    return currentPrinterSettings;
  }

  bool isPrintBasketInDolar = false;
  bool isPrintLabelOnLabelPrinter = true;
  bool printStoreNameOnLabel = true;
  togglePrintBasketInDolar() {
    isPrintBasketInDolar = !isPrintBasketInDolar;
    _ref
        .read(appPreferencesProvider)
        .saveData(key: "isPrintBasketInDolar", value: isPrintBasketInDolar);
    notifyListeners();
  }

  LabelSize currentLabelSize = LabelSize.normal;

  toggleLabelSize(LabelSize size) {
    currentLabelSize = size;
    _ref
        .read(appPreferencesProvider)
        .saveData(key: "labelSize", value: currentLabelSize.name);
    notifyListeners();
  }

  togglePrintStoreNameOnLabel() {
    printStoreNameOnLabel = !printStoreNameOnLabel;
    _ref
        .read(appPreferencesProvider)
        .saveData(key: "printStoreNameOnLabel", value: printStoreNameOnLabel);
    notifyListeners();
  }

  togglePrintLabelOnInvoice() {
    isPrintLabelOnLabelPrinter = !isPrintLabelOnLabelPrinter;
    _ref
        .read(appPreferencesProvider)
        .saveData(
          key: "isPrintLabelOnLabelPrinter",
          value: isPrintLabelOnLabelPrinter,
        );
    notifyListeners();
  }

  bool isPrintReceiptInDolar = false;
  togglePrintReceiptInDolar() {
    isPrintReceiptInDolar = !isPrintReceiptInDolar;
    _ref
        .read(appPreferencesProvider)
        .saveData(key: "isPrintReceiptInDolar", value: isPrintReceiptInDolar);
    notifyListeners();
  }

  bool showOpenCashButton = true;
  onChangeButtonCashVisibility() {
    showOpenCashButton = !showOpenCashButton;
    _ref
        .read(appPreferencesProvider)
        .saveData(key: "showOpenCashButton", value: showOpenCashButton);
    notifyListeners();
  }

  bool openCashDialogOnPay = false;
  onChangeOpenCashDialog() {
    openCashDialogOnPay = !openCashDialogOnPay;
    _ref
        .read(appPreferencesProvider)
        .saveData(key: "openCashDialogOnPay", value: openCashDialogOnPay);
    notifyListeners();
  }

  bool isPrintReceiptInLebanon = true;
  onchangePrintReceiptInLocal() {
    isPrintReceiptInLebanon = !isPrintReceiptInLebanon;
    _ref
        .read(appPreferencesProvider)
        .saveData(
          key: "isPrintReceiptInLebanon",
          value: isPrintReceiptInLebanon,
        );
    notifyListeners();
  }

  Future _fetchPrintingConfiguration() async {
    isPrintBasketInDolar = _ref
        .read(appPreferencesProvider)
        .getBool(key: "isPrintBasketInDolar");
    currentLabelSize = _ref
        .read(appPreferencesProvider)
        .getData(key: "labelSize")
        .toString()
        .toLabelSize();
    printStoreNameOnLabel = _ref
        .read(appPreferencesProvider)
        .getBool(key: "printStoreNameOnLabel");
    isPrintReceiptInDolar = _ref
        .read(appPreferencesProvider)
        .getBool(key: "isPrintReceiptInDolar");
    showOpenCashButton = _ref
        .read(appPreferencesProvider)
        .getBool(key: "showOpenCashButton");

    openCashDialogOnPay = _ref
        .read(appPreferencesProvider)
        .getBool(key: "openCashDialogOnPay", defaultValue: true);
    isPrintReceiptInLebanon = _ref
        .read(appPreferencesProvider)
        .getBool(key: "isPrintReceiptInLebanon", defaultValue: true);
    isPrintLabelOnLabelPrinter = _ref
        .read(appPreferencesProvider)
        .getBool(key: "isPrintLabelOnLabelPrinter", defaultValue: true);
    basketFontSize =
        _ref.read(appPreferencesProvider).getData(key: "basketFontSize") ?? 20;

    basketWidth =
        _ref.read(appPreferencesProvider).getData(key: "basketWidth") ?? 500;
  }

  // !  for print button

  // Future printOrder(
  //     int nbOfImage,
  //     List<ProductModel> basketItem,
  //     double dolarRate,
  //     Ref ref,
  //     BuildContext context,
  //     int receiptNumber,
  //     UserModel usermodel,
  //     SectionPrinterModel printer) async {
  //   buildReceiptImages(
  //           nbOfImage: nbOfImage,
  //           products: basketItem,
  //           dolarRate: dolarRate,
  //           context: context,
  //           typeOfPrint: TypeOfPrint.Order)
  //       .then((images) async {
  //     await ref
  //         .read(printerControllerProvider)
  //         .buildOrderTicket(
  //             images: images,
  //             receiptNumber: receiptNumber,
  //             tableNumber: '-',
  //             orderedBy: usermodel.name.toString(),
  //             printer: printer)
  //         .then((value) {
  //       //! send the bytes to the printer
  //       ref
  //           .read(printerControllerProvider)
  //           .printReceiptByNetwork(value, context, printer);
  //     });
  //   });
  // }

  RequestState makeOrderRequestState = RequestState.success;
  Future<void> makeOrder(BuildContext context) async {
    makeOrderRequestState = RequestState.loading;
    notifyListeners();
    var saleController = _ref.read(saleControllerProvider);
    try {
      if (saleController.discount == 0) {
        _ref.read(categoryControllerProvider).clearCategorySelection();
        //! print ticket
        //! check if printing is enable
        await Future.microtask(() async {
          if (isprintReceipt == true) {
            final receiptNumber = saleController.receiptNumber;
            final dolarRate = saleController.dolarRate;
            final products = saleController.basketItemsNew;

            if (products.isEmpty) {
              ToastUtils.showToast(
                message: "No items to order",
                type: RequestState.error,
              );
              return;
            }

            await printSectionOrders(
              context: context,
              receiptNumber: receiptNumber,
              dolarRate: dolarRate,
              products: products,
            );
          }
        });

        saleController.onIncreaseReceiptNumber(isQuickOrder: null);
        saleController.addBasketToTable();
        _ref.read(productControllerProvider).resetProductList();
      } // end if discount = 0;
      else {
        ToastUtils.showToast(
          message:
              "can't order with discount > 0 , remove new basket items then set discount to 0",
          type: RequestState.error,
        );
      }
      makeOrderRequestState = RequestState.success;
    } catch (e) {
      makeOrderRequestState = RequestState.error;
      ToastUtils.showToast(message: e.toString(), type: RequestState.error);
      notifyListeners();
    } finally {
      notifyListeners();
    }
  }

  // print end of shift
  RequestState printEndOfShiftRequest = RequestState.success;
  Future<void> printEndOfShift(
    BuildContext context, {
    bool? isPrintShift,
    bool? isForSelectedShift,
  }) async {
    printEndOfShiftRequest = RequestState.loading;
    notifyListeners();
    if (isPrintShift != true && !isprintReceipt) {
      printEndOfShiftRequest = RequestState.success;
      notifyListeners();
      return;
    }
    try {
      final shiftId = isForSelectedShift == true
          ? _ref.read(selectedShiftProvider).id!
          : _ref.read(currentShiftProvider).id!;
      final receiptController = _ref.read(receiptControllerProvider.notifier);
      List<ProductModel> sellingProducts = [];
      List<ProductModel> refundedProducts = [];
      List<ProductModel> StaffProducts = [];
      List<RestaurantStockUsageModel> stockUsage = [];
      List<RestaurantStockModel> stockItems = [];

      await Future.wait([
        // sales
        receiptController.getsellingProducts(shiftId: shiftId).then((value) {
          sellingProducts = value;
        }),
        // refund
        receiptController
            .getsellingProducts(shiftId: shiftId, isForReports: true)
            .then((value) {
              refundedProducts = value;
            }),
        // stuf
        receiptController
            .getsellingProducts(shiftId: shiftId, isForStaff: true)
            .then((value) {
              StaffProducts = value;
            }),
        // stock usage
        if (_ref.read(mainControllerProvider).isWorkWithIngredients &&
            _ref.read(mainControllerProvider).isSuperAdmin)
          _ref
              .read(receiptControllerProvider)
              .fetchStockUsageReport(
                view: null,
                shiftId: _ref.read(selectedShiftProvider).id!,
              )
              .then((value) {
                stockUsage = value;
              }),

        // restaurant stock
        if (_ref.read(mainControllerProvider).isWorkWithIngredients &&
            _ref.read(mainControllerProvider).isAdmin)
          _ref
              .read(receiptControllerProvider)
              .fetchAllStockItems(isForWarning: true)
              .then((value) {
                stockItems = value;
                stockItems.sort((a, b) {
                  // First, compare by unitType
                  int unitTypeComparison = a.unitType.name.compareTo(
                    b.unitType.name,
                  );

                  // If unitType is the same, then compare by qty
                  if (unitTypeComparison == 0) {
                    return b.qty.compareTo(
                      a.qty,
                    ); // Sort by qty in descending order
                  } else {
                    return unitTypeComparison; // Sort by unitType in ascending order
                  }
                });
              }),
      ]).then((value) async {
        final nbOfItems = sellingProducts.fold<double>(
          0,
          (sum, product) => sum + (product.countsAsItem ?? 0),
        );

        final nbOfImage = (sellingProducts.length / 20).ceil();
        if (nbOfImage > 0) {
          final images = await buildReceiptImages(
            staffProducts: StaffProducts,
            stockUsage: stockUsage,
            stockItems: stockItems,
            refundedProducts: refundedProducts,
            nbOfImage: nbOfImage,
            context: context,
            products: sellingProducts,
            typeOfPrint: TypeOfPrint.EndOfDay,
            dolarRate: _ref.read(saleControllerProvider).dolarRate,
          );
          final endOfShiftEmployeeModel = EndOfShiftEmployeeModel(
            shiftId: shiftId,
            employeeName: _ref.read(currentUserProvider)?.name ?? "User",
            startShiftDate: _ref
                .read(selectedShiftProvider)
                .startShiftDate
                .toString(),
            endShiftDate:
                _ref.read(selectedShiftProvider).endShiftDate ??
                DateTime.now().toString(),
          );
          final AsyncValue<ReceiptTotals> totalsAsync = _ref.watch(
            futureReceiptTotalsByShiftProvider,
          );
          totalsAsync.when(
            data: (totals) {
              var endOfDayModel = EndOfDayModel(
                date: _ref
                    .read(salesSelectedDateProvider)
                    .toString()
                    .split(" ")
                    .first,
                nbCustomers: totals.totalInvoices,
                employeeName: _ref
                    .read(shiftSelectedUserProvider)
                    ?.name
                    .toString(),
                salesPrimary: totals.salesDolar,
                salesSecondary: totals.salesLebanon,
                totalPrimary:
                    totals.totalPrimaryBalance +
                    (totals.totalSecondaryBalance /
                            _ref.read(saleControllerProvider).dolarRate)
                        .formatDouble(),
                depositDolar: totals.totalDepositDolar,
                depositLebanese: totals.totalDepositLebanon,
                withdrawDolar: totals.totalWithdrawDolar,
                withdrawLebanese: totals.totalWithdrawLebanon,
                withdrawDolarFromCash: totals.totalWithdrawDolarFromCash,
                withdrawLebaneseFromCash: totals.totalWithdrawLebanonFromCash,
                totalPendingAmount: totals.totalPendingAmount,
                totalPendingReceipts: totals.totalPendingReceipts,
                totalCollectedPending: totals.totalCollectedPending,
                totalRefunds: totals.totalRefunds,
                totalPurchasesPrimary: totals.totalPurchasesPrimary,
                totalPurchasesSecondary: totals.totalPurchasesSecondary,
                imageData: images,
                expenses: _ref.read(receiptControllerProvider).expensesByShift,
                endOfShiftEmployeeModel: endOfShiftEmployeeModel,
                totalSubscriptions:
                    _ref.read(mainControllerProvider).subscriptionActivated
                    ? totals.totalSubscriptions
                    : null,
              );

              buildEndOfDayTicket(endOfDayModel).then((ticket) {
                if (isPrintShift == true || isprintReceipt) {
                  printReceipt(ticket);
                } else {
                  ToastUtils.showToast(
                    message: S.of(context).checkPrinterConnectionStatus,
                    type: RequestState.loading,
                  );
                }
              });
            },
            error: (error, stackTrace) {},
            loading: () {},
          );
        }
      });

      printEndOfShiftRequest = RequestState.success;
    } catch (e) {
      printEndOfShiftRequest = RequestState.error;
      print(e.toString());
    } finally {
      notifyListeners();
    }
  }

  RequestState printEndOfDayRequest = RequestState.success;
  Future<void> printEndOfDay(
    BuildContext context, {
    bool? isPrintShift,
    bool? isForSelectedShift,
    bool? isForDailySales,
  }) async {
    printEndOfDayRequest = RequestState.loading;
    notifyListeners();

    var receiptController = _ref.read(receiptControllerProvider);
    List<ProductModel> sellingProducts = [];
    List<ProductModel> refundedProducts = [];
    List<ProductModel> staffProducts = [];
    List<RestaurantStockUsageModel> stockUsage = [];
    List<RestaurantStockModel> stockItems = [];
    try {
      await Future.wait<void>([
        // sales
        receiptController.getsellingProducts().then((value) {
          sellingProducts = value;
        }),
        // refund
        receiptController.getsellingProducts(isForReports: true).then((value) {
          refundedProducts = value;
        }),
        // stuf
        receiptController.getsellingProducts(isForStaff: true).then((value) {
          staffProducts = value;
        }),
        // stock usage
        if (_ref.read(mainControllerProvider).isWorkWithIngredients &&
            _ref.read(mainControllerProvider).isSuperAdmin)
          _ref
              .read(receiptControllerProvider)
              .fetchStockUsageReport(
                view: ReportInterval.daily,
                date: _ref
                    .read(salesSelectedDateProvider)
                    .toString()
                    .split(" ")
                    .first,
              )
              .then((value) {
                stockUsage = value;
              }),

        // restaurant stock
        if (_ref.read(mainControllerProvider).isWorkWithIngredients &&
            _ref.read(mainControllerProvider).isAdmin)
          _ref
              .read(receiptControllerProvider)
              .fetchAllStockItems(isForWarning: true)
              .then((value) {
                stockItems = value;
                stockItems.sort((a, b) {
                  // First, compare by unitType
                  int unitTypeComparison = a.unitType.name.compareTo(
                    b.unitType.name,
                  );

                  // If unitType is the same, then compare by qty
                  if (unitTypeComparison == 0) {
                    return b.qty.compareTo(
                      a.qty,
                    ); // Sort by qty in descending order
                  } else {
                    return unitTypeComparison; // Sort by unitType in ascending order
                  }
                });
              }),
      ]).then((value) async {
        final nbOfImage = (sellingProducts.length / 20).ceil();

        if (nbOfImage > 0) {
          final images = await buildReceiptImages(
            staffProducts: staffProducts,
            stockUsage: stockUsage,
            stockItems: stockItems,
            refundedProducts: refundedProducts,
            nbOfImage: nbOfImage,
            context: context,
            products: sellingProducts,
            typeOfPrint: TypeOfPrint.EndOfDay,
            dolarRate: _ref.read(saleControllerProvider).dolarRate,
          );
          final AsyncValue<ReceiptTotals> totalsAsync = _ref.watch(
            futureReceiptTotalsProvider,
          );
          totalsAsync.when(
            data: (totals) {
              var endOfDayModel = EndOfDayModel(
                date: _ref
                    .read(salesSelectedDateProvider)
                    .toString()
                    .split(" ")
                    .first,
                employeeName: _ref.read(salesSelectedUser)?.name,
                nbCustomers: totals.totalInvoices,
                salesPrimary: totals.salesDolar,
                salesSecondary: totals.salesLebanon,
                totalPrimary:
                    totals.totalPrimaryBalance +
                    (totals.totalSecondaryBalance /
                            _ref.read(saleControllerProvider).dolarRate)
                        .formatDouble(),
                depositDolar: totals.totalDepositDolar,
                depositLebanese: totals.totalDepositLebanon,
                withdrawDolar: totals.totalWithdrawDolar,
                withdrawLebanese: totals.totalWithdrawLebanon,
                withdrawDolarFromCash: totals.totalWithdrawDolarFromCash,
                withdrawLebaneseFromCash: totals.totalWithdrawLebanonFromCash,
                totalPendingAmount: totals.totalPendingAmount,
                totalPendingReceipts: totals.totalPendingReceipts,
                totalCollectedPending: totals.totalCollectedPending,
                totalRefunds: totals.totalRefunds,
                totalPurchasesPrimary: totals.totalPurchasesPrimary,
                totalPurchasesSecondary: totals.totalPurchasesSecondary,
                imageData: images,
                endOfShiftEmployeeModel: null,
                totalSubscriptions:
                    _ref.read(mainControllerProvider).subscriptionActivated
                    ? totals.totalSubscriptions
                    : null,
              );
              buildEndOfDayTicket(endOfDayModel).then((ticket) {
                printReceipt(ticket);
              });
            },
            error: (error, stackTrace) {},
            loading: () {},
          );
        }
      });

      printEndOfDayRequest = RequestState.success;
    } catch (e) {
      printEndOfDayRequest = RequestState.error;
    } finally {
      notifyListeners();
    }
  }

  RequestState printTableRequestState = RequestState.success;
  Future printTableReceipt({required BuildContext context}) async {
    try {
      printTableRequestState = RequestState.loading;
      notifyListeners();
      double originalTotalForeign = _ref
          .read(saleControllerProvider)
          .originalForeignPrice;
      double totalForeign = _ref.read(saleControllerProvider).foreignTotalPrice;

      var nbOfImage =
          (_ref.read(saleControllerProvider).basketItems.length / 20).ceil();
      var dolarRate = _ref.read(saleControllerProvider).dolarRate;

      // ! not refereced directly to basketitem cz after groupping the qty of basket will affetced
      List<ProductModel> basketItem = _ref
          .read(saleControllerProvider)
          .basketItems;

      await buildReceiptImages(
        nbOfImage: nbOfImage,
        products: basketItem,
        dolarRate: dolarRate,
        context: context,
        typeOfPrint: TypeOfPrint.Receipt,
      ).then((images) async {
        await buildReceiptTicket(
          images: images,
          receiptNumber: null,
          tableNumber: _ref
              .read(saleControllerProvider)
              .selectedTable
              ?.tableName,
          originalTotalForeign: originalTotalForeign,
          totalForeign: totalForeign,
          dolarRate: dolarRate,
          invoiceNumber: null,
        );
      });
      printTableRequestState = RequestState.success;
      notifyListeners();
    } catch (e) {
      printTableRequestState = RequestState.success;
      notifyListeners();
    }
  }

  RequestState generateAndPrintRequestState = RequestState.success;
  Future generateAndPrintReceipt({
    required int nbOfImage,
    bool? dontOpenCash,
    required List<ProductModel> products,
    required double dolarRate,
    required BuildContext context, // for screenshoot
    required TypeOfPrint typeOfPrint,
    required double originalTotalForeign,
    required double totalForeign,
    int? receiptNumber,
    int? invoiceNumber,
    CustomerModel? customerModel,
    bool? isQuotation,
    //! used to print old receipts
    String? receiptDate,
  }) async {
    generateAndPrintRequestState = RequestState.loading;
    notifyListeners();
    try {
      final isHasDiscount = products.any(
        (element) => (element.discount ?? 0) > 0,
      );
      final allProductSameDiscount = products.every(
        (element) =>
            (element.discount ?? 0) > 0 &&
            element.discount == products[0].discount,
      );
      await buildReceiptImages(
        isQuotation: isQuotation,
        nbOfImage: nbOfImage,
        products: products,
        dolarRate: dolarRate,
        context: context,
        typeOfPrint: typeOfPrint,
      ).then((images) async {
        await buildReceiptTicket(
          receiptDiscount: allProductSameDiscount
              ? "${products[0].discount!.toInt()}% (${(originalTotalForeign - totalForeign).formatDouble()}${AppConstance.primaryCurrency.currencyLocalization()})"
              : null,
          receiptDate: receiptDate,
          isHasDiscount: isHasDiscount,
          dontOpenCash: dontOpenCash,
          images: images,
          receiptNumber: receiptNumber,
          tableNumber: _ref
              .read(saleControllerProvider)
              .selectedTable
              ?.tableName,
          originalTotalForeign: originalTotalForeign,
          totalForeign: totalForeign,
          dolarRate: dolarRate,
          invoiceNumber: invoiceNumber,
          customerModel: customerModel,
          isQuotaion: isQuotation,
        );
      });
      generateAndPrintRequestState = RequestState.success;
      notifyListeners();
    } catch (e) {
      generateAndPrintRequestState = RequestState.error;
      notifyListeners();
    }
  }

  RequestState printRestaurantStockRequestState = RequestState.success;
  Future generateAndPrintRestaurantStock(BuildContext context) async {
    printRestaurantStockRequestState = RequestState.loading;
    notifyListeners();
    try {
      await _ref.read(receiptControllerProvider).fetchAllStockItems().then((
        stockItems,
      ) async {
        stockItems.sort((a, b) {
          // First, compare by unitType
          int unitTypeComparison = a.unitType.name.compareTo(b.unitType.name);

          // If unitType is the same, then compare by qty
          if (unitTypeComparison == 0) {
            return b.qty.compareTo(a.qty); // Sort by qty in descending order
          } else {
            return unitTypeComparison; // Sort by unitType in ascending order
          }
        });

        await buildRestaurantStockReceiptImages(stockItems, context).then((
          images,
        ) async {
          await buildRestaurantStockReceiptTicket(images: images);
        });
        printRestaurantStockRequestState = RequestState.success;
        notifyListeners();
      });
    } catch (e) {
      printRestaurantStockRequestState = RequestState.error;
      notifyListeners();
    }
  }

  Future buildRestaurantStockReceiptImages(
    List<RestaurantStockModel> stockItems,
    BuildContext context,
  ) async {
    ScreenshotController screenshotController = ScreenshotController();
    List<Uint8List> images = [];

    int itemsPerPage = 20;
    int nbOfImage = (stockItems.length / itemsPerPage).ceil();

    // Create a list of containers for each page
    List<Widget> containers = [
      buildSectionHeader("Restauarant Stock"),
      ...List.generate(nbOfImage, (index) {
        return buildRestaurantStockContainerToImage(
          stockItems.skip(index * itemsPerPage).take(itemsPerPage).toList(),
        );
      }),
    ];

    // Capture screenshots for each container
    for (var container in containers) {
      Uint8List image = await screenshotController.captureFromWidget(
        InheritedTheme.captureAll(context, Material(child: container)),
      );
      images.add(image);
    }
    return images;
  }

  Future<List<Uint8List>> buildReceiptImages({
    bool? isQuotation,
    required int nbOfImage,
    List<ProductModel>? refundedProducts,
    List<ProductModel>? staffProducts,
    List<RestaurantStockUsageModel>? stockUsage,
    List<RestaurantStockModel>? stockItems,
    required List<ProductModel> products,
    required double dolarRate,
    required BuildContext context, // for screenshoot

    required TypeOfPrint typeOfPrint,
  }) async {
    ScreenshotController screenshotController = ScreenshotController();
    List<Uint8List> images = [];
    int itemsPerPage = 20;
    List<Widget> containers = [];

    switch (typeOfPrint) {
      case TypeOfPrint.Order:
        containers = List.generate(nbOfImage, (index) {
          return buildOrderContainerToImage(
            products.skip(index * itemsPerPage).take(itemsPerPage).toList(),
          );
        });

        break;
      case TypeOfPrint.Receipt:
        containers = [
          buildBasketHedearToContainer(),
          ...List.generate(nbOfImage, (index) {
            return buildReceiptContainerToImage(
              products.skip(index * itemsPerPage).take(itemsPerPage).toList(),
              dolarRate,
              isQuotation: isQuotation,
            );
          }),
        ];

        break;
      case TypeOfPrint.EndOfDay:
        containers = [
          buildSectionHeader("Sales"),
          ...List.generate(nbOfImage, (index) {
            return buildEndOfDayContainerToImage(
              products.skip(index * itemsPerPage).take(itemsPerPage).toList(),
            );
          }),
        ];

        if (refundedProducts != null && refundedProducts.isNotEmpty) {
          int nbOfrefundedImages = (refundedProducts.length / 20).ceil();
          containers.addAll([
            buildSectionHeader("Refunded"),
            ...List.generate(nbOfrefundedImages, (index) {
              return buildRefundOrStaffContainerToImnage(
                refundedProducts
                    .skip(index * itemsPerPage)
                    .take(itemsPerPage)
                    .toList(),
              );
            }),
          ]);
        }
        if (staffProducts != null && staffProducts.isNotEmpty) {
          int nbOfStufImages = (staffProducts.length / 20).ceil();

          containers.addAll([
            buildSectionHeader("Staff"),
            ...List.generate(nbOfStufImages, (index) {
              return buildRefundOrStaffContainerToImnage(
                staffProducts
                    .skip(index * itemsPerPage)
                    .take(itemsPerPage)
                    .toList(),
              );
            }),
          ]);
        }
        if (stockUsage != null && stockUsage.isNotEmpty) {
          int nbofStockUsage = (stockUsage.length / 20).ceil();
          double totalCost = 0;
          for (var element in stockUsage) {
            totalCost += element.totalPrice!;
          }
          containers.addAll([
            buildSectionHeader(
              "Sales Stock Item (${totalCost.formatDouble()} ${AppConstance.primaryCurrency})",
            ),
            ...List.generate(nbofStockUsage, (index) {
              return buildStockUsageContainerToImnage(
                stockUsage
                    .skip(index * itemsPerPage)
                    .take(itemsPerPage)
                    .toList(),
              );
            }),
          ]);
        }

        if (stockItems != null && stockItems.isNotEmpty) {
          int nbofStockItems = (stockItems.length / 20).ceil();

          containers.addAll([
            buildSectionHeader("Warning Restaurant Stock"),
            ...List.generate(nbofStockItems, (index) {
              return buildRestaurantStockContainerToImage(
                stockItems
                    .skip(index * itemsPerPage)
                    .take(itemsPerPage)
                    .toList(),
              );
            }),
          ]);
        }

        break;
    }
    await Future.wait(
      containers.map((container) async {
        Uint8List image = await screenshotController.captureFromWidget(
          InheritedTheme.captureAll(context, Material(child: container)),
        );
        images.add(image);
      }),
    );

    return images;
  }

  buildReceiptContainerToImage(
    List<ProductModel> products,
    double dolarRate, {
    bool? isQuotation,
  }) {
    List<ProductModel> generatedProductList = [];
    var groupedByProductId = groupBy(products, (obj) => obj.id);
    groupedByProductId.forEach((key, value) {
      double qty = 0;
      for (var element in value) {
        qty += element.qty!;
      }
      value[0].qty = qty;
      generatedProductList.add(value[0]);
    });
    final allProductSameDiscount = generatedProductList.every(
      (element) =>
          (element.discount ?? 0) > 0 &&
          element.discount == generatedProductList[0].discount,
    );
    return Container(
      padding: kPaddH5,
      decoration: const BoxDecoration(color: Colors.white),
      // color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // !if lenght < 8  no need to set hedear data outside the image

          //! items
          SizedBox(
            width: basketWidth,
            child: Column(
              children: [
                ...generatedProductList.map((e) {
                  double totalOriginalPrice =
                      double.parse(e.qty.toString()) *
                      double.parse(
                        "${e.originalSellingPrice!.formatDoubleWith6()}",
                      );
                  if (e.discount! < 0) {
                    totalOriginalPrice =
                        totalOriginalPrice -
                        (totalOriginalPrice * e.discount! / 100);
                  }

                  double totalSellingPrice = e.qty! * e.sellingPrice!;

                  return Row(
                    children: [
                      Expanded(
                        flex: 5,
                        child: DefaultTextViewForPrinting(
                          maxlines: 1,
                          text:
                              "- ${e.name}  ${e.discount! > 0 && !allProductSameDiscount ? ' /${e.discount!.toInt()}%' : ''}",

                          // maxlines: 1,
                          textAlign: TextAlign.left,
                          fontWeight: FontWeight.bold,
                          overflow: TextOverflow.ellipsis,
                          fontsize: basketFontSize,
                        ),
                      ),
                      Expanded(
                        child: DefaultTextViewForPrinting(
                          text: "${e.qty}",
                          textAlign: TextAlign.center,
                          fontWeight: FontWeight.w700,
                          fontsize: basketFontSize,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: RichText(
                          text: TextSpan(
                            children: [
                              if (isQuotation != true && e.discount != 100)
                                TextSpan(
                                  text:
                                      "${isPrintBasketInDolar == true ? totalOriginalPrice.formatDouble() : (totalOriginalPrice * dolarRate).round()}",
                                  style: TextStyle(
                                    color: Pallete.blackColor,
                                    fontSize: basketFontSize,
                                    fontWeight:
                                        isPrintBasketInDolar == true &&
                                            e.discount! > 0
                                        ? FontWeight.w400
                                        : FontWeight.w700,
                                    decoration:
                                        isPrintBasketInDolar == true &&
                                            e.discount! > 0
                                        ? TextDecoration.lineThrough
                                        : TextDecoration.none,
                                  ),
                                ),
                              if (isPrintBasketInDolar == true &&
                                  e.discount! > 0)
                                TextSpan(
                                  text:
                                      ' ${totalSellingPrice > 0 ? totalSellingPrice.formatDouble() : totalSellingPrice}',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: basketFontSize,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  buildBasketHedearToContainer() {
    return Container(
      width: basketWidth,
      decoration: const BoxDecoration(color: Colors.white),
      child: SizedBox(
        width: 530,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 5,
                  child: DefaultTextViewForPrinting(
                    text: "Item",
                    textAlign: TextAlign.left,
                    fontWeight: FontWeight.bold,
                    overflow: TextOverflow.ellipsis,
                    fontsize: basketFontSize,
                  ),
                ),
                Expanded(
                  child: DefaultTextViewForPrinting(
                    textAlign: TextAlign.center,
                    text: "Qty",
                    fontWeight: FontWeight.bold,
                    fontsize: basketFontSize,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: DefaultTextViewForPrinting(
                    textAlign: TextAlign.center,
                    fontWeight: FontWeight.bold,
                    text: "Total",
                    fontsize: basketFontSize,
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.black),
          ],
        ),
      ),
    );
  }

  buildSectionHeader(String title) {
    return DefaultTextViewForPrinting(
      textDecoration: TextDecoration.underline,
      text: "$title :",
      fontsize: basketFontSize + 6,
      fontWeight: FontWeight.bold,
    );
  }

  buildRefundOrStaffContainerToImnage(List<ProductModel> refundedProducts) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      // color: Colors.white,
      child: Column(
        crossAxisAlignment: .start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ...refundedProducts.map(
            (e) => SizedBox(
              width: basketWidth,
              child: Row(
                children: [
                  DefaultTextViewForPrinting(
                    text: " ${e.name} : ",
                    textAlign: TextAlign.left,
                    fontsize: basketFontSize - 1,
                    fontWeight: FontWeight.bold,
                    maxlines: 2,
                  ),
                  Text(
                    " ${e.qty} ",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: basketFontSize - 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  buildStockUsageContainerToImnage(List<RestaurantStockUsageModel> stockUsage) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      // color: Colors.white,
      child: Column(
        crossAxisAlignment: .start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ...stockUsage.map(
            (e) => SizedBox(
              width: basketWidth,
              child: Row(
                children: [
                  DefaultTextViewForPrinting(
                    text: " ${e.name} : ",
                    textAlign: TextAlign.left,
                    fontsize: basketFontSize - 1,
                    fontWeight: FontWeight.bold,
                    maxlines: 2,
                  ),
                  Text(
                    " ${e.unitType == UnitType.kg ? '${e.qtyAsKilo.formatDouble()} kg' : '${e.qtyAsPortion.formatDouble()} po'} ",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: basketFontSize - 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  buildRestaurantStockItemsContainerToImnage(
    List<RestaurantStockModel> stockModels,
  ) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      // color: Colors.white,
      child: Column(
        crossAxisAlignment: .start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ...stockModels.map(
            (e) => SizedBox(
              width: basketWidth,
              child: Row(
                children: [
                  DefaultTextViewForPrinting(
                    text: " ${e.name} : ",
                    textAlign: TextAlign.left,
                    fontsize: basketFontSize - 1,
                    fontWeight: FontWeight.bold,
                    maxlines: 2,
                  ),
                  Text(
                    " '${e.qty.formatDouble()} ${e.unitType == UnitType.kg ? 'kg' : 'po'}",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: basketFontSize - 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  buildRestaurantStockContainerToImage(List<RestaurantStockModel> stocks) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      // color: Colors.white,
      child: Column(
        crossAxisAlignment: .start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ...stocks.map(
            (e) => SizedBox(
              width: basketWidth,
              child: Row(
                children: [
                  DefaultTextViewForPrinting(
                    text:
                        "${e.qty <= e.warningAlert! ? '**' : ''} ${e.name}  => ",
                    textAlign: TextAlign.left,
                    fontsize: basketFontSize - 1,
                    fontWeight: FontWeight.bold,
                    maxlines: 2,
                  ),
                  DefaultTextViewForPrinting(
                    text: "${e.qty} ${e.unitType == UnitType.kg ? 'kg' : 'po'}",
                    textAlign: TextAlign.left,
                    fontsize: basketFontSize - 1,
                    fontWeight: FontWeight.bold,
                    maxlines: 2,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  buildEndOfDayContainerToImage(
    List<ProductModel> products, {
    bool? isPrintSalesHeader,
  }) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      // color: Colors.white,
      child: Column(
        crossAxisAlignment: .start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isPrintSalesHeader == true)
            DefaultTextViewForPrinting(
              textDecoration: TextDecoration.underline,
              text: "Sales :",
              fontsize: basketFontSize + 6,
              fontWeight: FontWeight.bold,
            ),
          ...products.map(
            (e) => SizedBox(
              width: basketWidth,
              child: Row(
                children: [
                  DefaultTextViewForPrinting(
                    text: " ${e.name} : ",
                    textAlign: TextAlign.left,
                    fontsize: basketFontSize - 1,
                    fontWeight: FontWeight.bold,
                    maxlines: 2,
                  ),
                  Text(
                    " ${e.qty} ",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: basketFontSize - 1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  buildOrderContainerToImage(List<ProductModel> products) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      // color: Colors.white,
      child: Column(
        crossAxisAlignment: .start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          ...products.map(
            (e) => SizedBox(
              width: basketWidth,
              child: Column(
                crossAxisAlignment: .start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: DefaultTextViewForPrinting(
                          maxlines: 2,
                          text: "- ${e.name} ",
                          textAlign: TextAlign.left,
                          fontsize: basketFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: DefaultTextViewForPrinting(
                          text: " ${e.qty} ",
                          fontWeight: FontWeight.w700,
                          textAlign: TextAlign.left,
                          fontsize: basketFontSize,
                        ),
                      ),
                    ],
                  ),
                  ...e.withoutIngredients!.map(
                    (e) => Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: DefaultTextViewForPrinting(
                        fontWeight: FontWeight.bold,
                        text: "  *without  ${e.name.toString()}",
                        fontsize: basketFontSize - 4,
                      ),
                    ),
                  ),
                  if (e.notes.isNotEmpty)
                    DefaultTextViewForPrinting(
                      fontWeight: FontWeight.bold,
                      text: "  *Note: ${e.notes}",
                      fontsize: basketFontSize - 4,
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<SectionType, List<ProductModel>> groupProductsBySection(
    List<ProductModel> products,
  ) {
    final groupedProducts = <SectionType, List<ProductModel>>{};

    for (final product in products) {
      groupedProducts.putIfAbsent(product.sectionType!, () => []).add(product);
    }
    return groupedProducts;
  }

  Future<void> printSectionOrders({
    required BuildContext context,
    required int receiptNumber,
    required double dolarRate,
    required List<ProductModel> products,
  }) async {
    // Group products by section
    final groupedProducts = groupProductsBySection(products);
    // Track printing success
    String? lastErrorMessage;

    // Print each section separately
    for (final entry in groupedProducts.entries) {
      final section = entry.key;
      final sectionProducts = entry.value;

      final printer = sectionsPrinters.firstWhereOrNull(
        (p) => p.sectionType == section,
      );
      if (printer == null) {
        debugPrint('No printer configured for $section');
        lastErrorMessage = 'No printer configured for ${section.name}';
        continue;
      }

      try {
        // Calculate number of images needed for this section
        final nbOfImage = (sectionProducts.length / 20).ceil();

        if (nbOfImage > 0) {
          // Build images for this section
          final images = await buildReceiptImages(
            nbOfImage: nbOfImage,
            products: sectionProducts,
            dolarRate: dolarRate,
            context: context,
            typeOfPrint: TypeOfPrint.Order,
          );

          // Build ticket for this section
          final ticketBytes = await buildOrderTicket(
            images: images,
            receiptNumber: receiptNumber,
            tableNumber:
                _ref.read(saleControllerProvider).selectedTable?.tableName ??
                '',
            orderedBy:
                _ref.read(currentUserProvider)?.name.toString() ?? "User",
            printer: printer,
          );

          printReceiptByNetwork(ticketBytes, context, printer);
        }
      } catch (e) {
        debugPrint('Error printing $section: $e');
        lastErrorMessage =
            'Failed to print ${section.name} order: ${e.toString()}';
      }
    }
  }
}
