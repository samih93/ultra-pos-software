// ignore_for_file: unused_result

import 'dart:async';

import 'package:desktoppossystem/controller/auth_controller.dart';
import 'package:desktoppossystem/controller/category_controller.dart';
import 'package:desktoppossystem/controller/printer_controller.dart';
import 'package:desktoppossystem/controller/product_controller.dart';
import 'package:desktoppossystem/models/details_ingredients_receipt.dart';
import 'package:desktoppossystem/models/details_receipt.dart';
import 'package:desktoppossystem/models/expense_model.dart';
import 'package:desktoppossystem/models/financial_transaction_model.dart';
import 'package:desktoppossystem/models/product_model.dart';
import 'package:desktoppossystem/models/receipt_model.dart';
import 'package:desktoppossystem/models/reports/restaurant_stock_usage_model.dart';
import 'package:desktoppossystem/models/restaurant_stock_model.dart';
import 'package:desktoppossystem/models/role_model.dart';
import 'package:desktoppossystem/models/shift_model.dart';
import 'package:desktoppossystem/models/user_model.dart';
import 'package:desktoppossystem/repositories/financial_transaction.dart/financial_transaction_repository.dart';
import 'package:desktoppossystem/repositories/products/iproduct_repository.dart';
import 'package:desktoppossystem/repositories/products/product_repository.dart';
import 'package:desktoppossystem/repositories/receipts/ireceiptrepository.dart';
import 'package:desktoppossystem/repositories/receipts/receiptrepository.dart';
import 'package:desktoppossystem/repositories/restaurant_stock/restaurant_stock_repository.dart';
import 'package:desktoppossystem/repositories/users/user_reposiotry.dart';
import 'package:desktoppossystem/screens/daily%20sales/daily_financial_screen.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/screens/notifications_screen/notification_controller.dart';
import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
import 'package:desktoppossystem/screens/shift_screen/shift_screen.dart';
import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/services/deliver_service.dart';
import 'package:desktoppossystem/shared/services/dependency_injection.dart';
import 'package:desktoppossystem/shared/services/telegram/bot_notification.dart';
import 'package:desktoppossystem/shared/services/telegram/telegram_bot_service.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:desktoppossystem/shared/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final lastInvoiceProvider = FutureProvider<ReceiptModel?>((ref) async {
  final user = ref.watch(currentUserProvider);
  try {
    if (user != null) {
      final lastInvoiceRes = await ref
          .read(receiptProviderRepository)
          .fetchLastInvoice(userModel: user);

      ReceiptModel? receiptModel;
      await lastInvoiceRes.fold<Future>(
        (l) async {
          return null;
        },
        (r) async {
          receiptModel = r;
        },
      );
      return receiptModel;
    }
    return null;
  } catch (e) {
    return null;
  }
});

final futureReceiptTotalsProvider = FutureProvider.autoDispose<ReceiptTotals>((
  ref,
) async {
  final date = ref.watch(salesSelectedDateProvider);
  final selectedUser = ref.watch(salesSelectedUser);
  final response = await ref
      .read(receiptProviderRepository)
      .getReceiptTotalsByDay(
        date: date.toString(),
        userId: ref.read(currentUserProvider)?.id ?? 0,
        role: ref.read(currentUserProvider)?.role?.name ?? "All",
        filterUserId: selectedUser?.id,
      );
  return response.fold(
    (l) => ReceiptTotals(
      totalInvoices: 0,
      salesDolar: 0,
      salesLebanon: 0,
      totalDepositDolar: 0,
      totalDepositLebanon: 0,
      totalWithdrawDolar: 0,
      totalWithdrawLebanon: 0,
      totalWithdrawDolarFromCash: 0,
      totalWithdrawLebanonFromCash: 0,
      totalPendingAmount: 0,
      totalCollectedPending: 0,
      totalPendingReceipts: 0,
      totalPrimaryBalance: 0,
      totalRefunds: 0,
      totalSecondaryBalance: 0,
      totalPurchasesPrimary: 0,
      totalPurchasesSecondary: 0,
      totalSubscriptions: 0.0,
    ),
    (r) => r,
  );
});
final futureReceiptTotalsByShiftProvider =
    FutureProvider.autoDispose<ReceiptTotals>((ref) async {
      final currentUser = ref.watch(currentUserProvider);
      final selectedUser = ref.watch(shiftSelectedUserProvider);
      final selectedShift = ref.watch(selectedShiftProvider);
      final response = await ref
          .read(receiptProviderRepository)
          .getReceiptTotalsByShift(
            shiftId: selectedShift.id,
            userId: ref.read(currentUserProvider)?.id ?? 0,
            role: ref.read(currentUserProvider)?.role?.name ?? "All",
            filterUserId: selectedUser?.id,
          );
      return response.fold(
        (l) => ReceiptTotals(
          totalInvoices: 0,
          salesDolar: 0,
          salesLebanon: 0,
          totalDepositDolar: 0,
          totalDepositLebanon: 0,
          totalWithdrawDolar: 0,
          totalWithdrawLebanon: 0,
          totalWithdrawDolarFromCash: 0,
          totalWithdrawLebanonFromCash: 0,
          totalPendingAmount: 0,
          totalCollectedPending: 0,
          totalPendingReceipts: 0,
          totalPrimaryBalance: 0,
          totalRefunds: 0,
          totalSecondaryBalance: 0,
          totalPurchasesPrimary: 0,
          totalPurchasesSecondary: 0,
          totalSubscriptions: 0,
        ),
        (r) {
          return r;
        },
      );
    });
