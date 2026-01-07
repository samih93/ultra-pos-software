import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SetNbOfTableDialog extends ConsumerWidget {
  SetNbOfTableDialog({super.key});
  final List<int> nbOfTablesList = [5, 10, 15, 20, 25, 30, 35, 40, 50, 60, 100];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: DefaultTextView(
        textAlign: TextAlign.center,
        fontSize: 16,
        text: "${S.of(context).nbOfTables} ",
      ),
      content: SizedBox(
        height: 300,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              kGap5,
              ...nbOfTablesList.map((e) {
                return ListTile(
                  trailing:
                      ref.watch(saleControllerProvider).nbOfTables ==
                          nbOfTablesList[nbOfTablesList.indexOf(e)]
                      ? Icon(Icons.check_circle, color: context.primaryColor)
                      : kEmptyWidget,
                  title: DefaultTextView(text: e.toString()),
                  onTap: () async {
                    ref
                        .read(saleControllerProvider)
                        .setNbOfTables(
                          nbOfTablesList[nbOfTablesList.indexOf(e)],
                          context,
                        );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
