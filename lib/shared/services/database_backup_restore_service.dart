import 'dart:io';

import 'package:archive/archive.dart';
import 'package:desktoppossystem/models/failure_model.dart';
import 'package:desktoppossystem/repositories/categories/category_repository.dart';
import 'package:desktoppossystem/repositories/expenses/expenses_repository.dart';
import 'package:desktoppossystem/repositories/products/product_repository.dart';
import 'package:desktoppossystem/repositories/receipts/receiptrepository.dart';
import 'package:desktoppossystem/repositories/restaurant_stock/restaurant_stock_repository.dart';
import 'package:desktoppossystem/repositories/users/user_reposiotry.dart';
import 'package:desktoppossystem/screens/settings/components/sections/general_section/components/restore_from_cloud_section.dart';
import 'package:desktoppossystem/shared/config/secure_config.dart';
import 'package:desktoppossystem/shared/constances/table_constant.dart';
import 'package:desktoppossystem/shared/default%20components/are_you_sure_dialog.dart';
import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/services/dependency_injection.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:desktoppossystem/shared/utils/type_def.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

abstract class DatabaseBackupRestoreService {
  FutureEither<List<int>> createDatabaseFileAsZip();
  FutureEitherVoid backupDatabase();
  FutureEitherVoid restoreDatabase();
  FutureEither<String> backupDatabaseToCloud(String registrationId);
  FutureEitherVoid restoreDatabaseFromCloud(String registrationId);

  Future _copyDataFromSourceToTemp(Database destinationDb) async {}

  Future<File> _saveZipToFile(List<int> zipData) async {
    // Generate a temporary file path
    final tempDir = await getTemporaryDirectory();
    final tempFile = File('${tempDir.path}/backup.zip');

    // Write the zip data to the temporary file
    await tempFile.writeAsBytes(zipData);

    return tempFile;
  }
}

//MARK:for Windows
class WindowsDatabaseBackupService extends DatabaseBackupRestoreService {
  @override
  FutureEither<List<int>> createDatabaseFileAsZip({
    String databaseName = "PosDb.db",
  }) async {
    try {
      // Locate the database file
      var databaseFactory = databaseFactoryFfi;
      var databasesPath = await databaseFactory.getDatabasesPath();
      var dbPath = path.join(databasesPath, databaseName);

      // Check if the database file exists
      if (!await File(dbPath).exists()) {
        debugPrint('Database file does not exist.');
        return left(FailureModel("Database file does not exist."));
      }

      // Construct the destination path
      final archive = Archive();
      final dbFile = File(dbPath);
      int dbFileSizeBefore = dbFile.lengthSync(); // File size before archiving
      print(
        'Database file size before archiving: ${dbFileSizeBefore / (1024 * 1024)} MB',
      );
      archive.addFile(
        ArchiveFile('PosDb.db', dbFile.lengthSync(), dbFile.readAsBytesSync()),
      );
      final zipData = ZipEncoder().encode(archive);
      int zipFileSize = zipData.length;
      print(
        'Zip file size after compression: ${zipFileSize / (1024 * 1024)} MB',
      );
      return right(zipData);
    } catch (e) {
      print(e.toString());
      return left(FailureModel("An error occurred during backup: $e"));
    }
  }

  @override
  FutureEitherVoid backupDatabase() async {
    try {
      final zipDataResponse = await createDatabaseFileAsZip();
      return zipDataResponse.fold(
        (l) {
          return left(FailureModel(l.message));
        },
        (r) async {
          String? selectedDirectory = await FilePicker.platform
              .getDirectoryPath();
          if (selectedDirectory == null) {
            return left(FailureModel("Backup canceled"));
          }
          String backupPath = path.join(
            selectedDirectory.toString(),
            '${generateUniqueFileName("core_Backup")}.zip',
          );

          await File(backupPath).writeAsBytes(r);
          return right(null);
        },
      );
    } catch (e) {
      return left(FailureModel("An error occurred during backup: $e"));
    }
  }

