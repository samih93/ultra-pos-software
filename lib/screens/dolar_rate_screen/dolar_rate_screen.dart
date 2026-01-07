import 'package:desktoppossystem/controller/setting_controller.dart';
import 'package:desktoppossystem/screens/sale_screens/sale_controller.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_form.dart';
import 'package:desktoppossystem/shared/default%20components/elevated_button_widget.dart';
import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DolarRateScreen extends ConsumerStatefulWidget {
  const DolarRateScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DolarRateScreenState();
}

class _DolarRateScreenState extends ConsumerState<DolarRateScreen> {
  FocusNode myfocus = FocusNode();
  late TextEditingController dolarRateTextController;

  @override
  void initState() {
    dolarRateTextController = TextEditingController();
    dolarRateTextController.text =
        ref.read(saleControllerProvider).dolarRate.toString();
    Future.delayed(const Duration(seconds: 0), () {
      myfocus.requestFocus(); //auto focus on second text field.
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 150,
      child: Padding(
        padding: kPadd15,
        child: Column(
          children: [
            DefaultTextFormField(
                focusNode: myfocus,
                text: "Dolar Rate",
                textAlign: TextAlign.center,
                onfieldsubmit: (value) {
                  ref
                      .read(settingControllerProvider)
                      .saveDolarRate(double.parse(value.toString()));

                  context.pop();
                },
                controller: dolarRateTextController,
                // border: UnderlineInputBorder(),
                hinttext: "Dolar Rate",
                inputtype: TextInputType.number,
                format: currencyRateTextFormatter),
            kGap20,
            ElevatedButtonWidget(
                icon: Icons.save,
                width: 100,
                text: "save",
                onPressed: () {
                  ref.read(settingControllerProvider).saveDolarRate(
                      double.parse(dolarRateTextController.text));

                  context.pop();
                  //  context.read<MainController>().onchangeIndex(0);
                }),
          ],
        ),
      ),
    );
  }
}
