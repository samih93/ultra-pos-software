import 'package:desktoppossystem/controller/receipt_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/daily%20sales/daily_financial_screen.dart';
import 'package:desktoppossystem/shared/default%20components/app_squared_outlined_button.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SalesSelectDateSection extends ConsumerWidget {
  const SalesSelectDateSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentDate = ref.watch(salesSelectedDateProvider);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      spacing: 10,
      children: [
        AppSquaredOutlinedButton(
          child: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () {
            final newDate = currentDate.subtract(const Duration(days: 1));
            focusAndFetchReceiptsByDate(ref, newDate);
          },
        ),
        InkWell(
          onTap: () {
            showDatePicker(
              context: context,
              currentDate: DateTime.now(),
              initialDate: ref.watch(salesSelectedDateProvider),
              firstDate: DateTime.now().subtract(const Duration(days: 365 * 3)),
              lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
            ).then((value) {
              if (value != null) {
                focusAndFetchReceiptsByDate(ref, value);
              }
            });
          },
          child: Container(
            padding: defaultPadding,
            decoration: BoxDecoration(
              color: Pallete.whiteColor,
              borderRadius: defaultRadius,
              border: Border.all(color: Pallete.greyColor),
            ),
            child: DefaultTextView(
              textAlign: TextAlign.center,
              text:
                  "${currentDate.isToday() ? S.of(context).today : "${currentDate.toNormalDate()}"} ",
              color: context.primaryColor,
              fontSize: 18,
            ),
          ),
        ),
        AppSquaredOutlinedButton(
          isDisabled: currentDate.isToday(),
          child: const Icon(Icons.arrow_forward_ios_rounded),
          onPressed: () {
            final newDate = currentDate.add(const Duration(days: 1));
            focusAndFetchReceiptsByDate(ref, newDate);
          },
        ),
        if (!currentDate.isToday())
          AppSquaredOutlinedButton(
            size: const Size(60, 38),
            child: DefaultTextView(
              text: S.of(context).today,
              color: Pallete.blackColor,
            ),
            onPressed: () {
              focusAndFetchReceiptsByDate(ref, DateTime.now());
            },
          ),
      ],
    );
  }

  void focusAndFetchReceiptsByDate(WidgetRef ref, DateTime value) {
    ref.read(salesSelectedDateProvider.notifier).state = value;
    ref.read(salesSelectedUser.notifier).state = ref
        .read(receiptControllerProvider)
        .users
        .where((element) => element.role!.name == "All")
        .first;

    ref
        .read(receiptControllerProvider)
        .fetchPaginatedReceiptsByDay(resetPagination: true);
    ref.read(selectedFinancialFilterIndex.notifier).state = 0;
  }
}
