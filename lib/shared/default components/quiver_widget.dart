import 'package:desktoppossystem/shared/constances/asset_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CoreWidget extends ConsumerWidget {
  const CoreWidget({this.width, super.key});
  final double? width;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Image.asset(
      AssetConstant.coreLogoWithName,
      width: width ?? 200,
    );
  }
}
