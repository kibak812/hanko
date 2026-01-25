import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/local_storage.dart';
import '../../data/datasources/objectbox_database.dart';
import '../../data/repositories/project_repository.dart';
import '../../domain/services/ad_service.dart';

/// SharedPreferences Provider
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized');
});

/// ObjectBox Database Provider
final objectBoxDatabaseProvider = Provider<ObjectBoxDatabase>((ref) {
  throw UnimplementedError('ObjectBoxDatabase must be initialized');
});

/// Local Storage Provider
final localStorageProvider = Provider<LocalStorage>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocalStorage(prefs);
});

/// Project Repository Provider
final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  final db = ref.watch(objectBoxDatabaseProvider);
  return ProjectRepository(db);
});

/// AdService Provider
final adServiceProvider = Provider<AdService>((ref) {
  throw UnimplementedError('AdService must be initialized');
});

/// 전면 광고 표시 컨트롤러
class InterstitialAdController {
  final AdService _adService;
  final LocalStorage _localStorage;

  InterstitialAdController(this._adService, this._localStorage);

  /// 전면 광고 표시 시도 (빈도 제어 적용)
  Future<bool> tryShowAd() async {
    if (!_localStorage.canShowAd()) return false;
    final shown = await _adService.showInterstitialAd();
    if (shown) {
      await _localStorage.incrementAdCount();
      await _localStorage.setLastAdTime(DateTime.now());
    }
    return shown;
  }
}

/// 전면 광고 컨트롤러 Provider
final interstitialAdControllerProvider = Provider<InterstitialAdController>((ref) {
  return InterstitialAdController(
    ref.read(adServiceProvider),
    ref.read(localStorageProvider),
  );
});

/// App Settings Provider
final appSettingsProvider =
    StateNotifierProvider<AppSettingsNotifier, AppSettings>((ref) {
  final localStorage = ref.watch(localStorageProvider);
  return AppSettingsNotifier(localStorage);
});

class AppSettingsNotifier extends StateNotifier<AppSettings> {
  final LocalStorage _localStorage;

  AppSettingsNotifier(this._localStorage) : super(_localStorage.loadSettings());

  void setHapticFeedback(bool value) {
    state = state.copyWith(hapticFeedback: value);
    _localStorage.saveSettings(state);
  }

  void setVoiceFeedback(bool value) {
    state = state.copyWith(voiceFeedback: value);
    _localStorage.saveSettings(state);
  }

  void setKeepScreenOn(bool value) {
    state = state.copyWith(keepScreenOn: value);
    _localStorage.saveSettings(state);
  }

  void setThemeMode(String value) {
    state = state.copyWith(themeMode: value);
    _localStorage.saveSettings(state);
  }
}

/// 음성 사용량 Provider (5회마다 리워드 광고)
/// state: 다음 광고까지 남은 음성 사용 횟수 (5~0)
final voiceUsageProvider =
    StateNotifierProvider<VoiceUsageNotifier, int>((ref) {
  return VoiceUsageNotifier();
});

class VoiceUsageNotifier extends StateNotifier<int> {
  static const int adInterval = 5; // 5회마다 광고

  VoiceUsageNotifier() : super(adInterval);

  /// 음성 사용 후 호출 - 카운터 감소
  /// 0이 되면 광고 표시 필요
  void decrementCounter() {
    if (state > 0) {
      state = state - 1;
    }
  }

  /// 광고 표시 후 호출 - 카운터 리셋
  void resetAfterAd() {
    state = adInterval;
  }

  /// 광고 표시 필요 여부
  bool get shouldShowAd => state == 0;
}

/// 온보딩 완료 여부 Provider
final onboardingCompletedProvider = StateProvider<bool>((ref) {
  final localStorage = ref.watch(localStorageProvider);
  return localStorage.isOnboardingCompleted();
});
