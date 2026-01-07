import 'package:desktoppossystem/shared/default%20components/default_text_view.dart';
import 'package:desktoppossystem/shared/default%20components/new_default_button.dart';
import 'package:desktoppossystem/shared/styles/my_linears_gradient.dart';
import 'package:desktoppossystem/shared/utils/enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ReusableConfirmDialog extends ConsumerStatefulWidget {
  const ReusableConfirmDialog({
    super.key,
    required this.title,
    required this.content,
    this.confirmText = 'confirm',
    this.cancelText = 'cancel',
    this.onConfirm,
    this.onCancel,
    this.barrierDismissible = true,
    this.confirmButtonColor,
    this.cancelButtonColor,
    this.isDestructive = false,
    this.gradientAcceptColor,
    this.isLoading = false,
  });

  /// Dialog title
  final String title;

  /// Dialog content - can be String or Widget
  final dynamic content;

  /// Confirm button text
  final String confirmText;

  /// Cancel button text
  final String cancelText;

  /// Simple callback when confirm button is pressed - no async operations
  final VoidCallback? onConfirm;

  /// Callback when cancel button is pressed
  final VoidCallback? onCancel;

  /// Whether dialog can be dismissed by tapping outside
  final bool barrierDismissible;

  /// Confirm button background color
  final Color? confirmButtonColor;

  /// Cancel button text color
  final Color? cancelButtonColor;

  /// Whether this is a destructive action (red styling)
  final bool isDestructive;
  final Gradient? gradientAcceptColor;

  /// Whether the confirm button should show loading state
  final bool isLoading;

  /// Static method to show the dialog
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required dynamic content,
    String confirmText = 'تأكيد',
    String cancelText = 'إلغاء',
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool barrierDismissible = true,
    Color? confirmButtonColor,
    Color? cancelButtonColor,
    bool isDestructive = false,
    Gradient? gradientAcceptColor,
    bool isLoading = false,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => ReusableConfirmDialog(
        title: title,
        content: content,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
        barrierDismissible: barrierDismissible,
        confirmButtonColor: confirmButtonColor,
        cancelButtonColor: cancelButtonColor,
        isDestructive: isDestructive,
        gradientAcceptColor: gradientAcceptColor,
        isLoading: isLoading,
      ),
    );
  }

  @override
  ConsumerState<ReusableConfirmDialog> createState() =>
      _ReusableConfirmDialogState();
}

class _ReusableConfirmDialogState extends ConsumerState<ReusableConfirmDialog> {
  Widget _buildContent() {
    if (widget.content is Widget) {
      return widget.content as Widget;
    } else if (widget.content is String) {
      return DefaultTextView(
        text: widget.content as String,
        textAlign: TextAlign.center,
      );
    } else {
      return Text(
        widget.content.toString(),
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 16),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      title: DefaultTextView(
        text: widget.title,
        textAlign: TextAlign.center,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400, minWidth: 280),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [_buildContent()],
        ),
      ),
      actions: [
        TextButton(
          onPressed: widget.isLoading ? null : widget.onCancel,
          child: DefaultTextView(text: widget.cancelText),
        ),
        NewDefaultButton(
          width: widget.confirmText.length * 12.0 + 20,
          gradient: widget.gradientAcceptColor ?? (coreGradient()),
          text: widget.confirmText,
          state: widget.isLoading ? RequestState.loading : RequestState.success,
          onpress: widget.isLoading ? null : widget.onConfirm,
        ),
      ],
    );
  }
}

/* 
  ========== REUSABLE CONFIRM DIALOG USAGE EXAMPLES ==========
  
  // 1. SIMPLE CONFIRMATION DIALOG
  ReusableConfirmDialog.show(
    context: context,
    title: 'تأكيد الحذف',
    content: 'هل أنت متأكد من أنك تريد حذف هذا العنصر؟',
    confirmText: 'حذف',
    cancelText: 'إلغاء',
    isDestructive: true,
    gradientAcceptColor: myredLinearGradient(),
    onConfirm: () {
      Navigator.of(context).pop(true);
      // Handle delete action here
      deleteItem();
    },
    onCancel: () {
      Navigator.of(context).pop(false);
    },
  );

  // 2. LOGOUT CONFIRMATION
  ReusableConfirmDialog.show(
    context: context,
    title: 'تسجيل الخروج',
    content: 'هل تريد تسجيل الخروج من التطبيق؟',
    confirmText: 'تسجيل خروج',
    cancelText: 'إلغاء',
    isDestructive: true,
    gradientAcceptColor: myredLinearGradient(),
    onConfirm: () async {
      Navigator.of(context).pop(true);
      try {
        await ref.read(authControllerProvider).logout(context);
      } catch (error) {
        // Handle error
      }
    },
    onCancel: () {
      Navigator.of(context).pop(false);
    },
  );

  // 3. CUSTOM WIDGET CONTENT
  ReusableConfirmDialog.show(
    context: context,
    title: 'معلومات مهمة',
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.warning, color: Colors.orange, size: 48),
        SizedBox(height: 16),
        Text('هذا الإجراء لا يمكن التراجع عنه'),
      ],
    ),
    confirmText: 'متابعة',
    cancelText: 'إلغاء',
    onConfirm: () {
      Navigator.of(context).pop(true);
      // Handle action
    },
    onCancel: () {
      Navigator.of(context).pop(false);
    },
  );

  // 4. HANDLING DIALOG RESULT
  final result = await ReusableConfirmDialog.show(
    context: context,
    title: 'تأكيد العملية',
    content: 'هل تريد المتابعة؟',
    onConfirm: () {
      Navigator.of(context).pop(true);
    },
    onCancel: () {
      Navigator.of(context).pop(false);
    },
  );
  
  if (result == true) {
    // User confirmed
    print('User confirmed the action');
  } else {
    // User cancelled or dismissed
    print('User cancelled the action');
  }

  // 5. NON-DISMISSIBLE DIALOG
  ReusableConfirmDialog.show(
    context: context,
    title: 'طلب إذن',
    content: 'يحتاج التطبيق إلى إذن للمتابعة',
    confirmText: 'السماح',
    cancelText: 'رفض',
    barrierDismissible: false, // User must choose
    onConfirm: () {
      Navigator.of(context).pop(true);
      // Grant permission
    },
    onCancel: () {
      Navigator.of(context).pop(false);
      // Deny permission
    },
  );

  // 6. ASYNC OPERATIONS AFTER CONFIRMATION
  ReusableConfirmDialog.show(
    context: context,
    title: 'حفظ التغييرات',
    content: 'هل تريد حفظ التغييرات؟',
    onConfirm: () async {
      Navigator.of(context).pop(true);
      
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );
      
      try {
        await saveChanges();
        Navigator.of(context).pop(); // Close loading
        // Show success
      } catch (error) {
        Navigator.of(context).pop(); // Close loading
        // Show error
      }
    },
    onCancel: () {
      Navigator.of(context).pop(false);
    },
  );

  ========== KEY PRINCIPLES ==========
  
  1. Always call Navigator.of(context).pop() in your callbacks
  2. Pass true for confirm, false for cancel
  3. Handle async operations AFTER closing the dialog
  4. Use gradientAcceptColor for destructive actions
  5. Set barrierDismissible: false for required decisions
  6. Handle errors gracefully in your callbacks
  
*/
