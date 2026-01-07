import 'package:desktoppossystem/controller/auth_controller.dart';
import 'package:desktoppossystem/controller/receipt_controller.dart';
import 'package:desktoppossystem/models/customers_model.dart';
import 'package:desktoppossystem/models/failure_model.dart';
import 'package:desktoppossystem/models/financial_transaction_model.dart';
import 'package:desktoppossystem/models/reports/subscribtion_state_model.dart';
import 'package:desktoppossystem/models/subscription_model.dart';
import 'package:desktoppossystem/repositories/financial_transaction.dart/financial_transaction_repository.dart';
import 'package:desktoppossystem/shared/constances/table_constant.dart';
import 'package:desktoppossystem/shared/services/dependency_injection.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:desktoppossystem/shared/utils/type_def.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

// Provider for subscription repository
final subscriptionRepositoryProvider = Provider((ref) {
  return SubscriptionRepository(ref);
});

// Interface for subscription repository
abstract class ISubscriptionRepository {
  // Subscription management
  FutureEither<SubscriptionModel> createSubscription({
    required CustomerModel customer,
    required double monthlyAmount,
    required String startDate,
  });

  FutureEitherVoid updateSubscription({
    required int subscriptionId,
    String? status,
    String? nextPaymentDate,
    String? lastPaidDate,
    double? monthlyAmount,
  });

  // Specialized update functions
  FutureEitherVoid updateNextPaymentDate({
    required int subscriptionId,
    required String newNextPaymentDate,
  });

  FutureEitherVoid updateMonthlyAmount({
    required int subscriptionId,
    required double newMonthlyAmount,
  });

  FutureEitherVoid cancelSubscription(int subscriptionId);
  FutureEitherVoid pauseSubscription(int subscriptionId);
  FutureEitherVoid resumeSubscription(int subscriptionId);

  // Cycle management
  FutureEither<SubscriptionCycleModel> createSubscriptionCycle({
    required int subscriptionId,
    required String cycleStartDate,
    required String cycleEndDate,
    SubscriptionCycleStatus status = SubscriptionCycleStatus.unpaid,
    int? transactionId,
    int? paidByUserId,
  });

  FutureEitherVoid markCycleAsPaid({
    required int cycleId,
    required int transactionId,
    required int paidByUserId,
  });

  // Payment processing
  FutureEither<bool> processSubscriptionPayment({
    required int subscriptionId,
    required int customerId,
    required double amount,
    required int userId,
    required String paymentDate,
    bool isTransactionInPrimary = true,
    double? dollarRate,
  });

  // Daily automation
  FutureEitherVoid generateUnpaidCycles();

  // Queries
  FutureEither<SubscriptionModel?> getSubscriptionById(int subscriptionId);
  FutureEither<List<SubscriptionModel>> getSubscriptionsByCustomer(
    int customerId,
  );
  FutureEither<List<SubscriptionModel>> getActiveSubscriptions();
  FutureEither<List<SubscriptionModel>> getOverdueSubscriptions();
  FutureEither<List<SubscriptionCycleModel>> getUnpaidCycles(
    int subscriptionId,
  );
  FutureEither<List<SubscriptionCycleModel>> getSubscriptionHistory(
    int subscriptionId,
  );

  // Reports
  FutureEither<SubscriptionStatsModel> getSubscriptionStats();
  FutureEither<List<SubscriptionModel>> getSubscriptionsWithCustomerInfo();

  // Subscription payment stats for profit report
  FutureEither<List<SubscribtionStateModel>> fetchSubscriptionStatsByView({
    String? date,
    ReportInterval? view,
  });
}

// Implementation of subscription repository
class SubscriptionRepository implements ISubscriptionRepository {
  final Ref ref;

  SubscriptionRepository(this.ref);

