import 'package:flutter/material.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class ExpenseModel {
  int? id;
  String expensePurpose;
  double expenseAmount;
  Color? expenseColor;
  bool? isTransactionInPrimary = true;
  bool? withDrawFromCash;
  // bool? isFixedMonthly;
  // double? fixedMonthlyAmount;
  ExpenseModel({
    this.id,
    required this.expensePurpose,
    required this.expenseAmount,
    this.expenseColor,
    this.isTransactionInPrimary,
    this.withDrawFromCash,
    //   this.isFixedMonthly,
    //   this.fixedMonthlyAmount,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'expensePurpose': expensePurpose.toLowerCase(),
      //'isTransactionInPrimary': isTransactionInPrimary == true ? 1 : 0,
      // 'isFixedMonthly': isFixedMonthly == true ? 1 : 0,
      //   'fixedMonthlyAmount': fixedMonthlyAmount,
    };
  }

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id'] as int,
      expensePurpose: map['expensePurpose'] as String,
      expenseAmount: map['expenseAmount'] ?? 0,
      isTransactionInPrimary: map['isTransactionInPrimary'] == 1 ? true : false,
      //  withDrawFromCash: map['withDrawFromCash'] == 1 ? true : false,
      //  isFixedMonthly: map['isFixedMonthly'] == 1 ? true : false,
      //   fixedMonthlyAmount: map['fixedMonthlyAmount'] != null
      //       ? map['fixedMonthlyAmount'] as double
      //     : null,
    );
  }

  ExpenseModel copyWith({
    int? id,
    String? expensePurpose,
    double? expenseAmount,
    Color? expenseColor,
    bool? isTransactionInPrimary,
    bool? withDrawFromCash,
    bool? isFixedMonthly,
    double? fixedMonthlyAmount,
  }) {
    return ExpenseModel(
      id: id ?? this.id,
      expensePurpose: expensePurpose ?? this.expensePurpose,
      expenseAmount: expenseAmount ?? this.expenseAmount,
      expenseColor: expenseColor ?? this.expenseColor,
      isTransactionInPrimary:
          isTransactionInPrimary ?? this.isTransactionInPrimary,
      withDrawFromCash: withDrawFromCash ?? this.withDrawFromCash,
      // isFixedMonthly: isFixedMonthly ?? this.isFixedMonthly,
      //   fixedMonthlyAmount: fixedMonthlyAmount ?? this.fixedMonthlyAmount,
    );
  }
}
