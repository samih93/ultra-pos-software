import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';

class LoadingStockTransactions extends ConsumerWidget {
  const LoadingStockTransactions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return RepaintBoundary(
      child: Skeletonizer(
          child: Column(
        children: [
          ...List<Widget>.generate(10, (index) {
            return const Row(children: [
              Expanded(
                  child: Center(
                      child: DefaultTextView(
                text: "name",
              ))),
              Expanded(
                  child: Center(
                      child: DefaultTextView(
                text: "Kg",
              ))),
              Center(
                  child: DefaultTextView(
                text: "2",
              )),
              Expanded(
                  child: Center(
                      child: DefaultTextView(
                text: "0",
              ))),
              Expanded(
                  flex: 1,
                  child: Center(
                      child: DefaultTextView(
                    text: "####3",
                  ))),
              Expanded(
                  child: Center(
                      child: DefaultTextView(
                text: "--",
              ))),
              Expanded(
                  flex: 1,
                  child: Center(
                      child: DefaultTextView(
                          text: "###########", fontWeight: FontWeight.bold)))
            ]);
          }),
        ],
      )),
    );
  }
}
