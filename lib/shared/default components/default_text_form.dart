import 'package:desktoppossystem/shared/global.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DefaultTextFormField extends StatelessWidget {
  const DefaultTextFormField(
      {this.controller,
      this.inputtype,
      this.onfieldsubmit,
      this.ontap,
      this.onvalidate,
      this.onchange,
      this.text,
      this.textColor,
      this.prefixIcon,
      this.suffixIcon,
      this.obscure,
      this.border,
      this.enabledborder,
      this.focusedBorder,
      this.errorBorder,
      this.hinttext,
      this.prefixText,
      this.hintcolor,
      this.cursorColor,
      this.maxligne,
      this.minline,
      this.maxlengh,
      this.focusNode,
      this.autofocus,
      this.format,
      this.textAlign,
      this.readonly,
      this.contentPadding,
      this.initialValue,
      super.key});

  final TextEditingController? controller;
  final TextInputType? inputtype;
  final Function(String?)? onfieldsubmit;
  final VoidCallback? ontap;
  final String? Function(String?)? onvalidate;
  final Function(String)? onchange;
  final String? text;
  final Color? textColor;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool? obscure;
  final InputBorder? border;
  final InputBorder? enabledborder;
  final InputBorder? focusedBorder;
  final InputBorder? errorBorder;
  final String? hinttext;
  final String? prefixText;
  final Color? hintcolor;
  final Color? cursorColor;
  final int? maxligne;
  final int? minline;
  final int? maxlengh;
  final FocusNode? focusNode;
  final bool? autofocus;
  final List<TextInputFormatter>? format;
  final TextAlign? textAlign;
  final bool? readonly;
  final EdgeInsets? contentPadding;
  final String? initialValue;
  @override
  Widget build(BuildContext context) {
    return TextFormField(
        maxLength: maxlengh,
        initialValue: initialValue,
        textAlign:
            textAlign ?? (isEnglishLanguage ? TextAlign.left : TextAlign.right),
        controller: controller,
        textAlignVertical: prefixIcon == null && suffixIcon == null
            ? TextAlignVertical.top
            : TextAlignVertical.center,
        inputFormatters: format ?? [],
        keyboardType: inputtype ?? TextInputType.name,
        onFieldSubmitted: onfieldsubmit,
        onTap: ontap,
        autofocus: autofocus ?? false,
        maxLines: maxligne ?? 1,
        minLines: minline ?? 1,
        readOnly: readonly ?? false,
        obscureText: obscure ?? false,
        onChanged: onchange,
        focusNode: focusNode,
        cursorColor: cursorColor ?? Colors.blue,
        style: TextStyle(
          color: textColor ?? Colors.black,
          fontWeight: FontWeight.normal,
        ),
        decoration: InputDecoration(
          prefixText: prefixText,
          labelText: text,
          errorStyle: const TextStyle(color: Colors.red),
          hintText: hinttext,
          hintStyle: TextStyle(color: hintcolor ?? Colors.grey),
          contentPadding: contentPadding ??
              EdgeInsets.only(
                  left: 10,
                  right: 10,
                  bottom: prefixIcon != null || suffixIcon != null ? 10 : 5),
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          errorBorder: errorBorder ??
              const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.red)),
          focusedBorder: focusedBorder ??
              UnderlineInputBorder(
                  borderSide: BorderSide(color: context.primaryColor)),
          focusedErrorBorder: focusedBorder ??
              const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.red)),
          border: border ??
              UnderlineInputBorder(
                  borderSide: BorderSide(color: context.primaryColor)),
          enabledBorder: enabledborder ??
              UnderlineInputBorder(
                  borderSide: BorderSide(color: context.primaryColor)),
        ),
        validator: onvalidate);
  }
}