final currentShiftProvider = StateProvider<ShiftModel>((ref) {
  return ShiftModel(startShiftDate: DateTime.now().toString());
});
final selectedShiftProvider = StateProvider<ShiftModel>((ref) {
  return ShiftModel(startShiftDate: DateTime.now().toString());
});

final isAtLastShiftProvider = StateProvider<bool>((ref) {
  return ref.watch(currentShiftProvider) == ref.watch(selectedShiftProvider);
});

final receiptControllerProvider = ChangeNotifierProvider<ReceiptController>((
  ref,
) {
  return ReceiptController(
    ref: ref,
    receiptRepository: ref.read(receiptProviderRepository),
    productRepositoy: ref.read(productProviderRepository),
  );
});

class ReceiptController extends ChangeNotifier {
  final Ref _ref;
  final IReceiptRepository _receiptRepository;
  final IProductRepository _productRepositoy;

  ReceiptController({
    required Ref ref,
    required IReceiptRepository receiptRepository,
    required IProductRepository productRepositoy,
  }) : _ref = ref,
       _receiptRepository = receiptRepository,
       _productRepositoy = productRepositoy {
    getAllUsers();
    getCurrentShift();
    // fetchLast10Shifts();
  }

  List<UserModel> users = [];

  Future<List<UserModel>> getAllUsers() async {
    await _ref
        .read(userProviderRepository)
        .getAllUsers()
        .then((value) {
          users = value;
          users.add(
            UserModel(
              name: "All",
              password: "All",
              email: "email",
              role: RoleModel(id: 0, name: "All"),
            ),
          );
          users.sort((a, b) {
            if (a.name == "All") return -1; // Place "All" at the top
            if (b.name == "All") {
              return 1; // Place "All" at the top if `a` is not "All"
            }
            return a.name!.compareTo(b.name!); // Sort the rest alphabetically
          });
          _ref.read(salesSelectedUser.notifier).state = users
              .where((element) => element.role!.name == "All")
              .first;
          _ref.read(shiftSelectedUserProvider.notifier).state = users
              .where((element) => element.role!.name == "All")
              .first;
        })
        .catchError((error) {});
    return users;
  }

  // ! for daily sales

  Future getCurrentShift() async {
    final resCurrentShift = await _receiptRepository.fetchCurrentShift();
    resCurrentShift.fold((l) => () {}, (r) {
      _ref.read(currentShiftProvider.notifier).update((state) => r);
      _ref.read(selectedShiftProvider.notifier).update((state) => r);
    });
  }

  Future fetchShift({
    bool isPrev = false,
    bool isNext = false,
    bool isLast = false,
  }) async {
    int currentShiftId = _ref.read(selectedShiftProvider).id ?? 0;
    final resShift = await _receiptRepository.fetchShift(
      currentShiftId,
      isLast: isLast,
      isNext: isNext,
      isPrev: isPrev,
    );
    resShift.fold(
      (l) {
        print(l.message);
      },
      (r) {
        _ref.read(selectedShiftProvider.notifier).state = r;
        _ref.read(shiftSelectedUserProvider.notifier).state = users
            .where((element) => element.role!.name == "All")
            .first;
        fetchPaginatedReceiptsByShift(resetPagination: true);
      },
    );
  }

