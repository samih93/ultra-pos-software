import 'package:desktoppossystem/models/failure_model.dart';
import 'package:desktoppossystem/models/financial_transaction_model.dart';
import 'package:desktoppossystem/models/receipt_model.dart';
import 'package:desktoppossystem/shared/constances/table_constant.dart';
import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/services/dependency_injection.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/type_def.dart';
import 'package:fpdart/fpdart.dart';

abstract interface class FinancialTransactionService {
  FutureEitherVoid addTransaction({required ReceiptModel receiptModel});
  factory FinancialTransactionService(TransactionType transaction) {
    switch (transaction) {
      case TransactionType.salePayment:
        return SalePaymentTransaction();
      case TransactionType.pendingPayment:
        return PendingPaymentTransaction();
      // // Add more cases as needed
      default:
        return SalePaymentTransaction();
    }
  }
}

class SalePaymentTransaction implements FinancialTransactionService {
  @override
  FutureEitherVoid addTransaction({required ReceiptModel receiptModel}) async {
    try {
      var transaction = FinancialTransactionModel.fromReceipt(receiptModel);
      transaction =
          transaction.copyWith(transactionType: TransactionType.salePayment);
      await globalAppWidgetRef
          .read(posDbProvider)
          .database
          .insert(TableConstant.financialTransactionTable, transaction.toMap());
      return right(null);
    } catch (e) {
      print("Error adding financial transaction: $e");

      return left(FailureModel(e.toString()));
    }
  }
}

class PendingPaymentTransaction implements FinancialTransactionService {
  @override
  FutureEitherVoid addTransaction({required ReceiptModel receiptModel}) async {
    try {
      var transaction = FinancialTransactionModel.fromReceipt(receiptModel);
      transaction =
          transaction.copyWith(transactionType: TransactionType.pendingPayment);
      await globalAppWidgetRef
          .read(posDbProvider)
          .database
          .insert(TableConstant.financialTransactionTable, transaction.toMap());
      return right(null);
    } catch (e) {
      print("Error adding financial transaction: $e");

      return left(FailureModel(e.toString()));
    }
  }
}
