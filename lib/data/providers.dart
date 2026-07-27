import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/error/result.dart';
import '../core/network/supabase_client_provider.dart';
import '../domain/entities/app_config.dart';
import '../domain/repositories/i_app_config_repository.dart';
import '../domain/repositories/i_auth_repository.dart';
import '../domain/repositories/i_bill_repository.dart';
import '../domain/repositories/i_ocr_repository.dart';
import '../domain/repositories/i_profile_repository.dart';
import '../domain/repositories/i_saved_participant_repository.dart';
import 'datasources/app_config_remote_datasource.dart';
import 'datasources/auth_remote_datasource.dart';
import 'datasources/bill_remote_datasource.dart';
import 'datasources/profile_remote_datasource.dart';
import 'datasources/saved_participant_remote_datasource.dart';
import 'repositories/app_config_repository_impl.dart';
import 'repositories/auth_repository_impl.dart';
import 'repositories/bill_repository_impl.dart';
import 'repositories/ocr_repository_impl.dart';
import 'repositories/profile_repository_impl.dart';
import 'repositories/saved_participant_repository_impl.dart';
import 'services/history_plus_banner_preferences.dart';
import 'services/password_recovery_session.dart';
import 'services/pending_registration_preferences.dart';
import 'services/saved_participants_cache.dart';
import 'services/image_picker_wrapper.dart';
import 'services/ocr_service.dart';

part 'providers.g.dart';

@Riverpod(keepAlive: true)
BillRemoteDataSource billRemoteDataSource(Ref ref) =>
    BillRemoteDataSource(ref.watch(supabaseClientProvider));

@Riverpod(keepAlive: true)
PasswordRecoverySession passwordRecoverySession(Ref ref) =>
    throw UnimplementedError(
      'passwordRecoverySessionProvider must be overridden in main() with a '
      'pre-warmed PasswordRecoverySession instance. See _bootstrap().',
    );

@Riverpod(keepAlive: true)
AuthRemoteDataSource authRemoteDataSource(Ref ref) =>
    AuthRemoteDataSource(
      ref.watch(supabaseClientProvider),
      ref.watch(passwordRecoverySessionProvider),
    );

@Riverpod(keepAlive: true)
IBillRepository billRepository(Ref ref) =>
    BillRepositoryImpl(ref.watch(billRemoteDataSourceProvider));

@Riverpod(keepAlive: true)
IOCRRepository ocrRepository(Ref ref) =>
    OcrRepositoryImpl(ref.watch(ocrServiceProvider));

@Riverpod(keepAlive: true)
IAuthRepository authRepository(Ref ref) =>
    AuthRepositoryImpl(ref.watch(authRemoteDataSourceProvider));

@Riverpod(keepAlive: true)
ProfileRemoteDataSource profileRemoteDataSource(Ref ref) =>
    ProfileRemoteDataSource(ref.watch(supabaseClientProvider));

@Riverpod(keepAlive: true)
IProfileRepository profileRepository(Ref ref) =>
    ProfileRepositoryImpl(ref.watch(profileRemoteDataSourceProvider));

@Riverpod(keepAlive: true)
AppConfigRemoteDataSource appConfigRemoteDataSource(Ref ref) =>
    AppConfigRemoteDataSource(ref.watch(supabaseClientProvider));

@Riverpod(keepAlive: true)
IAppConfigRepository appConfigRepository(Ref ref) =>
    AppConfigRepositoryImpl(ref.watch(appConfigRemoteDataSourceProvider));

@Riverpod(keepAlive: true)
SavedParticipantRemoteDataSource savedParticipantRemoteDataSource(Ref ref) =>
    SavedParticipantRemoteDataSource(ref.watch(supabaseClientProvider));

@Riverpod(keepAlive: true)
ISavedParticipantRepository savedParticipantRepository(Ref ref) =>
    SavedParticipantRepositoryImpl(
      ref.watch(savedParticipantRemoteDataSourceProvider),
    );

/// Local SharedPreferences cache for the cross-bill participant library.
/// Created once on first read; reads/writes are awaited by the consumer
/// (typically the suggestion chips widget on first paint).
@Riverpod(keepAlive: true)
Future<SavedParticipantsCache> savedParticipantsCache(Ref ref) =>
    SavedParticipantsCache.create();

/// Exposes the runtime app configuration (legal doc versions, future feature
/// flags) to the rest of the app. Loaded once on first read and cached
/// in-memory by the repository; [refresh] drops the cache and re-reads.
/// Falls back to [AppConfig.fallback] when the read fails so the legal gate
/// still works offline (the user accepts v1, the next online read may bump
/// the version and re-prompt).
@Riverpod(keepAlive: true)
class AppConfigNotifier extends _$AppConfigNotifier {
  @override
  Future<AppConfig> build() async {
    final repo = ref.watch(appConfigRepositoryProvider);
    final result = await repo.getConfig();
    return switch (result) {
      Success(:final data) => data,
      ResultFailure() => AppConfig.fallback,
    };
  }

  /// Drops the in-memory cache in the repository and rebuilds this notifier
  /// so subsequent reads of [appConfigProvider] see the latest server state.
  Future<void> refresh() async {
    ref.read(appConfigRepositoryProvider).invalidate();
    ref.invalidateSelf();
    await future;
  }
}

@Riverpod(keepAlive: true)
IImagePicker imagePicker(Ref ref) => ImagePickerAdapter(ImagePicker());

@Riverpod(keepAlive: true)
Future<HistoryPlusBannerPreferences> historyPlusBannerPreferences(Ref ref) =>
    HistoryPlusBannerPreferences.create();

@Riverpod(keepAlive: true)
Future<PendingRegistrationPreferences> pendingRegistrationPreferences(Ref ref) =>
    PendingRegistrationPreferences.create();
