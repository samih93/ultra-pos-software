import 'package:desktoppossystem/controller/user_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/users/components/user_data_row.dart';
import 'package:desktoppossystem/screens/users/components/users_header.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserScreen extends ConsumerWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const UsersHeader(),
        Expanded(
          child: Consumer(
            builder: (context, ref, child) {
              return SizedBox(
                width: double.infinity,
                child: DataTable(
                  showCheckboxColumn: false,
                  columns: kTableColumns(context),
                  rows: <DataRow>[
                    ...ref
                        .watch(userControllerProvider)
                        .users
                        .where((element) => element.role!.name != "All")
                        .map((e) => UserDataRow(e, context, ref)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    ).baseContainer(context.cardColor);
  }

  ////// Columns in table.
  kTableColumns(BuildContext context) => <DataColumn>[
    DataColumn(
      label: Expanded(
        child: DefaultTextView(
          fontWeight: FontWeight.bold,
          text: S.of(context).userName,
        ),
      ),
    ),
    DataColumn(
      label: Expanded(
        child: DefaultTextView(
          fontWeight: FontWeight.bold,
          text: S.of(context).email,
        ),
      ),
    ),
    DataColumn(
      label: Expanded(
        child: DefaultTextView(
          fontWeight: FontWeight.bold,
          text: S.of(context).role,
        ),
      ),
    ),
    DataColumn(
      label: Expanded(
        child: Center(
          child: DefaultTextView(
            fontWeight: FontWeight.bold,
            text: S.of(context).actions,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    ),
  ];
}
