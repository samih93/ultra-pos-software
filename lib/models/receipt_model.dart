// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:desktoppossystem/models/customers_model.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';

class ReceiptModel {
  int? id;
  double? foreignReceiptPrice;
  double? localReceiptPrice;
  String receiptDate;
  int? userId;
  double? dollarRate;
  PaymentType paymentType = PaymentType.cash;
  TransactionType? transactionType;
  int shiftId = 1;
  String? note;
  int? expenseId;
  bool? isTransactionInPrimary;
  int? customerId;
  // double? discount;
  bool? isHasDiscount = false;
  CustomerModel? customerModel;
  bool? invoiceDelivered = false;

  bool? fromCash;

  int? nbOfCustomers;
  bool? isPaid;
  double? remainingAmount;

  // for dine in , delivery
  OrderType? orderType;
  ReceiptModel({
    this.id,
    required this.foreignReceiptPrice,
    required this.localReceiptPrice,
    required this.receiptDate,
    required this.userId,
    required this.dollarRate,
    required this.paymentType,
    this.transactionType,
    required this.shiftId,
    this.note,
    this.expenseId,
    this.isTransactionInPrimary,
    this.customerId,
    this.customerModel,
    this.isHasDiscount,
    this.orderType,
    this.invoiceDelivered,
    this.fromCash,
    this.nbOfCustomers,
    this.isPaid = true,
    this.remainingAmount = 0.0,
  });

  factory ReceiptModel.fromJson(Map<String, dynamic> map) {
    CustomerModel? customer;
    if (map['name'] != null &&
        map["address"] != null &&
        map["phoneNumber"] != null) {
      customer = CustomerModel(
        id: map['customerId'],
        name: map['name'],
        address: map["address"],
        phoneNumber: map["phoneNumber"],
      );
    }
    return ReceiptModel(
      id: map['id'],
      foreignReceiptPrice: map['foreignReceiptPrice']
          .toString()
          .validateDouble(),
      localReceiptPrice: map['localReceiptPrice'].toString().validateDouble(),
      //! if null set it to foreign receipt by default for old
      remainingAmount: map['remainingAmount'] != null
          ? map['remainingAmount'].toString().validateDouble().formatDouble()
          : 0,
      paymentType: map["paymentType"].toString().paymentToEnum(),

      transactionType: map["transactionType"].toString().transactionToEnum(),
      receiptDate: map['receiptDate'],
      userId: map['userId'],
      dollarRate: double.tryParse(map['dolarRate'].toString()) ?? 0,
      shiftId: map['shiftId'],
      note: map['expensePurpose'] ?? '',
      expenseId: map['expenseId'],
      isTransactionInPrimary: map['isTransactionInPrimary'] == 1 ? true : false,
      customerId: map['customerId'],
      customerModel: customer,
      orderType: map["orderType"] != null
          ? (map["orderType"] as String).orderToEnum()
          : OrderType.dineIn,
      isHasDiscount: map['isHasDiscount'] == 1 ? true : false,
      invoiceDelivered: map['invoiceDelivered'] == 1 ? true : false,
      fromCash: map['withDrawFromCash'] == 1 ? true : false,
      isPaid: map['isPaid'] == 1 ? true : false,
      nbOfCustomers: map['nbOfCustomers'] ?? 1,
    );
  }

  toJson() {
    return {
      'foreignReceiptPrice': foreignReceiptPrice,
      'localReceiptPrice': localReceiptPrice,
      'receiptDate': receiptDate,
      'userId': userId,
      'dolarRate': dollarRate,
      'paymentType': paymentType.name,
      'transactionType':
          transactionType?.name ?? TransactionType.salePayment.name,
      'shiftId': shiftId,
      'expenseId': expenseId,
      'isTransactionInPrimary': isTransactionInPrimary == true ? 1 : 0,
      'customerId': customerId,
      'isHasDiscount': isHasDiscount == true ? 1 : 0,
      'invoiceDelivered': invoiceDelivered == true ? 1 : 0,
      'withDrawFromCash': fromCash == true ? 1 : 0,
      'isPaid': isPaid == true ? 1 : 0,
      "orderType": orderType?.name ?? OrderType.dineIn.name,
      "nbOfCustomers": nbOfCustomers ?? 1,
      "remainingAmount": isPaid == true || orderType == OrderType.dineIn
          ? 0.0
          : foreignReceiptPrice,
    };
  }

