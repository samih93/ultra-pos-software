import 'package:desktoppossystem/controller/setting_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/shared/default%20components/default_list_tile.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/default%20components/elevated_button_widget.dart';
import 'package:desktoppossystem/shared/default%20components/quiver_circular_indicator.dart';
import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/services/dependency_injection.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:desktoppossystem/shared/utils/toast_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final futureDailyBackupLimitProvider = FutureProvider<int>((ref) async {
  final backupDate = ref
      .read(appPreferencesProvider)
      .getData(key: "lastBackupToCloudDate");
  final backupCount = ref
      .read(appPreferencesProvider)
      .getInt(key: 'backupCount');
  debugPrint("lastBackupDate $backupDate");
  debugPrint("backupCount $backupCount");
  final lastBackupDate = DateTime.tryParse(backupDate.toString());
  if (lastBackupDate == null) {
    return 3;
  } else {
    if (lastBackupDate.isToday()) {
      // Same day, check count
      if (backupCount >= 3) {
        return 0;
      } else {
        return 3 - backupCount;
      }
    } else {
      ref.read(appPreferencesProvider).saveData(key: 'backupCount', value: 0);

      return 3;
    }
  }
});

class BackupToCloudButton extends ConsumerStatefulWidget {
  const BackupToCloudButton({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _BackupToCloudButtonState();
}

class _BackupToCloudButtonState extends ConsumerState<BackupToCloudButton> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> performBackup() async {
    final today = DateTime.now().toString().split(" ").first;
    final currentCount = globalAppWidgetRef
        .read(appPreferencesProvider)
        .getInt(key: 'backupCount');
    // Update backup count
    await globalAppWidgetRef
        .read(appPreferencesProvider)
        .saveData(
          key: 'backupCount',
          value: (currentCount + 1) > 3 ? 3 : (currentCount + 1),
        );
    await globalAppWidgetRef
        .read(appPreferencesProvider)
        .saveData(key: 'lastBackupToCloudDate', value: today);
    final remainingBackups = 3 - (currentCount + 1);
    globalAppWidgetRef.refresh(futureDailyBackupLimitProvider);
    await Future.delayed(const Duration(seconds: 2));
    ToastUtils.showToast(
      message: "Backup completed! Remaining today: $remainingBackups",
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    final futureBackupLimit = ref.watch(futureDailyBackupLimitProvider);
    return DefaultListTile(
      leading: const Icon(Icons.cloud_upload_outlined, color: Colors.grey),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (ref.watch(settingControllerProvider).backupDatabaseRequestState ==
              RequestState.loading)
            DefaultTextView(
              text: "${ref.watch(settingControllerProvider).backupMessage} ",
            ),
          futureBackupLimit.when(
            data: (data) => ElevatedButtonWidget(
              text: "Backup ($data)",
              isDisabled:
                  ref
                      .watch(settingControllerProvider)
                      .backupDatabaseRequestState ==
                  RequestState.loading,
              onPressed: data == 0
                  ? null
                  : () {
                      ref
                          .read(settingControllerProvider)
                          .backupDatabaseToCloud()
                          .whenComplete(() async {
                            if (globalAppWidgetRef
                                    .read(settingControllerProvider)
                                    .backupDatabaseRequestState ==
                                RequestState.success) {
                              await performBackup();
                            }
                          });
                    },
              states: [
                ref.watch(settingControllerProvider).backupDatabaseRequestState,
              ],
            ),
            error: (Object error, StackTrace stackTrace) {
              return kEmptyWidget;
            },
            loading: () {
              return const CoreCircularIndicator();
            },
          ),
        ],
      ),
      title: DefaultTextView(text: "${S.of(context).backupToCloud} "),
    );
  }
}
