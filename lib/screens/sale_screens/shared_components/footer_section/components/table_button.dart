import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
import 'package:desktoppossystem/screens/settings/components/sections/general_section/general_section.dart';
import 'package:desktoppossystem/screens/tables/tables_screen.dart';
import 'package:desktoppossystem/shared/default%20components/elevated_button_widget.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TableButton extends ConsumerWidget {
  const TableButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref.watch(showTablesProvider)
        ? ElevatedButtonWidget(
            text: S.of(context).tablesButton,
            icon: Icons.table_bar_outlined,
            onPressed: () {
              context.to(const TablesScreen());
              ref.watch(saleControllerProvider).fetchTables();
            },
          )
        : kEmptyWidget;
  }
}
