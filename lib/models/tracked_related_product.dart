// ignore_for_file: public_member_api_docs, sort_constructors_first
// ! contains Model  for restaurant
//! offer model of market

import 'package:desktoppossystem/shared/utils/extentions.dart';

class TrackedRelatedProductModel {
  int? id;
  int? productId;
  double? costPrice;
  double? profitRate;
  int relatedProductId;
  String relatedProductName;
  double qtyFromRelatedProduct;
  TrackedRelatedProductModel({
    this.id,
    this.productId,
    this.costPrice,
    this.profitRate,
    required this.relatedProductId,
    required this.relatedProductName,
    required this.qtyFromRelatedProduct,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'productId': productId,
      'relatedProductId': relatedProductId,
      'relatedProductName': relatedProductName,
      'qtyFromRelatedProduct': qtyFromRelatedProduct,
    };
  }

  factory TrackedRelatedProductModel.fromMap(Map<String, dynamic> map) {
    return TrackedRelatedProductModel(
      id: map['id'] as int,
      productId: map['productId'] as int,
      relatedProductId: map['relatedProductId'] as int,
      costPrice: map['costPrice'].toString().validateDouble(),
      profitRate: map['profitRate'].toString().validateDouble(),
      relatedProductName: map['relatedProductName'] as String,
      qtyFromRelatedProduct: map['qtyFromRelatedProduct'],
    );
  }
}
