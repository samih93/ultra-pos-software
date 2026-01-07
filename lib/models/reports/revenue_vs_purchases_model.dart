// ignore_for_file: public_member_api_docs

class RevenueVsPurchasesVsExpensesModel {
  String period; // date label (day, week, month based on filter)
  double revenue; // total revenue from sales
  double purchases; // total purchases (invoices + stock-in)
  double expenses; // total expenses (withdrawals)

  RevenueVsPurchasesVsExpensesModel({
    required this.period,
    required this.revenue,
    required this.purchases,
    this.expenses = 0.0,
  });

  factory RevenueVsPurchasesVsExpensesModel.fromMap(Map<String, dynamic> map) {
    return RevenueVsPurchasesVsExpensesModel(
      period: map['period'] as String,
      revenue: (map['revenue'] ?? 0.0) as double,
      purchases: (map['purchases'] ?? 0.0) as double,
      expenses: (map['expenses'] ?? 0.0) as double,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'period': period,
      'revenue': revenue,
      'purchases': purchases,
      'expenses': expenses,
    };
  }

  RevenueVsPurchasesVsExpensesModel copyWith({
    String? period,
    double? revenue,
    double? purchases,
    double? expenses,
  }) {
    return RevenueVsPurchasesVsExpensesModel(
      period: period ?? this.period,
      revenue: revenue ?? this.revenue,
      purchases: purchases ?? this.purchases,
      expenses: expenses ?? this.expenses,
    );
  }
}
