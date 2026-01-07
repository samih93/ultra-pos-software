import 'package:desktoppossystem/controller/auth_controller.dart';
import 'package:desktoppossystem/controller/receipt_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/models/user_model.dart';
import 'package:desktoppossystem/screens/daily%20sales/components/receipt_details_dialog.dart';
import 'package:desktoppossystem/shared/constances/app_constances.dart';
import 'package:desktoppossystem/shared/constances/auth_role.dart';
import 'package:desktoppossystem/shared/default%20components/elevated_button_widget.dart';
import 'package:desktoppossystem/shared/default%20components/quiver_circular_indicator.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LastInvoiceButton extends ConsumerWidget {
  const LastInvoiceButton({this.height, super.key});
  final double? height;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    UserModel usermodel =
        ref.watch(currentUserProvider) ?? UserModel.fakeUser();
    var lastInvoiceFuture = ref.watch(lastInvoiceProvider);

    return usermodel.role?.name != AuthRole.waiterRole
        ? lastInvoiceFuture.when(
            data: (data) {
              return Row(
                children: [
                  if (data != null) ...[
                    ElevatedButtonWidget(
                      height: height,
                      onPressed: () async {
                        if (data.id != null) {
                          showDialog(
                            context: context,
                            builder: (context) =>
                                ReceiptDetailsDialog(receiptModel: data),
                          );
                        }
                      },
                      text:
                          "${S.of(context).lastReceipt} ${data.foreignReceiptPrice != null ? data.foreignReceiptPrice!.formatDouble() : 0} ${AppConstance.primaryCurrency.currencyLocalization()} ",
                    ),
                  ],
                ],
              );
            },
            error: (error, stackTrace) => kEmptyWidget,
            loading: () =>
                const SizedBox(width: 60, child: CoreCircularIndicator()),
          )
        : kEmptyWidget;
  }
}