  //! pay recipt ,
  RequestState payRequestState = RequestState.success;
  bool payUsingF12 = false;
  Future pay(
    ReceiptModel receiptModel,
    List<ProductModel> basketItems, {
    required BuildContext context,
    bool? isForStaff,
    bool? f12Pressed,
  }) async {
    if (payRequestState == RequestState.loading) return;
    int invoiceId = 0;
    payUsingF12 = f12Pressed ?? false;
    if (isForStaff != true) {
      payRequestState = RequestState.loading;
      notifyListeners();
    }

    try {
      await _receiptRepository.addReceipt(receiptModel).then((value) async {
        //! list of details receipt
        List<DetailsReceipt> detailsReceipts = [];

        invoiceId = value;
        receiptModel.id = invoiceId;
        _ref
            .read(telegramRepositoryProvider)
            .sendSms(ReceiptNotification(receiptModel: receiptModel));

        // var groupedByProductId = groupBy(basketItems, (obj) => obj.id);
        // groupedByProductId.forEach((key, value) {
        //   double qty = 0;
        //   for (var element in value) {
        //     qty += element.qty!;
        //   }
        for (var product in basketItems) {
          detailsReceipts.add(
            DetailsReceipt(
              productId: product.id,
              qty: product.qty,
              receiptId: invoiceId,
              originalSellingPrice: product.originalSellingPrice,
              sellingPrice: product.sellingPrice,
              costPrice: product.costPrice,
              countsAsItem: isForStaff == true ? 0 : product.countsAsItem,
              isForStaff: isForStaff,
              discount: product.discount!,
              ingredients:
                  _ref.read(mainControllerProvider).isShowRestaurantStock &&
                      _ref.read(mainControllerProvider).screenUI ==
                          ScreenUI.restaurant
                  ? product.ingredientsToBeAdded
                  : [],
            ),
          );
        }

        _receiptRepository.addDetailsReceipt(
          detailsReceipt: detailsReceipts,
          orderType: receiptModel.orderType!,
        );
        _ref.read(categoryControllerProvider).clearCategorySelection();
        _ref
            .read(productControllerProvider)
            .increaseDecreaseListOfProducts(
              list: _ref.read(saleControllerProvider).basketItems,
              isForDecrease: true,
            );

        refreshNotifications();

        // refresh quick selection section
        _ref.refresh(quiverSelectionProductsProvider);

        //! print ticket
        //! check if printing is enable
        await Future.delayed(Duration.zero)
            .then((value) async {
              if (_ref
                      .read(printerControllerProvider)
                      .currentPrinterSettings
                      .isprintReceipt ==
                  true) {
                double originalTotalForeign = _ref
                    .read(saleControllerProvider)
                    .originalForeignPrice;
                double totalForeign = _ref
                    .read(saleControllerProvider)
                    .foreignTotalPrice;

                int receiptNumber =
                    _ref.read(saleControllerProvider).isJustClickedQuickORder
                    ? _ref.read(saleControllerProvider).receiptNumber - 1
                    : _ref.read(saleControllerProvider).receiptNumber;

                var nbOfImage =
                    (_ref.read(saleControllerProvider).basketItems.length / 20)
                        .ceil();
                var dolarRate = _ref.read(saleControllerProvider).dolarRate;

                // ! not refereced directly to basketitem cz after groupping the qty of basket will affetced

                List<ProductModel> basketItem = deepCopyBasket(
                  _ref.read(saleControllerProvider).basketItems,
                );

                List<ProductModel> orderBasket = _ref
                    .read(saleControllerProvider)
                    .basketItems;

                await _ref
                    .read(printerControllerProvider)
                    .generateAndPrintReceipt(
                      nbOfImage: nbOfImage,
                      products: basketItem,
                      dolarRate: dolarRate,
                      context: context,
                      originalTotalForeign: originalTotalForeign,
                      totalForeign: totalForeign,
                      invoiceNumber: invoiceId,
                      receiptNumber: receiptNumber,
                      typeOfPrint: TypeOfPrint.Receipt,
                      customerModel: _ref
                          .read(saleControllerProvider)
                          .customerModel,
                    );

                await Future.delayed(Duration.zero).then((value) async {
                  // ! order on network if available
                  if (_ref.read(saleControllerProvider).selectedTable == null &&
                      _ref
                          .read(printerControllerProvider)
                          .isHasNetworkPrinter) {
                    await _ref
                        .read(printerControllerProvider)
                        .printSectionOrders(
                          context: context,
                          receiptNumber: receiptNumber,
                          dolarRate: dolarRate,
                          products: orderBasket,
                        );
                    //! sectionPrinterFix
                    // await _ref.read(printerControllerProvider).printOrder(
                    //     nbOfImage,
                    //     orderBasket,
                    //     dolarRate,
                    //     _ref,
                    //     context,
                    //     receiptNumber,
                    //     _ref.watch(currentUserProvider) ?? UserModel.fakeUser(),);
                  }
                });
              } else {
                debugPrint("open cash without receipt");
                if (_ref.read(printerControllerProvider).showOpenCashButton &&
                    !_ref.read(printerControllerProvider).openCashDialogOnPay) {
                  _ref.read(printerControllerProvider).openCashDrawer(context);
                }
              }
            })
            .then((value) {
              //! increase Receipt Number after printing

              if (_ref.read(saleControllerProvider).selectedTable == null &&
                  !_ref.read(saleControllerProvider).isJustClickedQuickORder) {
                _ref
                    .read(saleControllerProvider)
                    .onIncreaseReceiptNumber(isQuickOrder: null);
              }
              if (_ref.read(saleControllerProvider).selectedTable != null) {
                _ref
                    .read(saleControllerProvider)
                    .closeTable(
                      _ref.read(saleControllerProvider).selectedTable!,
                    );
              }

              _ref.read(saleControllerProvider).resetSaleScreen();
              _ref.read(productControllerProvider).resetProductList();
            });

        _ref.refresh(lastInvoiceProvider);

        ToastUtils.showToast(
          message: "Receipt $successAddedStatusMessage",
          type: RequestState.success,
        );
        payUsingF12 = false;
        // add transaction if the receipt is paid
        if (receiptModel.transactionType == TransactionType.salePayment) {
          _ref
              .read(financialTransactionProviderRepository)
              .addFinancialTransaction(
                FinancialTransactionModel.fromReceipt(receiptModel),
              );
        }

        payRequestState = RequestState.success;
        notifyListeners();
      });
    } catch (e) {
      debugPrint(e.toString());
      ToastUtils.showToast(message: e.toString(), type: RequestState.error);
      payRequestState = RequestState.error;
      notifyListeners();
    }
  }

