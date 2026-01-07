import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class ToastUtils {
  static void showToast({
    required String message,
    RequestState? type,
    Duration duration = const Duration(seconds: 2),
  }) {
    type = type ?? RequestState.success;

    final stateType = type == RequestState.error
        ? ToastificationType.error
        : type == RequestState.success
            ? ToastificationType.success
            : ToastificationType.warning;

    toastification.show(
      alignment: AlignmentDirectional.bottomCenter,
      margin: EdgeInsets.zero,
      type: stateType,
      style: ToastificationStyle.flatColored,
      title: Text(
        message,
        maxLines: 3,
      ),
      autoCloseDuration: duration,
    );
  }
}
