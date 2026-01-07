// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:flutter/cupertino.dart';

class PurchaseProductModel {
  final int id;
  String? productName;
  String? barcode;
  double? costPrice;
  double? sellingPrice;
  double? qty;

  double? oldCostPrice;
  double? oldSellingPrice;
  double? oldQty;
  double? newAverageCost;
  double? profitRate;
  double? secondarySellingPrice; //! for ui only
  bool? sellingInPrimary = true; //! for ui only

  // TextEditingControllers for each field
  late TextEditingController? nameController;
  late TextEditingController? costPriceController;
  late TextEditingController? profitRateController;
  late TextEditingController? sellingPriceController;

  final FocusNode? nameFocusNode;
  final FocusNode? costPriceFocusNode;
  final FocusNode? profitFocusNode;
  final FocusNode? sellingPriceFocusNode;

  // Constructor for the model
  PurchaseProductModel({
    required this.id,
    required this.productName,
    this.barcode,
    this.costPrice,
    this.sellingPrice,
    this.qty,
    this.oldCostPrice,
    this.oldSellingPrice,
    this.oldQty,
    this.newAverageCost,
    this.profitRate,
    this.sellingInPrimary,
    this.secondarySellingPrice,
    this.nameController,
    this.costPriceController,
    this.profitRateController,
    this.sellingPriceController,
    this.nameFocusNode,
    this.costPriceFocusNode,
    this.profitFocusNode,
    this.sellingPriceFocusNode,
  });

  // You can also add a copyWith method for creating modified copies of the model
  PurchaseProductModel copyWith({
    int? id,
    double? costPrice,
    String? productName,
    String? barcode,
    double? sellingPrice,
    double? qty,
    double? oldCostPrice,
    double? oldSellingPrice,
    double? oldQty,
    double? newAverageCost,
    double? profitRate,
    double? secondarySellingPrice,
    bool? sellingInPrimary,
    final TextEditingController? nameController,
    final TextEditingController? costPriceController,
    final TextEditingController? profitRateController,
    final TextEditingController? sellingPriceController,
    final FocusNode? nameFocusNode,
    final FocusNode? costPriceFocusNode,
    final FocusNode? sellingPriceFocusNode,
    final FocusNode? profitFocusNode,
  }) {
    return PurchaseProductModel(
      id: id ?? this.id,
      costPrice: costPrice ?? this.costPrice,
      productName: productName ?? this.productName,
      barcode: barcode ?? this.barcode,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      qty: qty ?? this.qty,
      oldCostPrice: oldCostPrice ?? this.oldCostPrice,
      oldSellingPrice: oldSellingPrice ?? this.oldSellingPrice,
      oldQty: oldQty ?? this.oldQty,
      newAverageCost: newAverageCost ?? this.newAverageCost,
      profitRate: profitRate ?? this.profitRate,
      secondarySellingPrice:
          secondarySellingPrice ?? this.secondarySellingPrice,
      sellingInPrimary: sellingInPrimary ?? this.sellingInPrimary,
      nameController: nameController ?? this.nameController,
      costPriceController: costPriceController ?? this.costPriceController,
      sellingPriceController:
          sellingPriceController ?? this.sellingPriceController,
      profitRateController: profitRateController ?? this.profitRateController,
      nameFocusNode: nameFocusNode ?? this.nameFocusNode,
      costPriceFocusNode: costPriceFocusNode ?? this.costPriceFocusNode,
      sellingPriceFocusNode:
          sellingPriceFocusNode ?? this.sellingPriceFocusNode,
      profitFocusNode: profitFocusNode ?? this.profitFocusNode,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'productName': productName,
      'barcode': barcode,
      'costPrice': costPrice,
      'sellingPrice': sellingPrice,
      'qty': qty,
      'oldCostPrice': oldCostPrice,
      'oldSellingPrice': oldSellingPrice,
      'oldQty': oldQty,
      'newAverageCost': newAverageCost,
      'profitRate': profitRate,
      'secondarySellingPrice': secondarySellingPrice,
      'sellingInPrimary': sellingInPrimary,
      'nameController': nameController?.text.toString(),
      'costPriceController': costPriceController?.text.toString(),
      'profitRateController': profitRateController?.text.toString(),
      'sellingPriceController': sellingPriceController?.text.toString(),
    };
  }

  factory PurchaseProductModel.fromMap(Map<String, dynamic> map) {
    return PurchaseProductModel(
      id: map['id'] as int,
      productName: map['productName'] != null
          ? map['productName'] as String
          : null,
      barcode: map['barcode'] != null ? map['barcode'] as String : null,
      costPrice: map['costPrice'] != null ? map['costPrice'] as double : null,
      sellingPrice: map['sellingPrice'] != null
          ? map['sellingPrice'] as double
          : null,
      qty: map['qty'] != null ? map['qty'] as double : null,
      oldCostPrice: map['oldCostPrice'] != null
          ? map['oldCostPrice'] as double
          : null,
      oldSellingPrice: map['oldSellingPrice'] != null
          ? map['oldSellingPrice'] as double
          : null,
      oldQty: map['oldQty'] != null ? map['oldQty'] as double : null,
      newAverageCost: map['newAverageCost'] != null
          ? map['newAverageCost'] as double
          : null,
      profitRate: map['profitRate'] != null
          ? map['profitRate'] as double
          : null,
      secondarySellingPrice: map['secondarySellingPrice'] != null
          ? map['secondarySellingPrice'] as double
          : null,
      sellingInPrimary: map['sellingInPrimary'] != null
          ? map['sellingInPrimary'] as bool
          : null,
      nameController: TextEditingController(
        text: map['nameController'] ?? '', // Initialize with saved value
      ),
      costPriceController: TextEditingController(
        text: map['costPriceController'] ?? '', // Initialize with saved value
      ),
      profitRateController: TextEditingController(
        text: map['profitRateController'] ?? '', // Initialize with saved value
      ),
      sellingPriceController: TextEditingController(
        text:
            map['sellingPriceController'] ?? '', // Initialize with saved value
      ),
    );
  }
}
