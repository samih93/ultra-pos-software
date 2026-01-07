// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class DetailsInvoice {
  int? id;
  String? productName;
  int? productId;
  int? invoiceId;
  double? qty;
  double? costPrice;
  double? sellingPrice;
  DetailsInvoice({
    this.id,
    this.productName,
    this.productId,
    this.invoiceId,
    this.qty,
    this.costPrice,
    this.sellingPrice,
  });

  DetailsInvoice copyWith({
    int? id,
    String? productName,
    int? productId,
    int? invoiceId,
    double? qty,
    double? costPrice,
    double? sellingPrice,
  }) {
    return DetailsInvoice(
      id: id ?? this.id,
      productName: productName ?? this.productName,
      productId: productId ?? this.productId,
      invoiceId: invoiceId ?? this.invoiceId,
      qty: qty ?? this.qty,
      costPrice: costPrice ?? this.costPrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'productName': productName,
      'productId': productId,
      'invoiceId': invoiceId,
      'qty': qty,
      'costPrice': costPrice,
      'sellingPrice': sellingPrice,
    };
  }

  factory DetailsInvoice.fromMap(Map<String, dynamic> map) {
    return DetailsInvoice(
      id: map['id'] != null ? map['id'] as int : null,
      productName:
          map['productName'] != null ? map['productName'] as String : null,
      productId: map['productId'] != null ? map['productId'] as int : null,
      invoiceId: map['invoiceId'] != null ? map['invoiceId'] as int : null,
      qty: map['qty'] != null ? map['qty'] as double : null,
      costPrice: map['costPrice'] != null ? map['costPrice'] as double : null,
      sellingPrice:
          map['sellingPrice'] != null ? map['sellingPrice'] as double : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory DetailsInvoice.fromJson(String source) =>
      DetailsInvoice.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'DetailsInvoice(id: $id, productName: $productName, productId: $productId, invoiceId: $invoiceId, qty: $qty, costPrice: $costPrice, sellingPrice: $sellingPrice)';
  }

  @override
  bool operator ==(covariant DetailsInvoice other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.productName == productName &&
        other.productId == productId &&
        other.invoiceId == invoiceId &&
        other.qty == qty &&
        other.costPrice == costPrice &&
        other.sellingPrice == sellingPrice;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        productName.hashCode ^
        productId.hashCode ^
        invoiceId.hashCode ^
        qty.hashCode ^
        costPrice.hashCode ^
        sellingPrice.hashCode;
  }
}
