import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
import 'package:desktoppossystem/shared/default%20components/elevated_button_widget.dart';
import 'package:desktoppossystem/shared/default%20components/quiver_circular_indicator.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CloseTableButton extends ConsumerWidget {
  const CloseTableButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final saleController = ref.watch(saleControllerProvider);
    return saleController.selectedTable != null &&
            (ref.watch(mainControllerProvider).isAdmin ||
                saleController.basketItems.isEmpty)
        ? Row(
            children: [
              kGap5,
              ElevatedButtonWidget(
                text: S.of(context).close,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) {
                      bool isloadingCloseTable = false;

                      return StatefulBuilder(
                        builder: (context, setState) {
                          return AlertDialog(
                            title: const Text(
                              'Are you sure you want to close this table?',
                            ),
                            actions: [
                              TextButton(
                                child: const Text('No'),
                                onPressed: () {
                                  context.pop();
                                },
                              ),
                              isloadingCloseTable
                                  ? const SizedBox(
                                      width: 60,
                                      child: CoreCircularIndicator(),
                                    )
                                  : TextButton(
                                      child: Text(
                                        '${S.of(context).yes.capitalizeFirstLetter()}',
                                      ),
                                      onPressed: () async {
                                        setState(() {
                                          isloadingCloseTable = true;
                                        });

                                        ref
                                            .read(saleControllerProvider)
                                            .closeTable(
                                              saleController.selectedTable!,
                                            );

                                        setState(() {
                                          isloadingCloseTable = false;
                                        });
                                        context.pop();
                                      },
                                    ),
                            ],
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ],
          )
        : kEmptyWidget;
  }
}
