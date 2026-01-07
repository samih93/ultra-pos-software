// domain/bot_notifications.dart
import 'package:desktoppossystem/models/details_receipt.dart';
import 'package:desktoppossystem/models/receipt_model.dart';
import 'package:desktoppossystem/shared/constances/app_constances.dart';
import 'package:desktoppossystem/shared/utils/extentions.dart';

sealed class BotNotification {
  const BotNotification();

  /// Returns a ready-to-send payload for Telegram sendMessage
  String generateMessage();
}

class ReceiptNotification extends BotNotification {
  final ReceiptModel receiptModel;

  const ReceiptNotification({
    required this.receiptModel,
  });

  @override
  String generateMessage() {
    final sb = StringBuffer()
      ..writeln('🧾 Invoice Created')
      ..writeln('ID: ${receiptModel.id}');

    final customer = receiptModel.customerModel;
    if (customer?.id != null) {
      sb.writeln(
          'Customer: ${customer?.name ?? "No Customer"}, phone: ${customer?.phoneNumber ?? "No Phone"}');
    }

    sb
      ..writeln('Amount: ${receiptModel.foreignReceiptPrice.formatDouble()} '
          '${AppConstance.primaryCurrency.currencyLocalization()}')
      ..writeln(
          'Amount: ${receiptModel.foreignReceiptPrice.formatDouble() * (receiptModel.dollarRate ?? 0)} '
          '${AppConstance.secondaryCurrency.currencyLocalization()}')
      ..writeln('Date: ${receiptModel.receiptDate}'); // format if needed

    return sb.toString().trimRight();
  }
}

class RefundNotification extends BotNotification {
  final int receiptId;
  final List<DetailsReceipt> detailsReceipt;

  const RefundNotification(
      {required this.receiptId, required this.detailsReceipt});

  @override
  String generateMessage() {
    final currency = AppConstance.primaryCurrency.currencyLocalization();

    double total = 0;
    final sb = StringBuffer()
      ..writeln('↩️ Refund Issued')
      ..writeln('Invoice: $receiptId')
      ..writeln('Date: ${DateTime.now()}')
      ..writeln('Items:');

    if (detailsReceipt.isEmpty) {
      sb.writeln('• (none)');
    } else {
      for (final d in detailsReceipt) {
        final price = (d.sellingPrice ?? 0);
        total += price;

        final item = d.productName; // adapt to your model
        final reason = d.refundReason?.trim();

        final line = StringBuffer()
          ..write('• $item — ${d.sellingPrice.formatDouble()} $currency');

        if (reason != null && reason.isNotEmpty) {
          line.write(' — Reason: $reason');
        }
        sb.writeln(line.toString());
      }
    }

    sb.writeln('Total refunded: ${total.formatDouble()} $currency');
    return sb.toString().trimRight();
  }
}

class DeleteReceiptNotification extends BotNotification {
  final ReceiptModel receipt;

  const DeleteReceiptNotification({required this.receipt});

  @override
  String generateMessage() {
    final sb = StringBuffer()
      ..writeln('🗑️ Receipt Deleted')
      ..writeln('Receipt ID: ${receipt.id}');
    if (receipt.customerModel != null) {
      sb.writeln(
          'Customer: ${receipt.customerModel?.name ?? "No Customer"},  phone: ${receipt.customerModel?.phoneNumber ?? "No Phone"}');
    }
    sb
      ..writeln(
          'Amount: ${receipt.foreignReceiptPrice.formatDouble()} ${AppConstance.primaryCurrency.currencyLocalization()}')
      ..writeln('Date: ${DateTime.now()}');

    return sb.toString().trimRight();
  }
}
