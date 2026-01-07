// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:desktoppossystem/shared/utils/extentions.dart';

class ProductStatsModel {
  double? totalCost;
  double? totalPrice;
  int? totalCount;
  ProductStatsModel({
    required this.totalCost,
    required this.totalPrice,
    required this.totalCount,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'totalCost': totalCost,
      'totalPrice': totalPrice,
    };
  }

  factory ProductStatsModel.fromMap(Map<String, dynamic> map) {
    return ProductStatsModel(
      totalCost: map['totalCost'].toString().validateDouble(),
      totalPrice: map['totalPrice'].toString().validateDouble(),
      totalCount: map['totalCount'].toString().validateInteger(),
    );
  }

  ProductStatsModel copyWith({
    double? totalCost,
    double? totalPrice,
    int? totalCount,
  }) {
    return ProductStatsModel(
      totalCost: totalCost ?? this.totalCost,
      totalPrice: totalPrice ?? this.totalPrice,
      totalCount: totalCount ?? this.totalCount,
    );
  }
}
