// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:desktoppossystem/models/stock_transaction_model.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';

class RestaurantStockModel {
  int? id;
  String? color;
  String name;
  UnitType unitType;
  double pricePerUnit;
  double? portionsPerKg;
  double qty;
  double? warningAlert;
  bool? forPackaging;
  bool? isSelected = false;
  String? expiryDate;
  String? wasteFormula;

  double get totalWeightFromFormula {
    if (wasteFormula != null && wasteFormula!.contains("/")) {
      return double.tryParse(wasteFormula!.split("/").first) ?? 0;
    }
    return 0;
  }

  double get netWeightFromFormula {
    if (wasteFormula != null && wasteFormula!.contains("/")) {
      return double.tryParse(wasteFormula!.split("/").last) ?? 0;
    }
    return 0;
  }

  double get wastePerKg {
    double totalWeight = totalWeightFromFormula;
    double totalNetWeight = netWeightFromFormula;

    double waste = totalWeight - totalNetWeight;

    double wastePerKg = totalWeight > 0 ? waste / totalWeight : 0;
    return wastePerKg.formatDouble();
  }

  factory RestaurantStockModel.fake() {
    return RestaurantStockModel(
      id: 1,
      color: '0xffffffff', // Random hex color
      name: 'Stock Item', // Random stock item name
      unitType: UnitType.portion, // Random unit type
      pricePerUnit: 2, // Random price per unit
      portionsPerKg: 10, // Random portions per kg
      qty: 15, // Random quantity
      warningAlert: 1, // Random warning alert value
      forPackaging: false, // Random forPackaging status
      expiryDate: null, // Random expiry date
    );
  }

  RestaurantStockModel(
      {this.id,
      this.color,
      //  this.textColor,
      required this.name,
      required this.unitType,
      required this.qty,
      required this.pricePerUnit,
      this.portionsPerKg,
      this.forPackaging,
      this.warningAlert,
      this.expiryDate,
      this.wasteFormula});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'color': color,
      'unitType': unitType.name,
      'pricePerUnit': pricePerUnit,
      'portionsPerKg': portionsPerKg,
      'qty': qty,
      'warningAlert': warningAlert ?? 1,
      'forPackaging': forPackaging == true ? 1 : 0,
      'expiryDate': expiryDate,
      'wasteFormula': wasteFormula,
    };
  }

  factory RestaurantStockModel.fromMap(Map<String, dynamic> map) {
    return RestaurantStockModel(
      id: map['id'] != null ? map['id'] as int : null,
      name: map['name'] as String,
      color: map['color'] as String,
      unitType: (map["unitType"] as String).unitTypeToEnum(),
      pricePerUnit: map['pricePerUnit'],
      portionsPerKg:
          map['portionsPerKg'] != null ? map['portionsPerKg'] as double : null,
      qty: map['qty'],
      forPackaging: map['forPackaging'] != null
          ? map['forPackaging'] == 0
              ? false
              : true
          : false,
      warningAlert: map['warningAlert'] ?? 0,
      expiryDate: map['expiryDate'],
      wasteFormula: map['wasteFormula'],
    );
  }

  RestaurantStockModel copyWith({
    int? id,
    String? color,
    String? textColor,
    String? name,
    UnitType? unitType,
    double? pricePerUnit,
    double? portionsPerKg,
    double? qty,
    double? warningAlert,
    bool? isSelected,
    String? expiryDate,
    String? wasteFormula,
  }) {
    return RestaurantStockModel(
      id: id ?? this.id,
      color: color ?? this.color,
      name: name ?? this.name,
      unitType: unitType ?? this.unitType,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      portionsPerKg: portionsPerKg ?? this.portionsPerKg,
      qty: qty ?? this.qty,
      warningAlert: warningAlert ?? this.warningAlert,
      expiryDate: expiryDate ?? this.expiryDate,
      wasteFormula: wasteFormula ?? this.wasteFormula,
    );
  }

  StockTransactionModel mapToFoodTracker({
    required int employeeId,
    double? oldQty,
    required double transactionQty,
    double? qtyAsGram,
    double? qtyAsPortion,
    double? pricePerUnit,
    required String transactionDate,
    required WasteType wasteType,
    required StockTransactionType transactionType,
    String? transactionReason,
  }) {
    return StockTransactionModel(
      id: null, // or generate a new ID
      stockId: id ?? 0, // assuming 0 is not a valid ID
      employeeId: employeeId,
      itemName: name,
      unitType: unitType,
      pricePerUnit: pricePerUnit ?? this.pricePerUnit,
      oldQty: oldQty,
      transactionQty: transactionQty,
      transactionDate: transactionDate,
      wasteType: wasteType,
      qtyAsGram: qtyAsGram,
      qtyAsPortion: qtyAsPortion,
      transactionReason: transactionReason,
      transactionType: transactionType,
    );
  }

  @override
  bool operator ==(covariant RestaurantStockModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.color == color &&
        other.name == name &&
        other.unitType == unitType &&
        other.pricePerUnit == pricePerUnit &&
        other.portionsPerKg == portionsPerKg &&
        other.qty == qty &&
        other.warningAlert == warningAlert &&
        other.forPackaging == forPackaging &&
        other.isSelected == isSelected &&
        other.expiryDate == expiryDate &&
        other.wastePerKg == wastePerKg &&
        other.wasteFormula == wasteFormula;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        color.hashCode ^
        name.hashCode ^
        unitType.hashCode ^
        pricePerUnit.hashCode ^
        portionsPerKg.hashCode ^
        qty.hashCode ^
        warningAlert.hashCode ^
        forPackaging.hashCode ^
        isSelected.hashCode ^
        expiryDate.hashCode ^
        wastePerKg.hashCode ^
        wasteFormula.hashCode;
  }
}
