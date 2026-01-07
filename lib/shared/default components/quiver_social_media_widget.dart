import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class CoreSocialMediaWidget extends ConsumerWidget {
  const CoreSocialMediaWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        InkWell(
          onTap: () {
            launchUrl(
              Uri.parse("https://www.instagram.com/coremanager.software/"),
            );
          },
          child: const FaIcon(
            FontAwesomeIcons.instagram,
            color: Pallete.primaryColorDark,
          ),
        ),
        InkWell(
          onTap: () {},
          child: const FaIcon(
            FontAwesomeIcons.tiktok,
            color: Pallete.primaryColorDark,
          ),
        ),
        InkWell(
          onTap: () {
            launchUrl(Uri.parse("https://wa.me/96171422844"));
          },
          child: const FaIcon(
            FontAwesomeIcons.whatsapp,
            color: Pallete.primaryColorDark,
          ),
        ),
        InkWell(
          onTap: () {
            launchUrl(Uri.parse("https://www.facebook.com/crepyBarja/photos"));
          },
          child: const FaIcon(
            FontAwesomeIcons.facebook,
            color: Pallete.primaryColorDark,
          ),
        ),
      ],
    );
  }
}
