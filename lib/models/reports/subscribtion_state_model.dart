class SubscribtionStateModel {
  final String customerName;
  final int paymentCount;
  final double totalPaid;
  SubscribtionStateModel({
    required this.customerName,
    required this.paymentCount,
    required this.totalPaid,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'customerName': customerName,
      'paymentCount': paymentCount,
      'totalPaid': totalPaid,
    };
  }

  factory SubscribtionStateModel.fromMap(Map<String, dynamic> map) {
    return SubscribtionStateModel(
      customerName: map['customerName'] as String,
      paymentCount: map['paymentCount'] as int,
      totalPaid: map['totalPaid'] as double,
    );
  }
}
