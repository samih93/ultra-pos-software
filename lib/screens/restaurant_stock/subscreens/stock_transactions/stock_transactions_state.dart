import 'package:desktoppossystem/models/stock_transaction_model.dart';
import 'package:desktoppossystem/repositories/restaurant_stock/restaurant_stock_repository.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedstockTransactionDateProvider = StateProvider<DateTime>((ref) {
  return DateTime.now();
});
final stockInProvider = Provider<List<StockTransactionModel>>((ref) {
  final allTransactions = ref.watch(stockTransactionsProvider).value ?? [];
  return allTransactions
      .where((t) => t.transactionType == StockTransactionType.stockIn)
      .toList();
});

final wasteOutProvider = Provider<List<StockTransactionModel>>((ref) {
  final allTransactions = ref.watch(stockTransactionsProvider).value ?? [];
  return allTransactions
      .where((t) => t.transactionType == StockTransactionType.stockOut)
      .toList();
});
final stockTransactionsProvider =
    FutureProvider<List<StockTransactionModel>>((ref) async {
  final date = ref.watch(selectedstockTransactionDateProvider);
  final response = await ref
      .read(restaurantProviderRepository)
      .fetchStockTransactionsByDate(date);
  return response.fold(
    (l) => throw Exception(),
    (r) => r,
  );
});
