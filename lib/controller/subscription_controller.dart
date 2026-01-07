import 'package:desktoppossystem/models/customers_model.dart';
import 'package:desktoppossystem/models/subscription_model.dart';
import 'package:desktoppossystem/repositories/subscription/subscription_repository.dart';
import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:desktoppossystem/shared/utils/toast_utils.dart';
import 'package:desktoppossystem/shared/utils/type_def.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// State classes for subscription management
class SubscriptionState {
  final List<SubscriptionModel> subscriptions;
  final List<SubscriptionModel> filteredSubscriptions;
  final List<SubscriptionCycleModel> cycles;
  final SubscriptionStatsModel? stats;
  final SubscriptionStatus? selectedStatus; // null means "All"
  final String searchQuery;
  final bool showOverdueOnly;
  final RequestState state;
  final String? errorMessage;
  final bool isLoading;

  const SubscriptionState({
    this.subscriptions = const [],
    this.filteredSubscriptions = const [],
    this.cycles = const [],
    this.stats,
    this.selectedStatus,
    this.searchQuery = '',
    this.showOverdueOnly = false,
    this.state = RequestState.success,
    this.errorMessage,
    this.isLoading = false,
  });

  SubscriptionState copyWith({
    List<SubscriptionModel>? subscriptions,
    List<SubscriptionModel>? filteredSubscriptions,
    List<SubscriptionCycleModel>? cycles,
    SubscriptionStatsModel? stats,
    SubscriptionStatus? selectedStatus,
    bool? clearStatus,
    String? searchQuery,
    bool? showOverdueOnly,
    RequestState? state,
    String? errorMessage,
    bool? isLoading,
  }) {
    return SubscriptionState(
      subscriptions: subscriptions ?? this.subscriptions,
      filteredSubscriptions:
          filteredSubscriptions ?? this.filteredSubscriptions,
      cycles: cycles ?? this.cycles,
      stats: stats ?? this.stats,
      selectedStatus: clearStatus == true
          ? null
          : (selectedStatus ?? this.selectedStatus),
      searchQuery: searchQuery ?? this.searchQuery,
      showOverdueOnly: showOverdueOnly ?? this.showOverdueOnly,
      state: state ?? this.state,
      errorMessage: errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// Provider for subscription management
final subscriptionControllerProvider =
    StateNotifierProvider.autoDispose<
      SubscriptionController,
      SubscriptionState
    >((ref) {
      return SubscriptionController(
        ref: ref,
        subscriptionRepository: ref.read(subscriptionRepositoryProvider),
      );
    });

// Alias provider for backward compatibility with subscription management screens
final subscriptionManagementProvider = subscriptionControllerProvider;

// FutureProvider for subscription stats
final subscriptionStatsProvider = FutureProvider<SubscriptionStatsModel>((
  ref,
) async {
  final repository = ref.read(subscriptionRepositoryProvider);
  final result = await repository.getSubscriptionStats();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (stats) => stats,
  );
});

// FutureProvider for active subscriptions
final activeSubscriptionsProvider = FutureProvider<List<SubscriptionModel>>((
  ref,
) async {
  final repository = ref.read(subscriptionRepositoryProvider);
  final result = await repository.getActiveSubscriptions();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (subscriptions) => subscriptions,
  );
});

// FutureProvider for overdue subscriptions
final overdueSubscriptionsProvider = FutureProvider<List<SubscriptionModel>>((
  ref,
) async {
  final repository = ref.read(subscriptionRepositoryProvider);
  final result = await repository.getOverdueSubscriptions();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (subscriptions) => subscriptions,
  );
});

// FutureProvider for customer subscriptions
final customerSubscriptionsProvider =
    FutureProvider.family<List<SubscriptionModel>, int>((
      ref,
      customerId,
    ) async {
      final repository = ref.read(subscriptionRepositoryProvider);
      final result = await repository.getSubscriptionsByCustomer(customerId);
      return result.fold(
        (failure) => throw Exception(failure.message),
        (subscriptions) => subscriptions,
      );
    });

// FutureProvider for subscription history
final subscriptionHistoryProvider =
    FutureProvider.family<List<SubscriptionCycleModel>, int>((
      ref,
      subscriptionId,
    ) async {
      final repository = ref.read(subscriptionRepositoryProvider);
      final result = await repository.getSubscriptionHistory(subscriptionId);
      return result.fold(
        (failure) => throw Exception(failure.message),
        (history) => history,
      );
    });

