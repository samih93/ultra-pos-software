// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';

class StockTransactionModel {
  int? id;
  int stockId;
  int employeeId;
  String? employeeName;
  String itemName;
  UnitType unitType;
  double pricePerUnit;
  double? oldQty; // used on stock in to know the old qty
  double transactionQty; // portions or (grams as in ingredient item)
  String transactionDate;
  WasteType? wasteType; // normal, staff , null
  String? transactionReason;
  //for more reports and actually when i add 2 plate as waste so the transaction qty will be 2
  // and based on unit type i will calculate the qty as gram or portion
  double? qtyAsGram;
  double? qtyAsPortion;
  StockTransactionType transactionType; //   stockIn, stockOut
  int? productId;
  StockTransactionModel(
      {this.id,
      required this.stockId,
      required this.employeeId,
      this.employeeName,
      required this.itemName,
      required this.unitType,
      required this.pricePerUnit,
      required this.transactionQty,
      required this.transactionDate,
      this.wasteType,
      this.transactionReason,
      required this.transactionType,
      this.qtyAsGram,
      this.qtyAsPortion,
      this.productId,
      this.oldQty});

  StockTransactionModel copyWith({
    int? id,
    int? stockId,
    int? employeeId,
    String? itemName,
    UnitType? unitType,
    double? pricePerUnit,
    double? transactionQty,
    double? oldQty,
    String? transactionDate,
    WasteType? wasteType,
    String? transactionReason,
    StockTransactionType? transactionType,
    double? qtyAsGram,
    double? qtyAsPortion,
    int? productId,
  }) {
    return StockTransactionModel(
      id: id ?? this.id,
      stockId: stockId ?? this.stockId,
      employeeId: employeeId ?? this.employeeId,
      itemName: itemName ?? this.itemName,
      unitType: unitType ?? this.unitType,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      oldQty: oldQty ?? this.oldQty,
      transactionQty: transactionQty ?? this.transactionQty,
      transactionDate: transactionDate ?? this.transactionDate,
      wasteType: wasteType ?? this.wasteType,
      transactionReason: transactionReason ?? this.transactionReason,
      transactionType: transactionType ?? this.transactionType,
      qtyAsGram: qtyAsGram ?? this.qtyAsGram,
      qtyAsPortion: qtyAsPortion ?? this.qtyAsPortion,
      productId: productId ?? this.productId,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'stockId': stockId,
      'employeeId': employeeId,
      'itemName': itemName,
      'unitType': unitType.name,
      'pricePerUnit': pricePerUnit,
      'oldQty': oldQty,
      'transactionQty': transactionQty,
      'transactionDate': transactionDate,
      'wasteType': wasteType?.name,
      'transactionReason': transactionReason,
      'transactionType': transactionType.name,
      'qtyAsGram': qtyAsGram,
      'qtyAsPortion': qtyAsPortion,
      'productId': productId,
    };
  }

  factory StockTransactionModel.fromMap(Map<String, dynamic> map) {
    return StockTransactionModel(
      id: map['id'] != null ? map['id'] as int : null,
      stockId: map['stockId'] as int,
      employeeId: map['employeeId'] as int,
      employeeName: map['employeeName'],
      itemName: map['itemName'] as String,
      unitType: (map["unitType"] as String).unitTypeToEnum(),
      pricePerUnit: map['pricePerUnit'] as double,
      oldQty: map['oldQty'],
      transactionQty: map['transactionQty'] as double,
      transactionDate: map['transactionDate'] as String,
      wasteType: (map["wasteType"] as String).wasteTypeToEnum(),
      transactionReason: map['transactionReason'] != null
          ? map['transactionReason'] as String
          : null,
      transactionType:
          (map["transactionType"] as String).stockTransactionTypeToEnum(),
      qtyAsGram: map['qtyAsGram'] ?? 0.0,
      qtyAsPortion: map['qtyAsPortion'] ?? 0.0,
      productId: map['productId'],
    );
  }

  @override
  bool operator ==(covariant StockTransactionModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.stockId == stockId &&
        other.employeeId == employeeId &&
        other.employeeName == employeeName &&
        other.itemName == itemName &&
        other.unitType == unitType &&
        other.pricePerUnit == pricePerUnit &&
        other.transactionQty == transactionQty &&
        other.transactionDate == transactionDate &&
        other.wasteType == wasteType &&
        other.transactionReason == transactionReason &&
        other.qtyAsGram == qtyAsGram &&
        other.qtyAsPortion == qtyAsPortion &&
        other.transactionType == transactionType &&
        other.productId == productId;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        stockId.hashCode ^
        employeeId.hashCode ^
        employeeName.hashCode ^
        itemName.hashCode ^
        unitType.hashCode ^
        pricePerUnit.hashCode ^
        transactionQty.hashCode ^
        transactionDate.hashCode ^
        wasteType.hashCode ^
        transactionReason.hashCode ^
        qtyAsGram.hashCode ^
        qtyAsPortion.hashCode ^
        transactionType.hashCode ^
        productId.hashCode;
  }
}
