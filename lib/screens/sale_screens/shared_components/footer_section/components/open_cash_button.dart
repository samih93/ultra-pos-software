import 'package:desktoppossystem/controller/printer_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/shared/default%20components/elevated_button_widget.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OpenCashButton extends ConsumerWidget {
  const OpenCashButton({this.height, super.key});
  final double? height;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(printerControllerProvider).showOpenCashButton
        ? ElevatedButtonWidget(
            height: height,
            width: 80,
            text: S.of(context).openCashButton,
            onPressed: () {
              ref.read(printerControllerProvider).openCashDrawer(context);
            },
          )
        : kEmptyWidget;
  }
}
