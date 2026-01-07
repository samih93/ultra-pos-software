// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:desktoppossystem/shared/utils/extentions.dart';

class SalesProductModel {
  int? id;
  String? name;
  String? barcode;
  double qty;
  double totalCost;
  double paidCost;
  double profit;
  bool? isHasIngredients = false;
  int? categoryId;
  SalesProductModel(
      {this.id,
      this.name,
      required this.qty,
      required this.totalCost,
      required this.paidCost,
      required this.profit,
      required this.categoryId});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'barcode': barcode,
      'totalCost': totalCost.formatDouble(),
      'paidCost': paidCost.formatDouble(),
      'qty': qty.formatDouble(),
      'profit': profit.formatDouble(),
      'categoryId': categoryId,
    };
  }

  // factory SalesProductModel.fromMap(Map<String, dynamic> map) {
  //   return SalesProductModel(
  //     id: map['id'] != null ? map['id'] as int : null,
  //     name: map['name'] != null ? map['name'] as String : null,
  //     profit: map['profit'] != null ? map['profit'] as double : 0,
  //   );
  // }
}
