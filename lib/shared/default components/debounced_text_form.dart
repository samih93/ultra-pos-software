import 'dart:async';
import 'dart:io';
import 'package:desktoppossystem/screens/main_screen.dart/main_controller.dart';
import 'package:desktoppossystem/shared/default%20components/app_text_form_field.dart';
import 'package:desktoppossystem/shared/styles/pallete.dart';
import 'package:desktoppossystem/shared/styles/sizes.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A text form field with built-in debouncing for API calls
/// Styled exactly like NewDefaultTextFormField but with debounce functionality
/// Use this when you want to delay API calls while user is typing
class DebouncedTextFormField extends ConsumerStatefulWidget {
  const DebouncedTextFormField({
    this.readonly,
    this.onTapOutside,
    this.obscure,
    this.controller,
    this.inputtype,
    this.ontap,
    this.onvalidate,
    this.onchange,
    this.onFieldSubmitted,
    this.onDebouncedChange,
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
    this.showText,
    this.backColor,
    this.height,
    this.debounceDuration = const Duration(milliseconds: 500),
    super.key,
  });

  final TextEditingController? controller;
  final TextInputType? inputtype;
  final Function(String)? onFieldSubmitted;
  final VoidCallback? ontap;
  final String? Function(String?)? onvalidate;

  /// Called immediately on every change (for local updates like character count)
  final Function(String)? onchange;

  /// Called after debounce duration (for API calls)
  final Function(String)? onDebouncedChange;

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

  /// Duration to wait before calling onDebouncedChange
  /// Default is 300ms
  final Duration debounceDuration;

  @override
  ConsumerState<DebouncedTextFormField> createState() =>
      _DebouncedTextFormFieldState();
}

class _DebouncedTextFormFieldState
    extends ConsumerState<DebouncedTextFormField> {
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onChanged(String value) {
    // Call immediate onChange for local updates
    widget.onchange?.call(value);

    // Cancel previous timer
    _debounceTimer?.cancel();

    // Only debounce if onDebouncedChange is provided
    if (widget.onDebouncedChange != null) {
      _debounceTimer = Timer(widget.debounceDuration, () {
        widget.onDebouncedChange?.call(value);
      });
    }
  }

  double calculatePadding() {
    if (widget.prefixIcon == null && widget.suffixIcon == null) {
      // For web, set a smaller padding if no icons are present
      return kIsWeb ? 5.0 : 0.0;
    } else {
      if (widget.prefixIcon != null || widget.suffixIcon != null) {
        return kIsWeb ? 20.0 : 10.0;
      } else {
        return kIsWeb ? 14.0 : 10.0;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLtr = ref.read(mainControllerProvider).isLtr;

    return Directionality(
      textDirection:
          widget.textDirection ??
          (isLtr ? TextDirection.ltr : TextDirection.rtl),
      child: Column(
        crossAxisAlignment: .start,
        children: [
          TextFieldTitle(showText: widget.showText, hintText: widget.hinttext),
          Container(
            height: widget.height ?? 45,
            decoration: BoxDecoration(
              borderRadius: kRadius15,
              border: Border.all(width: 1, color: Pallete.greyColor),
            ),
            child: TextFormField(
              textCapitalization:
                  widget.textCapitalization ?? TextCapitalization.sentences,
              maxLength: widget.maxLength,
              //initialValue: initialValue ?? '',
              inputFormatters: widget.format ?? [],
              textAlignVertical:
                  widget.prefixIcon == null && widget.suffixIcon == null
                  ? TextAlignVertical.top
                  : TextAlignVertical.bottom,
              textAlign: widget.textAlign ?? TextAlign.left,
              controller: widget.controller,
              keyboardType: widget.inputtype,
              onFieldSubmitted: widget.onFieldSubmitted,
              onTap: widget.ontap,
              autofocus: widget.autofocus ?? false,
              maxLines: widget.maxligne ?? 1,
              minLines: widget.minline ?? 1,
              readOnly: widget.readonly ?? false,
              obscureText: widget.obscure ?? false,
              onChanged: _onChanged,
              focusNode: widget.focusNode,
              cursorColor: widget.cursorColor ?? context.primaryColor,
              style: TextStyle(
                fontSize: widget.fontSize,
                decorationThickness: 0,
                color: Theme.of(context).textTheme.bodyMedium!.color,
                fontWeight: FontWeight.normal,
                decoration: TextDecoration.none,
              ),
              decoration: InputDecoration(
                contentPadding:
                    widget.contentPadding ??
                    EdgeInsets.only(
                      left: 20,
                      right: 20,
                      bottom:
                          widget.prefixIcon == null && widget.suffixIcon == null
                          ? 5
                          : Platform.isWindows
                          ? 20
                          : 12,
                    ),
                labelText: widget.labelText,
                labelStyle: TextStyle(color: widget.labelColor),
                hintText: widget.hinttext,
                hintStyle: TextStyle(
                  color: widget.hintcolor ?? Pallete.greyColor,
                  fontStyle: FontStyle.italic,
                  decoration: TextDecoration.none,
                ),
                prefixIcon: widget.prefixIcon,
                suffixIcon: widget.suffixIcon,
                border: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
              ),
              onTapOutside: (event) {
                FocusScope.of(context).unfocus();
              },
              validator: widget.onvalidate,
            ),
          ).cornerRadiusWithClipRRect(),
        ],
      ),
    );
  }
}
