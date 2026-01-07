import 'dart:io';

import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AppTextFormField extends ConsumerWidget {
  const AppTextFormField({
    this.readonly,
    this.onTapOutside,
    this.obscure,
    this.controller,
    this.inputtype,
    this.ontap,
    this.onvalidate,
    this.onchange,
    this.onEditingComplete,
    this.fontSize,
    this.labelText,
    this.labelColor,
    this.textColor,
    this.prefixIcon,
    this.suffixIcon,
    this.border,
    this.focusedborder,
    this.hinttext,
    this.hintcolor,
    this.cursorColor,
    this.maxligne,
    this.minline,
    this.focusNode,
    this.autofocus,
    this.textAlign,
    this.textAlignVertical,
    this.format,
    this.initialValue,
    this.textDirection,
    this.radius,
    this.maxLength,
    this.contentPadding,
    this.textCapitalization,
    this.onfieldsubmit,
    this.showText,
    this.backColor,
    this.height,
    super.key,
  });
  final TextEditingController? controller;
  final TextInputType? inputtype;
  final Function(String)? onfieldsubmit;
  final VoidCallback? ontap;
  final String? Function(String?)? onvalidate;
  final Function(String)? onchange;
  final Function()? onEditingComplete;
  final double? fontSize;
  final String? labelText;
  final Color? labelColor;
  final Color? textColor;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool? obscure;
  final InputBorder? border;
  final InputBorder? focusedborder;
  final String? hinttext;
  final Color? hintcolor;
  final Color? cursorColor;
  final int? maxligne;
  final int? minline;
  final FocusNode? focusNode;
  final bool? autofocus;
  final TextAlign? textAlign;
  final TextAlignVertical? textAlignVertical;
  final List<TextInputFormatter>? format;
  final String? initialValue;
  final TextDirection? textDirection;
  final double? radius;
  final int? maxLength;
  final bool? readonly;
  final EdgeInsets? contentPadding;
  final TextCapitalization? textCapitalization;
  final Function(PointerDownEvent)? onTapOutside;
  final bool? showText;
  final Color? backColor;
  final double? height;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLtr = ref.read(mainControllerProvider).isLtr;
    return Directionality(
      textDirection:
          textDirection ?? (isLtr ? TextDirection.ltr : TextDirection.rtl),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          TextFieldTitle(showText: showText, hintText: hinttext),
          Container(
            height: height ?? 45,
            decoration: BoxDecoration(
              borderRadius: kRadius15,
              border: Border.all(width: 1, color: Pallete.greyColor),
            ),
            child: TextFormField(
              onEditingComplete: onEditingComplete,
              initialValue: initialValue,
              textCapitalization:
                  textCapitalization ?? TextCapitalization.sentences,
              maxLength: maxLength,
              //initialValue: initialValue ?? '',
              inputFormatters: format ?? [],
              textAlignVertical: prefixIcon == null && suffixIcon == null
                  ? TextAlignVertical.top
                  : TextAlignVertical.bottom,
              textAlign:
                  textAlign ?? (isLtr ? TextAlign.left : TextAlign.right),
              controller: controller,
              keyboardType: inputtype,
              onFieldSubmitted: onfieldsubmit,
              onTap: ontap,
              autofocus: autofocus ?? false,
              maxLines: maxligne ?? 1,
              minLines: minline ?? 1,
              readOnly: readonly ?? false,
              obscureText: obscure ?? false,
              onChanged: onchange,
              focusNode: focusNode,
              cursorColor: cursorColor ?? context.primaryColor,
              style: TextStyle(
                fontSize: fontSize,
                decorationThickness: 0,
                color: Theme.of(context).textTheme.bodyMedium!.color,
                fontWeight: FontWeight.normal,
                decoration: TextDecoration.none,
              ),
              decoration: InputDecoration(
                contentPadding:
                    contentPadding ??
                    EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom: prefixIcon == null && suffixIcon == null
                          ? 5
                          : Platform.isWindows
                          ? 20
                          : 12,
                    ),
                labelText: labelText,
                labelStyle: TextStyle(color: labelColor),
                hintText: hinttext,
                hintStyle: TextStyle(
                  color: hintcolor,
                  fontStyle: FontStyle.italic,
                  decoration: TextDecoration.none,
                ),
                prefixIcon: prefixIcon,
                suffixIcon: suffixIcon,
                border: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
              ),
              onTapOutside: (event) {
                FocusScope.of(context).unfocus();
              },
              validator: onvalidate,
            ),
          ).cornerRadiusWithClipRRect(),
        ],
      ),
    );
  }
}

class TextFieldTitle extends ConsumerWidget {
  const TextFieldTitle({this.showText, this.hintText, super.key});
  final bool? showText;
  final String? hintText;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return showText == true
        ? Padding(
            padding: const EdgeInsets.only(left: 4, right: 4, top: 4),
            child: DefaultTextView(text: "$hintText"),
          )
        : kEmptyWidget;
  }
}
