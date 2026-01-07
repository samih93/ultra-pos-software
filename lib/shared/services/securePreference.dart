import 'dart:convert';

import 'package:desktoppossystem/models/user_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecurePreferences {
  FlutterSecureStorage flutterSecureStorage;

  SecurePreferences(this.flutterSecureStorage);

  Future saveUser(UserModel user) async {
    return await flutterSecureStorage.write(
      key: 'user',
      value: jsonEncode(user.toJson()),
    );
  }

  Future<UserModel?> getUser() async {
    final json = await flutterSecureStorage.read(key: 'user') ?? '';
    return json != '' ? UserModel.fromJson(jsonDecode(json)) : null;
  }

  Future saveData({required String key, required dynamic value}) async {
    await flutterSecureStorage.write(key: key, value: value);
  }

  Future<String?> getData({required String key}) async {
    return await flutterSecureStorage.read(key: key);
  }

  Future<Map<String, String>> fetchAll() async {
    return await flutterSecureStorage.readAll();
  }

  Future removeByKey({required String key}) async {
    await flutterSecureStorage.delete(key: key);
  }

  Future removeAll() async {
    await flutterSecureStorage.deleteAll();
  }
}
