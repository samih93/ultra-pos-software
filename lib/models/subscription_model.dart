// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';

class SubscriptionModel {
  int? id;
  int customerId;
  String startDate;
  String nextPaymentDate;
  SubscriptionStatus status; // active, paused, canceled
  double monthlyAmount;
  String? lastPaidDate;
  String? createdAt;
  String? updatedAt;

  // For joined queries with customer info
  String? customerName;
  String? customerPhone;
  String? customerAddress;
  int? unpaidCyclesCount; // Number of unpaid cycles (months overdue)

  SubscriptionModel({
    this.id,
    required this.customerId,
    required this.startDate,
    required this.nextPaymentDate,
    this.status = SubscriptionStatus.active,
    required this.monthlyAmount,
    this.lastPaidDate,
    this.createdAt,
    this.updatedAt,
    this.customerName,
    this.customerPhone,
    this.customerAddress,
    this.unpaidCyclesCount,
  });

  factory SubscriptionModel.fromJson(Map<String, dynamic> map) {
    return SubscriptionModel(
      id: map['id'] as int?,
      customerId: map['customerId'] as int,
      startDate: map['startDate'] as String,
      nextPaymentDate: map['nextPaymentDate'] as String,
      status: SubscriptionStatusExtension.fromString(
        map['status'] as String? ?? 'active',
      ),
      monthlyAmount: double.tryParse(map['monthlyAmount'].toString()) ?? 0.0,
      lastPaidDate: map['lastPaidDate'] as String?,
      createdAt: map['createdAt'] as String?,
      updatedAt: map['updatedAt'] as String?,
      customerName: map['customerName'] as String?,
      customerPhone: map['customerPhone'] as String?,
      customerAddress: map['customerAddress'] as String?,
      unpaidCyclesCount: map['unpaidCyclesCount'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'customerId': customerId,
      'startDate': startDate,
      'nextPaymentDate': nextPaymentDate,
      'status': status.toString(),
      'monthlyAmount': monthlyAmount,
      if (lastPaidDate != null) 'lastPaidDate': lastPaidDate,
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
    };
  }

  // Helper methods
  bool get isActive => status == SubscriptionStatus.active;
  bool get isCanceled => status == SubscriptionStatus.canceled;

  bool get isOverdue {
    if (!isActive) return false;
    final today = DateTime.now();
    final nextPayment = DateTime.parse(nextPaymentDate);
    return today.isAfter(nextPayment);
  }

  // Calculate how many months overdue (even if cycles aren't created yet)
  int get monthsOverdue {
    if (!isOverdue) return 0;

    final today = DateTime.now();
    final nextPayment = DateTime.parse(nextPaymentDate);

    // Calculate difference in months
    int months =
        (today.year - nextPayment.year) * 12 +
        (today.month - nextPayment.month);

    // If we're past the day of the month, add 1
    if (today.day > nextPayment.day) {
      months += 1;
    }

    return months > 0 ? months : 1; // At least 1 month if overdue
  }

  // Get display text for overdue status
  String get overdueDisplayText {
    if (!isOverdue) return '';

    // Use unpaidCyclesCount if available (more accurate)
    final count = unpaidCyclesCount ?? monthsOverdue;
    return count == 1 ? '1 month overdue' : '$count months overdue';
  }

  @override
  String toString() {
    return 'SubscriptionModel(id: $id, customerId: $customerId, customerName: $customerName, monthlyAmount: $monthlyAmount, status: $status, nextPaymentDate: $nextPaymentDate)';
  }
}

class SubscriptionCycleModel {
  int? id;
  int subscriptionId;
  String cycleStartDate;
  String cycleEndDate;
  SubscriptionCycleStatus status; // paid, unpaid
  int? transactionId;
  int? paidByUserId;
  String? createdAt;
  String? updatedAt;

  // For joined queries
  double? primaryAmount;
  double? secondaryAmount;
  String? transactionDate;
  String? paidByUserName;

