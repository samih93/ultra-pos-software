import 'package:desktoppossystem/controller/setting_controller.dart';
import 'package:desktoppossystem/models/failure_model.dart';
import 'package:desktoppossystem/shared/config/secure_config.dart';
import 'package:desktoppossystem/shared/services/dependency_injection.dart';
import 'package:desktoppossystem/shared/services/telegram/bot_notification.dart';
import 'package:desktoppossystem/shared/utils/type_def.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

final telegramRepositoryProvider = Provider<TelegramBotServiceRepo>((ref) {
  return TelegramBotService(ref);
});

abstract class TelegramBotServiceRepo {
  FutureEitherVoid sendSms(BotNotification notification);
}

class TelegramBotService extends TelegramBotServiceRepo {
  final Ref ref;
  TelegramBotService(this.ref);
  @override
  FutureEitherVoid sendSms(BotNotification notification) async {
    try {
      final chatId =
          ref.read(settingControllerProvider).settingModel.telegramChatId;

      if (chatId != null) {
        final base = Uri.parse(
          SecureConfig.telegramRequestUrl,
        );

        final uri = base.replace(queryParameters: {
          "chat_id": chatId,
          "text": notification.generateMessage(),
        });

        final res =
            await ref.read(quiverDioProvider).getData(url: uri.toString());
        return right(null);
      } else {
        print("not registered");
        return left(FailureModel("telegram not registered"));
      }
    } catch (e) {
      print(e.toString());

      return left(FailureModel(e.toString()));
    }
  }
}
