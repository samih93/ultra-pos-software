import 'package:desktoppossystem/controller/auth_controller.dart';
import 'package:desktoppossystem/models/user_model.dart';
import 'package:desktoppossystem/screens/settings/components/sections/owner_section/owner_query_screen/owner_query_screen.dart';
import 'package:desktoppossystem/shared/config/secure_config.dart';
import 'package:desktoppossystem/shared/default%20components/default_list_tile.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OwnerQuerySection extends ConsumerWidget {
  const OwnerQuerySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userModel = ref.read(currentUserProvider) ?? UserModel.fakeUser();

    return userModel.id == int.tryParse(SecureConfig.quiverUserId)
        ? Row(
            children: [
              Expanded(
                child: DefaultListTile(
                  leading: const Icon(Icons.query_builder_outlined),
                  title: const DefaultTextView(text: "Query Screen"),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded),
                  onTap: () {
                    context.to(const OwnerQueryScreen());
                  },
                ),
              ),
            ],
          )
        : kEmptyWidget;
  }
}
