import 'package:desktoppossystem/screens/sale_screens/caffe_sale_screens/components/table_section/components/nb_of_customers_section.dart';
import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TableSection extends ConsumerWidget {
  const TableSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool isTableSelected =
        ref.watch(saleControllerProvider).selectedTable != null;
    return isTableSelected
        ? Column(
            children: [
              Row(
                children: [
                  const DefaultTextView(
                    text: "Table :  ",
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                  DefaultTextView(
                    text:
                        "(${ref.read(saleControllerProvider).selectedTable!.tableName})",
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: context.primaryColor,
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      ref.read(saleControllerProvider).unselectTable();
                    },
                    icon: const Icon(Icons.remove, color: Colors.red),
                  ),
                ],
              ),
              const NbOfCustomersSection(),
            ],
          )
        : kEmptyWidget;
  }
}
