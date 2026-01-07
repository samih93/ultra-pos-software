// ignore_for_file: public_member_api_docs, sort_constructors_first

class DailySalesModel {
  String day;
  double price;

  DailySalesModel(this.day, this.price);

  factory DailySalesModel.fromJson(Map<String, dynamic> map) {
    return DailySalesModel(map['day'], map['price']);
  }

  toJson() {
    return {
      "day": day,
      "price": price,
    };
  }
}

class SalesByUserModel {
  String userName;
  double amount;
  SalesByUserModel({
    required this.userName,
    required this.amount,
  });
  factory SalesByUserModel.fake() {
    return SalesByUserModel(
      userName: 'user',
      amount: 0,
    );
  }
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'userName': userName,
      'amount': amount,
    };
  }

  factory SalesByUserModel.fromMap(Map<String, dynamic> map) {
    return SalesByUserModel(
      userName: map['userName'] as String,
      amount: map['amount'] as double,
    );
  }
}
