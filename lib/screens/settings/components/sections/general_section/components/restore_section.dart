import 'package:desktoppossystem/controller/setting_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/shared/default%20components/default_list_tile.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RestoreSection extends ConsumerWidget {
  const RestoreSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSuperAdmin = ref.watch(mainControllerProvider).isSuperAdmin;
    final state = ref.watch(settingControllerProvider).localBackupRequestState;
    return isSuperAdmin
        ? DefaultListTile(
            onTap: () async {
              await ref
                  .read(settingControllerProvider.notifier)
                  .restoreDatabase();
            },
            leading: const Icon(Icons.restart_alt_rounded, color: Colors.grey),
            trailing: const Icon(
              Icons.arrow_forward_ios_outlined,
              color: Colors.grey,
            ),
            subtitle: DefaultTextView(
              maxlines: 2,
              text: S.of(context).restoreSubtitle,
              color: Colors.grey,
              fontSize: 12,
            ),
            title: DefaultTextView(text: "${S.of(context).restore} "),
          )
        : kEmptyWidget;
  }
}