  @override
  FutureEitherVoid restoreDatabase() async {
    Database database = globalAppWidgetRef.read(posDbProvider).database;
    final databaseFactory = databaseFactoryFfi;
    final databasesPath = await databaseFactory.getDatabasesPath();
    final dbPath = path.join(databasesPath, "PosDb.db");
    try {
      // Select the backup zip file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
        allowMultiple: false,
      );
      if (result == null || result.files.isEmpty) {
        return left(FailureModel("No backup file selected"));
      }

      // 2. Verify the zip contains our database file
      final zipFilePath = result.files.single.path!;
      final zipData = await File(zipFilePath).readAsBytes();
      final archive = ZipDecoder().decodeBytes(zipData);

      if (!archive.files.any((file) => file.name == 'PosDb.db')) {
        return left(
          FailureModel("Selected file is not a valid database backup"),
        );
      }
      final confirm = await showDialog<bool>(
        context: globalAppContext,
        builder: (context) {
          return AreYouSureDialog(
            "Are you sure you want to restore and override your current data? ",
            agreeText: "Confirm restore",
            onCancel: () => globalAppContext.pop(value: false),
            onAgree: () {
              globalAppContext.pop(value: true);
            },
          );
        },
      );
      if (confirm == true) {
        // User confirmed; now restore
        await database.close();

        ArchiveFile? dbArchiveFile = archive.files.firstWhere(
          (file) => file.name == 'PosDb.db',
          orElse: () => throw Exception('Database file not found in backup'),
        );

        await windowsSafeReplace(
          dbPath: dbPath,
          newData: dbArchiveFile.content as List<int>,
        );

        return right(null);
      } else {
        return left(FailureModel("Restore cancelled by user"));
      }
    } catch (e) {
      return left(FailureModel("An error occurred during restore: $e"));
    }
  }

  Future<void> windowsSafeReplace({
    required String dbPath,
    required List<int> newData,
  }) async {
    final tempPath = '$dbPath.temp';
    final walPath = '$dbPath-wal';
    final shmPath = '$dbPath-shm';

    try {
      // Write to temp file first
      await File(tempPath).writeAsBytes(newData);

      // Delete existing files if they exist
      await deleteIfExists(dbPath);
      await deleteIfExists(walPath);
      await deleteIfExists(shmPath);

      // Atomic rename
      await File(tempPath).rename(dbPath);
    } catch (e) {
      await deleteIfExists(tempPath);
      rethrow;
    }
  }

  Future<void> deleteIfExists(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Warning: Could not delete $path: $e');
      // Continue anyway - this might be just a missing file
    }
  }

  @override
  FutureEither<String> backupDatabaseToCloud(String registrationId) async {
    try {
      Database database = globalAppWidgetRef.read(posDbProvider).database;

      var currentDatabasesPath = await databaseFactoryFfi.getDatabasesPath();
      var dbPath = path.join(currentDatabasesPath, "PosDb.db");

      // Create a zip of the database using your common function
      final zipDataResponse = await createDatabaseFileAsZip();
      double fileSizeInMB = 0;
      bool isCompletlyBackedup = false;

      await zipDataResponse.fold<Future>(
        (l) async {
          return left(FailureModel("Failed to create database zip file."));
        },
        (r) async {
          // Calculate the size of the zip file

          String uploadPath = 'databases/$registrationId/backup.zip';
          final tempFile = await _saveZipToFile(r);
          int fileSizeInBytes = tempFile.lengthSync(); // Get file size in bytes
          fileSizeInMB = fileSizeInBytes / (1024 * 1024); // Convert to MB
          if (fileSizeInMB <= 40) {
            isCompletlyBackedup = true;
            // If file size is less than or equal to 40MB, just upload the zip file
            await globalAppWidgetRef
                .read(supaBaseProvider)
                .storage
                .from('ultra_pos')
                .upload(
                  uploadPath,
                  tempFile, // Upload as stream of bytes
                  fileOptions: const FileOptions(upsert: true),
                );
            tempFile.delete();
          } else {
            isCompletlyBackedup = false;
            // Step 1: Get the source database from Riverpod
            Database sourceDb = database;
            print("use manual copy");
            // Step 2: Copy the destination database from assets and open it
            dbPath = await _copyDatabaseOnWindowsToTemp();
            Database destinationDb = await databaseFactoryFfi.openDatabase(
              dbPath,
            );

            // Step 6: Copy data from the source database to the temporary database
            await _copyDataFromSourceToTemp(destinationDb);
            // Step 7: Run VACUUM to reduce the size of the temporary database
            await destinationDb.execute('VACUUM');

            await destinationDb.close();
            final newZip = await createDatabaseFileAsZip(
              databaseName: "TempDb.db",
            );

            return newZip.fold((l) {}, (r) async {
              final tempFile = await _saveZipToFile(r);

              fileSizeInBytes = tempFile.lengthSync(); // Get file size in bytes
              fileSizeInMB = fileSizeInBytes / (1024 * 1024); // Convert to MB
              print("new temp size $fileSizeInMB");
              await globalAppWidgetRef
                  .read(supaBaseProvider)
                  .storage
                  .from('ultra_pos')
                  .upload(
                    uploadPath,
                    tempFile,
                    fileOptions: const FileOptions(upsert: true),
                  );
              tempFile.delete();
            });
          }
        },
      );

      return right(
        "${fileSizeInMB.toStringAsFixed(2)} MB - completlyBackedup: ${isCompletlyBackedup ? 'yes' : 'no'}",
      );
    } catch (e) {
      print("error is $e");
      String url = SecureConfig.supabaseUrl.split("//").last;
      return left(
        FailureModel(
          "An error occurred during backup: ${e.toString().replaceAll(url, "******")}",
        ),
      );
    }
  }

  Future<String> _copyDatabaseOnWindowsToTemp() async {
    // Step 1: Get the path for the temporary database
    var databasesPath = await databaseFactoryFfi.getDatabasesPath();
    var tempDbPath = path.join(databasesPath, "TempDb.db");

    // Step 2: Load the empty database from assets
    ByteData data = await rootBundle.load("assets/db/PosDb.db");
    List<int> bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );

    // Step 3: Write the empty database to the temporary location
    await File(tempDbPath).writeAsBytes(bytes);

    return tempDbPath;
  }

  @override
  FutureEitherVoid restoreDatabaseFromCloud(String registrationId) async {
    Database database = globalAppWidgetRef.read(posDbProvider).database;
    final databaseFactory = databaseFactoryFfi;
    final databasesPath = await databaseFactory.getDatabasesPath();
    final dbPath = path.join(databasesPath, 'PosDb.db');

    try {
      // Reset progress
      globalAppWidgetRef.read(restoreFromCloudProgressProvider.notifier).state =
          0.0;

      // Get Supabase client
      final supabase = globalAppWidgetRef.read(supaBaseProvider);

      // Construct paths
      final zipFilePath = path.join(databasesPath, 'backup.zip');
      String downloadPath = 'databases/$registrationId/backup.zip';

      // Get public URL from Supabase storage
      final publicPath = supabase.storage
          .from('ultra_pos')
          .getPublicUrl(downloadPath);

      debugPrint("Downloading from: $publicPath");

      // Download the backup zip file using Dio with direct progress tracking
      final dio = Dio();
      await dio.download(
        publicPath,
        zipFilePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            // Direct progress tracking from 0% to 70% for download
            final downloadProgress = (received / total) * 70;
            globalAppWidgetRef
                    .read(restoreFromCloudProgressProvider.notifier)
                    .state =
                downloadProgress;
          }
        },
      );

      // Progress 70% - Download completed, starting extraction
      globalAppWidgetRef.read(restoreFromCloudProgressProvider.notifier).state =
          70.0;

      // Read and verify the zip file
      final zipData = await File(zipFilePath).readAsBytes();
      final archive = ZipDecoder().decodeBytes(zipData);

      if (!archive.files.any((file) => file.name == 'PosDb.db')) {
        await deleteIfExists(zipFilePath);
        return left(
          FailureModel("Downloaded file is not a valid database backup"),
        );
      }

      // Progress 75% - Verification complete
      globalAppWidgetRef.read(restoreFromCloudProgressProvider.notifier).state =
          75.0;

      // Extract the database file from archive
      ArchiveFile? dbArchiveFile = archive.files.firstWhere(
        (file) => file.name == 'PosDb.db',
        orElse: () => throw Exception('Database file not found in backup'),
      );

      // Progress 80% - Starting database replacement
      globalAppWidgetRef.read(restoreFromCloudProgressProvider.notifier).state =
          80.0;

      // Close the database before replacing
      await database.close();
      debugPrint('Database closed successfully');

      // Progress 85% - Database closed, replacing files
      globalAppWidgetRef.read(restoreFromCloudProgressProvider.notifier).state =
          85.0;

      // Use safe replace method (same as local restore)
      await windowsSafeReplace(
        dbPath: dbPath,
        newData: dbArchiveFile.content as List<int>,
      );

      debugPrint('Database file replaced successfully at: $dbPath');

      // Progress 90% - Database replacement completed, starting verification
      globalAppWidgetRef.read(restoreFromCloudProgressProvider.notifier).state =
          90.0;

      // Verify the file was written correctly
      final restoredFile = File(dbPath);
      if (!await restoredFile.exists()) {
        throw Exception('Failed to write restored database file');
      }

      final fileSize = await restoredFile.length();
      debugPrint('Restored database file size: $fileSize bytes');

      // Progress 95% - Starting database validation
      globalAppWidgetRef.read(restoreFromCloudProgressProvider.notifier).state =
          95.0;

      // Additional verification - try to open the database to ensure it's valid
      try {
        final testDb = await databaseFactoryFfi.openDatabase(
          dbPath,
          options: OpenDatabaseOptions(readOnly: true),
        );
        await testDb.close();
        debugPrint('Database validation successful');
      } catch (e) {
        debugPrint('Database validation failed: $e');
        throw Exception('Restored database appears to be corrupted');
      }

      // Cleanup zip file
      await deleteIfExists(zipFilePath);

      // Save restore date
      await globalAppWidgetRef
          .read(appPreferencesProvider)
          .saveData(key: "lastRestoreDate", value: DateTime.now().toString());

      // Progress 100% - Restoration completed
      globalAppWidgetRef.read(restoreFromCloudProgressProvider.notifier).state =
          100.0;
      debugPrint('Database restore completed successfully');
      return right(null);
    } catch (e) {
      debugPrint('Cloud restore failed: $e');
      // Reset progress on failure
      globalAppWidgetRef.read(restoreFromCloudProgressProvider.notifier).state =
          0.0;
      return left(FailureModel('Database restore from cloud failed: $e'));
    }
  }
}