  @override
  FutureEither<SubscriptionModel> createSubscription({
    required CustomerModel customer,
    required double monthlyAmount,
    required String startDate,
  }) async {
    try {
      final hasActiveSubscription = await _checkActiveSubscription(
        customer.id ?? 0,
      );
      if (hasActiveSubscription) {
        return left(
          FailureModel('Customer already has an active subscription'),
        );
      }
      final now = DateTime.now().toString().substring(0, 10);
      final nextPaymentDate = DateTime.parse(
        startDate,
      ).add(const Duration(days: 30)).toString().substring(0, 10);

      // Get current user ID
      final currentUser = ref.read(currentUserProvider);
      final userId = currentUser?.id ?? 1; // Default to 1 if no user found
      final shiftId = ref.read(currentShiftProvider).id;

      // Create subscription
      final subscriptionId = await ref
          .read(posDbProvider)
          .database
          .insert(TableConstant.subscriptionsTable, {
            'customerId': customer.id ?? 0,
            'startDate': startDate,
            'nextPaymentDate': nextPaymentDate,
            'status': 'active',
            'monthlyAmount': monthlyAmount,
            'lastPaidDate': startDate,
            'createdAt': now,
            'updatedAt': now,
          });

      // Create financial transaction for initial subscription payment
      final transaction = FinancialTransactionModel(
        transactionDate: DateTime.now().toString(),
        primaryAmount: monthlyAmount,
        secondaryAmount: 0.0,
        isTransactionInPrimary: true,
        dollarRate: 1.0,
        paymentType: PaymentType.cash,
        flow: TransactionFlow.IN,
        transactionType: TransactionType.subscriptionPayment,
        userId: userId,
        receiptId: null,
        shiftId: shiftId,
        note: 'Initial subscription payment for customer ${customer.name}',
      );

      final transactionResult = await ref
          .read(financialTransactionProviderRepository)
          .addFinancialTransaction(transaction);

      final transactionId = transactionResult.fold(
        (failure) => throw Exception(failure.message),
        (id) => id,
      );

      // Create first cycle as paid with transaction ID
      await createSubscriptionCycle(
        subscriptionId: subscriptionId,
        cycleStartDate: startDate,
        cycleEndDate: nextPaymentDate,
        status: SubscriptionCycleStatus.paid,
        transactionId: transactionId,
        paidByUserId: userId,
      );

      // Create second cycle as unpaid for next month
      // This ensures there's always an unpaid cycle ready for payment
      final secondCycleEndDate = DateTime.parse(
        nextPaymentDate,
      ).add(const Duration(days: 30)).toString().substring(0, 10);

      await createSubscriptionCycle(
        subscriptionId: subscriptionId,
        cycleStartDate: nextPaymentDate,
        cycleEndDate: secondCycleEndDate,
        status: SubscriptionCycleStatus.unpaid,
      );

      debugPrint(
        'Created initial unpaid cycle from $nextPaymentDate to $secondCycleEndDate',
      );

      final subscription = SubscriptionModel(
        id: subscriptionId,
        customerId: customer.id ?? 0,
        startDate: startDate,
        nextPaymentDate: nextPaymentDate,
        monthlyAmount: monthlyAmount,
        lastPaidDate: startDate,
        createdAt: now,
        updatedAt: now,
      );

      debugPrint(
        'Created subscription $subscriptionId for customer ${customer.id}',
      );
      return right(subscription);
    } catch (e) {
      debugPrint('Error creating subscription: $e');
      return left(FailureModel(e.toString()));
    }
  }

  Future<bool> _checkActiveSubscription(int customerId) async {
    final result = await ref.read(posDbProvider).database.rawQuery(
      'SELECT * FROM subscriptions WHERE customerId = ? AND status = ?',
      [customerId, 'active'],
    );
    return result.isNotEmpty;
  }

