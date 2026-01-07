// File: lib/core/config/secure_config.dart
import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class SecureConfig {
  static final _key = encrypt.Key.fromUtf8('d9f3b8e7a1c4f2d6e8b9a3c7f0e1d5b2');
  static final _iv = encrypt.IV(Uint8List.fromList(List.filled(16, 0)));
  static final _encrypter = encrypt.Encrypter(encrypt.AES(_key));
  // Obfuscated values (paste output from Step 1)
  static const _obfuscatedUrl =
      'qui:SlSHSPdhXozJinu5TpblJN4DoSUHtZH6jgWri0tgrtBO6W3UzJf46gVKjy+QAhW6';
  static const _obfuscatedAnonKey =
      'qui:R1m5UOYcEsr1lV2DYYfCeOIegiAgrKGknzWEzyx4q/h5yEaeh9ziz30htGrxRXT45FBCc4z1ss/EdWANOAh4v7piBD8lwYYzPPSFV0bhQL7kyVBTu1EG0d9oZXCKl62+4f3PCUFOgYBHopQIeU96NuFOffcZnbHsdZ9LUfN+rZMQd84N3YDhoVRZ0S4q8H5UmHy80w097cR4mrJOXV4+K9vdme9oE/ebQxH3D4wKvxz5VJESx0OPfQbQlwpLWQUACxUmdnRJwoxBjVwesssAbbG6NU2g4r0WYZxnQvFbh28=';
  static const _obfuscatedSupaEmail =
      'qui:RkGeWe4oEM6Dz1etWZziJYIUpD5lzv+d8HrB9Wkf16w=';
  static const _obfuscatedSupaPassword =
      'qui:U1WaTuEpIePJj0j4Ab25fLxn20N50uOB7Gbd6XUDy7A=';
  static const _obfuscatedQE =
      'qui:QU+BXdtpROPdkXajWNPoJsF4xFxmzfye83nC9moc1K8=';
  static const _obfuscatedKP =
      'qui:QU+BXdQbAtDNzGWua8++CZ5CxV1nzP2f8njD92sd1a4=';
  static const _quiverUserId = 'qui:GxPAALBtQpOO+xDNM/qMTg==';
  static const _telegramBotToken =
      'qui:GhTLC7FpQpCNyC2LdbvHGPQdnxsMlLnJjEWItlAil+NkszWekdLU8nsV1U/ybR+w';
  static const _telegramRequestUrl =
      'qui:SlSHSPdhXozbjH7kQJjnLMsFqj5HrYH20xSijWEX36Q=';
  static const _ultraPosTokenKey =
      'qui:R1m5UOYcEsr1lV2DYYfCeOIegiAgrKGknzWEzyx4q/h5yEaeh9ziz30htGrxRXT45lBNXdb2h8DXSWJqfA8nlO91XxQry9sZOtP4f0bHReOo4wdr+n5aiN58O2r38Jvg';
  static const _subscribtionKey =
      "qui:UVWRS+cpGMHOlXikdZ7/INoWvzYNyfia933G8m4Y0Ks=";

  static const _activateMenuKey = "qui:T0WdTcU4BcrMnWOvUP6ISg==";
  static const _onlyActivateMenuKey =
      "qui:TU6fQck+H9b7n2OjQpz/LMh4xFxmzfye83nC9moc1K8=";

  // Runtime getters
  static String get supabaseUrl => deObfuscateCoreManagerKeys(_obfuscatedUrl);
  static String get supabaseAnonKey =>
      deObfuscateCoreManagerKeys(_obfuscatedAnonKey);
  static String get supaEmail =>
      deObfuscateCoreManagerKeys(_obfuscatedSupaEmail);
  static String get supaPass =>
      deObfuscateCoreManagerKeys(_obfuscatedSupaPassword);
  static String get coreEmail => deObfuscateCoreManagerKeys(_obfuscatedQE);
  static String get corePassword => deObfuscateCoreManagerKeys(_obfuscatedKP);
  static String get quiverUserId => deObfuscateCoreManagerKeys(_quiverUserId);
  // one way hashed keys
  static String get launchTimeKey => hashKey("lastLaunchTime");
  static String get validDateKey => hashKey('validDate');
  static String get licenseKey => hashKey('isLicenseExpires');
  static String get trueKey => hashKey('true');
  static String get falseKey => hashKey('false');
  static String get telegramBotToken =>
      deObfuscateCoreManagerKeys(_telegramBotToken);
  static String get telegramRequestUrl =>
      "${deObfuscateCoreManagerKeys(_telegramRequestUrl)}$telegramBotToken/sendMessage";
  static String get ultraPosTokenKey =>
      deObfuscateCoreManagerKeys(_ultraPosTokenKey);
  static String get subscriptionKey => hashKey("activateSubscription");

  static String obfuscateCoreManagerKeys(String text) {
    final encrypted = _encrypter.encrypt(text, iv: _iv);
    return 'qui:${encrypted.base64}';
  }

  static String get activateMenuKey => hashKey("activateMenu");
  static String get onlyActivateMenuKey => hashKey("onlyActivateMenu");

  static String deObfuscateCoreManagerKeys(String? encryptedText) {
    try {
      if (encryptedText == null || !encryptedText.startsWith('qui:')) {
        return "";
      }
      final base64Str = encryptedText.substring(4); // remove 'qui:'

      final encrypted = encrypt.Encrypted.fromBase64(base64Str);
      final decrypted = _encrypter.decrypt(encrypted, iv: _iv);

      return decrypted;
    } catch (e) {
      throw Exception('failed for obfuscated data: $e');
    }
  }

  static String hashKey(String key) {
    final bytes = utf8.encode(key);
    final digest = sha256.convert(bytes);
    return digest.toString(); // hex string of 64 chars
  }
}
