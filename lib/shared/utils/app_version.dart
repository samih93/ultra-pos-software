import 'package:flutter/services.dart';

class AppVersion {
  static const platform = MethodChannel('com.core.manager/version');

  static Future<String> get versionCode async {
    try {
      final String versionCode = await platform.invokeMethod('getVersionCode');
      return versionCode;
    } on PlatformException catch (e) {
      print("Failed to get version code: '${e.message}'.");
      return "Unknown";
    }
  }

  static Future<String> get versionName async {
    try {
      final String versionName = await platform.invokeMethod('getVersionName');
      return versionName;
    } on PlatformException catch (e) {
      print("Failed to get version name: '${e.message}'.");
      return "Unknown";
    }
  }
}
