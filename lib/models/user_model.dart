// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:desktoppossystem/models/role_model.dart';

class UserModel {
  final int? id;
  final String? name;
  final String? email;
  final String? password;
  final RoleModel? role;

  UserModel(
      {this.id,
      required this.name,
      required this.password,
      required this.email,
      this.role});

  static UserModel fakeUser() {
    return UserModel(
        id: 1,
        name: 'user',
        email: 'example@gmail.com',
        password: 'exam',
        role: RoleModel(id: 1, name: 'user'));
  }

  factory UserModel.fromJson(Map<String, dynamic> map) {
    return UserModel(
        id: map['id'],
        name: map['name'],
        email: map['email'],
        password: map['password'],
        role: RoleModel(id: map['roleId'] ?? 0, name: map['role'] ?? 'user'));
  }

  factory UserModel.fromJsonLocalStorage(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      password: map['password'],
      role: RoleModel.fromMap(map['role']),
    );
  }

  toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role!.toMap(),
    };
  }

  toJsonWithoutId() {
    return {
      'name': name,
      'email': email,
      'roleId': role?.id,
      'password': password
    };
  }

  toJsonWithoutForCloud() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'roleId': role?.id,
      'password': password
    };
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? password,
    RoleModel? role,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
    );
  }
}