  //MArke ,
  RequestState payDeliveryRequestState = RequestState.success;

  Future payAsDelivery(
    ReceiptModel receiptModel,
    List<ProductModel> basketItems, {
    required BuildContext context,
  }) async {
    int invoiceId = 0;

    try {
      payDeliveryRequestState = RequestState.loading;
      notifyListeners();
      await _receiptRepository.addReceipt(receiptModel).then((value) async {
        //! list of details receipt
        List<DetailsReceipt> detailsReceipts = [];

        invoiceId = value;

        // var groupedByProductId = groupBy(basketItems, (obj) => obj.id);
        // groupedByProductId.forEach((key, value) {
        //   double qty = 0;
        //   for (var element in value) {
        //     qty += element.qty!;
        //   }
        for (var product in basketItems) {
          detailsReceipts.add(
            DetailsReceipt(
              productId: product.id,
              qty: product.qty,
              receiptId: invoiceId,
              originalSellingPrice: product.originalSellingPrice,
              sellingPrice: product.sellingPrice,
              costPrice: product.costPrice,
              discount: product.discount!,
              ingredients:
                  _ref.read(mainControllerProvider).isShowRestaurantStock &&
                      _ref.read(mainControllerProvider).screenUI ==
                          ScreenUI.restaurant
                  ? product.ingredientsToBeAdded
                  : [],
            ),
          );
        }

        _receiptRepository.addDetailsReceipt(
          detailsReceipt: detailsReceipts,
          orderType: receiptModel.orderType!,
        );
        _ref.read(categoryControllerProvider).clearCategorySelection();
        _ref
            .read(productControllerProvider)
            .increaseDecreaseListOfProducts(
              list: _ref.read(saleControllerProvider).basketItems,
              isForDecrease: true,
            );

        // !refresh the counts
        refreshNotifications();
        // refresh quick selection
        _ref.refresh(quiverSelectionProductsProvider);

        //! print ticket
        //! check if printing is enable
        await Future.delayed(Duration.zero)
            .then((value) async {
              if (_ref
                      .read(printerControllerProvider)
                      .currentPrinterSettings
                      .isprintReceipt ==
                  true) {
                double originalTotalForeign = _ref
                    .read(saleControllerProvider)
                    .originalForeignPrice;
                double totalForeign = _ref
                    .read(saleControllerProvider)
                    .foreignTotalPrice;

                int receiptNumber =
                    _ref.read(saleControllerProvider).isJustClickedQuickORder
                    ? _ref.read(saleControllerProvider).receiptNumber - 1
                    : _ref.read(saleControllerProvider).receiptNumber;

                var nbOfImage =
                    (_ref.read(saleControllerProvider).basketItems.length / 20)
                        .ceil();
                var dolarRate = _ref.read(saleControllerProvider).dolarRate;

                // ! not refereced directly to basketitem cz after groupping the qty of basket will affetced

                List<ProductModel> basketItem = deepCopyBasket(
                  _ref.read(saleControllerProvider).basketItems,
                );

                List<ProductModel> orderBasket = _ref
                    .read(saleControllerProvider)
                    .basketItems;

                await _ref
                    .read(printerControllerProvider)
                    .generateAndPrintReceipt(
                      nbOfImage: nbOfImage,
                      products: basketItem,
                      dolarRate: dolarRate,
                      context: context,
                      originalTotalForeign: originalTotalForeign,
                      totalForeign: totalForeign,
                      invoiceNumber: invoiceId,
                      receiptNumber: receiptNumber,
                      typeOfPrint: TypeOfPrint.Receipt,
                      customerModel: _ref
                          .read(saleControllerProvider)
                          .customerModel,
                    );

                await Future.delayed(Duration.zero).then((value) async {
                  // ! order on network if available
                  if (_ref.read(saleControllerProvider).selectedTable == null &&
                      _ref
                          .read(printerControllerProvider)
                          .isHasNetworkPrinter) {
                    await _ref
                        .read(printerControllerProvider)
                        .printSectionOrders(
                          context: context,
                          receiptNumber: receiptNumber,
                          dolarRate: dolarRate,
                          products: orderBasket,
                        );
                    //! sectionPrinterFix
                    // await _ref.read(printerControllerProvider).printOrder(
                    //     nbOfImage,
                    //     orderBasket,
                    //     dolarRate,
                    //     _ref,
                    //     context,
                    //     receiptNumber,
                    //     _ref.watch(currentUserProvider) ?? UserModel.fakeUser(),);
                  }
                });
              }
            })
            .then((value) {
              //! increase Receipt Number after printing

              if (_ref.read(saleControllerProvider).selectedTable == null &&
                  !_ref.read(saleControllerProvider).isJustClickedQuickORder) {
                _ref
                    .read(saleControllerProvider)
                    .onIncreaseReceiptNumber(isQuickOrder: null);
              }

              _ref.read(saleControllerProvider).resetSaleScreen();
              _ref.read(productControllerProvider).resetProductList();
            });

        _ref.refresh(lastInvoiceProvider);

        ToastUtils.showToast(
          message: "Receipt $successAddedStatusMessage",
          type: RequestState.success,
        );
        payDeliveryRequestState = RequestState.success;
        notifyListeners();
      });
    } catch (e) {
      debugPrint(e.toString());
      ToastUtils.showToast(message: e.toString(), type: RequestState.error);
      payDeliveryRequestState = RequestState.error;
      notifyListeners();
    }
  }

