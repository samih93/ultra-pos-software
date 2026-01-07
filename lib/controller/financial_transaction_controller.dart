import 'package:desktoppossystem/controller/auth_controller.dart';
import 'package:desktoppossystem/controller/receipt_controller.dart';
import 'package:desktoppossystem/models/expense_model.dart';
import 'package:desktoppossystem/models/financial_transaction_model.dart';
import 'package:desktoppossystem/repositories/financial_transaction.dart/financial_transaction_repository.dart';
import 'package:desktoppossystem/screens/daily%20sales/daily_financial_screen.dart';
import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final financialTransactionControllerProvider =
    ChangeNotifierProvider<FinancialTransactionController>((ref) {
  return FinancialTransactionController(
      ref.read(financialTransactionProviderRepository), ref);
});

final futureDailyTransactionProvider = FutureProvider.autoDispose
    .family<List<FinancialTransactionModel>, DateTime>((ref, date) async {
  final userModel = ref.read(currentUserProvider);
  final filterId = ref.watch(salesSelectedUser)?.id;
  final response = await ref
      .read(financialTransactionProviderRepository)
      .fetchTransactionsByDay(
          currentDate: date,
          userId: userModel!.id!,
          role: userModel.role!.name,
          filterUserId: filterId);
  return response.fold((l) => throw Exception(l.message), (r) => r);
});

class FinancialTransactionController extends ChangeNotifier {
  final Ref ref;
  final IFinancialTransactionRepository financialTransactionRepository;
  FinancialTransactionController(this.financialTransactionRepository, this.ref);

  bool isloadingAddAmount = false;

  bool isPrimaryCurrency = true;
  TransactionType selectedTransactionType = TransactionType.deposit;
  var receiptAmountTextController = TextEditingController();
  ExpenseModel? selectedExpense;
  var noteTextController = TextEditingController();
  bool withDrawFromCash = false;

  clearSelectedExpense() {
    noteTextController.clear();
    selectedExpense = null;
    notifyListeners();
  }

  resetTransactionDialog() {
    noteTextController.clear();
    receiptAmountTextController.clear();
    selectedExpense = null;
    withDrawFromCash = false;
    notifyListeners();
  }

  onSelectExpense(ExpenseModel expenseModel) {
    selectedExpense = expenseModel;
    noteTextController.text = expenseModel.expensePurpose;
    notifyListeners();
  }

  bool isPaymentTypeWithDraw = false;
  onchangePaymentType() {
    isPaymentTypeWithDraw = !isPaymentTypeWithDraw;
    selectedTransactionType = isPaymentTypeWithDraw
        ? TransactionType.withdraw
        : TransactionType.deposit;
    if (selectedTransactionType == TransactionType.deposit) {
      withDrawFromCash = false;
    }

    notifyListeners();
  }

  onchangeWithDrawFromCash({bool? value}) {
    withDrawFromCash = value ?? !withDrawFromCash;
    notifyListeners();
  }

  onchangePrimaryCurrencyCurrency() {
    isPrimaryCurrency = !isPrimaryCurrency;
    notifyListeners();
  }

  Future<void> addFinancialTransaction(FinancialTransactionModel transaction,
      {bool? withoutNotification}) async {
    final response = await financialTransactionRepository
        .addFinancialTransaction(transaction);
    response.fold(
      (l) {
        ToastUtils.showToast(message: l.message, type: RequestState.error);
      },
      (r) {
        if (withoutNotification != true) {
          ToastUtils.showToast(
              message: "Transaction added successfully",
              type: RequestState.success);
        }
        ref.refresh(futureReceiptTotalsProvider);
        ref.refresh(futureDailyTransactionProvider(
            ref.read(salesSelectedDateProvider)));
      },
    );
    notifyListeners();
  }

  Future<void> deleteTransaction(
      int transactionId, BuildContext context) async {
    try {
      final deleteRes = await financialTransactionRepository
          .deleteFinancialTransactionById(transactionId);
      ToastUtils.showToast(message: "Transaction $successDeletedStatusMessage");
      ref.refresh(
          futureDailyTransactionProvider(ref.read(salesSelectedDateProvider)));
      ref.refresh(futureReceiptTotalsProvider);
    } catch (e) {
      ToastUtils.showToast(message: "Error deleting Transaction");
    }
  }
}
