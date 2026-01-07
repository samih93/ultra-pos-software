// ignore_for_file: public_member_api_docs, sort_constructors_first

class RoleModel {
  int id;
  String name;
  RoleModel({
    required this.id,
    required this.name,
  });

  factory RoleModel.fromMap(Map<String, dynamic> map) {
    return RoleModel(
      id: map['id'] as int,
      name: map['role'] as String,
    );
  }

  toMap() {
    return <String, dynamic>{
      'id': id,
      'role': name,
    };
  }

  toMapWithoutId() {
    return <String, dynamic>{
      //'id': id,
      'role': name,
    };
  }
}
