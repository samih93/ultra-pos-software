import 'dart:io';

import 'package:desktoppossystem/controller/auth_controller.dart';
import 'package:desktoppossystem/controller/printer_controller.dart';
import 'package:desktoppossystem/controller/receipt_controller.dart';
import 'package:desktoppossystem/models/receipt_model.dart';
import 'package:desktoppossystem/screens/add_edit_product/add_edit_product_screen.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_screen.dart';
import 'package:desktoppossystem/screens/sale_screens/caffe_sale_screens/components/change_quatity_widget.dart';
import 'package:desktoppossystem/screens/sale_screens/market_sale_screen/components/last_scanned_item.dart';
import 'package:desktoppossystem/screens/sale_screens/market_sale_screen/components/market_basket_list.dart';
import 'package:desktoppossystem/screens/sale_screens/market_sale_screen/components/market_sale_mobile.dart';
import 'package:desktoppossystem/screens/sale_screens/market_sale_screen/components/mobile_scanner_section.dart';
import 'package:desktoppossystem/screens/sale_screens/market_sale_screen/components/quick_selection_product_section.dart';
import 'package:desktoppossystem/screens/sale_screens/market_sale_screen/components/restore_last_delete_item_button.dart';
import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
import 'package:desktoppossystem/screens/sale_screens/shared_components/customer_section.dart';
import 'package:desktoppossystem/screens/sale_screens/shared_components/discount_section.dart';
import 'package:desktoppossystem/screens/sale_screens/shared_components/footer_section/components/change_amount_dialog.dart';
import 'package:desktoppossystem/screens/sale_screens/shared_components/footer_section/components/last_invoice_button.dart';
import 'package:desktoppossystem/screens/sale_screens/shared_components/footer_section/components/open_cash_button.dart';
import 'package:desktoppossystem/screens/sale_screens/shared_components/footer_section/components/pay_button.dart';
import 'package:desktoppossystem/screens/sale_screens/shared_components/footer_section/components/pay_delivery_button.dart';
import 'package:desktoppossystem/screens/sale_screens/shared_components/footer_section/components/quotation_button.dart';
import 'package:desktoppossystem/screens/sale_screens/shared_components/footer_section/components/staff_market_button.dart';
import 'package:desktoppossystem/screens/sale_screens/shared_components/hold_invoices_section.dart';
import 'package:desktoppossystem/screens/sale_screens/shared_components/order_type_section.dart';
import 'package:desktoppossystem/screens/sale_screens/shared_components/total_amount_section.dart';
import 'package:desktoppossystem/shared/default%20components/app_squared_outlined_button.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:desktoppossystem/shared/utils/responsive_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MarketSaleScreen extends ConsumerWidget {
  const MarketSaleScreen({super.key});

  Future<void> _handleKeyEvent(
    KeyEvent event,
    WidgetRef ref,
    BuildContext context,
  ) async {
    final keyLabel = event.logicalKey.keyLabel;
    final character = event.character;

    if (ref.read(isChangeDialogOpenProvider) == true) {
      return;
    }

    final saleController = ref.read(saleControllerProvider);

    if (event is KeyDownEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.f11:
          ref.read(printerControllerProvider).openCashDrawer(context);
          return;

        case LogicalKeyboardKey.f12:
          ReceiptModel receiptModel = ReceiptModel(
            nbOfCustomers: saleController.nbOfCustomers,
            orderType: ref.read(selectedOrderTypeProvider),
            foreignReceiptPrice: saleController.foreignTotalPrice,
            localReceiptPrice: saleController.localTotalPrice,
            receiptDate: DateTime.now().toString(),
            userId: ref.read(currentUserProvider)?.id,
            dollarRate: saleController.dolarRate,
            paymentType: PaymentType.cash,
            shiftId: ref.read(currentShiftProvider).id!,
            customerId: saleController.customerModel?.id,
            isHasDiscount: saleController.basketItems.any(
              (e) => e.discount! > 0,
            ),
          );
          receiptModel.customerModel = saleController.customerModel;
          if (ref.read(printerControllerProvider).openCashDialogOnPay) {
            ref.read(saleControllerProvider).onChangeEnteringAmountType(true);
            ref.read(isChangeDialogOpenProvider.notifier).state = true;
            ref.read(printerControllerProvider).openCashDrawer(context);

            showDialog(
              context: context,
              builder: (context) => const ChangeAmountDialog(),
            ).whenComplete(() {
              ref.read(isChangeDialogOpenProvider.notifier).state = false;
            });
          } else {
            ref.read(printerControllerProvider).openCashDrawer(context);

            await ref
                .read(receiptControllerProvider)
                .pay(
                  receiptModel,
                  saleController.basketItems,
                  context: context,
                  f12Pressed: true,
                );

            // Close mobile scanner on payment (Android only)
            if (!Platform.isWindows) {
              ref.read(mobileScannerActiveProvider.notifier).state = false;
            }
            return;
          }
        // open cash then pay

        case LogicalKeyboardKey.arrowDown:
          ref.read(saleControllerProvider).toggleShouldAnimated(false);
          saleController.changeSelectedIndex(false);
          break;
        case LogicalKeyboardKey.arrowUp:
          ref.read(saleControllerProvider).toggleShouldAnimated(false);
          saleController.changeSelectedIndex(true);

          break;
        case LogicalKeyboardKey.delete:
          saleController.removeItemFromBasket(context);
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var saleController = ref.watch(saleControllerProvider);
    return ResponsiveWidget(
      mobileView: const MarketSaleMobile(),
      desktopView: Padding(
        padding: kPadd5,
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: defaultRadius,
                        color: context.cardColor,
                        border: Border.all(color: Pallete.greyColor),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: const CustomerSection().paddingAll(),
                              ),
                              kGap50,
                              Expanded(
                                child: const DiscountSection().paddingAll(),
                              ),
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Badge(
                                label: Text(
                                  saleController.totalItemQty.toStringAsFixed(
                                    0,
                                  ),
                                ),
                                child: const Icon(Icons.shopping_cart),
                              ),
                              Flexible(
                                child: ChangeQtyWidget(
                                  axix: Axis.horizontal,
                                  qty: "1",
                                ),
                              ),
                              Row(
                                spacing: 5,
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  const RestoreLastDeletedItemButton(),
                                  const HoldInvoicesSection(),
                                  AppSquaredOutlinedButton(
                                    borderColor: Pallete.redColor,
                                    isDisabled: ref
                                        .watch(saleControllerProvider)
                                        .basketItems
                                        .isEmpty,
                                    onPressed: () {
                                      ref
                                          .read(saleControllerProvider)
                                          .resetSaleScreen();
                                    },
                                    child: const Icon(
                                      Icons.delete,
                                      color: Pallete.redColor,
                                    ),
                                  ),
                                  AppSquaredOutlinedButton(
                                    child: const Icon(Icons.add),
                                    onPressed: () {
                                      ref
                                              .read(
                                                barcodeListenerEnabledProvider
                                                    .notifier,
                                              )
                                              .state =
                                          false;
                                      context.to(
                                        const AddEditProductScreen(null, null),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ).paddingSymmetric(horizontal: 5),
                          Expanded(
                            child: KeyboardListener(
                              focusNode: FocusNode()..requestFocus(),
                              autofocus: true,
                              onKeyEvent: (event) =>
                                  _handleKeyEvent(event, ref, context),
                              child: const MarketBasketList(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  kGap8,
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        Expanded(
                          flex: Platform.isWindows ? 3 : 2,
                          child: const RightPanelContent(),
                        ),
                        const Expanded(child: LastScannedItem()),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            kGap8,
            Container(
              padding: defaultPadding,
              decoration: BoxDecoration(
                borderRadius: defaultRadius,
                border: Border.all(color: Pallete.greyColor),
                color: context.cardColor,
              ),
              child: const Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Row(
                      spacing: 5,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        OpenCashButton(),
                        QuotationButton(),
                        LastInvoiceButton(),
                        StaffMarketButton(),
                        PayDeliveryButton(),
                      ],
                    ),
                  ),
                  kGap10,
                  Expanded(flex: 2, child: TotalAmountSection()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RightPanelContent extends ConsumerWidget {
  const RightPanelContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Consumer(
      builder: (context, ref, child) {
        final isScannerActive = ref.watch(mobileScannerActiveProvider);

        // On Windows, always show QuickSelectionProductSection
        if (Platform.isWindows) {
          return const QuickSelectionProductSection();
        }

        // On mobile platforms, show scanner or quick selection based on toggle
        return const MobileScannerSection();
      },
    );
  }
}
