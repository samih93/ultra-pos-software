import 'package:desktoppossystem/models/failure_model.dart';
import 'package:desktoppossystem/models/financial_transaction_model.dart';
import 'package:desktoppossystem/shared/constances/auth_role.dart';
import 'package:desktoppossystem/shared/constances/table_constant.dart';
import 'package:desktoppossystem/shared/services/dependency_injection.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/type_def.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

final financialTransactionProviderRepository = Provider((ref) {
  return FinancialTransactionRepository(ref);
});

abstract class IFinancialTransactionRepository {
  FutureEither<int> addFinancialTransaction(
    FinancialTransactionModel transaction,
  );
  Future<List<FinancialTransactionModel>> getFinancialTransactions();
  Future<void> updateFinancialTransaction(
    FinancialTransactionModel transaction,
  );
  Future<void> deleteFinancialTransactionById(int id);
  Future<void> deleteFinancialTransactionByReceiptId(int id);

  // deposit , withdraw
  FutureEither<List<FinancialTransactionModel>> fetchTransactionsByDay({
    required DateTime currentDate,
    required int userId,
    required String role,
    int? filterUserId,
  });
}

class FinancialTransactionRepository
    implements IFinancialTransactionRepository {
  final Ref ref;
  FinancialTransactionRepository(this.ref);
  @override
  FutureEither<int> addFinancialTransaction(
    FinancialTransactionModel transaction,
  ) async {
    try {
      final transactionId = await ref
          .read(posDbProvider)
          .database
          .insert(TableConstant.financialTransactionTable, transaction.toMap());
      return right(transactionId);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  Future<void> deleteFinancialTransactionById(int id) async {
    print("id $id");
    await ref.read(posDbProvider).database.rawDelete(
      "delete from ${TableConstant.financialTransactionTable} where id=?",
      ['$id'],
    );
  }

  @override
  Future<void> deleteFinancialTransactionByReceiptId(int id) async {
    print("id $id");
    await ref.read(posDbProvider).database.rawDelete(
      "delete from ${TableConstant.financialTransactionTable} where receiptId=?",
      ['$id'],
    );
  }

  @override
  Future<List<FinancialTransactionModel>> getFinancialTransactions() {
    throw UnimplementedError();
  }

  @override
  Future<void> updateFinancialTransaction(
    FinancialTransactionModel transaction,
  ) {
    throw UnimplementedError();
  }

  @override
  FutureEither<List<FinancialTransactionModel>> fetchTransactionsByDay({
    required DateTime currentDate,
    required int userId,
    required String role,
    int? filterUserId,
  }) async {
    List<FinancialTransactionModel> transactions = [];
    String query =
        "CAST(SUBSTR(transactionDate, 1, 4) AS integer)=${currentDate.year} AND "
        "CAST(SUBSTR(transactionDate, 6, 7) AS integer)=${currentDate.month} AND "
        "CAST(SUBSTR(transactionDate, 9, 10) AS integer)=${currentDate.day}";
    if (role == AuthRole.userRole) {
      query += " AND userId=$userId";
    } else if ((role == AuthRole.adminRole ||
            role == AuthRole.superAdminRole) &&
        filterUserId != null) {
      query += " AND userId=$filterUserId";
    }
    query +=
        " and (transactionType ='${TransactionType.deposit.name}' or transactionType='${TransactionType.withdraw.name}' or transactionType='${TransactionType.pendingPayment.name}' or transactionType='${TransactionType.purchase.name}' or transactionType='${TransactionType.refund.name}' or transactionType='${TransactionType.subscriptionPayment.name}')";
    try {
      final response = await ref
          .read(posDbProvider)
          .database
          .rawQuery(
            "SELECT * from ${TableConstant.financialTransactionTable} WHERE $query",
          );
      transactions = List.from(
        response.map((e) => FinancialTransactionModel.fromMap(e)),
      );
      return right(transactions);
    } catch (e) {
      print(e.toString());
      return left(FailureModel(e.toString()));
    }
  }
}
