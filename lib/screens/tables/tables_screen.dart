import 'package:desktoppossystem/controller/auth_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/table_model.dart';
import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
import 'package:desktoppossystem/screens/tables/components/table_item.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/default%20components/quiver_circular_indicator.dart';
import 'package:desktoppossystem/shared/styles/my_linears_gradient.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TablesScreen extends ConsumerWidget {
  const TablesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int currentUserId = ref.read(currentUserProvider)?.id ?? 0;
    var saleController = ref.watch(saleControllerProvider);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(saleControllerProvider).clearTables();
            context.pop();
          },
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: myLinearGradient(context)),
        ),
        title: DefaultTextView(
          text: S.of(context).tablesButton,
          color: Colors.white,
        ),
      ),
      body: saleController.fetchTableRequestState == RequestState.loading
          ? const Center(child: CoreCircularIndicator())
          : Padding(
              padding: kPadd10,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: tablesStatusWidget(
                          context,
                          list: saleController.tables
                              .where(
                                (element) => element.openedBy == currentUserId,
                              )
                              .toList(),
                          status: S.of(context).mine,
                        ),
                      ),
                      Expanded(
                        child: tablesStatusWidget(
                          context,
                          list: saleController.tables
                              .where(
                                (element) =>
                                    element.openedBy != currentUserId &&
                                    element.isOpened == true,
                              )
                              .toList(),
                          status: S.of(context).otherUsers,
                        ),
                      ),
                      Expanded(
                        child: tablesStatusWidget(
                          context,
                          list: saleController.tables
                              .where((element) => element.isOpened == false)
                              .toList(),
                          status: S.of(context).closed,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Center(
                        child: Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            ...saleController.tables.map((e) => TableItem(e)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  tablesStatusWidget(
    BuildContext context, {
    required List<TableModel> list,
    required String status,
  }) {
    Color color = status == S.of(context).mine
        ? context.primaryColor
        : status == S.of(context).otherUsers
        ? Colors.red
        : Colors.grey.shade800;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        CircleAvatar(
          backgroundColor: color,
          radius: 20,
          child: DefaultTextView(text: "${list.length}", color: Colors.white),
        ),
        DefaultTextView(color: color, fontSize: 20, text: status),
      ],
    );
  }
}
