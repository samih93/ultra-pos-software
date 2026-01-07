import 'package:desktoppossystem/models/expense_model.dart';
import 'package:desktoppossystem/repositories/expenses/expenses_repository.dart';
import 'package:desktoppossystem/shared/utils/toast_utils.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final expensesControllerProvider =
    ChangeNotifierProvider<ExpensesController>((ref) {
  return ExpensesController(ref: ref);
});

// final fixedExpensesProvider = FutureProvider<List<ExpenseModel>>((ref) async {
//   final fetchfixedResponse =
//       await ref.read(expenseProviderRepository).fetchFixedMonthlyExpense();
//   List<ExpenseModel> expenses = [];
//   await fetchfixedResponse.fold<Future>(
//     (l) async => 0,
//     (r) async {
//       expenses = r;
//       // for (var e in r) {
//       //   if (e.isFixedMonthly == true) {
//       //     total += e.isTransactionInPrimary == true
//       //         ? e.fixedMonthlyAmount!
//       //         : (e.fixedMonthlyAmount! /
//       //             (ref.read(saleControllerProvider).dolarRate));
//       //   }
//       // }
//     },
//   );
//   return expenses;
// });

class ExpensesController extends ChangeNotifier {
  final Ref _ref;
  ExpensesController({required Ref ref}) : _ref = ref {
    fetchAllExpenses();
  }

  Future addExpense(String expense) async {
    ExpenseModel expenseModel =
        ExpenseModel(expensePurpose: expense.toLowerCase(), expenseAmount: 0);

    if (expense.isNotEmpty) {
      final addResponse = await _ref
          .read(expenseProviderRepository)
          .addExpensesItem(expenseModel);
      addResponse.fold(
        (l) {
          ToastUtils.showToast(message: l.message, type: RequestState.error);
        },
        (r) {
          allExpenses.add(r);
          dialogExpensesList.add(r);
          notifyListeners();
        },
      );
    }
  }

  List<ExpenseModel> allExpenses = [];
  RequestState fetchAllExpensesRequestState = RequestState.success;
  Future fetchAllExpenses() async {
    fetchAllExpensesRequestState = RequestState.loading;
    allExpenses = [];

    notifyListeners();
    final fetchResponse =
        await _ref.read(expenseProviderRepository).fetchAllExpenses();
    fetchResponse.fold(
      (l) {
        debugPrint(l.message);
        allExpenses = [];

        fetchAllExpensesRequestState = RequestState.success;
        notifyListeners();
      },
      (r) {
        allExpenses = r;
        dialogExpensesList = allExpenses;
        fetchAllExpensesRequestState = RequestState.success;
        notifyListeners();
        print("Fetched all expenses");
      },
    );
  }

  Future updateExpenseName(
      ExpenseModel expenseModel, BuildContext context) async {
    final updateResponse = await _ref
        .read(expenseProviderRepository)
        .updateExpenseName(expenseModel);

    updateResponse.fold(
      (l) {
        ToastUtils.showToast(message: l.message, type: RequestState.error);
      },
      (r) {
        updateExpenseInTemp(expenseModel);
        context.pop();
      },
    );
  }

  List<ExpenseModel> dialogExpensesList = [];

  Future updateFixedExpense(
      ExpenseModel expenseModel, BuildContext context) async {
    final updateResponse = await _ref
        .read(expenseProviderRepository)
        .updateExpenseModel(expenseModel);

    updateResponse.fold(
      (l) {
        ToastUtils.showToast(message: l.message, type: RequestState.error);
      },
      (r) {
        updateExpenseInTemp(expenseModel);

        context.pop();
      },
    );
  }

  updateExpenseInTemp(ExpenseModel expenseModel) {
    for (var i = 0; i < allExpenses.length; i++) {
      if (allExpenses[i].id == expenseModel.id) {
        allExpenses[i] = allExpenses[i].copyWith(
            expensePurpose: expenseModel.expensePurpose,
            isTransactionInPrimary: expenseModel.isTransactionInPrimary);
      }
    }
    notifyListeners();
  }

  clearSearchInExpense() {
    dialogExpensesList = allExpenses;
    notifyListeners();
  }

  onSearchInExpenses(String query) {
    if (query.trim() == "") {
      dialogExpensesList = allExpenses;
    } else {
      dialogExpensesList = allExpenses
          .where((element) => element.expensePurpose
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    }
    notifyListeners();
  }

  Future deleteExpense(ExpenseModel expenseModel, BuildContext context) async {
    final deleteResponse = await _ref
        .read(expenseProviderRepository)
        .deleteExpense(expenseModel.id!);
    deleteResponse.fold((l) {
      ToastUtils.showToast(message: l.message, type: RequestState.error);
    }, (r) {
      allExpenses.remove(expenseModel);

      context.pop();
      notifyListeners();
    });
  }
}
