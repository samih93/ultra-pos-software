// ignore_for_file: public_member_api_docs, sort_constructors_first

class ProductHistoryModel {
  final String productName;
  final String productBarcode;
  final String supplierName;
  final String puchaseDate;
  final double oldQty;
  final double newQty;
  final double oldCost;
  final double cost;
  final double averageCost;

  double get totalQty => oldQty + newQty;
  ProductHistoryModel({
    required this.productName,
    required this.productBarcode,
    required this.supplierName,
    required this.puchaseDate,
    required this.oldQty,
    required this.newQty,
    required this.cost,
    required this.oldCost,
    required this.averageCost,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'productName': productName,
      'productBarcode': productBarcode,
      'supplierName': supplierName,
      'puchaseDate': puchaseDate,
      'oldQty': oldQty,
      'newQty': newQty,
      'cost': cost,
      'oldCost': oldCost,
      'averageCost': averageCost,
    };
  }

  factory ProductHistoryModel.fromMap(Map<String, dynamic> map) {
    return ProductHistoryModel(
      productName: map['productName'] as String,
      productBarcode: map['productBarcode'] as String,
      supplierName: map['supplierName'] as String,
      puchaseDate: map['puchaseDate'] as String,
      oldQty: map['oldQty'] as double,
      cost: map['cost'] as double,
      newQty: map['newQty'] as double,
      oldCost: map['oldCost'] as double,
      averageCost: map['averageCost'] as double,
    );
  }
}