  RequestState printQuotationRequestState = RequestState.success;

  Future printQuotation(
    ReceiptModel receiptModel,
    List<ProductModel> basketItems, {
    required BuildContext context,
  }) async {
    try {
      printQuotationRequestState = RequestState.loading;
      notifyListeners();
      await Future.delayed(Duration.zero)
          .then((value) async {
            if (_ref
                    .read(printerControllerProvider)
                    .currentPrinterSettings
                    .isprintReceipt ==
                true) {
              double originalTotalForeign = _ref
                  .read(saleControllerProvider)
                  .originalForeignPrice;
              double totalForeign = _ref
                  .read(saleControllerProvider)
                  .foreignTotalPrice;

              var nbOfImage =
                  (_ref.read(saleControllerProvider).basketItems.length / 20)
                      .ceil();
              var dolarRate = _ref.read(saleControllerProvider).dolarRate;

              // ! not refereced directly to basketitem cz after groupping the qty of basket will affetced
              List<ProductModel> basketItem = deepCopyBasket(
                _ref.read(saleControllerProvider).basketItems,
              );

              List<ProductModel> orderBasket = _ref
                  .read(saleControllerProvider)
                  .basketItems;

              await _ref
                  .read(printerControllerProvider)
                  .generateAndPrintReceipt(
                    isQuotation: true,
                    nbOfImage: nbOfImage,
                    products: basketItem,
                    dolarRate: dolarRate,
                    context: context,
                    originalTotalForeign: originalTotalForeign,
                    totalForeign: totalForeign,
                    typeOfPrint: TypeOfPrint.Receipt,
                    customerModel: _ref
                        .read(saleControllerProvider)
                        .customerModel,
                  );
            }
          })
          .then((value) {
            _ref.read(saleControllerProvider).resetSaleScreen();
            _ref.read(productControllerProvider).resetProductList();
          });

      printQuotationRequestState = RequestState.success;
      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
      ToastUtils.showToast(message: e.toString(), type: RequestState.error);
      printQuotationRequestState = RequestState.error;
      notifyListeners();
    }
  }

  List<ProductModel> deepCopyBasket(List<ProductModel> basket) {
    List<ProductModel> copiedBasket = [];
    for (ProductModel item in basket) {
      ProductModel p = ProductModel.fromJson(item.toJsonWithoutNote());
      p.originalSellingPrice = item.originalSellingPrice;
      p.sectionType = item.sectionType;

      copiedBasket.add(p);
    }
    return copiedBasket;
  }

  bool isSortByPaymentType = false;
  sortReceiptByPaymentType() {
    isSortByPaymentType = !isSortByPaymentType;

    if (isSortByPaymentType) {
      receiptsListByDay.sort(
        (a, b) => a.paymentType.name.compareTo(b.paymentType.name),
      );
    } else {
      receiptsListByDay.sort((a, b) => b.id!.compareTo(a.id!));
    }

    notifyListeners();
  }

  bool sortShiftByPaymentType = false;
  sortShiftReceiptByPaymentType() {
    sortShiftByPaymentType = !sortShiftByPaymentType;

    if (sortShiftByPaymentType) {
      receiptsListByShift.sort(
        (a, b) => a.paymentType.name.compareTo(b.paymentType.name),
      );
    } else {
      receiptsListByShift.sort((a, b) => b.id!.compareTo(a.id!));
    }

    notifyListeners();
  }

  searchByInvoiceId(String query) async {
    if (query.trim() == "") {
      receiptsListByDay = originalReceiptsListByDay;
    } else {
      int id = int.tryParse(query) ?? 0;
      if (id != 0) {
        final r = await _receiptRepository.getReceiptById(id);
        receiptsListByDay = r != null ? [r] : [];
      }
    }
    notifyListeners();
  }

  List<ReceiptModel> receiptsListByDay = [];
  List<ReceiptModel> originalReceiptsListByDay = [];

  onChangeReceiptsOrderType(int index) {
    receiptsListByDay = index == 0
        ? originalReceiptsListByDay
        : originalReceiptsListByDay
              .where(
                (e) =>
                    (e.orderType == OrderType.delivery && e.isPaid != true) ||
                    e.transactionType == TransactionType.purchase,
              )
              .toList();

    notifyListeners();
  }

  int _batchSize = 30;
  int currentOffset = 0;
  bool isHasMoreReceiptsData = true;
  RequestState getReceiptByDayRequestState = RequestState.success;

