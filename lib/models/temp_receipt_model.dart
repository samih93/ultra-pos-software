import 'package:desktoppossystem/models/product_model.dart';

class TempReceiptModel {
  List<ProductModel> products;
  String note;

  TempReceiptModel({required this.products, required this.note});
  Map<String, dynamic> toJson() {
    return {
      'products': products
          .map((p) => p.toJson())
          .toList(), // Assuming ProductModel has a toJson method
      'note': note,
    };
  }

  // Convert JSON to TempInvoice
  factory TempReceiptModel.fromJson(Map<String, dynamic> json) {
    return TempReceiptModel(
      products: (json['products'] as List)
          .map((p) => ProductModel.fromJson(
              p)) // Assuming ProductModel has a fromJson method
          .toList(),
      note: json['note'],
    );
  }
}