  @override
  FutureEitherVoid updateSubscription({
    required int subscriptionId,
    String? status,
    String? nextPaymentDate,
    String? lastPaidDate,
    double? monthlyAmount,
  }) async {
    try {
      final now = DateTime.now().toString().substring(0, 10);
      final updateData = <String, dynamic>{'updatedAt': now};

      if (status != null) updateData['status'] = status;
      if (nextPaymentDate != null) {
        updateData['nextPaymentDate'] = nextPaymentDate;
      }
      if (lastPaidDate != null) updateData['lastPaidDate'] = lastPaidDate;
      if (monthlyAmount != null) updateData['monthlyAmount'] = monthlyAmount;

      await ref
          .read(posDbProvider)
          .database
          .update(
            TableConstant.subscriptionsTable,
            updateData,
            where: 'id = ?',
            whereArgs: [subscriptionId],
          );

      return right(null);
    } catch (e) {
      debugPrint('Error updating subscription: $e');
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEitherVoid updateNextPaymentDate({
    required int subscriptionId,
    required String newNextPaymentDate,
  }) async {
    try {
      final now = DateTime.now().toString().substring(0, 10);

      // 1. Update the subscription's nextPaymentDate
      await ref
          .read(posDbProvider)
          .database
          .update(
            TableConstant.subscriptionsTable,
            {'nextPaymentDate': newNextPaymentDate, 'updatedAt': now},
            where: 'id = ?',
            whereArgs: [subscriptionId],
          );

      // 2. Calculate the new cycle start date (1 month before next payment date)
      final newCycleStartDate = DateTime.parse(
        newNextPaymentDate,
      ).subtract(const Duration(days: 30)).toString().substring(0, 10);

      // 3. Update the cycleStartDate and cycleEndDate for all unpaid cycles of this subscription
      await ref
          .read(posDbProvider)
          .database
          .update(
            TableConstant.subscriptionCyclesTable,
            {
              'cycleStartDate': newCycleStartDate,
              'cycleEndDate': newNextPaymentDate,
              'updatedAt': now,
            },
            where: 'subscriptionId = ? AND status = ?',
            whereArgs: [subscriptionId, 'unpaid'],
          );

      debugPrint(
        'Updated subscription $subscriptionId: nextPaymentDate = $newNextPaymentDate',
      );
      debugPrint(
        'Updated all unpaid cycles for subscription $subscriptionId: cycleStartDate = $newCycleStartDate, cycleEndDate = $newNextPaymentDate',
      );
      return right(null);
    } catch (e) {
      debugPrint('Error updating next payment date: $e');
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEitherVoid updateMonthlyAmount({
    required int subscriptionId,
    required double newMonthlyAmount,
  }) async {
    try {
      final now = DateTime.now().toString().substring(0, 10);

      // Update only the monthly amount in the subscription
      await ref
          .read(posDbProvider)
          .database
          .update(
            TableConstant.subscriptionsTable,
            {'monthlyAmount': newMonthlyAmount, 'updatedAt': now},
            where: 'id = ?',
            whereArgs: [subscriptionId],
          );

      debugPrint(
        'Updated subscription $subscriptionId: monthlyAmount = $newMonthlyAmount',
      );
      return right(null);
    } catch (e) {
      debugPrint('Error updating monthly amount: $e');
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEitherVoid cancelSubscription(int subscriptionId) async {
    return await updateSubscription(
      subscriptionId: subscriptionId,
      status: 'canceled',
    );
  }

  @override
  FutureEitherVoid pauseSubscription(int subscriptionId) async {
    return await updateSubscription(
      subscriptionId: subscriptionId,
      status: 'paused',
    );
  }

  @override
  FutureEitherVoid resumeSubscription(int subscriptionId) async {
    return await updateSubscription(
      subscriptionId: subscriptionId,
      status: 'active',
    );
  }

  @override
  FutureEither<SubscriptionCycleModel> createSubscriptionCycle({
    required int subscriptionId,
    required String cycleStartDate,
    required String cycleEndDate,
    SubscriptionCycleStatus status = SubscriptionCycleStatus.unpaid,
    int? transactionId,
    int? paidByUserId,
  }) async {
    try {
      final now = DateTime.now().toString().substring(0, 10);

      final cycleId = await ref
          .read(posDbProvider)
          .database
          .insert(TableConstant.subscriptionCyclesTable, {
            'subscriptionId': subscriptionId,
            'cycleStartDate': cycleStartDate,
            'cycleEndDate': cycleEndDate,
            'status': status.name,
            'transactionId': transactionId,
            'paidByUserId': paidByUserId,
            'createdAt': now,
            'updatedAt': now,
          });

      final cycle = SubscriptionCycleModel(
        id: cycleId,
        subscriptionId: subscriptionId,
        cycleStartDate: cycleStartDate,
        cycleEndDate: cycleEndDate,
        status: status,
        transactionId: transactionId,
        paidByUserId: paidByUserId,
        createdAt: now,
        updatedAt: now,
      );

      return right(cycle);
    } catch (e) {
      debugPrint('Error creating subscription cycle: $e');
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEitherVoid markCycleAsPaid({
    required int cycleId,
    required int transactionId,
    required int paidByUserId,
  }) async {
    try {
      final now = DateTime.now().toString().substring(0, 10);

      await ref
          .read(posDbProvider)
          .database
          .update(
            TableConstant.subscriptionCyclesTable,
            {
              'status': 'paid',
              'transactionId': transactionId,
              'paidByUserId': paidByUserId,
              'updatedAt': now,
            },
            where: 'id = ?',
            whereArgs: [cycleId],
          );

      return right(null);
    } catch (e) {
      debugPrint('Error marking cycle as paid: $e');
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<bool> processSubscriptionPayment({
    required int subscriptionId,
    required int customerId,
    required double amount,
    required int userId,
    required String paymentDate,
    bool isTransactionInPrimary = true,
    double? dollarRate,
  }) async {
    try {
      // Get unpaid cycles for this subscription
      final unpaidCyclesResult = await getUnpaidCycles(subscriptionId);

      return unpaidCyclesResult.fold((failure) => left(failure), (
        unpaidCycles,
      ) async {
        if (unpaidCycles.isEmpty) {
          debugPrint('No unpaid cycles found for subscription $subscriptionId');
          return right(false);
        }

        // Get the oldest unpaid cycle
        final oldestCycle = unpaidCycles.first;
        final cycleId = oldestCycle.id!;

        try {
          // Create financial transaction
          final transaction = FinancialTransactionModel(
            transactionDate: paymentDate,
            primaryAmount: isTransactionInPrimary
                ? amount
                : (dollarRate != null ? amount / dollarRate : amount),
            secondaryAmount: isTransactionInPrimary
                ? (dollarRate != null ? amount * dollarRate : amount)
                : amount,
            isTransactionInPrimary: isTransactionInPrimary,
            dollarRate: dollarRate ?? 1.0,
            paymentType: PaymentType.cash,
            flow: TransactionFlow.IN,
            transactionType: TransactionType.subscriptionPayment,
            userId: userId,
            receiptId: null,
            customerId: customerId,
            note: 'Subscription payment',
          );

          final transactionResult = await ref
              .read(financialTransactionProviderRepository)
              .addFinancialTransaction(transaction);

          final transactionId = transactionResult.fold(
            (failure) => throw Exception(failure.message),
            (id) => id,
          );

          // Mark cycle as paid
          await markCycleAsPaid(
            cycleId: cycleId,
            transactionId: transactionId,
            paidByUserId: userId,
          );

          // Calculate next payment date (30 days from the paid cycle's end date)
          final paidCycleEndDate = DateTime.parse(oldestCycle.cycleEndDate);

          final newNextPaymentDateStr = paymentDate.toString().substring(0, 10);

          // Check if there are still more unpaid cycles
          // If this was the last unpaid cycle, create a new one for next month
          if (unpaidCycles.length == 1) {
            // This was the last unpaid cycle, create a new one
            await createSubscriptionCycle(
              subscriptionId: subscriptionId,
              cycleStartDate: oldestCycle.cycleEndDate,
              cycleEndDate: newNextPaymentDateStr,
              status: SubscriptionCycleStatus.unpaid,
            );

            debugPrint(
              'Created new unpaid cycle from ${oldestCycle.cycleEndDate} to $newNextPaymentDateStr',
            );
          }

          // Update subscription with new next payment date and last paid date
          await updateSubscription(
            subscriptionId: subscriptionId,
            lastPaidDate: paymentDate,
            nextPaymentDate: unpaidCycles.length == 1
                ? newNextPaymentDateStr
                : unpaidCycles[1]
                      .cycleEndDate, // If more unpaid cycles, use next cycle's end date
          );

          debugPrint(
            'Processed subscription payment: $amount for subscription $subscriptionId',
          );
          debugPrint(
            'Updated nextPaymentDate to: ${unpaidCycles.length == 1 ? newNextPaymentDateStr : unpaidCycles[1].cycleEndDate}',
          );
          debugPrint('Remaining unpaid cycles: ${unpaidCycles.length - 1}');
          return right(true);
        } catch (e) {
          debugPrint('Error processing subscription payment: $e');
          return left(FailureModel(e.toString()));
        }
      });
    } catch (e) {
      debugPrint('Error processing subscription payment: $e');
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEitherVoid generateUnpaidCycles() async {
    try {
      // Get all active subscriptions where next payment date has passed
      final today = DateTime.now().toString().substring(
        0,
        10,
      ); // YYYY-MM-DD format

      final overdueSubscriptions = await ref
          .read(posDbProvider)
          .database
          .query(
            TableConstant.subscriptionsTable,
            where: 'status = ? AND nextPaymentDate <= ?',
            whereArgs: ['active', today],
          );

      for (final subscription in overdueSubscriptions) {
        final subscriptionId = subscription['id'] as int;
        final currentNextPayment = DateTime.parse(
          subscription['nextPaymentDate'] as String,
        );
        final newNextPayment = currentNextPayment.add(const Duration(days: 30));

        // Create new unpaid cycle
        await createSubscriptionCycle(
          subscriptionId: subscriptionId,
          cycleStartDate: subscription['nextPaymentDate'] as String,
          cycleEndDate: newNextPayment.toString().substring(0, 10),
          status: SubscriptionCycleStatus.unpaid,
        );

        // Update next payment date
        await updateSubscription(
          subscriptionId: subscriptionId,
          nextPaymentDate: newNextPayment.toString().substring(0, 10),
        );

        debugPrint('Generated unpaid cycle for subscription $subscriptionId');
      }

      return right(null);
    } catch (e) {
      debugPrint('Error generating unpaid cycles: $e');
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<SubscriptionModel?> getSubscriptionById(
    int subscriptionId,
  ) async {
    try {
      final result = await ref
          .read(posDbProvider)
          .database
          .query(
            TableConstant.subscriptionsTable,
            where: 'id = ?',
            whereArgs: [subscriptionId],
          );

      if (result.isEmpty) {
        return right(null);
      }

      final subscription = SubscriptionModel.fromJson(result.first);
      return right(subscription);
    } catch (e) {
      debugPrint('Error getting subscription by ID: $e');
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<List<SubscriptionModel>> getSubscriptionsByCustomer(
    int customerId,
  ) async {
    try {
      final result = await ref
          .read(posDbProvider)
          .database
          .query(
            TableConstant.subscriptionsTable,
            where: 'customerId = ?',
            whereArgs: [customerId],
            orderBy: 'createdAt DESC',
          );

      final subscriptions = result
          .map((json) => SubscriptionModel.fromJson(json))
          .toList();
      return right(subscriptions);
    } catch (e) {
      debugPrint('Error getting subscriptions by customer: $e');
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<List<SubscriptionModel>> getActiveSubscriptions() async {
    try {
      final result = await ref
          .read(posDbProvider)
          .database
          .query(
            TableConstant.subscriptionsTable,
            where: 'status = ?',
            whereArgs: ['active'],
            orderBy: 'nextPaymentDate ASC',
          );

      final subscriptions = result
          .map((json) => SubscriptionModel.fromJson(json))
          .toList();
      return right(subscriptions);
    } catch (e) {
      debugPrint('Error getting active subscriptions: $e');
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<List<SubscriptionModel>> getOverdueSubscriptions() async {
    try {
      final today = DateTime.now().toString().substring(0, 10);
      final result = await ref
          .read(posDbProvider)
          .database
          .query(
            TableConstant.subscriptionsTable,
            where: 'status = ? AND nextPaymentDate < ?',
            whereArgs: ['active', today],
            orderBy: 'nextPaymentDate ASC',
          );

      final subscriptions = result
          .map((json) => SubscriptionModel.fromJson(json))
          .toList();
      return right(subscriptions);
    } catch (e) {
      debugPrint('Error getting overdue subscriptions: $e');
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<List<SubscriptionCycleModel>> getUnpaidCycles(
    int subscriptionId,
  ) async {
    try {
      final result = await ref
          .read(posDbProvider)
          .database
          .query(
            TableConstant.subscriptionCyclesTable,
            where: 'subscriptionId = ? AND status = ?',
            whereArgs: [subscriptionId, 'unpaid'],
            orderBy: 'cycleStartDate ASC',
          );

      final cycles = result
          .map((json) => SubscriptionCycleModel.fromJson(json))
          .toList();
      return right(cycles);
    } catch (e) {
      debugPrint('Error getting unpaid cycles: $e');
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<List<SubscriptionCycleModel>> getSubscriptionHistory(
    int subscriptionId,
  ) async {
    try {
      final result = await ref
          .read(posDbProvider)
          .database
          .rawQuery(
            '''
        SELECT 
          sc.*,
          ft.primaryAmount,
          ft.secondaryAmount,
          ft.transactionDate,
          u.name as paidByUserName
        FROM ${TableConstant.subscriptionCyclesTable} sc
        LEFT JOIN ${TableConstant.financialTransactionTable} ft ON sc.transactionId = ft.id
        LEFT JOIN ${TableConstant.userTable} u ON sc.paidByUserId = u.id
        WHERE sc.subscriptionId = ?
        ORDER BY sc.cycleStartDate DESC
      ''',
            [subscriptionId],
          );

      final cycles = result
          .map((json) => SubscriptionCycleModel.fromJson(json))
          .toList();
      return right(cycles);
    } catch (e) {
      debugPrint('Error getting subscription history: $e');
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<SubscriptionStatsModel> getSubscriptionStats() async {
    try {
      final activeCount = await ref.read(posDbProvider).database.rawQuery(
        'SELECT COUNT(*) as count FROM ${TableConstant.subscriptionsTable} WHERE status = ?',
        ['active'],
      );

      // Count subscriptions that are overdue (nextPaymentDate has passed and still unpaid cycles)
      final today = DateTime.now().toString().substring(0, 10);
      final overdueCount = await ref
          .read(posDbProvider)
          .database
          .rawQuery(
            '''
        SELECT COUNT(DISTINCT s.id) as count 
        FROM ${TableConstant.subscriptionsTable} s
        INNER JOIN ${TableConstant.subscriptionCyclesTable} sc ON s.id = sc.subscriptionId
        WHERE s.status = ? AND s.nextPaymentDate <= ? AND sc.status = ?
        ''',
            ['active', today, 'unpaid'],
          );

      final canceledCount = await ref.read(posDbProvider).database.rawQuery(
        'SELECT COUNT(*) as count FROM ${TableConstant.subscriptionsTable} WHERE status = ?',
        ['canceled'],
      );

      // Count total unpaid cycles across all active subscriptions
      final unpaidCyclesCount = await ref
          .read(posDbProvider)
          .database
          .rawQuery(
            '''
        SELECT COUNT(*) as count 
        FROM ${TableConstant.subscriptionCyclesTable} sc
        INNER JOIN ${TableConstant.subscriptionsTable} s ON sc.subscriptionId = s.id
        WHERE s.status = ? AND sc.status = ?
        ''',
            ['active', 'unpaid'],
          );

      final totalRevenue = await ref.read(posDbProvider).database.rawQuery(
        'SELECT SUM(primaryAmount) as total FROM ${TableConstant.financialTransactionTable} WHERE transactionType = ?',
        ['subscription'],
      );

      // Calculate monthly revenue from active subscriptions
      final monthlyRevenue = await ref.read(posDbProvider).database.rawQuery(
        'SELECT SUM(monthlyAmount) as total FROM ${TableConstant.subscriptionsTable} WHERE status = ?',
        ['active'],
      );

      final stats = SubscriptionStatsModel(
        activeSubscriptions: activeCount.first['count'] as int? ?? 0,
        overdueSubscriptions: overdueCount.first['count'] as int? ?? 0,
        canceledSubscriptions: canceledCount.first['count'] as int? ?? 0,
        unpaidCyclesCount: unpaidCyclesCount.first['count'] as int? ?? 0,
        totalRevenue:
            double.tryParse(totalRevenue.first['total']?.toString() ?? '0') ??
            0.0,
        monthlyRevenue:
            double.tryParse(monthlyRevenue.first['total']?.toString() ?? '0') ??
            0.0,
      );

      return right(stats);
    } catch (e) {
      debugPrint('Error getting subscription stats: $e');
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<List<SubscriptionModel>>
  getSubscriptionsWithCustomerInfo() async {
    try {
      final result = await ref.read(posDbProvider).database.rawQuery('''
        SELECT 
          s.*,
          c.name as customerName,
          c.phoneNumber as customerPhone,
          c.address as customerAddress,
          (
            SELECT COUNT(*) 
            FROM ${TableConstant.subscriptionCyclesTable} sc 
            WHERE sc.subscriptionId = s.id AND sc.status = 'unpaid'
          ) as unpaidCyclesCount
        FROM ${TableConstant.subscriptionsTable} s
        INNER JOIN ${TableConstant.customersTable} c ON s.customerId = c.id
        ORDER BY s.status ASC, s.nextPaymentDate ASC
      ''');

      final subscriptions = result
          .map((json) => SubscriptionModel.fromJson(json))
          .toList();
      return right(subscriptions);
    } catch (e) {
      debugPrint('Error getting subscriptions with customer info: $e');
      return left(FailureModel(e.toString()));
    }
  }

  @override
  FutureEither<List<SubscribtionStateModel>> fetchSubscriptionStatsByView({
    String? date,
    ReportInterval? view,
  }) async {
    try {
      final db = ref.read(posDbProvider).database;

      // Build date filter based on view
      String dateFilter = '';
      if (date != null && view != null) {
        switch (view) {
          case ReportInterval.daily:
            dateFilter = "AND DATE(ft.transactionDate) = '$date'";
            break;
          case ReportInterval.monthly:
            final parsedDate = DateTime.parse(date);
            final year = parsedDate.year;
            final month = parsedDate.month.toString().padLeft(2, '0');
            dateFilter =
                "AND strftime('%Y-%m', ft.transactionDate) = '$year-$month'";
            break;
          case ReportInterval.yearly:
            final year = DateTime.parse(date).year;
            dateFilter = "AND strftime('%Y', ft.transactionDate) = '$year'";
            break;
        }
      }

      final query =
          '''
        SELECT 
          c.name as customerName,
          COUNT(ft.id) as paymentCount,
          SUM(ft.primaryAmount) as totalPaid
        FROM ${TableConstant.financialTransactionTable} ft
        INNER JOIN ${TableConstant.customersTable} c ON ft.customerId = c.id
        WHERE ft.transactionType = '${TransactionType.subscriptionPayment.name}'
        $dateFilter
        GROUP BY ft.customerId, c.name
        ORDER BY totalPaid DESC
      ''';

      final result = await db.rawQuery(query);

      final stats = result.map((row) {
        return SubscribtionStateModel(
          customerName: row['customerName'] as String,
          paymentCount: row['paymentCount'] as int,
          totalPaid: double.parse(row['totalPaid'].toString()).formatDouble(),
        );
      }).toList();

      return right(stats);
    } catch (e) {
      debugPrint('Error fetching subscription stats: $e');
      return left(FailureModel(e.toString()));
    }
  }
}
