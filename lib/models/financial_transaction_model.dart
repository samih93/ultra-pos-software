// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:desktoppossystem/models/receipt_model.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';

class FinancialTransactionModel {
  int? id;
  String transactionDate;
  double primaryAmount; // in local currency
  double? secondaryAmount; // in foreign currency
  bool? isTransactionInPrimary;

  double? dollarRate;

  PaymentType paymentType; // cash, card, bank
  TransactionFlow flow; // IN / OUT
  TransactionType transactionType;

  int? receiptId;
  int? expenseId;
  int? customerId;
  int? shiftId;
  String? note;
  int userId;
  bool? fromCash;
  FinancialTransactionModel(
      {this.id,
      required this.transactionDate,
      required this.primaryAmount,
      this.secondaryAmount,
      this.isTransactionInPrimary,
      this.dollarRate,
      required this.paymentType,
      required this.flow,
      required this.transactionType,
      this.receiptId,
      this.expenseId,
      this.customerId,
      this.shiftId,
      this.note,
      required this.userId,
      this.fromCash});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'transactionDate': transactionDate,
      'primaryAmount': primaryAmount,
      'secondaryAmount': secondaryAmount,
      'isTransactionInPrimary': isTransactionInPrimary == true ? 1 : 0,
      'dollarRate': dollarRate,
      'paymentType': paymentType.name,
      'transactionType': transactionType.name,
      'flow': flow.name,
      'receiptId': receiptId,
      'expenseId': expenseId,
      'customerId': customerId,
      'shiftId': shiftId,
      'note': note,
      "userId": userId,
      "fromCash": fromCash == true ? 1 : 0
    };
  }

  factory FinancialTransactionModel.fromMap(Map<String, dynamic> map) {
    return FinancialTransactionModel(
      id: map['id'] != null ? map['id'] as int : null,
      transactionDate: map['transactionDate'] as String,
      primaryAmount: map['primaryAmount'] as double,
      secondaryAmount: map['secondaryAmount'] != null
          ? map['secondaryAmount'] as double
          : null,
      isTransactionInPrimary: map['isTransactionInPrimary'] == 1 ? true : false,
      dollarRate:
          map['dollarRate'] != null ? map['dollarRate'] as double : null,
      paymentType: map["paymentType"].toString().paymentToEnum(),
      flow: map['flow'].toString().transactionFlowToEnum(),
      transactionType: map["transactionType"].toString().transactionToEnum(),
      receiptId: map['receiptId'] != null ? map['receiptId'] as int : null,
      expenseId: map['expenseId'] != null ? map['expenseId'] as int : null,
      customerId: map['customerId'] != null ? map['customerId'] as int : null,
      shiftId: map['shiftId'] != null ? map['shiftId'] as int : null,
      note: map['note'],
      userId: map['userId'].toString().validateInteger(),
      fromCash: map['fromCash'] == 1 ? true : false,
    );
  }

  factory FinancialTransactionModel.fromReceipt(ReceiptModel receipt) {
    TransactionFlow flow;

    if (receipt.transactionType == TransactionType.withdraw) {
      flow = TransactionFlow.OUT;
    } else {
      flow = TransactionFlow.IN;
    }

    return FinancialTransactionModel(
      transactionDate: receipt.receiptDate,
      primaryAmount: receipt.foreignReceiptPrice ?? 0,
      secondaryAmount: receipt.localReceiptPrice ?? 0,
      isTransactionInPrimary: receipt.isTransactionInPrimary,
      dollarRate: receipt.dollarRate,
      paymentType: receipt.paymentType,
      flow: flow,
      transactionType: receipt.transactionType ?? TransactionType.salePayment,
      receiptId: receipt.id,
      expenseId: receipt.expenseId,
      customerId: receipt.customerId,
      shiftId: receipt.shiftId,
      note: receipt.note,
      userId: receipt.userId ?? 0,
      fromCash: receipt.fromCash,
    );
  }

  FinancialTransactionModel copyWith({
    int? id,
    String? transactionDate,
    double? primaryAmount,
    double? secondaryAmount,
    bool? isTransactionInPrimary,
    double? dollarRate,
    PaymentType? paymentType,
    TransactionFlow? flow,
    TransactionType? transactionType,
    int? receiptId,
    int? expenseId,
    int? customerId,
    int? shiftId,
    String? note,
    int? userId,
    bool? withDrawFromCash,
  }) {
    return FinancialTransactionModel(
      id: id ?? this.id,
      transactionDate: transactionDate ?? this.transactionDate,
      primaryAmount: primaryAmount ?? this.primaryAmount,
      secondaryAmount: secondaryAmount ?? this.secondaryAmount,
      isTransactionInPrimary:
          isTransactionInPrimary ?? this.isTransactionInPrimary,
      dollarRate: dollarRate ?? this.dollarRate,
      paymentType: paymentType ?? this.paymentType,
      flow: flow ?? this.flow,
      transactionType: transactionType ?? this.transactionType,
      receiptId: receiptId ?? this.receiptId,
      expenseId: expenseId ?? this.expenseId,
      customerId: customerId ?? this.customerId,
      shiftId: shiftId ?? this.shiftId,
      note: note ?? this.note,
      userId: userId ?? this.userId,
      fromCash: withDrawFromCash ?? fromCash,
    );
  }
}
