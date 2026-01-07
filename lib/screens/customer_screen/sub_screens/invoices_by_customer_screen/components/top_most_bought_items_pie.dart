import 'package:desktoppossystem/controller/customer_controller.dart';
import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/screens/error_section.dart';
import 'package:desktoppossystem/shared/default%20components/default_prodgress_indicator.dart';

import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TopMostBoughtItemsPie extends ConsumerWidget {
  const TopMostBoughtItemsPie({required this.customerId, super.key});
  final int customerId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var topSellingFuture = ref.watch(topSellingProductProvider(customerId));

    return topSellingFuture.when(
      data: (data) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: Pallete.greyColor),
          ),
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    S.of(context).topMostBoughtItemsPie, // Title
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
              kGap10,
              Expanded(
                child: ListView.separated(
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  shrinkWrap: true,
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    var product = data[index];

                    return ListTile(
                      dense: true,
                      leading: CircleAvatar(
                        radius: 16,
                        child: Text((index + 1).toString()),
                      ),
                      title: Text("${product.name}"),
                      trailing: Text(
                        "${product.qty}",
                        style: const TextStyle(color: Pallete.redColor),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
      error: (error, stackTrace) => ErrorSection(
        retry: () => ref.refresh(topSellingProductProvider(customerId)),
        title: error.toString(),
      ),
      loading: () => const Center(child: DefaultProgressIndicator()),
    );
  }
}
