// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';

import '../../shared/utils/enum.dart';

class RestaurantStockUsageModel {
  int? id;
  String name;
  UnitType? unitType;
  double qtyAsKilo;
  double qtyAsPortion;
  double pricePerIngredient;
  double? totalPrice = 0;
  Color? color;
  bool? forPackaging;

  RestaurantStockUsageModel(
      {this.id,
      required this.name,
      this.unitType,
      required this.qtyAsKilo,
      required this.qtyAsPortion,
      required this.pricePerIngredient,
      this.totalPrice,
      this.forPackaging,
      this.color});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'unitType': unitType?.name,
      'qtyAsKilo': qtyAsKilo,
      'qtyAsPortion': qtyAsPortion,
    };
  }

  factory RestaurantStockUsageModel.fromMap(Map<String, dynamic> map) {
    return RestaurantStockUsageModel(
        id: map['id'] != null ? map['id'] as int : null,
        name: map['name'] as String,
        unitType: (map["unitType"] as String).unitTypeToEnum(),
        qtyAsKilo: map['qtyAsKilo'] as double,
        qtyAsPortion: map['qtyAsPortion'] as double,
        pricePerIngredient: map['pricePerIngredient'] as double,
        totalPrice: map['totalPrice'],
        forPackaging: map['forPackaging'] != null
            ? map['forPackaging'] == 0
                ? false
                : true
            : false,
        color: map['color'] != null
            ? map['color'].toString().getColorFromHex()
            : Pallete.redColor);
  }
}