  Future fetchPaginatedReceiptsByDay({
    int? batch,
    int? offset,
    int? filterUserId,
    bool resetPagination = false,
  }) async {
    debugPrint("fetch pagination");
    if (getReceiptByDayRequestState == RequestState.loading) return;

    final date = _ref
        .read(salesSelectedDateProvider)
        .toString()
        .split(" ")
        .first;

    if (resetPagination) {
      currentOffset = 0;
      isHasMoreReceiptsData = true;
      receiptsListByDay = [];
    }

    if ((batch != null && offset != null)) {
      _batchSize = batch;
      currentOffset = offset;
      isHasMoreReceiptsData = true;
      if (currentOffset == 0) {
        receiptsListByDay = []; // clear list if offset zero (new fetch)
      }
    }

    if (!isHasMoreReceiptsData) {
      getReceiptByDayRequestState = RequestState.success;
      notifyListeners();
      return;
    }

    getReceiptByDayRequestState = RequestState.loading;
    notifyListeners();
    try {
      UserModel userModel =
          _ref.watch(currentUserProvider) ?? UserModel.fakeUser();
      _ref.refresh(futureReceiptTotalsProvider);

      final newReceipts = await _receiptRepository
          .getReceiptsByDayWithPagination(
            filterUserId: filterUserId,
            date: date,
            userId: userModel.id!,
            role: userModel.role!.name.validateString(),
            limit: _batchSize,
            offset: currentOffset,
          );

      currentOffset += _batchSize;
      isHasMoreReceiptsData = newReceipts.length == _batchSize;

      // If batch and offset are passed, replace the list; else append
      receiptsListByDay = batch != null && offset != null
          ? newReceipts
          : [...receiptsListByDay, ...newReceipts];
      originalReceiptsListByDay = receiptsListByDay;
      // filter by current selected index
      onChangeReceiptsOrderType(_ref.read(selectedFinancialFilterIndex));
      getReceiptByDayRequestState = RequestState.success;
      notifyListeners();
    } catch (error) {
      debugPrint(error.toString());
      getReceiptByDayRequestState = RequestState.error;
    } finally {
      notifyListeners();
    }
  }

  List<DetailsReceipt> detailsReceiptList = [];
  RequestState getDetailsReceiptByIdRequestState = RequestState.success;

  Future<List<DetailsReceipt>> getDetailsReceiptById(int id) async {
    detailsReceiptList = [];
    getDetailsReceiptByIdRequestState = RequestState.loading;
    await _receiptRepository
        .getDetailsReceiptById(id)
        .then((value) {
          detailsReceiptList = value;
          getDetailsReceiptByIdRequestState = RequestState.success;
        })
        .catchError((error) {
          getDetailsReceiptByIdRequestState = RequestState.error;
          debugPrint(error.toString());
        });
    return detailsReceiptList;
  }

  RequestState refundItemsRequestState = RequestState.success;
  Future refundItems({
    required List<DetailsReceipt> list,
    required BuildContext context,
  }) async {
    refundItemsRequestState = RequestState.loading;
    notifyListeners();
    await _receiptRepository
        .refundItems(list)
        .then((value) {
          ToastUtils.showToast(
            message: "Items $successrefundStatusMessage",
            type: RequestState.success,
          );
          refundItemsRequestState = RequestState.success;
          _ref.refresh(lastInvoiceProvider);
          _ref
              .read(telegramRepositoryProvider)
              .sendSms(
                RefundNotification(
                  receiptId: list[0].receiptId ?? 0,
                  detailsReceipt: list,
                ),
              );
          context.pop();
        })
        .catchError((error) {
          refundItemsRequestState = RequestState.error;
          ToastUtils.showToast(
            message: error.toString(),
            type: RequestState.error,
          );
          notifyListeners();
        });

    //! getting receipt by day after refunds
    await fetchPaginatedReceiptsByDay(resetPagination: true);
    notifyListeners();
  }

  Future deleteReceipt(ReceiptModel receipt, BuildContext context) async {
    List<DetailsReceipt> detailsReceipt = await _receiptRepository
        .getDetailsReceiptById(receipt.id!);
    List<ProductModel> products = detailsReceipt
        .where((e) => e.isRefunded != true)
        .map(
          (e) => ProductModel(
            id: e.productId,
            qty: e.qty!,
            name: '',
            sellingPrice: null,
            selected: null,
            categoryId: null,
            isTracked: e.isTracked,
          ),
        )
        .toList();
    final deleteRes = await _receiptRepository.deleteReceipt(receipt.id!);

    deleteRes.fold(
      (l) {
        ToastUtils.showToast(message: "Error deleting Receipt");
      },
      (r) async {
        _ref
            .read(productControllerProvider)
            .increaseDecreaseListOfProducts(
              list: products,
              isForDecrease: false,
            );
        //! remove it without getting all dailyreciptbyday from database
        receiptsListByDay.removeWhere((element) => element.id == receipt.id!);
        originalReceiptsListByDay.removeWhere(
          (element) => element.id == receipt.id!,
        );
        _ref.refresh(futureReceiptTotalsProvider);

        context.pop();

        notifyListeners();
        ToastUtils.showToast(message: "Receipt Deleted Successfully");
        _ref.refresh(lastInvoiceProvider);

        if (_ref.read(mainControllerProvider).isShowRestaurantStock &&
            _ref.read(mainControllerProvider).screenUI == ScreenUI.restaurant) {
          for (var details in detailsReceipt) {
            List<DetailsIngredientsReceipt> detailsIngredientsReceipt =
                await _ref
                    .read(restaurantProviderRepository)
                    .fetchSaledIngredientByDetailsReceiptId(details.id!);
            _ref
                .read(restaurantProviderRepository)
                .refundIngredients(
                  detailsIngredientsReceipt,
                  details.refundedQty!,
                  isDelete: true,
                );
          }
        }

        _ref
            .read(telegramRepositoryProvider)
            .sendSms(DeleteReceiptNotification(receipt: receipt));
      },
    );
  }

