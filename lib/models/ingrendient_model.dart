import 'package:desktoppossystem/models/stock_transaction_model.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';

class IngredientModel {
  int? id;
  String name;
  double qtyAsGram;
  double qtyAsPortion;
  String? color;
  String? textColor;
  int restaurantStockId;
  UnitType unitType;
  double? pricePerIngredient;
  int? receiptId;
  int? sandwichIngredientId;
  int? productId;
  bool? forPackaging;
  bool isSelected = true;

  String get nameWithQty {
    String qty = unitType == UnitType.kg
        ? '${qtyAsPortion.formatDouble()} po / ${qtyAsGram.formatDouble()}g'
        : '${qtyAsPortion.formatDouble()} po';
    return '$name ($qty)';
  }

  IngredientModel(
      {this.id,
      required this.name,
      required this.qtyAsGram,
      required this.qtyAsPortion,
      required this.unitType,
      this.pricePerIngredient,
      this.color,
      this.textColor,
      required this.restaurantStockId,
      this.receiptId,
      this.sandwichIngredientId,
      this.forPackaging,
      this.productId});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'qtyAsGram': qtyAsGram,
      'qtyAsPortion': qtyAsPortion,
      'unitType': unitType.name,
      'restaurantStockId': restaurantStockId,
    };
  }

  Map<String, dynamic> toMapForTable() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'qtyAsGram': qtyAsGram,
      'qtyAsPortion': qtyAsPortion,
      'unitType': unitType.name,
      'restaurantStockId': restaurantStockId,
      'pricePerIngredient': pricePerIngredient,
      //  'forPackaging': forPackaging,
    };
  }

  factory IngredientModel.fromMap(Map<String, dynamic> map) {
    return IngredientModel(
      id: map['id'] != null ? map['id'] as int : null,
      name: map['name'],
      color: map['color'],
      textColor: map['textColor'],
      qtyAsGram: map['qtyAsGram'] as double,
      qtyAsPortion: map['qtyAsPortion'] as double,
      pricePerIngredient:
          (double.tryParse(map['pricePerIngredient'].toString()) ?? 0)
              .formatDoubleWith6(),
      restaurantStockId: map['restaurantStockId'] as int,
      sandwichIngredientId: map['sandwichIngredientId'] as int?,
      forPackaging: map['forPackaging'] == 1 ? true : false,
      unitType: (map["unitType"] as String).unitTypeToEnum(),
    );
  }

  StockTransactionModel mapIngredientToStockTransaction({
    required IngredientModel ingredient,
    required int employeeId,
    required double transactionQty,
    double? qtyAsGram,
    double? qtyAsPortion,
    required String transactionDate,
    required StockTransactionType transactionType,
    WasteType? wasteType,
    String? transactionReason,
    int? productId,
  }) {
    return StockTransactionModel(
      stockId: ingredient.restaurantStockId,
      employeeId: employeeId,
      itemName: ingredient.name,
      unitType: ingredient.unitType,
      pricePerUnit:
          ingredient.pricePerIngredient ?? 0.0, // Default to 0 if null
      transactionQty: transactionQty,
      qtyAsGram: qtyAsGram,
      qtyAsPortion: qtyAsPortion,
      transactionDate: transactionDate,
      wasteType: wasteType,
      transactionReason: transactionReason,
      transactionType: StockTransactionType.stockOut, // Default to stockIn
      productId: productId,
    );
  }
}
