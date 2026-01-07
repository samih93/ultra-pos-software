import 'package:collection/collection.dart';
import 'package:desktoppossystem/models/expense_model.dart';
import 'package:desktoppossystem/models/failure_model.dart';
import 'package:desktoppossystem/models/financial_transaction_model.dart';
import 'package:desktoppossystem/shared/constances/table_constant.dart';
import 'package:desktoppossystem/shared/services/dependency_injection.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/type_def.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

final expenseProviderRepository = Provider((ref) {
  return ExpensesRepository(ref);
});

abstract class IExpensesRepository {
  FutureEither<ExpenseModel> addExpensesItem(ExpenseModel expenseModel);
  FutureEither<ExpenseModel> editExpensesItem(ExpenseModel expenseModel);
  FutureEither<List<ExpenseModel>> fetchAllExpenses();
  FutureEitherVoid deleteExpense(int expenseId);
  FutureEither<ExpenseModel> updateExpenseName(ExpenseModel expenseModel);
  FutureEither<ExpenseModel> updateExpenseModel(ExpenseModel expenseModel);
  Future<bool> isExsist(String expensePurpose);
  FutureEither<List<ExpenseModel>> fetchFixedMonthlyExpense();
  FutureEither<List<ExpenseModel>> getExpensesForProfitReport({
    ReportInterval? view,
    String? date,
  });
  FutureEither<List<ExpenseModel>> fetchExpensesByIdForProfitReport({
    ReportInterval? view,
    String? date,
    int? expenseId,
  });
}

class ExpensesRepository extends IExpensesRepository {
  final Ref ref;
  ExpensesRepository(this.ref);

