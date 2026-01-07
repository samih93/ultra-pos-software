import 'package:desktoppossystem/shared/services/app_preferences.dart';
import 'package:desktoppossystem/shared/services/database_backup_restore_service.dart';
import 'package:desktoppossystem/shared/services/menu_dio_helper.dart';
import 'package:desktoppossystem/shared/services/dio_helper.dart';
import 'package:desktoppossystem/shared/services/file_logger.dart';
import 'package:desktoppossystem/shared/services/pos_db_helper.dart';
import 'package:desktoppossystem/shared/services/securePreference.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';

final appPreferencesProvider = Provider<AppPreferences>((ref) {
  return AppPreferences();
});

final secureStorageProvider = Provider((ref) {
  return const FlutterSecureStorage(
    wOptions: WindowsOptions(useBackwardCompatibility: false),
  );
});

final securePreferencesProvider = Provider<SecurePreferences>((ref) {
  return SecurePreferences(ref.read(secureStorageProvider));
});

// Regular Dio without authentication
Dio coreTechDio = Dio(BaseOptions(receiveDataWhenStatusError: true));
final quiverDioProvider = Provider<DioHelper>((ref) {
  return DioHelper(coreTechDio);
});

// Authenticated Dio for menu APIs (automatically includes token and user key)
Dio ultraPosDio = Dio(
  BaseOptions(
    receiveDataWhenStatusError: true,
    baseUrl: 'https://ultrapos.ultra-pal.com/api', // Set your base URL here
    //
    //  baseUrl: 'http://192.168.1.4:3000/api', // Set your base URL here
  ),
);
final ultraPosDioProvider = Provider<UltraDioHelper>((ref) {
  return UltraDioHelper(ultraPosDio);
});

final posDbProvider = Provider<PosDbHelper>((ref) {
  return PosDbHelper.db;
});

final supaBaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final fileLoggerProvider = Provider<FileLogger>((ref) {
  return FileLogger();
});

final databaseBackupRestoreServiceProvider =
    Provider<DatabaseBackupRestoreService>((ref) {
      if (Platform.isWindows) {
        return WindowsDatabaseBackupService();
      } else {
        return AndroidDatabaseBackupService();
      }
    });