//MARK: for android
class AndroidDatabaseBackupService extends DatabaseBackupRestoreService {
  @override
  FutureEither<List<int>> createDatabaseFileAsZip({
    String databaseName = "PosDb.db",
  }) async {
    try {
      var databasesPath = await getDatabasesPath();
      var dbPath = path.join(databasesPath, databaseName);
      if (!await File(dbPath).exists()) {
        debugPrint('Database file does not exist.');
        return left(FailureModel("Database file does not exist."));
      }

      final archive = Archive();
      final dbFile = File(dbPath);
      archive.addFile(
        ArchiveFile('PosDb.db', dbFile.lengthSync(), dbFile.readAsBytesSync()),
      );

      final zipData = ZipEncoder().encode(archive);

      return right(zipData);
    } catch (e) {
      return left(FailureModel("An error occurred during backup: $e"));
    }
  }

  @override
  FutureEitherVoid backupDatabase() async {
    try {
      final zipDataResponse = await createDatabaseFileAsZip();
      return zipDataResponse.fold(
        (l) {
          return left(FailureModel(l.message));
        },
        (r) async {
          // Save in Public Downloads folder (accessible by user & file picker)
          final directory = Directory('/storage/emulated/0/Download');
          if (!await directory.exists()) {
            await directory.create(recursive: true);
          }

          final backupPath = path.join(
            directory.path,
            '${generateUniqueFileName("core_Backup")}.zip',
          );
          await File(backupPath).writeAsBytes(r);
          return right(null);
        },
      );
    } catch (e) {
      return left(FailureModel("An error occurred during backup: $e"));
    }
  }

