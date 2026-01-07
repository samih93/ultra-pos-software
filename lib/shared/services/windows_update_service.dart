import 'dart:io';
import 'package:desktoppossystem/models/app_version_model.dart';
import 'package:desktoppossystem/repositories/update/update_repository.dart';
import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/services/dependency_injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;

final updateProgressProvider = StateProvider<String>((ref) => '');
final isUpdatingProvider = StateProvider<bool>((ref) => false);
final isCheckingUpdatesProvider = StateProvider<bool>((ref) => false);
final availableUpdateProvider = StateProvider<AppVersionModel?>((ref) => null);

final windowsUpdateProvider = Provider((ref) {
  return WindowsUpdateService(ref);
});

class WindowsUpdateService {
  final Ref ref;
  WindowsUpdateService(this.ref);

  // Check for updates only (no automatic download)
  Future<AppVersionModel?> checkForUpdates() async {
    try {
      ref.read(isCheckingUpdatesProvider.notifier).state = true;
      ref.read(updateProgressProvider.notifier).state =
          'Checking for updates...';

      final updateRepo = ref.read(updateRepositoryProvider);
      final latestResult = await updateRepo.getLatestVersion();

      return await latestResult.fold(
        (failure) {
          debugPrint('Failed to check for updates: ${failure.message}');
          ref.read(updateProgressProvider.notifier).state = 'Check failed';
          ref.read(isCheckingUpdatesProvider.notifier).state = false;
          ref.read(availableUpdateProvider.notifier).state = null;
          return null;
        },
        (latestVersion) async {
          if (latestVersion == null) {
            ref.read(updateProgressProvider.notifier).state =
                'No updates available';
            ref.read(availableUpdateProvider.notifier).state = null;
          } else if (_isVersionNewer(appVersion, latestVersion.version)) {
            ref.read(updateProgressProvider.notifier).state =
                'Update available: v${latestVersion.version}';
            ref.read(availableUpdateProvider.notifier).state = latestVersion;
          } else {
            ref.read(updateProgressProvider.notifier).state =
                'App is up to date';
            ref.read(availableUpdateProvider.notifier).state = null;
          }

          ref.read(isCheckingUpdatesProvider.notifier).state = false;
          return ref.read(availableUpdateProvider);
        },
      );
    } catch (e) {
      debugPrint('Update check failed: $e');
      ref.read(updateProgressProvider.notifier).state = 'Check failed: $e';
      ref.read(isCheckingUpdatesProvider.notifier).state = false;
      ref.read(availableUpdateProvider.notifier).state = null;
      return null;
    }
  }

  // Download and install update (manual trigger)
  Future<bool> downloadAndInstallUpdate() async {
    final availableUpdate = ref.read(availableUpdateProvider);
    if (availableUpdate == null) {
      ref.read(updateProgressProvider.notifier).state = 'No update available';
      return false;
    }

    try {
      ref.read(isUpdatingProvider.notifier).state = true;
      await _downloadAndInstall(availableUpdate);
      return true;
    } catch (e) {
      debugPrint('Update failed: $e');
      ref.read(updateProgressProvider.notifier).state = 'Update failed: $e';
      ref.read(isUpdatingProvider.notifier).state = false;
      return false;
    }
  }

  // Legacy method for backward compatibility
  Future<bool> checkAndDownloadUpdate() async {
    final update = await checkForUpdates();
    if (update != null) {
      return await downloadAndInstallUpdate();
    }
    return false;
  }