  @override
  FutureEither<ExpenseModel> addExpensesItem(ExpenseModel expenseModel) async {
    try {
      ExpenseModel itemModel;
      bool exist = await isExsist(expenseModel.expensePurpose.trim());
      if (exist) {
        return left(FailureModel("expense type already exist"));
      }
      final insertedId = await ref
          .read(posDbProvider)
          .database
          .insert(TableConstant.expensesTable, expenseModel.toMap());

      itemModel = expenseModel;
      itemModel.id = insertedId;
      return right(itemModel);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<ExpenseModel> editExpensesItem(ExpenseModel expenseModel) async {
    try {
      ExpenseModel item;
      bool exist = await isExsist(expenseModel.expensePurpose.trim());
      if (exist) {
        return left(FailureModel("expense type already exist"));
      }
      await ref
          .read(posDbProvider)
          .database
          .update(TableConstant.expensesTable, expenseModel.toMap());
      item = expenseModel;
      return right(item);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<List<ExpenseModel>> fetchAllExpenses() async {
    try {
      List<ExpenseModel> list = [];

      await ref
          .read(posDbProvider)
          .database
          .query(TableConstant.expensesTable)
          .then((response) {
            list = List.from((response).map((e) => ExpenseModel.fromMap(e)));
          });

      return right(list);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEitherVoid deleteExpense(int expenseId) async {
    try {
      bool isUsedAsTransaction = await isExpenseUsed(expenseId);
      if (isUsedAsTransaction) {
        return left(FailureModel("expense already used in transactions"));
      }

      await ref.read(posDbProvider).database.rawDelete(
        "delete from ${TableConstant.expensesTable} where id=?",
        ['$expenseId'],
      );
      return right(null);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<ExpenseModel> updateExpenseName(
    ExpenseModel expenseModel,
  ) async {
    try {
      bool exist = await isExsist(expenseModel.expensePurpose.trim());
      if (exist) {
        return left(FailureModel("expense type already exist"));
      }
      await ref
          .read(posDbProvider)
          .database
          .rawUpdate(
            "update ${TableConstant.expensesTable} set expensePurpose='${expenseModel.expensePurpose}' where id=${expenseModel.id}",
          );

      return right(expenseModel);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<ExpenseModel> updateExpenseModel(
    ExpenseModel expenseModel,
  ) async {
    try {
      await ref
          .read(posDbProvider)
          .database
          .update(
            TableConstant.expensesTable,
            expenseModel.toMap(),
            where: "id=${expenseModel.id}",
          );

      return right(expenseModel);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  Future<bool> isExsist(String expensePurpose) async {
    try {
      final result = await ref
          .read(posDbProvider)
          .database
          .query(
            TableConstant.expensesTable,
            where: "expensePurpose='$expensePurpose'",
          );

      if (result.isNotEmpty) {
        debugPrint("is not empty");
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isExpenseUsed(int id) async {
    try {
      final result = await ref
          .read(posDbProvider)
          .database
          .query(TableConstant.receiptTable, where: "expenseId=$id");

      if (result.isNotEmpty) {
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  @override
  FutureEither<List<ExpenseModel>> fetchFixedMonthlyExpense() async {
    try {
      List<ExpenseModel> list = [];

      await ref
          .read(posDbProvider)
          .database
          .query(TableConstant.expensesTable, where: "isFixedMonthly =1")
          .then((response) {
            list = List.from((response).map((e) => ExpenseModel.fromMap(e)));
          });

      return right(list);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<List<ExpenseModel>> getExpensesForProfitReport({
    ReportInterval? view,
    String? date,
  }) async {
    List<ExpenseModel> expenses = [];
    try {
      String query =
          "select  * from  ${TableConstant.financialTransactionTable} as f left join ${TableConstant.expensesTable} as e on e.id = f.expenseId where transactionType='${TransactionType.withdraw.name}' ";
      DateTime currentDate = date != null
          ? DateTime.parse(date)
          : DateTime.now();
      if (view != null) {
        switch (view) {
          case ReportInterval.daily:
            query +=
                " and CAST(SUBSTR(f.transactionDate, 9, 11) AS integer)=${currentDate.day} and CAST(SUBSTR(f.transactionDate, 6, 8) AS integer)=${currentDate.month} and CAST(SUBSTR(f.transactionDate, 1, 4) AS integer)=${currentDate.year}";

            break;
          case ReportInterval.monthly:
            query +=
                "  and CAST(SUBSTR(f.transactionDate, 6, 8) AS integer)=${currentDate.month} and CAST(SUBSTR(f.transactionDate, 1, 4) AS integer)=${currentDate.year}";
            break;
          case ReportInterval.yearly:
            query +=
                "  and  CAST(SUBSTR(f.transactionDate, 1, 4) AS integer)=${currentDate.year}";
            break;
        }
      } else {
        query +=
            " and CAST(SUBSTR(f.transactionDate, 9, 11) AS integer)=${currentDate.day} and CAST(SUBSTR(f.transactionDate, 6, 8) AS integer)=${currentDate.month} and CAST(SUBSTR(f.transactionDate, 1, 4) AS integer)=${currentDate.year}";
      }

      List<FinancialTransactionModel> transactions = [];
      await ref.read(posDbProvider).database.rawQuery(query).then((value) {
        if (value.isNotEmpty) {
          transactions = List.from(
            (value as List).map((e) => FinancialTransactionModel.fromMap(e)),
          );

          var groupedByExpenseType = groupBy(transactions, (obj) => obj.note);
          groupedByExpenseType.forEach((key, value) async {
            double amount = 0;
            String note = key.toString();
            ExpenseModel expenseModel = ExpenseModel(
              id: value[0].expenseId,
              expensePurpose: note,
              expenseAmount: 0,
            );
            for (var receipt in value) {
              if (receipt.primaryAmount == 0) {
                amount +=
                    receipt.secondaryAmount! /
                    (receipt.dollarRate == 0 ? 1 : receipt.dollarRate!);
              } else {
                amount += receipt.primaryAmount;
              }
              expenseModel.expenseAmount = amount;
            }
            expenses.add(expenseModel);
          });
        }
      });
      return right(expenses);
    } catch (e) {
      debugPrint("error $e");
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<List<ExpenseModel>> fetchExpensesByIdForProfitReport({
    ReportInterval? view,
    String? date,
    int? expenseId,
  }) async {
    try {
      String query =
          "select  * from  ${TableConstant.financialTransactionTable} as f left join ${TableConstant.expensesTable} as e on e.id = f.expenseId where transactionType='${TransactionType.withdraw.name}' and f.expenseId=$expenseId ";
      DateTime currentDate = date != null
          ? DateTime.parse(date)
          : DateTime.now();
      if (view != null) {
        switch (view.name) {
          case "daily":
            query +=
                " and CAST(SUBSTR(f.transactionDate, 9, 11) AS integer)=${currentDate.day} and CAST(SUBSTR(f.transactionDate, 6, 8) AS integer)=${currentDate.month} and CAST(SUBSTR(f.transactionDate, 1, 4) AS integer)=${currentDate.year}";

            break;
          case "monthly":
            query +=
                "  and CAST(SUBSTR(f.transactionDate, 6, 8) AS integer)=${currentDate.month} and CAST(SUBSTR(f.transactionDate, 1, 4) AS integer)=${currentDate.year}";
            break;
          case "yearly":
            query +=
                "  and  CAST(SUBSTR(f.transactionDate, 1, 4) AS integer)=${currentDate.year}";
            break;
        }
      } else {
        query +=
            " and CAST(SUBSTR(f.transactionDate, 9, 11) AS integer)=${currentDate.day} and CAST(SUBSTR(f.transactionDate, 6, 8) AS integer)=${currentDate.month} and CAST(SUBSTR(f.transactionDate, 1, 4) AS integer)=${currentDate.year}";
      }

      query += " order by f.transactionDate";

      final response = await ref.read(posDbProvider).database.rawQuery(query);

      List<FinancialTransactionModel> receipts = List.from(
        (response as List).map((e) => FinancialTransactionModel.fromMap(e)),
      );
      List<ExpenseModel> expenses = [];

      for (var receipt in receipts) {
        double amount = 0;
        if (receipt.primaryAmount == 0) {
          amount +=
              receipt.secondaryAmount! /
              (receipt.dollarRate == 0 ? 1 : receipt.dollarRate!);
        } else {
          amount += receipt.primaryAmount;
        }
        ExpenseModel expenseModel = ExpenseModel(
          expensePurpose: receipt.transactionDate.toString(),
          expenseAmount: amount,
        );
        expenses.add(expenseModel);
      }

      return right(expenses);
    } catch (e) {
      debugPrint("error $e");
      return left(FailureModel(e.toString()));
    }
  }
}