  static ReceiptModel fakeReceipt = ReceiptModel(
    id: 1,
    foreignReceiptPrice: 100.0,
    localReceiptPrice: 85.0,
    receiptDate: DateTime.now().toString(),
    userId: 123,
    dollarRate: 1.18,
    paymentType: PaymentType.card,
    transactionType: null,
    shiftId: 1,
    note: 'Sample Expense',
    expenseId: 456,
    isTransactionInPrimary: true,
    customerId: 789,
    customerModel: CustomerModel(
      id: 789,
      name: 'John Doe',
      address: '123 Main St',
      phoneNumber: '555-1234',
    ),
    isHasDiscount: false,
    orderType: OrderType.dineIn,
    invoiceDelivered: true,
    fromCash: false,
  );
}

class ReceiptTotals {
  final double totalPrimaryBalance;
  final double totalSecondaryBalance;

  final int totalInvoices;
  final double salesDolar;
  final double salesLebanon;
  final double totalDepositDolar;
  final double totalDepositLebanon;
  final double totalWithdrawDolar;
  final double totalWithdrawLebanon;
  final double totalWithdrawDolarFromCash;
  final double totalWithdrawLebanonFromCash;
  final double totalPendingAmount;
  final int totalPendingReceipts;
  final double totalCollectedPending;
  final double totalRefunds;
  final double totalPurchasesPrimary;
  final double totalPurchasesSecondary;
  final double totalSubscriptions;

  ReceiptTotals({
    required this.totalInvoices,
    required this.salesDolar,
    required this.salesLebanon,
    required this.totalDepositDolar,
    required this.totalDepositLebanon,
    required this.totalWithdrawDolar,
    required this.totalWithdrawLebanon,
    required this.totalWithdrawDolarFromCash,
    required this.totalWithdrawLebanonFromCash,
    required this.totalPendingAmount,
    required this.totalPendingReceipts,
    required this.totalCollectedPending,
    required this.totalRefunds,
    required this.totalPrimaryBalance,
    required this.totalSecondaryBalance,
    required this.totalPurchasesPrimary,
    required this.totalPurchasesSecondary,
    required this.totalSubscriptions,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'totalInvoices': totalInvoices,
      'salesDolar': salesDolar,
      'salesLebanon': salesLebanon,
      'totalDepositDolar': totalDepositDolar,
      'totalDepositLebanon': totalDepositLebanon,
      'totalWithdrawDolar': totalWithdrawDolar,
      'totalWithdrawLebanon': totalWithdrawLebanon,
      'totalWithdrawDolarFromCash': totalWithdrawDolarFromCash,
      'totalWithdrawLebanonFromCash': totalWithdrawLebanonFromCash,
      'totalPendingAmount': totalPendingAmount,
      'totalPendingReceipts': totalPendingReceipts,
    };
  }

