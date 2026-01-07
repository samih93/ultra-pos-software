// ignore_for_file: public_member_api_docs, sort_constructors_first

class SalesByCategoryModel {
  int? id;
  String? name;
  double totalCost;
  double paidCost;
  double profit;
  int? categoryId;
  SalesByCategoryModel(
      {this.id,
      this.name,
      required this.totalCost,
      required this.paidCost,
      required this.profit,
      required this.categoryId});
}
