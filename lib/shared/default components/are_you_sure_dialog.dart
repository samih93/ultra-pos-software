import 'package:desktoppossystem/generated/l10n.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/default%20components/elevated_button_widget.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AreYouSureDialog extends ConsumerWidget {
  const AreYouSureDialog(
    this.title, {
    super.key,
    this.onCancel,
    this.onAgree,
    this.agreeState,
    this.content,
    required this.agreeText,
    this.textColor,
  });
  final String title;
  final Widget? content;
  final VoidCallback? onCancel;
  final VoidCallback? onAgree;
  final RequestState? agreeState;
  final String agreeText;
  final Color? textColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: context.width * 0.4),
        child: IntrinsicHeight(
          child: AlertDialog(
            actionsPadding: defaultPadding,
            titlePadding: defaultPadding,
            title: Center(
              child: DefaultTextView(
                maxlines: 3,
                text: title,
                textAlign: TextAlign.center,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [content ?? kEmptyWidget],
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                spacing: 10,
                children: [
                  ElevatedButtonWidget(
                    text: S.of(context).cancel,
                    onPressed: onCancel,
                    // width: 120,
                  ),
                  // kGap20,
                  ElevatedButtonWidget(
                    // width: 120,
                    states: agreeState != null ? [agreeState!] : [],
                    text: agreeText,
                    color: textColor ?? Pallete.redColor,
                    //icon: forRestore == true ? Icons.restore : Icons.delete,
                    onPressed: onAgree,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
