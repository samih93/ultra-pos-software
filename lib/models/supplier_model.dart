// ignore_for_file: public_member_api_docs, sort_constructors_first

class SupplierModel {
  final int? id;
  final String name;
  final String? phoneNumber;
  final String? contactDetails;
  final String? supplierAddress;
  SupplierModel(
      {this.id,
      required this.name,
      this.phoneNumber,
      this.contactDetails,
      this.supplierAddress});

  SupplierModel copyWith({
    int? id,
    String? name,
    String? phoneNumber,
    String? contactDetails,
    String? supplierAddress,
  }) {
    return SupplierModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      contactDetails: contactDetails ?? this.contactDetails,
      supplierAddress: supplierAddress ?? this.supplierAddress,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'phoneNumber': phoneNumber,
      'contactDetails': contactDetails,
      'supplierAddress': supplierAddress,
    };
  }

  factory SupplierModel.fromMap(Map<String, dynamic> map) {
    return SupplierModel(
      id: map['id'] != null ? map['id'] as int : null,
      name: map['name'],
      phoneNumber: map['phoneNumber'] ?? '',
      contactDetails: map['contactDetails'] ?? '',
      supplierAddress: map['supplierAddress'] ?? '',
    );
  }

  @override
  String toString() =>
      'SupplierModel(id: $id, name: $name, phoneNumber: $phoneNumber)';

  @override
  bool operator ==(covariant SupplierModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.phoneNumber == phoneNumber &&
        other.contactDetails == contactDetails &&
        other.supplierAddress == supplierAddress;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        phoneNumber.hashCode ^
        contactDetails.hashCode ^
        supplierAddress.hashCode;
  }
}
