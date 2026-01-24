import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/datasources/local_storage.dart';
import '../../data/datasources/objectbox_database.dart';
import '../../data/repositories/project_repository.dart';
import '../../domain/services/ad_service.dart';
import '../../domain/services/premium_service.dart';

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

/// PremiumService Provider
final premiumServiceProvider = Provider<PremiumService>((ref) {
  throw UnimplementedError('PremiumService must be initialized');
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
/// 프리미엄 사용자는 null 반환 (광고 없음)
final interstitialAdControllerProvider = Provider<InterstitialAdController?>((ref) {
  final isPremium = ref.watch(premiumStatusProvider);
  if (isPremium) return null;
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

/// Premium Status Provider (RevenueCat 연동)
final premiumStatusProvider =
    StateNotifierProvider<PremiumStatusNotifier, bool>((ref) {
  final localStorage = ref.watch(localStorageProvider);
  final premiumService = ref.watch(premiumServiceProvider);
  return PremiumStatusNotifier(localStorage, premiumService);
});

class PremiumStatusNotifier extends StateNotifier<bool> {
  final LocalStorage _localStorage;
  final PremiumService _premiumService;

  PremiumStatusNotifier(this._localStorage, this._premiumService)
      : super(_localStorage.getCachedPremiumStatus());

  /// RevenueCat에서 실제 구독 상태 동기화
  Future<void> syncWithRevenueCat() async {
    try {
      final isPremium = await _premiumService.isPremium();
      state = isPremium;
      await _localStorage.cachePremiumStatus(isPremium);
    } catch (e) {
      // 오류 시 캐시된 상태 유지 (네트워크 오류 등)
      debugPrint('Failed to sync premium status: $e');
    }
  }

  void setPremium(bool value) {
    state = value;
    _localStorage.cachePremiumStatus(value);
  }

  /// 무료 체험 시작
  Future<void> startFreeTrial() async {
    await _localStorage.setFreeTrialStartDate(DateTime.now());
    state = true;
    await _localStorage.cachePremiumStatus(true);
  }

  /// 무료 체험 종료 체크 및 구독 상태 확인
  Future<void> checkTrialExpiry() async {
    if (!state) return; // 이미 무료 상태면 무시

    // 무료 체험이 끝났으면 RevenueCat에서 실제 구독 상태 확인
    if (_localStorage.isFreeTrialExpired()) {
      await syncWithRevenueCat();
    }
  }
}

/// 음성 사용량 Provider
final voiceUsageProvider =
    StateNotifierProvider<VoiceUsageNotifier, int>((ref) {
  final localStorage = ref.watch(localStorageProvider);
  return VoiceUsageNotifier(localStorage);
});

class VoiceUsageNotifier extends StateNotifier<int> {
  final LocalStorage _localStorage;
  static const int dailyLimit = 5; // 기본 5회, 광고 시청 시 +5회

  VoiceUsageNotifier(this._localStorage)
      : super(_localStorage.getRemainingVoiceCount(dailyLimit: dailyLimit));

  /// 음성 사용
  Future<bool> useVoice() async {
    if (state <= 0) return false;

    await _localStorage.incrementVoiceUsage();
    state = _localStorage.getRemainingVoiceCount(dailyLimit: dailyLimit);
    return true;
  }

  /// 보너스 추가 (광고 시청 후)
  Future<void> addBonus(int count) async {
    await _localStorage.addBonusVoiceUsage(count);
    state = _localStorage.getRemainingVoiceCount(dailyLimit: dailyLimit);
  }

  /// 새로고침
  void refresh() {
    state = _localStorage.getRemainingVoiceCount(dailyLimit: dailyLimit);
  }
}

/// 온보딩 완료 여부 Provider
final onboardingCompletedProvider = StateProvider<bool>((ref) {
  final localStorage = ref.watch(localStorageProvider);
  return localStorage.isOnboardingCompleted();
});
