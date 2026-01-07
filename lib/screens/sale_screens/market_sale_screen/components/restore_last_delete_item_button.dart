import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
import 'package:desktoppossystem/shared/default%20components/app_squared_outlined_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RestoreLastDeletedItemButton extends ConsumerWidget {
  const RestoreLastDeletedItemButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saleController = ref.watch(saleControllerProvider);
    return AppSquaredOutlinedButton(
      isDisabled: saleController.lastDeletedItem == null,
      onPressed: () {
        if (saleController.lastDeletedItem != null) {
          ref.read(saleControllerProvider).restoreLastDeletedItem();
        }
      },
      child: const Icon(Icons.undo_outlined),
    );
  }
}
