import 'dart:io';

import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/shared/default%20components/default_list_tile.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/default%20components/quiver_circular_indicator.dart';
import 'package:desktoppossystem/shared/services/dependency_injection.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:desktoppossystem/shared/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:terminate_restart/terminate_restart.dart';

// Cloud restore state providers
final isRestoringFromCloudProvider = StateProvider<bool>((ref) => false);
final restoreFromCloudProgressProvider = StateProvider<double>((ref) => 0.0);

// Last sync time provider
final lastSyncTimeProvider = FutureProvider<String>((ref) async {
  final String? lastSyncTime = await ref
      .read(appPreferencesProvider)
      .getData(key: "lastRestoreTime");
  return lastSyncTime ?? "Never";
});

// Check if backup is available and newer than last restore
final isBackupAvailableProvider =
    FutureProvider<({bool isAvailable, DateTime? backupDate})>((ref) async {
      try {
        final registrationId = await ref
            .read(securePreferencesProvider)
            .getData(key: 'registrationUserId');

        if (registrationId == null) {
          return (isAvailable: false, backupDate: null);
        }

        final lastRestoreTime = await ref
            .read(appPreferencesProvider)
            .getData(key: "lastRestoreTime");

        // Get backup files from cloud
        final objects = await ref
            .read(supaBaseProvider)
            .storage
            .from('ultra_pos')
            .list(path: "databases/$registrationId");

        if (objects.isEmpty) return (isAvailable: false, backupDate: null);

        // Find the backup.zip file
        final backupFile = objects.firstWhere(
          (file) => file.name == "backup.zip",
          orElse: () => objects.first,
        );

        if (backupFile.name == ".emptyFolderPlaceholder")
          return (isAvailable: false, backupDate: null);

        // Parse backup date
        DateTime? backupDate = DateTime.tryParse(
          backupFile.updatedAt.toString(),
        )?.toLocal();

        // If never restored before, backup is available
        if (lastRestoreTime == null || lastRestoreTime == "Never") {
          return (isAvailable: true, backupDate: backupDate);
        }

        // Compare dates
        DateTime? lastRestoreDate = DateTime.tryParse(
          lastRestoreTime.toString(),
        );

        if (lastRestoreDate == null || backupDate == null) {
          return (isAvailable: false, backupDate: backupDate);
        }

        return (
          isAvailable: backupDate.isAfter(lastRestoreDate),
          backupDate: backupDate,
        );
      } catch (e) {
        debugPrint("Error checking backup availability: $e");
        return (isAvailable: false, backupDate: null);
      }
    });

class RestoreFromCloudSection extends ConsumerWidget {
  const RestoreFromCloudSection({super.key});