  Future<void> _downloadAndInstall(AppVersionModel version) async {
    final updateRepo = ref.read(updateRepositoryProvider);

    try {
      ref.read(updateProgressProvider.notifier).state = 'Starting download...';

      // Get current user ID
      final userId =
          await ref
              .read(securePreferencesProvider)
              .getData(key: "registrationUserId") ??
          "unknown";

      // Download
      final tmpDir = Directory.systemTemp.createTempSync('app_update_');
      final zipFile = File(p.join(tmpDir.path, 'update.zip'));
      int received = 0;
      final totalSize = version.fileSize ?? 0;

      await ref
          .read(quiverDioProvider)
          .dio
          .download(
            version.downloadUrl,
            zipFile.path,
            onReceiveProgress: (count, total) {
              received = count;
              final receivedMB = (received / 1024 / 1024).toStringAsFixed(1);
              final totalMB = (totalSize / 1024 / 1024).toStringAsFixed(1);
              ref.read(updateProgressProvider.notifier).state =
                  'Downloading: ${receivedMB}MB / ${totalMB}MB';
            },
          );

      ref.read(updateProgressProvider.notifier).state =
          'Download complete. Installing...';

      // Track successful download
      await updateRepo.trackUserUpdate(
        userId: userId,
        versionId: version.id,
        deviceInfo: Platform.operatingSystem,
        success: true,
      );

      // Launch PowerShell updater
      final installDir = Directory.current.path;
      const exeName = 'Core_manager.exe'; // Your app exe name
      final updaterPath = p.join(installDir, 'updater.ps1');

      if (!File(updaterPath).existsSync()) {
        throw Exception('Updater not found at: $updaterPath');
      }

      // Copy ZIP to install directory to avoid temp path issues
      ref.read(updateProgressProvider.notifier).state =
          'Preparing update files...';
      final localZipPath = p.join(installDir, 'update_temp.zip');
      final localZipFile = File(localZipPath);

      // Copy the downloaded ZIP to a reliable location
      await zipFile.copy(localZipPath);

      // Verify the copied file exists and has the right size
      if (!localZipFile.existsSync()) {
        throw Exception('Failed to copy update file to install directory');
      }

      final originalSize = zipFile.lengthSync();
      final copiedSize = localZipFile.lengthSync();
      if (originalSize != copiedSize) {
        throw Exception('Update file copy verification failed: size mismatch');
      }

      ref.read(updateProgressProvider.notifier).state = 'Launching updater...';

      // Debug: Log the exact command being executed
      final psArgs = [
        '-ExecutionPolicy',
        'Bypass',
        '-File',
        updaterPath,
        '-ZipPath',
        localZipPath,
        '-TargetDir',
        installDir,
        '-ExeName',
        exeName,
      ];

      debugPrint('PowerShell command: powershell.exe ${psArgs.join(' ')}');
      debugPrint('Updater path exists: ${File(updaterPath).existsSync()}');
      debugPrint('Zip file exists: ${zipFile.existsSync()}');

      try {
        // Test PowerShell availability first
        final testResult = await Process.run('powershell.exe', [
          '-Command',
          'Get-ExecutionPolicy',
        ]);
        debugPrint('PowerShell execution policy: ${testResult.stdout}');

        if (testResult.exitCode != 0) {
          throw Exception(
            'PowerShell not available or blocked. Error: ${testResult.stderr}',
          );
        }

        // Launch PowerShell updater using batch file for true process independence
        final batchLauncher = p.join(installDir, 'launch_updater.bat');

        if (!File(batchLauncher).existsSync()) {
          throw Exception('Batch launcher not found at: $batchLauncher');
        }

        final batchArgs = [updaterPath, localZipPath, installDir, exeName];

        debugPrint(
          'Launching updater via BATCH: $batchLauncher ${batchArgs.join(' ')}',
        );

        final process = await Process.start(
          batchLauncher,
          batchArgs,
          mode: ProcessStartMode.detached,
          runInShell: false,
          workingDirectory: installDir,
        );

        debugPrint(
          'Batch launcher started with PID: ${process.pid}',
        ); // Give the process a moment to start and potentially fail
        await Future.delayed(const Duration(milliseconds: 500));

        // Try to check if process is still running (basic validation)
        try {
          process.kill(ProcessSignal.sigusr1); // Non-destructive signal check
          debugPrint('PowerShell process appears to be running');
        } catch (e) {
          debugPrint('PowerShell process may have exited early: $e');
        }

        // Create a debug file to help troubleshoot
        final debugFile = File(p.join(installDir, 'update_debug.txt'));
        await debugFile.writeAsString('''
Update Debug Info - ${DateTime.now()}
=================================
App Version: $appVersion
Target Version: ${version.version}
Updater Path: $updaterPath
Original Zip Path: ${zipFile.path}
Local Zip Path: $localZipPath
Install Dir: $installDir
Exe Name: $exeName
PowerShell Args: ${psArgs.join(' ')}
Process PID: ${process.pid}
PowerShell Policy: ${testResult.stdout}

Files Check:
- Updater exists: ${File(updaterPath).existsSync()}
- Original zip exists: ${zipFile.existsSync()}
- Local zip exists: ${localZipFile.existsSync()}
- Original zip size: ${zipFile.lengthSync()} bytes
- Local zip size: ${localZipFile.lengthSync()} bytes
''');

        debugPrint('Debug file created at: ${debugFile.path}');

        // Give PowerShell script more time to fully start and read parameters
        // before we exit the Flutter app
        debugPrint('Waiting for PowerShell to initialize...');
        await Future.delayed(const Duration(seconds: 2));

        // Verify PowerShell log file was created (indicates script started successfully)
        await Future.delayed(const Duration(milliseconds: 500));
        final logFiles = Directory(
          installDir,
        ).listSync().where((f) => f.path.contains('update_log')).toList();

        if (logFiles.isNotEmpty) {
          debugPrint(
            'PowerShell log file detected - update process started successfully',
          );
        } else {
          debugPrint(
            'WARNING: No PowerShell log file detected yet - update may fail',
          );
        }
      } catch (e) {
        debugPrint('Failed to launch PowerShell updater: $e');
        ref.read(updateProgressProvider.notifier).state =
            'Failed to launch updater: $e';
        throw Exception('Failed to launch updater: $e');
      }

      // Exit current app to allow updater to replace files
      debugPrint('Exiting Flutter app to allow update process...');
      exit(0);
    } catch (e) {
      // Track failed download
      final userId =
          await ref
              .read(securePreferencesProvider)
              .getData(key: "registrationUserId") ??
          "unknown";
      await updateRepo.trackUserUpdate(
        userId: userId,
        versionId: version.id,
        deviceInfo: Platform.operatingSystem,
        success: false,
      );

      ref.read(updateProgressProvider.notifier).state = 'Update failed: $e';
      ref.read(isUpdatingProvider.notifier).state = false;
      rethrow;
    }
  }

  bool _isVersionNewer(String current, String server) {
    // Remove 'V' prefix if present
    current = current.replaceFirst('V', '');
    server = server.replaceFirst('V', '');

    List<int> c = current.split('.').map(int.parse).toList();
    List<int> s = server.split('.').map(int.parse).toList();

    int maxLength = c.length > s.length ? c.length : s.length;

    for (int i = 0; i < maxLength; i++) {
      final currentPart = i < c.length ? c[i] : 0;
      final serverPart = i < s.length ? s[i] : 0;

      if (serverPart > currentPart) return true;
      if (serverPart < currentPart) return false;
    }
    return false;
  }
}