  SubscriptionCycleModel({
    this.id,
    required this.subscriptionId,
    required this.cycleStartDate,
    required this.cycleEndDate,
    this.status = SubscriptionCycleStatus.unpaid,
    this.transactionId,
    this.paidByUserId,
    this.createdAt,
    this.updatedAt,
    this.primaryAmount,
    this.secondaryAmount,
    this.transactionDate,
    this.paidByUserName,
  });

  factory SubscriptionCycleModel.fromJson(Map<String, dynamic> map) {
    return SubscriptionCycleModel(
      id: map['id'] as int?,
      subscriptionId: map['subscriptionId'] as int,
      cycleStartDate: map['cycleStartDate'] as String,
      cycleEndDate: map['cycleEndDate'] as String,
      status: SubscriptionCycleStatusExtension.fromString(
        map['status'] as String? ?? 'unpaid',
      ),
      transactionId: map['transactionId'] as int?,
      paidByUserId: map['paidByUserId'] as int?,
      createdAt: map['createdAt'] as String?,
      updatedAt: map['updatedAt'] as String?,
      primaryAmount: map['primaryAmount'] != null
          ? double.tryParse(map['primaryAmount'].toString())
          : null,
      secondaryAmount: map['secondaryAmount'] != null
          ? double.tryParse(map['secondaryAmount'].toString())
          : null,
      transactionDate: map['transactionDate'] as String?,
      paidByUserName: map['paidByUserName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'subscriptionId': subscriptionId,
      'cycleStartDate': cycleStartDate,
      'cycleEndDate': cycleEndDate,
      'status': status.toString(),
      if (transactionId != null) 'transactionId': transactionId,
      if (paidByUserId != null) 'paidByUserId': paidByUserId,
      if (createdAt != null) 'createdAt': createdAt,
      if (updatedAt != null) 'updatedAt': updatedAt,
    };
  }

  // Helper methods
  bool get isPaid => status == SubscriptionCycleStatus.paid;
  bool get isUnpaid => status == SubscriptionCycleStatus.unpaid;

  DateTime get cycleStart => DateTime.parse(cycleStartDate);
  DateTime get cycleEnd => DateTime.parse(cycleEndDate);

  @override
  String toString() {
    return 'SubscriptionCycleModel(id: $id, subscriptionId: $subscriptionId, cycleStartDate: $cycleStartDate, cycleEndDate: $cycleEndDate, status: $status)';
  }
}

// Stats model for dashboard/reports
class SubscriptionStatsModel {
  final int activeSubscriptions;
  final int overdueSubscriptions;
  final int canceledSubscriptions;
  final int unpaidCyclesCount; // Total unpaid cycles across all subscriptions
  final double totalRevenue;
  final double monthlyRevenue;

  SubscriptionStatsModel({
    this.activeSubscriptions = 0,
    this.overdueSubscriptions = 0,
    this.canceledSubscriptions = 0,
    this.unpaidCyclesCount = 0,
    this.totalRevenue = 0.0,
    this.monthlyRevenue = 0.0,
  });

  factory SubscriptionStatsModel.fromJson(Map<String, dynamic> map) {
    return SubscriptionStatsModel(
      activeSubscriptions: map['activeSubscriptions'] as int? ?? 0,
      overdueSubscriptions: map['overdueSubscriptions'] as int? ?? 0,
      canceledSubscriptions: map['canceledSubscriptions'] as int? ?? 0,
      unpaidCyclesCount: map['unpaidCyclesCount'] as int? ?? 0,
      totalRevenue:
          double.tryParse(map['totalRevenue']?.toString() ?? '0') ?? 0.0,
      monthlyRevenue:
          double.tryParse(map['monthlyRevenue']?.toString() ?? '0') ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'activeSubscriptions': activeSubscriptions,
      'overdueSubscriptions': overdueSubscriptions,
      'canceledSubscriptions': canceledSubscriptions,
      'totalRevenue': totalRevenue,
      'monthlyRevenue': monthlyRevenue,
    };
  }

  @override
  String toString() {
    return 'SubscriptionStatsModel(active: $activeSubscriptions, overdue: $overdueSubscriptions, totalRevenue: $totalRevenue)';
  }
}
