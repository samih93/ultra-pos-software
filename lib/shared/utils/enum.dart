enum RequestState { loading, success, error }

enum PageSize { mm58, mm80, mm120 }

enum LabelSize { normal, mm20_30, mm10G10 }

enum ScreenUI { restaurant, market }

enum ReportInterval { daily, monthly, yearly }

enum TypeOfPrint { Order, Receipt, EndOfDay }

enum PaymentType { cash, card, bankTransfer }

enum TransactionFlow { IN, OUT }

enum TransactionType {
  salePayment,
  pendingPayment,
  deposit,
  withdraw,
  refund,
  adjustment,
  purchase,
  subscriptionPayment,
}

enum Currency { LBP, USD, EGP, ILS, SAR, SYP, QAR }

enum Language { en, fr, ar }

enum UnitType { kg, portion }

// used for invoice
enum OrderType { dineIn, delivery }

// filter restauarant stock
enum RestaurantStockFilter { all, foodItems, packaging, lowStock }

// dashboard filter
enum DashboardFilterEnum {
  lastYear,
  lastMonth,
  yesterday,
  today,
  thisWeek,
  thisMonth,
  thisYear,
}

enum WasteType { normal, staff }

enum StockTransactionType { stockIn, stockOut }

enum SectionType { kitchen, bar, tobacco, desserts }

enum ReceiptStatus { all, paid, pending }

enum DailyFinancialFilter { receipts, pending, transactions }

enum SortType { profit, qty }

enum SubscriptionStatus {
  active,
  overdue,
  canceled;

  @override
  String toString() {
    return name;
  }
}

// Subscription cycle status enum
enum SubscriptionCycleStatus {
  paid,
  unpaid;

  @override
  String toString() {
    return name;
  }
}
