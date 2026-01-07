package com.core.manager

import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.core.manager/version"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        GeneratedPluginRegistrant.registerWith(flutterEngine)

        // Set up the method channel to communicate with Dart
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getVersionCode") {
                val versionCode = getVersionCode()
                result.success(versionCode)
            } else if (call.method == "getVersionName") {
                val versionName = getVersionName()
                result.success(versionName)
            } else {
                result.notImplemented()
            }
        }
    }

    // Get the version code from the package info
    private fun getVersionCode(): String? {
        return try {
            val packageInfo: PackageInfo = packageManager.getPackageInfo(packageName, 0)
            packageInfo.versionCode.toString()
        } catch (e: PackageManager.NameNotFoundException) {
            null
        }
    }

    // Get the version name from the package info
    private fun getVersionName(): String? {
        return try {
            val packageInfo: PackageInfo = packageManager.getPackageInfo(packageName, 0)
            packageInfo.versionName
        } catch (e: PackageManager.NameNotFoundException) {
            null
        }
    }
}