import 'package:desktoppossystem/screens/profit_report_screen/profit_controller.dart';
import 'package:desktoppossystem/screens/profit_report_screen/sections/waste_section/components/waste_header.dart';
import 'package:desktoppossystem/screens/profit_report_screen/sections/waste_section/components/waste_report_item.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WasteSection extends ConsumerWidget {
  const WasteSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var profitController = ref.watch(profitControllerProvider);
    double totalWaste = profitController.totalWaste;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 20,
      ), // Symmetric padding
      child: profitController.wasteList.isEmpty
          ? const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DefaultTextView(
                  text: "No Wastes yet",
                  color: Colors.grey,
                  fontSize: 25,
                ),
              ],
            )
          : Column(
              crossAxisAlignment: .start,
              children: [
                // Expenses Header Row
                const WasteHeader(),

                Divider(height: 1, color: context.primaryColor),

                // Expenses List (Each Item in Row Format)
                Expanded(
                  child: ListView.builder(
                    itemExtent: 50,
                    itemCount: profitController.wasteList.length,
                    itemBuilder: (context, index) {
                      final backgroundColor = index.isEven
                          ? ref.watch(isDarkModeProvider)
                                ? context.cardColor
                                : Pallete.whiteColor
                          : context.selectedPrimaryColor.withValues(alpha: 0.5);
                      return WasteReportItem(
                        backgroundColor: backgroundColor,
                        profitController.wasteList[index],
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
