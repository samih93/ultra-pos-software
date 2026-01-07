import 'package:desktoppossystem/controller/printer_controller.dart';
import 'package:desktoppossystem/screens/settings/components/sections/printer%20section/printer_properties_section.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NetworkSectionsPrinter extends ConsumerWidget {
  const NetworkSectionsPrinter({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final printerController = ref.watch(printerControllerProvider);
    print("printer controller ${printerController.sectionsPrinters.length}");
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Pallete.coreMistColor,
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                ...SectionType.values.map((view) {
                  final isSelected =
                      printerController.selectedPrinterSection == view;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: () {
                        printerController.onchangePrinterSection(view);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Pallete.primaryColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          view.sectionTypeToString(),
                          style: TextStyle(
                            color: isSelected
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ]),
            ),
            IconButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => PrinterSelectionDialog(
                      selectedSection: SectionType.bar,
                      onPrinterSelected: (String printerName) {
                        ref
                            .read(printerControllerProvider)
                            .addSectionPrinter(printerName);
                      },
                    ),
                  );
                },
                icon: const Icon(
                  Icons.print_outlined,
                  size: 30,
                )),
          ],
        ),
        ...printerController.sectionsPrinters.map((e) {
          return Column(
            children: [
              ListTile(
                dense: true,
                leading: const Icon(
                  Icons.print_outlined,
                  color: Pallete.greenColor,
                ),
                title: DefaultTextView(text: e.printerName.toString()),
                subtitle: DefaultTextView(text: e.sectionType.name),
                trailing: IconButton(
                    onPressed: () {
                      ref
                          .read(printerControllerProvider)
                          .removeSectionPrinter(e.printerName);
                    },
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Pallete.redColor,
                    )),
              ),
              const Divider(
                height: 1,
              )
            ],
          );
        })
      ],
    );
  }
}