  factory ReceiptTotals.fromMap(Map<String, dynamic> map) {
    return ReceiptTotals(
      totalInvoices: map['totalInvoices'].toString().validateInteger(),
      salesDolar: map['salesDolar'].toString().validateDouble(),
      salesLebanon: map['salesLebanon'].toString().validateDouble(),
      totalDepositDolar: map['totalDepositDolar'].toString().validateDouble(),
      totalDepositLebanon: map['totalDepositLebanon']
          .toString()
          .validateDouble(),
      totalWithdrawDolar: map['totalWithdrawDolar'].toString().validateDouble(),
      totalWithdrawLebanon: map['totalWithdrawLebanon']
          .toString()
          .validateDouble(),
      totalWithdrawDolarFromCash: map['totalWithdrawDolarFromCash']
          .toString()
          .validateDouble(),
      totalWithdrawLebanonFromCash: map['totalWithdrawLebanonFromCash']
          .toString()
          .validateDouble(),
      totalPendingAmount: map['totalPendingAmount'].toString().validateDouble(),
      totalCollectedPending: map['totalCollectedPending']
          .toString()
          .validateDouble(),
      totalPendingReceipts: map['totalPendingReceipts']
          .toString()
          .validateInteger(),
      totalPrimaryBalance: map['totalPrimaryBalance']
          .toString()
          .validateDouble(),
      totalSecondaryBalance: map['totalSecondaryBalance']
          .toString()
          .validateDouble(),
      totalRefunds: map['totalRefunds'].toString().validateDouble(),
      totalPurchasesPrimary: map['totalPurchasesPrimary']
          .toString()
          .validateDouble(),
      totalPurchasesSecondary: map['totalPurchasesSecondary']
          .toString()
          .validateDouble(),
      totalSubscriptions: map['totalSubscriptions'].toString().validateDouble(),
    );
  }

  ReceiptTotals copyWith({
    int? totalInvoices,
    double? salesDolar,
    double? salesLebanon,
    double? totalDepositDolar,
    double? totalDepositLebanon,
    double? totalWithdrawDolar,
    double? totalWithdrawLebanon,
    double? totalWithdrawDolarFromCash,
    double? totalWithdrawLebanonFromCash,
    double? totalPendingAmount,
    double? totalCollectedPending,
    int? totalPendingReceipts,
    double? totalRefunds,
    double? totalPrimaryBalance,
    double? totalSecondaryBalance,
    double? totalPurchasesPrimary,
    double? totalPurchasesSecondary,
    double? totalSubscriptions,
  }) {
    return ReceiptTotals(
      totalInvoices: totalInvoices ?? this.totalInvoices,
      salesDolar: salesDolar ?? this.salesDolar,
      salesLebanon: salesLebanon ?? this.salesLebanon,
      totalDepositDolar: totalDepositDolar ?? this.totalDepositDolar,
      totalDepositLebanon: totalDepositLebanon ?? this.totalDepositLebanon,
      totalWithdrawDolar: totalWithdrawDolar ?? this.totalWithdrawDolar,
      totalWithdrawLebanon: totalWithdrawLebanon ?? this.totalWithdrawLebanon,
      totalWithdrawDolarFromCash:
          totalWithdrawDolarFromCash ?? this.totalWithdrawDolarFromCash,
      totalWithdrawLebanonFromCash:
          totalWithdrawLebanonFromCash ?? this.totalWithdrawLebanonFromCash,
      totalPendingAmount: totalPendingAmount ?? this.totalPendingAmount,
      totalCollectedPending:
          totalCollectedPending ?? this.totalCollectedPending,
      totalPendingReceipts: totalPendingReceipts ?? this.totalPendingReceipts,
      totalPrimaryBalance: totalPrimaryBalance ?? this.totalPrimaryBalance,
      totalSecondaryBalance:
          totalSecondaryBalance ?? this.totalSecondaryBalance,
      totalRefunds: totalRefunds ?? this.totalRefunds,
      totalPurchasesPrimary:
          totalPurchasesPrimary ?? this.totalPurchasesPrimary,
      totalPurchasesSecondary:
          totalPurchasesSecondary ?? this.totalPurchasesSecondary,
      totalSubscriptions: totalSubscriptions ?? this.totalSubscriptions,
    );
  }
}

class ReceiptRequest {
  final int customerId;
  final ReceiptStatus status;

  ReceiptRequest({required this.customerId, required this.status});

  @override
  bool operator ==(covariant ReceiptRequest other) {
    if (identical(this, other)) return true;

    return other.customerId == customerId && other.status == status;
  }

  @override
  int get hashCode => customerId.hashCode ^ status.hashCode;
}
