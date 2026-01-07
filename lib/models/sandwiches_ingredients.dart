import 'dart:convert';

class SandwichesIngredients {
  int? id;
  final int ingredientId;
  final int productId;
  SandwichesIngredients({
    this.id,
    required this.ingredientId,
    required this.productId,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'ingredientId': ingredientId,
      'productId': productId,
    };
  }

  factory SandwichesIngredients.fromMap(Map<String, dynamic> map) {
    return SandwichesIngredients(
      id: map['id'] != null ? map['id'] as int : null,
      ingredientId: map['ingredientId'] as int,
      productId: map['productId'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory SandwichesIngredients.fromJson(String source) =>
      SandwichesIngredients.fromMap(
          json.decode(source) as Map<String, dynamic>);
}