  @override
  FutureEitherVoid restoreDatabase() async {
    try {
      // Select the backup zip file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
        allowMultiple: false,
      );
      if (result == null || result.files.isEmpty) {
        return left(FailureModel("No backup file selected"));
      }

      // Verify the zip contains our database file
      final zipFilePath = result.files.single.path!;
      final zipData = await File(zipFilePath).readAsBytes();
      final archive = ZipDecoder().decodeBytes(zipData);

      if (!archive.files.any((file) => file.name == 'PosDb.db')) {
        return left(
          FailureModel("Selected file is not a valid database backup"),
        );
      }

      // Show confirmation dialog
      final confirm = await showDialog<bool>(
        context: globalAppContext,
        builder: (context) {
          return AreYouSureDialog(
            "Are you sure you want to restore and override your current data?",
            agreeText: "Confirm restore",
            onCancel: () => globalAppContext.pop(value: false),
            onAgree: () {
              globalAppContext.pop(value: true);
            },
          );
        },
      );

      if (confirm != true) {
        return left(FailureModel("Restore cancelled by user"));
      }

      // User confirmed, now restore
      Database database = globalAppWidgetRef.read(posDbProvider).database;
      await database.close();

      final databasesPath = await getDatabasesPath();
      final dbPath = path.join(databasesPath, "PosDb.db");

      ArchiveFile dbArchiveFile = archive.files.firstWhere(
        (file) => file.name == 'PosDb.db',
        orElse: () => throw Exception('Database file not found in backup'),
      );

      await androidSafeReplace(
        dbPath: dbPath,
        newData: dbArchiveFile.content as List<int>,
      );

      return right(null);
    } catch (e) {
      return left(FailureModel("An error occurred during restore: $e"));
    }
  }

  Future<void> androidSafeReplace({
    required String dbPath,
    required List<int> newData,
  }) async {
    final tempPath = '$dbPath.temp';
    final walPath = '$dbPath-wal';
    final shmPath = '$dbPath-shm';

    try {
      // Write to temp file first
      await File(tempPath).writeAsBytes(newData);

      // Delete existing DB files
      await deleteIfExists(dbPath);
      await deleteIfExists(walPath);
      await deleteIfExists(shmPath);

      // Atomic rename
      await File(tempPath).rename(dbPath);
    } catch (e) {
      await deleteIfExists(tempPath);
      rethrow;
    }
  }

  Future<void> deleteIfExists(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Warning: Could not delete $path: $e');
    }
  }

  @override
  FutureEither<String> backupDatabaseToCloud(String registrationId) async {
    try {
      // Get the current database reference
      Database database = globalAppWidgetRef.read(posDbProvider).database;

      // Get the default database path for Android using sqflite
      final databasesPath =
          await getDatabasesPath(); // This will return the path
      var dbPath = path.join(
        databasesPath,
        "PosDb.db",
      ); // Join the database filename

      // Create a zip of the database using the common function
      final zipDataResponse = await createDatabaseFileAsZip();
      double fileSizeInMB = 0;

      // Handling the result of the zip file creation
      await zipDataResponse.fold<Future>(
        (l) async {
          return left(FailureModel("Failed to create database zip file."));
        },
        (r) async {
          // Calculate the size of the zip file
          String uploadPath = 'databases/$registrationId/backup.zip';
          final tempFile = await _saveZipToFile(r);
          int fileSizeInBytes = tempFile.lengthSync(); // Get file size in bytes
          fileSizeInMB = fileSizeInBytes / (1024 * 1024); // Convert to MB

          // If the file size is less than or equal to 2MB, upload directly
          if (fileSizeInMB <= 20) {
            await globalAppWidgetRef
                .read(supaBaseProvider)
                .storage
                .from('ultra_pos')
                .upload(
                  uploadPath,
                  tempFile, // Upload as a stream of bytes
                  fileOptions: const FileOptions(upsert: true),
                );
            tempFile.delete(); // Delete the temp file after upload
          } else {
            // Step 1: Get the source database from Riverpod
            Database sourceDb = database;

            // Step 2: Copy the destination database from assets and open it
            dbPath = await _copyDatabaseOnAndroidToTemp();

            Database destinationDb = await databaseFactoryFfi.openDatabase(
              dbPath,
            );

            // Step 6: Copy data from the source database to the temporary database
            await _copyDataFromSourceToTemp(destinationDb);
            // Step 7: Run VACUUM to reduce the size of the temporary database
            await destinationDb.execute('VACUUM');

            await destinationDb.close();
            final newZip = await createDatabaseFileAsZip(
              databaseName: "TempDb.db",
            );

            return newZip.fold((l) {}, (r) async {
              final tempFile = await _saveZipToFile(r);

              fileSizeInBytes = tempFile.lengthSync(); // Get file size in bytes
              fileSizeInMB = fileSizeInBytes / (1024 * 1024); // Convert to MB
              await globalAppWidgetRef
                  .read(supaBaseProvider)
                  .storage
                  .from('ultra_pos')
                  .upload(
                    uploadPath,
                    tempFile,
                    fileOptions: const FileOptions(upsert: true),
                  );
              tempFile.delete();
            });
          }
        },
      );

      return right("${fileSizeInMB.toStringAsFixed(2)} MB");
    } catch (e) {
      String url = SecureConfig.supabaseUrl.split("//").last;
      return left(
        FailureModel(
          "An error occurred during backup: ${e.toString().replaceAll(url, "******")}",
        ),
      );
    }
  }

  Future<String> _copyDatabaseOnAndroidToTemp() async {
    // Step 1: Get the path for the temporary database
    final databasesPath = await getDatabasesPath(); // This will return the path

    var tempDbPath = path.join(databasesPath, "TempDb.db");

    // Step 2: Load the empty database from assets
    ByteData data = await rootBundle.load("assets/db/posDb.db");
    List<int> bytes = data.buffer.asUint8List(
      data.offsetInBytes,
      data.lengthInBytes,
    );

    // Step 3: Write the empty database to the temporary location
    await File(tempDbPath).writeAsBytes(bytes);

    return tempDbPath;
  }

  @override
  FutureEitherVoid restoreDatabaseFromCloud(String registrationId) async {
    try {
      // Reset progress
      globalAppWidgetRef.read(restoreFromCloudProgressProvider.notifier).state =
          0.0;

      // Get Supabase client
      final supabase = globalAppWidgetRef.read(supaBaseProvider);

      // Use the correct database path - same as PosDbHelper
      final databasesPath = await getDatabasesPath();
      final dbPath = path.join(databasesPath, 'PosDb.db');
      final zipFilePath = path.join(databasesPath, 'backup.zip');

      // Construct download path
      String downloadPath = 'databases/$registrationId/backup.zip';

      // Get public URL from Supabase storage
      final publicPath = supabase.storage
          .from('ultra_pos')
          .getPublicUrl(downloadPath);

      debugPrint("Downloading from: $publicPath");

      // Close the global database connection first
      try {
        final globalDb = globalAppWidgetRef.read(posDbProvider);
        if (globalDb.database.isOpen) {
          await globalDb.database.close();
          debugPrint('Global database closed successfully');
        }
      } catch (e) {
        debugPrint('Error closing global database: $e');
      }

      // Delete existing database files (including WAL and SHM files)
      await deleteIfExists(dbPath);
      await deleteIfExists('$dbPath-wal');
      await deleteIfExists('$dbPath-shm');
      await deleteIfExists('$dbPath-journal');

      // Wait a bit to ensure files are released
      await Future.delayed(const Duration(milliseconds: 500));

      // Download the backup zip file using Dio with direct progress tracking
      final dio = Dio();
      await dio.download(
        publicPath,
        zipFilePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            // Direct progress tracking from 0% to 80% for download
            final downloadProgress = (received / total) * 80;
            globalAppWidgetRef
                    .read(restoreFromCloudProgressProvider.notifier)
                    .state =
                downloadProgress;
          }
        },
      );

      // Progress 80% - Download completed, starting extraction
      globalAppWidgetRef.read(restoreFromCloudProgressProvider.notifier).state =
          80.0;

      // Extract the zip file
      final bytes = await File(zipFilePath).readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      bool extracted = false;

      // Progress 85% - Starting database replacement
      globalAppWidgetRef.read(restoreFromCloudProgressProvider.notifier).state =
          85.0;

      for (var file in archive) {
        if (file.isFile && file.name == 'PosDb.db') {
          // Use safe replace method for better reliability
          await androidSafeReplace(
            dbPath: dbPath,
            newData: file.content as List<int>,
          );
          extracted = true;
          debugPrint('Database file extracted successfully to: $dbPath');
          break;
        }
      }

      if (!extracted) {
        throw Exception('PosDb.db not found in backup archive.');
      }

      // Progress 90% - Database replacement completed, starting verification
      globalAppWidgetRef.read(restoreFromCloudProgressProvider.notifier).state =
          90.0;

      // Verify the file was written correctly
      final restoredFile = File(dbPath);
      if (!await restoredFile.exists()) {
        throw Exception('Failed to write restored database file');
      }

      final fileSize = await restoredFile.length();
      debugPrint('Restored database file size: $fileSize bytes');

      // Progress 95% - Starting database validation
      globalAppWidgetRef.read(restoreFromCloudProgressProvider.notifier).state =
          95.0;

      // Cleanup zip file
      await deleteIfExists(zipFilePath);

      // Save restore date
      await globalAppWidgetRef
          .read(appPreferencesProvider)
          .saveData(key: "lastRestoreDate", value: DateTime.now().toString());

      // Progress 100% - Restoration completed
      globalAppWidgetRef.read(restoreFromCloudProgressProvider.notifier).state =
          100.0;
      debugPrint('Database restore completed successfully');
      return right(null);
    } catch (e) {
      debugPrint('Cloud restore failed: $e');
      // Reset progress on failure
      globalAppWidgetRef.read(restoreFromCloudProgressProvider.notifier).state =
          0.0;
      return left(FailureModel('Database restore from cloud failed: $e'));
    }
  }
}