  // ! End Of Day Report
  int nbCustomers = 0;
  RequestState getSellingProductsRequestState = RequestState.success;
  //! isForReports to get all details receipt with refunded
  Future<List<ProductModel>> getsellingProducts({
    int? shiftId,
    bool? isForReports,
    bool? isForStaff,
  }) async {
    List<ProductModel> sellingProducts = [];
    getSellingProductsRequestState = RequestState.loading;
    notifyListeners();
    await _productRepositoy
        .getMostSellingProductByType(
          isForStaff: isForStaff,
          isForReports: isForReports,
          view: shiftId != null ? null : DashboardFilterEnum.today,
          limit: 1000,
          shiftId: shiftId,
          date: shiftId != null
              ? null
              : _ref
                    .read(salesSelectedDateProvider)
                    .toString()
                    .split(" ")
                    .first,
        )
        .then((value) {
          sellingProducts = value;
          getSellingProductsRequestState = RequestState.success;
          notifyListeners();
        })
        .catchError((error) {
          debugPrint(error.toString());
          getSellingProductsRequestState = RequestState.error;
          notifyListeners();
        });
    return sellingProducts;
  }

  RequestState getrefundedProductsRequestState = RequestState.success;
  //! isForReports to get all details receipt with refunded
  Future<List<ProductModel>> getrefundedProducts({
    int? shiftId,
    bool? isForReports,
  }) async {
    List<ProductModel> sellingProducts = [];
    getrefundedProductsRequestState = RequestState.loading;
    notifyListeners();
    await _productRepositoy
        .getMostSellingProductByType(
          view: shiftId != null ? null : DashboardFilterEnum.today,
          limit: 1000,
          shiftId: shiftId,
          date: shiftId != null
              ? null
              : _ref
                    .read(salesSelectedDateProvider)
                    .toString()
                    .split(" ")
                    .first,
        )
        .then((value) {
          sellingProducts = value;
          getrefundedProductsRequestState = RequestState.success;
          notifyListeners();
        })
        .catchError((error) {
          getrefundedProductsRequestState = RequestState.error;
          notifyListeners();
        });
    return sellingProducts;
  }

  sortReceiptListByDay() {
    receiptsListByDay.sort((a, b) => b.id!.compareTo(a.id!));
  }

  onChangeUserSelection(UserModel user, {bool? isForShift}) {
    //switch to all if pending is pressed
    // _ref.read(selectedFinancialFilterIndex.notifier).state = 0;
    if (isForShift == true) {
      _ref.read(shiftSelectedUserProvider.notifier).state = user;

      if (user.role!.name == "All") {
        fetchPaginatedReceiptsByShift(resetPagination: true);
      } else {
        fetchPaginatedReceiptsByShift(
          filterUserId: user.id,
          resetPagination: true,
        );
      }
    } else {
      _ref.read(salesSelectedUser.notifier).state = user;

      if (user.role!.name == "All") {
        fetchPaginatedReceiptsByDay(resetPagination: true);
      } else {
        fetchPaginatedReceiptsByDay(
          filterUserId: user.id,
          resetPagination: true,
        );
      }
    }
  }

  //! end shift section  ///////////
  Future onEndShift({required int userId, required String role}) async {
    final newShiftRes = await _receiptRepository.createShift();
    newShiftRes.fold((l) => () {}, (r) {
      _ref.read(currentShiftProvider.notifier).update((state) => r);
      _ref.read(selectedShiftProvider.notifier).update((state) => r);
      fetchPaginatedReceiptsByShift(resetPagination: true);
      notifyListeners();
    });
  }

  List<ReceiptModel> get withDrawReceiptbyShift => receiptsListByShift;

  RequestState getReceiptByShiftRequestState = RequestState.success;
  List<ReceiptModel> receiptsListByShift = [];
  List<ReceiptModel> originalReceiptsListByShift = [];
  // Add these to your controller's state
  int? _currentShiftId;

