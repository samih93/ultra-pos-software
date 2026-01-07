import 'package:desktoppossystem/controller/setting_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/dolar_rate_screen/dolar_rate_screen.dart';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
import 'package:desktoppossystem/screens/settings/components/sections/currency_sections/components/foreign_curreny_dialog.dart';
import 'package:desktoppossystem/screens/settings/components/sections/currency_sections/components/local_curreny_dialog.dart';
import 'package:desktoppossystem/shared/default%20components/default_list_tile.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/default%20components/elevated_button_widget.dart';
import 'package:desktoppossystem/shared/default%20components/quiver_circular_indicator.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CurrencySection extends ConsumerWidget {
  const CurrencySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var settingController = ref.watch(settingControllerProvider);

    return settingController.fetchSettingRequestState == RequestState.loading
        ? const Center(child: CoreCircularIndicator())
        : Container(
            padding: kPadd10,
            decoration: BoxDecoration(
              borderRadius: defaultRadius,
              border: Border.all(color: Colors.grey, width: 1),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    DefaultTextView(
                      text: S.of(context).currencies.capitalizeFirstLetter(),
                      color: context.primaryColor,
                      fontSize: 20,
                    ),
                    ElevatedButtonWidget(
                      icon: Icons.save,
                      text: S.of(context).save,
                      onPressed: () {
                        ref
                            .read(settingControllerProvider)
                            .saveCurrencies(context);
                      },
                    ),
                  ],
                ),
                const Divider(),
                // ! primary
                DefaultListTile(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => const ForeignCurrenyDialog(),
                    );
                  },
                  leading: const Icon(
                    Icons.currency_exchange_outlined,
                    color: Colors.grey,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      DefaultTextView(
                        text: ref
                            .read(settingControllerProvider)
                            .selectedPrimaryCurrency
                            .name
                            .currencyLocalization(),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_outlined,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                  title: DefaultTextView(
                    text: "${S.of(context).primaryCurrency}  ",
                  ),
                ),
                // ! secondary
                DefaultListTile(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => const LocalCurrenyDialog(),
                    );
                  },
                  leading: const Icon(
                    Icons.currency_exchange_outlined,
                    color: Colors.grey,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      DefaultTextView(
                        text: ref
                            .read(settingControllerProvider)
                            .selectedSecondaryCurrency
                            .name
                            .currencyLocalization(),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_outlined,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                  title: DefaultTextView(
                    text: "${S.of(context).secondaryCurrency}  ",
                  ),
                ),
                DefaultListTile(
                  onTap: ref.read(mainControllerProvider).isAdmin
                      ? () {
                          showDialog(
                            context: context,
                            builder: (context) =>
                                const AlertDialog(content: DolarRateScreen()),
                          );
                        }
                      : null,
                  leading: const Icon(
                    Icons.monetization_on_outlined,
                    color: Colors.grey,
                  ),
                  title: DefaultTextView(
                    text:
                        "1${ref.watch(settingControllerProvider).selectedPrimaryCurrency.name.currencyLocalization()} => ${ref.watch(saleControllerProvider).dolarRate.formatAmountNumber()} ${ref.watch(settingControllerProvider).selectedSecondaryCurrency.name.currencyLocalization()}",
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios_outlined,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
  }
}
