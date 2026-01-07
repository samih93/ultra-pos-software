import 'package:desktoppossystem/models/notification_model.dart';
import 'package:desktoppossystem/repositories/products/product_repository.dart';
import 'package:desktoppossystem/repositories/receipts/receiptrepository.dart';
import 'package:desktoppossystem/repositories/restaurant_stock/restaurant_stock_repository.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final notificationControllerProvider =
    ChangeNotifierProvider<NotificationController>((ref) {
  return NotificationController();
});

class NotificationController extends ChangeNotifier {
  RequestState exportNotificationsRequestState = RequestState.success;

  Future exportNotificationsToExcel(
      List<NotificationModel> notifications, String title) async {
    exportNotificationsRequestState = RequestState.loading;
    notifyListeners();

    try {
      await generateNotificationsExcel(notifications, title);
      exportNotificationsRequestState = RequestState.success;
      notifyListeners();
    } catch (e) {
      exportNotificationsRequestState = RequestState.error;
      notifyListeners();
    }
  }
}

/// ! MARKET
void refreshNotifications() {
  final ref = globalAppWidgetRef as WidgetRef;
  final isRestaurant = ref.read(mainControllerProvider).isWorkWithIngredients;
  if (isRestaurant) {
    ref.refresh(restaurantNotificationCountProvider);
    ref.refresh(futureRestaurantLowStockProvider);
    ref.refresh(futurePendingReceiptsNotification);
    ref.refresh(futureRestaurantExpiredStockProvider);
  } else {
    ref.refresh(marketNotificationCountProvider);
    ref.refresh(futurePendingReceiptsNotification);
    ref.refresh(futureMarketLowStockProvider);
    ref.refresh(futureMarketOutOfStockProvider);
    ref.refresh(futureMarketExpiredStockProvider);
  }
}

final marketNotificationCountProvider =
    FutureProvider.autoDispose<int>((ref) async {
  var nbOfMonths = ref.watch(nbOfMonthsProvider);

  final response = await ref
      .read(productProviderRepository)
      .fetchMarketNotificationCounts(nbOfMonths);
  return response.fold(
    (l) => throw Exception(l.message),
    (r) => r,
  );
});

final futurePendingReceiptsNotification =
    FutureProvider.autoDispose<List<NotificationModel>>((ref) async {
  final response = await ref
      .read(receiptProviderRepository)
      .fetchPendingReceiptsNotifications();
  return response.fold(
    (l) => throw Exception(l.message),
    (r) => r,
  );
});

final futureMarketLowStockProvider =
    FutureProvider.autoDispose<List<NotificationModel>>((ref) async {
  final response =
      await ref.read(productProviderRepository).fetchMarketLowStockList();
  return response.fold(
    (l) => throw Exception(l.message),
    (r) => r,
  );
});
final futureMarketOutOfStockProvider =
    FutureProvider.autoDispose<List<NotificationModel>>((ref) async {
  final response =
      await ref.read(productProviderRepository).fetchMarketOutOfStockProducts();
  return response.fold(
    (l) => throw Exception(l.message),
    (r) => r,
  );
});

final nbOfMonthsProvider = StateProvider<int>((ref) {
  return 1;
});
final futureMarketExpiredStockProvider =
    FutureProvider.autoDispose<List<NotificationModel>>((ref) async {
  var nbOfMonths = ref.watch(nbOfMonthsProvider);
  final response = await ref
      .read(productProviderRepository)
      .fetchMarketExpiryDateProducts(nbOfMonths);
  return response.fold(
    (l) => throw Exception(l.message),
    (r) => r,
  );
});

///MARK:! RESTAURANT

final restaurantNotificationCountProvider =
    FutureProvider.autoDispose<int>((ref) async {
  var nbOfMonths = ref.watch(nbOfMonthsProvider);

  final response = await ref
      .read(restaurantProviderRepository)
      .fetchRestaurantNotificationCounts(nbOfMonths);
  return response.fold(
    (l) => throw Exception(l.message),
    (r) => r,
  );
});

final futureRestaurantLowStockProvider =
    FutureProvider.autoDispose<List<NotificationModel>>((ref) async {
  final response = await ref
      .read(restaurantProviderRepository)
      .fetchRestaurantLowStockList();
  return response.fold(
    (l) => throw Exception(l.message),
    (r) => r,
  );
});

final futureRestaurantExpiredStockProvider =
    FutureProvider.autoDispose<List<NotificationModel>>((ref) async {
  var nbOfMonths = ref.watch(nbOfMonthsProvider);
  final response = await ref
      .read(restaurantProviderRepository)
      .fetchRestaurantExpiryDateProducts(nbOfMonths);
  return response.fold(
    (l) => throw Exception(l.message),
    (r) => r,
  );
});
