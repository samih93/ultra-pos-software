import 'package:desktoppossystem/models/ingrendient_model.dart';

class DetailsReceipt {
  int? id;
  String? productName;
  bool? selected = false;
  int? productId;
  int? receiptId;
  double? qty;
  double? originalSellingPrice;
  double? sellingPrice;
  double? costPrice;
  bool? isRefunded = false;
  double? refundedQty = 1.0;
  String? refundReason;
  String? refundDate;
  bool? isTracked;
  bool? isForStaff;
  double discount = 0;
  List<IngredientModel>? ingredients = [];

  DetailsReceipt({
    this.id,
    this.productName,
    this.originalSellingPrice,
    this.sellingPrice,
    this.costPrice,
    this.qty,
    this.productId,
    this.receiptId,
    this.isTracked,
    this.isRefunded,
    this.refundedQty,
    this.refundReason,
    this.refundDate,
    this.isForStaff,
    this.ingredients,
    required this.discount,
  });

  factory DetailsReceipt.fromJson(Map<String, dynamic> map) {
    return DetailsReceipt(
      id: map['id'],
      productName: map['productName'],
      productId: int.parse(map['productId'].toString()),
      receiptId: int.parse(map['receiptId'].toString()),
      qty: double.tryParse(map['qty'].toString()) ?? 0,
      originalSellingPrice:
          double.tryParse(map['originalSellingPrice'].toString()) ?? 0,
      sellingPrice: double.tryParse(map['sellingPrice'].toString()) ?? 0,
      costPrice: double.tryParse(map['costPrice'].toString()) ?? 0,
      isTracked: map['isTracked'] != null
          ? map['isTracked'] == 1
                ? true
                : false
          : false,
      isRefunded: map['isRefunded'] != null
          ? map['isRefunded'] == 1
                ? true
                : false
          : false,
      // used for initialize the refunds
      refundedQty: 1,
      refundReason: map['refundReason'] ?? "--",
      refundDate: map['refundDate'],
      isForStaff: map['isForStuff'],
      discount: map["discount"],
    );
  }

  toJson() {
    return {
      "productName": productName,
      "selected": selected,
      "qty": qty,
      "productId": productId,
      "receiptId": receiptId,
      "originalSellingPrice": originalSellingPrice,
      "sellingPrice": sellingPrice,
      "costPrice": costPrice,
      "isRefunded": isRefunded == true ? 1 : 0,
    };
  }

  toJsonForInsert() {
    return {
      "productId": productId,
      "receiptId": receiptId,
      "qty": qty,
      "originalSellingPrice": originalSellingPrice,
      "sellingPrice": sellingPrice,
      "costPrice": costPrice,
      "isRefunded": isRefunded == true ? 1 : 0,
      "refundReason": refundReason,
      "refundDate": refundDate,
      "isForStuff": isForStaff == true ? 1 : 0,
      "discount": discount,
    };
  }

  toJsonForSupabaseBackup() {
    return {
      "productId": productId,
      "receiptId": receiptId,
      "qty": qty,
      "originalSellingPrice": originalSellingPrice,
      "sellingPrice": sellingPrice,
      "costPrice": costPrice,
      "isRefunded": isRefunded == true ? 1 : 0,
      "refundReason": refundReason,
      "refundDate": refundDate,
      "isForStaff": isForStaff == true ? 1 : 0,
      "discount": discount,
    };
  }
}
