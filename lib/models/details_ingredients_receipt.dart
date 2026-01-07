// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';

class DetailsIngredientsReceipt {
  int? id;
  int ingredientId;
  int receiptId;
  String name;
  UnitType? unitType;
  double qtyAsGram;
  double qtyAsPortion;
  int restaurantStockId;
  double pricePerIngredient;
  int detailsReceiptId;
  double qty;
  bool? forPackaging;

  DetailsIngredientsReceipt(
      {this.id,
      required this.ingredientId,
      required this.receiptId,
      required this.name,
      this.unitType,
      required this.qtyAsGram,
      required this.qtyAsPortion,
      required this.restaurantStockId,
      required this.pricePerIngredient,
      required this.qty,
      required this.detailsReceiptId,
      this.forPackaging});

  DetailsIngredientsReceipt copyWith({
    int? id,
    int? ingredientId,
    int? receiptId,
    String? name,
    UnitType? unitType,
    double? qtyAsGram,
    double? qtyAsPortion,
    int? restaurantStockId,
    double? pricePerIngredient,
    int? detailsReceiptId,
    double? qty,
    bool? forPackaging,
  }) {
    return DetailsIngredientsReceipt(
      id: id ?? this.id,
      ingredientId: ingredientId ?? this.ingredientId,
      receiptId: receiptId ?? this.receiptId,
      name: name ?? this.name,
      unitType: unitType ?? this.unitType,
      qtyAsGram: qtyAsGram ?? this.qtyAsGram,
      qtyAsPortion: qtyAsPortion ?? this.qtyAsPortion,
      restaurantStockId: restaurantStockId ?? this.restaurantStockId,
      pricePerIngredient: pricePerIngredient ?? this.pricePerIngredient,
      detailsReceiptId: detailsReceiptId ?? this.detailsReceiptId,
      qty: qty ?? this.qty,
      forPackaging: forPackaging ?? this.forPackaging,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'ingredientId': ingredientId,
      'detailsReceiptId': detailsReceiptId,
      'receiptId': receiptId,
      'name': name,
      'unitType': unitType!.name,
      'qtyAsGram': qtyAsGram,
      'qtyAsPortion': qtyAsPortion,
      'restaurantStockId': restaurantStockId,
      'pricePerIngredient': pricePerIngredient,
      'qty': qty,
      'forPackaging': forPackaging == true ? 1 : 0
    };
  }

  factory DetailsIngredientsReceipt.fromMap(Map<String, dynamic> map) {
    return DetailsIngredientsReceipt(
      id: map['id'] as int,
      ingredientId: map['ingredientId'] as int,
      receiptId: map['receiptId'] as int,
      name: map['name'] as String,
      unitType: (map["unitType"] as String).unitTypeToEnum(),
      qtyAsGram: map['qtyAsGram'] as double,
      qtyAsPortion: map['qtyAsPortion'] as double,
      restaurantStockId: map['restaurantStockId'] as int,
      pricePerIngredient: map['pricePerIngredient'] as double,
      qty: double.tryParse(map['qty'].toString()) ?? 1,
      detailsReceiptId: map['detailsReceiptId'],
      forPackaging: map['forPackaging'] != null
          ? map['forPackaging'] == 0
              ? false
              : true
          : false,
    );
  }
}
