import 'package:desktoppossystem/models/app_version_model.dart';
import 'package:desktoppossystem/models/failure_model.dart';
import 'package:desktoppossystem/shared/services/dependency_injection.dart';
import 'package:desktoppossystem/shared/utils/type_def.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fpdart/fpdart.dart';

final updateRepositoryProvider = Provider((ref) {
  return UpdateRepository(ref);
});

class UpdateRepository {
  final Ref ref;
  UpdateRepository(this.ref);

  // Get latest version
  FutureEither<AppVersionModel?> getLatestVersion() async {
    try {
      final response = await ref
          .read(supaBaseProvider)
          .from('app_versions')
          .select()
          .eq('is_latest', true)
          .single();

      return right(AppVersionModel.fromJson(response));
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  // Track user download
  FutureEither<void> trackUserUpdate({
    required String userId,
    required int versionId,
    String? deviceInfo,
    bool success = true,
  }) async {
    try {
      await ref.read(supaBaseProvider).from('user_updates').insert({
        'user_id': userId,
        'version_id': versionId,
        'device_info': deviceInfo,
        'success': success,
      });

      return right(null);
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }

  // Get update statistics
  FutureEither<Map<String, dynamic>> getUpdateStats(int versionId) async {
    try {
      final response = await ref
          .read(supaBaseProvider)
          .from('user_updates')
          .select('id, success')
          .eq('version_id', versionId);

      final total = response.length;
      final successful =
          response.where((item) => item['success'] == true).length;

      return right({
        'total_downloads': total,
        'successful_downloads': successful,
        'failed_downloads': total - successful,
      });
    } catch (e) {
      return left(FailureModel(e.toString()));
    }
  }
}
