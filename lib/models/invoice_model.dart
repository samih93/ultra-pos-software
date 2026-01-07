// ignore_for_file: public_member_api_docs, sort_constructors_first

class InvoiceModel {
  final int? id;
  final String referenceId;
  double? foreignPrice;
  double? localPrice;
  String? receiptDate;
  int? userId;
  int? supplierId;
  String? supplierName;
  double? dolarRate;
  bool? transactionInPrimary;

  InvoiceModel({
    this.id,
    required this.referenceId,
    this.foreignPrice,
    this.localPrice,
    this.receiptDate,
    this.userId,
    this.supplierId,
    this.supplierName,
    this.dolarRate,
    this.transactionInPrimary,
  });

  InvoiceModel copyWith({
    int? id,
    String? referenceId,
    double? foreignPrice,
    double? localPrice,
    String? receiptDate,
    int? userId,
    int? supplierId,
    String? supplierName,
    double? dolarRate,
    bool? transactionInPrimary,
  }) {
    return InvoiceModel(
      id: id ?? this.id,
      referenceId: referenceId ?? this.referenceId,
      foreignPrice: foreignPrice ?? this.foreignPrice,
      localPrice: localPrice ?? this.localPrice,
      receiptDate: receiptDate ?? this.receiptDate,
      userId: userId ?? this.userId,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      dolarRate: dolarRate ?? this.dolarRate,
      transactionInPrimary: transactionInPrimary ?? this.transactionInPrimary,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'referenceId': referenceId,
      'foreignPrice': foreignPrice,
      'localPrice': localPrice,
      'receiptDate': receiptDate,
      'userId': userId,
      'supplierId': supplierId,
      'dolarRate': dolarRate,
      'transactionInPrimary': transactionInPrimary == true ? 1 : 0,
    };
  }

  factory InvoiceModel.fromMap(Map<String, dynamic> map) {
    return InvoiceModel(
      id: map['id'] as int,
      referenceId: map['referenceId'],
      foreignPrice:
          map['foreignPrice'] != null ? map['foreignPrice'] as double : null,
      localPrice:
          map['localPrice'] != null ? map['localPrice'] as double : null,
      receiptDate:
          map['receiptDate'] != null ? map['receiptDate'] as String : null,
      userId: map['userId'] != null ? map['userId'] as int : null,
      supplierName: map['supplierName'],
      dolarRate: map['dolarRate'] != null ? map['dolarRate'] as double : null,
      transactionInPrimary: map['transactionInPrimary'] != null
          ? map['transactionInPrimary'] == 1
              ? true
              : false
          : false,
    );
  }

  @override
  String toString() {
    return 'InvoiceModel(id: $id, foreignPrice: $foreignPrice, localPrice: $localPrice, receiptDate: $receiptDate, userId: $userId, dolarRate: $dolarRate, transactionInPrimary: $transactionInPrimary)';
  }
}