  Future<void> _performRestore(
    BuildContext context,
    WidgetRef ref,
    String registrationId,
  ) async {
    try {
      ref.read(isRestoringFromCloudProvider.notifier).state = true;

      // Use the DatabaseBackupRestoreService
      final result = await ref
          .read(databaseBackupRestoreServiceProvider)
          .restoreDatabaseFromCloud(registrationId);

      ref.read(isRestoringFromCloudProvider.notifier).state = false;

      await result.fold(
        (failure) async {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Restore failed: ${failure.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        (success) async {
          // Save last restore time
          debugPrint("Restore success in cloud section");
          await ref
              .read(appPreferencesProvider)
              .saveData(
                key: "lastRestoreTime",
                value: DateTime.now().toIso8601String(),
              );

          // Refresh backup availability
          ref.invalidate(isBackupAvailableProvider);

          ToastUtils.showToast(
            type: RequestState.success,
            message: 'Restore completed successfully! Restarting app...',
          );

          await _restartApp();
        },
      );
    } catch (e) {
      ref.read(isRestoringFromCloudProvider.notifier).state = false;

      ToastUtils.showToast(
        message: "Restore failed $e",
        type: RequestState.error,
      );
    }
  }

  Future<void> _restartApp() async {
    // Restart the app on Android platforms
    if (!Platform.isWindows) {
      try {
        await Future.delayed(const Duration(seconds: 1));
        await TerminateRestart.instance.restartApp(
          options: const TerminateRestartOptions(terminate: true),
        );
      } catch (e) {
        ToastUtils.showToast(
          type: RequestState.success,
          message: 'Restore completed successfully! Restarting app...',
        );
      }
    } else {
      await _restartWindowsApp();
    }
  }

  Future<void> _restartWindowsApp() async {
    await Future.delayed(const Duration(seconds: 2));

    // Launch external restart script (handles single-instance restriction)
    final installDir = Directory.current.path;
    final exePath = Platform.resolvedExecutable;
    final batchLauncher = path.join(installDir, 'launch_restart.bat');
    final restartScript = path.join(installDir, 'restart_app.ps1');

    if (File(batchLauncher).existsSync() && File(restartScript).existsSync()) {
      try {
        // Launch restart script in detached mode
        await Process.start(
          batchLauncher,
          [restartScript, exePath, installDir],
          mode: ProcessStartMode.detached,
          runInShell: false,
          workingDirectory: installDir,
        );

        debugPrint('Restart script launched, exiting app...');
      } catch (e) {
        debugPrint('Failed to launch restart script: $e');
      }
    } else {
      debugPrint('Restart scripts not found - app will exit without restart');
    }

    // Exit current instance (restart script will wait and then relaunch)
    exit(0);
  }

  void _showRestoreDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Center(
          child: DefaultTextView(
            text: S.of(context).restoreFromCloud,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange,
              size: 60,
            ),
            const SizedBox(height: 16),
            DefaultTextView(
              textAlign: TextAlign.center,
              text: S.of(context).restoreFromCloudExplanation,
              maxlines: 3,
            ),
            const SizedBox(height: 16),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(S.of(context).cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              String? registrationId = await ref
                  .read(securePreferencesProvider)
                  .getData(key: 'registrationUserId');
              debugPrint("registration id $registrationId");

              if (registrationId == null) {
                ToastUtils.showToast(
                  type: RequestState.error,
                  message:
                      "Registration ID not found. Cannot restore from cloud.",
                );
                return;
              }

              await _performRestore(context, ref, registrationId);
            },
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRestoring = ref.watch(isRestoringFromCloudProvider);
    final isOwner = ref.watch(mainControllerProvider).isOwner;
    final lastSyncTime = ref.watch(lastSyncTimeProvider);
    final isBackupAvailable = ref.watch(isBackupAvailableProvider);

    if ((isOwner) || (!Platform.isWindows)) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DefaultListTile(
            leading: InkWell(
              onTap: isRestoring
                  ? null
                  : () {
                      ref.invalidate(isBackupAvailableProvider);
                      ref.invalidate(lastSyncTimeProvider);
                    },
              child: Icon(
                Icons.refresh,
                color: isRestoring ? Colors.grey : Pallete.primaryColor,
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: DefaultTextView(
                    text: S.of(context).restoreFromCloud,
                    color: Pallete.redColor,
                  ),
                ),
                isBackupAvailable.when(
                  data: (backup) {
                    if (backup.backupDate != null) {
                      String formattedDate = backup.backupDate!
                          .formatDateTime12Hours();
                      return DefaultTextView(
                        text: '${S.of(context).backupDate}: $formattedDate',
                        color: Pallete.coreMistColor,
                        fontSize: 11,
                      );
                    } else {
                      return kEmptyWidget;
                    }
                  },
                  error: (error, stackTrace) => kEmptyWidget,
                  loading: () => kEmptyWidget,
                ),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isRestoring)
                  DefaultTextView(
                    text: S.of(context).restoringDatabaseFromCloud,
                    color: Colors.blue,
                    fontSize: 12,
                  )
                else
                  DefaultTextView(
                    color: Pallete.redColor,
                    text: S.of(context).downloadAndRestore,
                    maxlines: 2,
                    fontSize: 12,
                  ),
                const SizedBox(height: 4),
                lastSyncTime.when(
                  data: (time) {
                    String? formattedTime = time != "Never"
                        ? DateTime.tryParse(time)?.formatDateTime12Hours()
                        : "Never";
                    return DefaultTextView(
                      text:
                          "${S.of(context).lastRestore}: ${formattedTime ?? S.of(context).never}",
                      color: Pallete.coreMistColor,
                      fontSize: 11,
                    );
                  },
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
            trailing: isBackupAvailable.when(
              data: (backup) {
                if (isRestoring) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CoreCircularIndicator(),
                      ),
                      const SizedBox(height: 4),
                      Consumer(
                        builder: (context, ref, child) {
                          final progress = ref.watch(
                            restoreFromCloudProgressProvider,
                          );
                          return DefaultTextView(
                            text: '${progress.toStringAsFixed(1)}%',
                            fontSize: 10,
                            color: Colors.grey,
                          );
                        },
                      ),
                    ],
                  );
                }

                return backup.isAvailable
                    ? const Icon(
                        Icons.cloud_download_outlined,
                        color: Pallete.redColor,
                      )
                    : const DefaultTextView(
                        text: "No backup",
                        color: Colors.grey,
                        fontSize: 11,
                      );
              },
              loading: () => const SizedBox(
                width: 20,
                height: 20,
                child: CoreCircularIndicator(),
              ),
              error: (_, __) =>
                  const Icon(Icons.error_outline, color: Colors.grey, size: 20),
            ),
            onTap: isRestoring
                ? null
                : () {
                    isBackupAvailable.when(
                      data: (backup) {
                        if (backup.isAvailable) {
                          _showRestoreDialog(context, ref);
                        } else {
                          ToastUtils.showToast(
                            type: RequestState.error,
                            message: "No backup available to restore",
                          );
                        }
                      },
                      loading: () {},
                      error: (_, __) {},
                    );
                  },
          ),
        ],
      );
    } else {
      return kEmptyWidget;
    }
  }
}