class SubscriptionController extends StateNotifier<SubscriptionState> {
  final SubscriptionRepository _subscriptionRepository;

  SubscriptionController({
    required Ref ref,
    required SubscriptionRepository subscriptionRepository,
  }) : _subscriptionRepository = subscriptionRepository,
       super(const SubscriptionState()) {
    loadSubscriptionsWithCustomerInfo();
  }

  // Create new subscription
  Future<void> createSubscription({
    required CustomerModel customer,
    required double monthlyAmount,
    required String startDate,
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      final result = await _subscriptionRepository.createSubscription(
        customer: customer,
        monthlyAmount: monthlyAmount,
        startDate: startDate,
      );

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            state: RequestState.error,
            errorMessage: failure.message,
          );
          ToastUtils.showToast(
            message: failure.message,
            type: RequestState.error,
          );
        },
        (subscription) {
          state = state.copyWith(
            isLoading: false,
            state: RequestState.success,
            subscriptions: [...state.subscriptions, subscription],
          );
          ToastUtils.showToast(
            message: 'Subscription created successfully',
            type: RequestState.success,
          );
          globalAppContext.pop();
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        state: RequestState.error,
        errorMessage: e.toString(),
      );
      ToastUtils.showToast(
        message: 'Failed to create subscription',
        type: RequestState.error,
      );
    }
  }

  // Update subscription status
  Future<void> updateSubscriptionStatus({
    required int subscriptionId,
    required SubscriptionStatus status,
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      final result = await _subscriptionRepository.updateSubscription(
        subscriptionId: subscriptionId,
        status: status.toString(),
      );

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            state: RequestState.error,
            errorMessage: failure.message,
          );
          ToastUtils.showToast(
            message: failure.message,
            type: RequestState.error,
          );
        },
        (_) {
          // Update the subscription in the current state
          final updatedSubscriptions = state.subscriptions.map((sub) {
            if (sub.id == subscriptionId) {
              return SubscriptionModel(
                id: sub.id,
                customerId: sub.customerId,
                startDate: sub.startDate,
                nextPaymentDate: sub.nextPaymentDate,
                status: status,
                monthlyAmount: sub.monthlyAmount,
                lastPaidDate: sub.lastPaidDate,
                createdAt: sub.createdAt,
                updatedAt: DateTime.now().toIso8601String(),
                customerName: sub.customerName,
                customerPhone: sub.customerPhone,
                customerAddress: sub.customerAddress,
              );
            }
            return sub;
          }).toList();

          state = state.copyWith(
            isLoading: false,
            state: RequestState.success,
            subscriptions: updatedSubscriptions,
          );
          ToastUtils.showToast(
            message: 'Subscription status updated',
            type: RequestState.success,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        state: RequestState.error,
        errorMessage: e.toString(),
      );
      ToastUtils.showToast(
        message: 'Failed to update subscription',
        type: RequestState.error,
      );
    }
  }

  // Cancel subscription
  Future<void> cancelSubscription(int subscriptionId) async {
    await updateSubscriptionStatus(
      subscriptionId: subscriptionId,
      status: SubscriptionStatus.canceled,
    );
  }

  // Resume subscription
  Future<void> resumeSubscription(int subscriptionId) async {
    await updateSubscriptionStatus(
      subscriptionId: subscriptionId,
      status: SubscriptionStatus.active,
    );
  }

  // Process subscription payment for unpaid cycles
  Future<void> processSubscriptionPayment({
    required int subscriptionId,
    required int customerId,
    required double amount,
    required int userId,
    required String paymentDate,
    bool isTransactionInPrimary = true,
    double? dollarRate,
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      final result = await _subscriptionRepository.processSubscriptionPayment(
        customerId: customerId,
        subscriptionId: subscriptionId,
        amount: amount,
        userId: userId,
        paymentDate: paymentDate,
        isTransactionInPrimary: isTransactionInPrimary,
        dollarRate: dollarRate,
      );

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            state: RequestState.error,
            errorMessage: failure.message,
          );
          ToastUtils.showToast(
            message: failure.message,
            type: RequestState.error,
          );
        },
        (success) {
          if (success) {
            state = state.copyWith(
              isLoading: false,
              state: RequestState.success,
            );
            ToastUtils.showToast(
              message: 'Payment processed successfully',
              type: RequestState.success,
            );
            // Refresh subscription list to reflect payment
            loadSubscriptionsWithCustomerInfo();
            globalAppContext.pop();
          } else {
            state = state.copyWith(
              isLoading: false,
              state: RequestState.error,
              errorMessage: 'No unpaid cycles found',
            );
            ToastUtils.showToast(
              message: 'No unpaid cycles found for this subscription',
              type: RequestState.error,
            );
          }
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        state: RequestState.error,
        errorMessage: e.toString(),
      );
      ToastUtils.showToast(
        message: 'Failed to process payment',
        type: RequestState.error,
      );
    }
  }

  // Load all subscriptions with customer info for management screen
  Future<void> loadSubscriptionsWithCustomerInfo() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Load subscriptions with customer info
      final subscriptionsResult = await _subscriptionRepository
          .getSubscriptionsWithCustomerInfo();

      // Load stats
      final statsResult = await _subscriptionRepository.getSubscriptionStats();

      subscriptionsResult.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            errorMessage: failure.message,
          );
        },
        (subscriptions) {
          statsResult.fold(
            (failure) {
              state = state.copyWith(
                subscriptions: subscriptions,
                isLoading: false,
                errorMessage: failure.message,
              );
              _applyFilters();
            },
            (stats) {
              state = state.copyWith(
                subscriptions: subscriptions,
                stats: stats,
                isLoading: false,
              );
              _applyFilters();
            },
          );
        },
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  // Filter subscriptions by status
  void filterByStatus(SubscriptionStatus? status) {
    state = state.copyWith(
      selectedStatus: status,
      clearStatus: status == null,
      showOverdueOnly: false,
    );
    _applyFilters();
  }

  // Filter to show only overdue subscriptions
  void filterOverdue() {
    state = state.copyWith(
      showOverdueOnly: true,
      selectedStatus: null,
      clearStatus: true,
    );
    _applyFilters();
  }

  // Search subscriptions by customer name or phone
  void searchSubscriptions(String query) {
    state = state.copyWith(searchQuery: query);
    _applyFilters();
  }

  // Apply both status filter and search query
  void _applyFilters() {
    List<SubscriptionModel> filtered = state.subscriptions;

    // Apply overdue filter first if enabled
    if (state.showOverdueOnly) {
      filtered = filtered
          .where(
            (sub) => sub.status == SubscriptionStatus.active && sub.isOverdue,
          )
          .toList();
    } else if (state.selectedStatus != null) {
      // Apply status filter
      filtered = filtered
          .where((sub) => sub.status == state.selectedStatus)
          .toList();
    }
    // If selectedStatus is null, show all subscriptions (no filter)

    // Apply search filter
    if (state.searchQuery.isNotEmpty) {
      final query = state.searchQuery.toLowerCase();
      filtered = filtered.where((sub) {
        final customerName = (sub.customerName ?? '').toLowerCase();
        final customerPhone = (sub.customerPhone ?? '').toLowerCase();
        return customerName.contains(query) || customerPhone.contains(query);
      }).toList();
    }

    state = state.copyWith(filteredSubscriptions: filtered);
  }

  // Get overdue subscriptions count
  int get overdueCount {
    return state.subscriptions
        .where(
          (sub) => sub.status == SubscriptionStatus.active && sub.isOverdue,
        )
        .length;
  }

  // Get due subscriptions (next payment in next 7 days)
  int get dueCount {
    final today = DateTime.now();
    final nextWeek = today.add(const Duration(days: 7));

    return state.subscriptions.where((sub) {
      if (sub.status != SubscriptionStatus.active) return false;
      final nextPayment = DateTime.parse(sub.nextPaymentDate);
      return nextPayment.isAfter(today) && nextPayment.isBefore(nextWeek);
    }).length;
  }

  // Get overdue subscriptions list
  List<SubscriptionModel> get overdueSubscriptions {
    return state.subscriptions
        .where(
          (sub) => sub.status == SubscriptionStatus.active && sub.isOverdue,
        )
        .toList();
  }

  // Get all subscriptions count by status
  int getCountByStatus(SubscriptionStatus status) {
    return state.subscriptions.where((sub) => sub.status == status).length;
  }

  // Refresh subscription data for management screen
  Future<void> refreshSubscriptions() async {
    await loadSubscriptionsWithCustomerInfo();
  }

  Future<void> generateUnpaidCycles() async {
    try {
      final result = await _subscriptionRepository.generateUnpaidCycles();

      result.fold(
        (failure) {
          debugPrint('Failed to generate unpaid cycles: ${failure.message}');
        },
        (_) {
          debugPrint('Unpaid cycles generated successfully');
          // Refresh data to reflect new cycles
          //  refreshSubscriptionData();
        },
      );
    } catch (e) {
      debugPrint('Error generating unpaid cycles: $e');
    }
  }

  // Get subscription stats
  FutureEither<SubscriptionStatsModel> getSubscriptionStats() {
    return _subscriptionRepository.getSubscriptionStats();
  }

  // Get active subscriptions
  FutureEither<List<SubscriptionModel>> getActiveSubscriptions() {
    return _subscriptionRepository.getActiveSubscriptions();
  }

  // Get overdue subscriptions
  FutureEither<List<SubscriptionModel>> getOverdueSubscriptions() {
    return _subscriptionRepository.getOverdueSubscriptions();
  }

  // Get subscriptions by customer
  FutureEither<List<SubscriptionModel>> getSubscriptionsByCustomer(
    int customerId,
  ) {
    return _subscriptionRepository.getSubscriptionsByCustomer(customerId);
  }

  // Get subscription history
  FutureEither<List<SubscriptionCycleModel>> getSubscriptionHistory(
    int subscriptionId,
  ) {
    return _subscriptionRepository.getSubscriptionHistory(subscriptionId);
  }

  // Get unpaid cycles
  FutureEither<List<SubscriptionCycleModel>> getUnpaidCycles(
    int subscriptionId,
  ) {
    return _subscriptionRepository.getUnpaidCycles(subscriptionId);
  }

  // Get subscription by ID
  FutureEither<SubscriptionModel?> getSubscriptionById(int subscriptionId) {
    return _subscriptionRepository.getSubscriptionById(subscriptionId);
  }

  // Get subscriptions with customer info
  FutureEither<List<SubscriptionModel>> getSubscriptionsWithCustomerInfo() {
    return _subscriptionRepository.getSubscriptionsWithCustomerInfo();
  }

  // // Refresh subscription data
  // Future<void> refreshSubscriptionData() async {
  //   state = state.copyWith(isLoading: true, subscriptions: []);

  //   try {
  //     final subscriptionsResult = await _subscriptionRepository
  //         .getSubscriptionsWithCustomerInfo();
  //     final statsResult = await _subscriptionRepository.getSubscriptionStats();

  //     subscriptionsResult.fold(
  //       (failure) {
  //         state = state.copyWith(
  //           isLoading: false,
  //           state: RequestState.error,
  //           errorMessage: failure.message,
  //         );
  //       },
  //       (subscriptions) {
  //         statsResult.fold(
  //           (failure) {
  //             state = state.copyWith(
  //               isLoading: false,
  //               state: RequestState.success,
  //               subscriptions: subscriptions,
  //             );
  //           },
  //           (stats) {
  //             state = state.copyWith(
  //               isLoading: false,
  //               state: RequestState.success,
  //               subscriptions: subscriptions,
  //               stats: stats,
  //             );
  //           },
  //         );
  //       },
  //     );
  //   } catch (e) {
  //     state = state.copyWith(
  //       isLoading: false,
  //       state: RequestState.error,
  //       errorMessage: e.toString(),
  //     );
  //   }
  // }

  // Load subscriptions for a specific customer
  Future<void> loadCustomerSubscriptions(int customerId) async {
    state = state.copyWith(isLoading: true);

    try {
      final result = await _subscriptionRepository.getSubscriptionsByCustomer(
        customerId,
      );

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            state: RequestState.error,
            errorMessage: failure.message,
          );
        },
        (subscriptions) {
          state = state.copyWith(
            isLoading: false,
            state: RequestState.success,
            subscriptions: subscriptions,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        state: RequestState.error,
        errorMessage: e.toString(),
      );
    }
  }

  // Clear error state
  void clearError() {
    state = state.copyWith(state: RequestState.success, errorMessage: null);
  }

  // Reset state
  void resetState() {
    state = const SubscriptionState();
  }
}