  Future fetchPaginatedReceiptsByShift({
    int? batch,
    int? offset,
    int? filterUserId,
    bool resetPagination = false,
  }) async {
    if (getReceiptByShiftRequestState == RequestState.loading) return;

    final selectedShift = _ref.read(selectedShiftProvider).id;

    // Reset conditions: forced reset OR shift changed (tracked via currentShiftId)
    if (resetPagination || _currentShiftId != selectedShift) {
      _currentShiftId = selectedShift; // Store current shift
      currentOffset = 0;
      isHasMoreReceiptsData = true;
      receiptsListByShift = [];
    }

    // Handle batch/offset parameters
    if (batch != null && offset != null) {
      _batchSize = batch;
      currentOffset = offset;
      isHasMoreReceiptsData = true;
      if (currentOffset == 0) {
        receiptsListByShift = []; // Clear list if offset is zero
      }
    }

    if (!isHasMoreReceiptsData) {
      getReceiptByShiftRequestState = RequestState.success;
      notifyListeners();
      return;
    }

    getReceiptByShiftRequestState = RequestState.loading;
    notifyListeners();

    try {
      UserModel userModel =
          _ref.watch(currentUserProvider) ?? UserModel.fakeUser();
      _ref.refresh(futureReceiptTotalsByShiftProvider);

      final newReceipts = await _receiptRepository
          .getReceiptsByShiftWithPagination(
            shiftId: selectedShift,
            filterUserId: filterUserId,
            userId: userModel.id!,
            role: userModel.role!.name.validateString(),
            limit: _batchSize,
            offset: currentOffset,
          );

      // Update pagination state
      currentOffset += _batchSize;
      isHasMoreReceiptsData = newReceipts.length == _batchSize;

      // Update receipts list
      receiptsListByShift = batch != null && offset != null
          ? newReceipts
          : [...receiptsListByShift, ...newReceipts];
      originalReceiptsListByShift = receiptsListByShift;

      getReceiptByShiftRequestState = RequestState.success;
    } catch (error) {
      debugPrint(error.toString());
      getReceiptByShiftRequestState = RequestState.error;
    } finally {
      notifyListeners();
    }
  }

  List<ExpenseModel> expensesByShift = [];
  generateExpensesByShift() {
    expensesByShift = [];
    // for (var receipt in withDrawReceiptbyShift) {
    //   expensesByShift.add(ExpenseModel(
    //     isTransactionInPrimary: receipt.isTransactionInPrimary,
    //     withDrawFromCash: receipt.withDrawFromCash,
    //     expensePurpose: receipt.expensePurpose.toString(),
    //     expenseAmount: receipt.isTransactionInPrimary == true
    //         ? receipt.foreignReceiptPrice!
    //         : receipt.localReceiptPrice!,
    //   ));
    // }
  }

  Future<List<RestaurantStockUsageModel>> fetchStockUsageReport({
    String? date,
    ReportInterval? view,
    int? shiftId,
  }) async {
    List<RestaurantStockUsageModel> stockUsage = [];

    final response = await _ref
        .read(restaurantProviderRepository)
        .fetchStockUsageReport(date: date, view: view, shiftId: shiftId);
    await response.fold<Future>(
      (l) async {
        debugPrint(l.message.toString());
      },
      (r) async {
        stockUsage = r;
        notifyListeners();
      },
    );
    return stockUsage;
  }

  Future<List<RestaurantStockModel>> fetchAllStockItems({
    bool? isForWarning,
  }) async {
    List<RestaurantStockModel> stockItems = [];

    final stockResponse = await _ref
        .read(restaurantProviderRepository)
        .fetchAllStockItems(isForWarning: isForWarning);
    stockResponse.fold(
      (l) {
        notifyListeners();
      },
      (r) {
        stockItems = r;
      },
    );
    return stockItems;
  }

  Future deliverInvoice({
    required ReceiptModel receiptModel,
    String? note,
  }) async {
    String? registrationUserId = await _ref
        .read(securePreferencesProvider)
        .getData(key: "registrationUserId");
    if (registrationUserId != null) {
      final clientService = DeliverService(registrationUserId);
      final response = await clientService.deliverInvoice(
        receiptModel: receiptModel,
        note: note ?? '',
      );
      response.fold(
        (l) {
          ToastUtils.showToast(
            type: RequestState.error,
            message: l.message.toString(),
          );
        },
        (r) {
          _ref.refresh(lastInvoiceProvider);
          ToastUtils.showToast(
            type: RequestState.success,
            message: "delivered successfully",
          );
        },
      );
    } else {
      ToastUtils.showToast(type: RequestState.error, message: "not registered");
    }
  }

  Future<void> togglePayReceipt(ReceiptModel receipt, bool value) async {
    final response = await _receiptRepository.togglePayReceipt(receipt, value);
    response.fold(
      (l) {
        ToastUtils.showToast(
          type: RequestState.error,
          message: l.message.toString(),
        );
      },
      (r) {
        if (value) {
          ToastUtils.showToast(
            type: RequestState.success,
            message: "Receipt nb ${receipt.id} paid successfully",
          );
          for (var e in receiptsListByDay) {
            if (e.id == receipt.id) {
              e.isPaid == true;
              e.remainingAmount = 0.0;
            }
          }
          receiptsListByDay.singleWhere((e) => e.id == receipt.id)
            ..isPaid = true
            ..remainingAmount = 0;
          notifyListeners();
          _ref.refresh(futureReceiptTotalsProvider);
          refreshNotifications();
        }
      },
    );
  }
}
