// ignore_for_file: public_member_api_docs, sort_constructors_first
class CustomerModel {
  int? id;
  String? name;
  String? phoneNumber;
  String? address;
  int? discount;
  double? totalPurchases;

  factory CustomerModel.fake() {
    return CustomerModel(
      id: 1,
      name: "user",
      phoneNumber: "0000000",
      totalPurchases: 0,
    );
  }
  CustomerModel({
    this.id,
    this.name,
    this.phoneNumber,
    this.address,
    this.discount,
    this.totalPurchases,
  });

  CustomerModel.second();
  factory CustomerModel.fromJson(Map<String, dynamic> map) {
    return CustomerModel(
      id: map["id"] as int?,
      name: map["name"] as String?,
      phoneNumber: map["phoneNumber"] as String?,
      totalPurchases: map["totalPurchases"] != null
          ? double.tryParse(map["totalPurchases"].toString()) ?? 0
          : 0,
      address: map["address"] as String?,
      discount: int.tryParse(map["discount"].toString()) ?? 0,
    );
  }

  toJson() {
    return {
      "name": name,
      "phoneNumber": phoneNumber,
      "address": address,
      "discount": discount,
    };
  }

  @override
  String toString() {
    return ' name: $name, phoneNumber: $phoneNumber, address: $address';
  }
}
