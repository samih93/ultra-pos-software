// ignore_for_file: public_member_api_docs, sort_constructors_first

class PurchaseDetailsModel {
  int? id;
  String? productName;
  String? barcode;
  int? productId;
  int? invoiceId;
  double? qty;
  double? oldCostPrice;
  double? profitRate;
  double? costPrice;
  double? newAverageCost;
  double? oldQty;
  double? sellingPrice;
  double? oldSellingPrice;
  PurchaseDetailsModel(
      {this.id,
      this.productName,
      this.barcode,
      this.productId,
      this.invoiceId,
      this.qty,
      this.oldCostPrice,
      this.profitRate,
      this.costPrice,
      this.newAverageCost,
      this.oldSellingPrice,
      this.sellingPrice,
      this.oldQty});

  PurchaseDetailsModel copyWith({
    int? id,
    String? productName,
    int? productId,
    int? invoiceId,
    double? qty,
    double? oldCostPrice,
    double? costPrice,
    double? newAverageCost,
    double? oldSellingPrice,
    double? sellingPrice,
    double? oldQty,
  }) {
    return PurchaseDetailsModel(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      productId: productId ?? this.productId,
      invoiceId: invoiceId ?? this.invoiceId,
      qty: qty ?? this.qty,
      oldCostPrice: oldCostPrice ?? this.oldCostPrice,
      costPrice: costPrice ?? this.costPrice,
      newAverageCost: newAverageCost ?? this.newAverageCost,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      oldSellingPrice: oldSellingPrice ?? this.oldSellingPrice,
      oldQty: oldQty ?? this.oldQty,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'productId': productId,
      'invoiceId': invoiceId,
      'qty': qty,
      'costPrice': costPrice,
      'newAverageCost': newAverageCost,
      'sellingPrice': sellingPrice,
      'oldCostPrice': oldCostPrice,
      'oldSellingPrice': oldSellingPrice,
      'oldQty': oldQty,
    };
  }

  factory PurchaseDetailsModel.fromMap(Map<String, dynamic> map) {
    return PurchaseDetailsModel(
      id: map['id'] != null ? map['id'] as int : null,
      productName:
          map['productName'] != null ? map['productName'] as String : null,
      barcode: map['barcode'] != null ? map['barcode'] as String : null,
      productId: map['productId'] != null ? map['productId'] as int : null,
      invoiceId: map['invoiceId'] != null ? map['invoiceId'] as int : null,
      oldQty: map['oldQty'] != null ? map['oldQty'] as double : null,
      qty: map['qty'] != null ? map['qty'] as double : null,
      costPrice: map['costPrice'] != null ? map['costPrice'] as double : null,
      newAverageCost: map['newAverageCost'] != null
          ? map['newAverageCost'] as double
          : null,
      sellingPrice:
          map['sellingPrice'] != null ? map['sellingPrice'] as double : null,
      oldCostPrice:
          map['oldCostPrice'] != null ? map['oldCostPrice'] as double : null,
      oldSellingPrice: map['oldSellingPrice'] != null
          ? map['oldSellingPrice'] as double
          : null,
    );
  }

  @override
  String toString() {
    return 'InvoiceDetails(id: $id, productName: $productName, productId: $productId, invoiceId: $invoiceId, qty: $qty, costPrice: $costPrice, sellingPrice: $sellingPrice)';
  }

  @override
  bool operator ==(covariant PurchaseDetailsModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.productName == productName &&
        other.productId == productId &&
        other.invoiceId == invoiceId &&
        other.qty == qty &&
        other.oldCostPrice == oldCostPrice &&
        other.costPrice == costPrice &&
        other.oldQty == oldQty &&
        other.sellingPrice == sellingPrice &&
        other.oldSellingPrice == oldSellingPrice;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        productName.hashCode ^
        productId.hashCode ^
        invoiceId.hashCode ^
        qty.hashCode ^
        oldCostPrice.hashCode ^
        costPrice.hashCode ^
        oldQty.hashCode ^
        sellingPrice.hashCode ^
        oldSellingPrice.hashCode;
  }
}
