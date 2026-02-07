import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hanko_hanko/data/models/app_settings.dart';
import 'package:hanko_hanko/presentation/providers/app_providers.dart';
import '../../helpers/mocks.dart';

void main() {
  setUpAll(() {
    registerFallbacks();
  });

  // ============================================================
  // AppSettingsNotifier
  // ============================================================

  group('AppSettingsNotifier', () {
    late MockLocalStorage mockStorage;

    setUp(() {
      mockStorage = MockLocalStorage();
    });

    AppSettingsNotifier createNotifier({AppSettings? initial}) {
      when(() => mockStorage.loadSettings())
          .thenReturn(initial ?? AppSettings());
      when(() => mockStorage.saveSettings(any()))
          .thenAnswer((_) async => true);
      return AppSettingsNotifier(mockStorage);
    }

    test('초기 상태: localStorage.loadSettings()에서 로드', () {
      final settings = AppSettings(
        hapticFeedback: false,
        voiceFeedback: false,
        keepScreenOn: false,
        themeMode: 'dark',
      );
      final notifier = createNotifier(initial: settings);

      expect(notifier.state.hapticFeedback, false);
      expect(notifier.state.voiceFeedback, false);
      expect(notifier.state.keepScreenOn, false);
      expect(notifier.state.themeMode, 'dark');
    });

    test('초기 상태: 기본값 확인', () {
      final notifier = createNotifier();

      expect(notifier.state.hapticFeedback, true);
      expect(notifier.state.voiceFeedback, true);
      expect(notifier.state.keepScreenOn, true);
      expect(notifier.state.themeMode, 'light');
    });

    test('setHapticFeedback(false): 상태 업데이트 및 저장', () {
      final notifier = createNotifier();

      notifier.setHapticFeedback(false);

      expect(notifier.state.hapticFeedback, false);
      // 다른 설정은 유지
      expect(notifier.state.voiceFeedback, true);
      expect(notifier.state.keepScreenOn, true);
      expect(notifier.state.themeMode, 'light');

      verify(() => mockStorage.saveSettings(any())).called(1);
    });

    test('setVoiceFeedback(false): 상태 업데이트 및 저장', () {
      final notifier = createNotifier();

      notifier.setVoiceFeedback(false);

      expect(notifier.state.voiceFeedback, false);
      expect(notifier.state.hapticFeedback, true);

      verify(() => mockStorage.saveSettings(any())).called(1);
    });

    test('setKeepScreenOn(false): 상태 업데이트 및 저장', () {
      final notifier = createNotifier();

      notifier.setKeepScreenOn(false);

      expect(notifier.state.keepScreenOn, false);
      expect(notifier.state.hapticFeedback, true);

      verify(() => mockStorage.saveSettings(any())).called(1);
    });

    test('setThemeMode("dark"): 상태 업데이트 및 저장', () {
      final notifier = createNotifier();

      notifier.setThemeMode('dark');

      expect(notifier.state.themeMode, 'dark');
      expect(notifier.state.hapticFeedback, true);

      verify(() => mockStorage.saveSettings(any())).called(1);
    });

    test('setThemeMode("system"): 시스템 모드로 변경', () {
      final notifier = createNotifier();

      notifier.setThemeMode('system');

      expect(notifier.state.themeMode, 'system');
      verify(() => mockStorage.saveSettings(any())).called(1);
    });

    test('여러 설정 연속 변경 시 각각 저장됨', () {
      final notifier = createNotifier();

      notifier.setHapticFeedback(false);
      notifier.setVoiceFeedback(false);
      notifier.setKeepScreenOn(false);

      expect(notifier.state.hapticFeedback, false);
      expect(notifier.state.voiceFeedback, false);
      expect(notifier.state.keepScreenOn, false);

      verify(() => mockStorage.saveSettings(any())).called(3);
    });
  });

  // ============================================================
  // VoiceUsageNotifier
  // ============================================================

  group('VoiceUsageNotifier', () {
    test('초기 상태: adInterval(5)', () {
      final notifier = VoiceUsageNotifier();
      expect(notifier.state, 5);
    });

    test('decrementCounter(): 1씩 감소', () {
      final notifier = VoiceUsageNotifier();

      notifier.decrementCounter();
      expect(notifier.state, 4);

      notifier.decrementCounter();
      expect(notifier.state, 3);
    });

    test('decrementCounter(): 0에서 더 감소하지 않음', () {
      final notifier = VoiceUsageNotifier();

      // 5회 감소 -> 0
      for (var i = 0; i < 5; i++) {
        notifier.decrementCounter();
      }
      expect(notifier.state, 0);

      // 추가 감소 시도
      notifier.decrementCounter();
      expect(notifier.state, 0);
    });

    test('shouldShowAd: 0일 때만 true', () {
      final notifier = VoiceUsageNotifier();

      expect(notifier.shouldShowAd, false);

      // 0까지 감소
      for (var i = 0; i < 5; i++) {
        notifier.decrementCounter();
      }

      expect(notifier.shouldShowAd, true);
    });

    test('resetAfterAd(): adInterval로 리셋', () {
      final notifier = VoiceUsageNotifier();

      // 0까지 감소
      for (var i = 0; i < 5; i++) {
        notifier.decrementCounter();
      }
      expect(notifier.state, 0);
      expect(notifier.shouldShowAd, true);

      notifier.resetAfterAd();

      expect(notifier.state, 5);
      expect(notifier.shouldShowAd, false);
    });

    test('전체 사이클: 감소 -> 광고 -> 리셋 -> 감소', () {
      final notifier = VoiceUsageNotifier();

      // 첫 사이클
      for (var i = 0; i < 5; i++) {
        notifier.decrementCounter();
      }
      expect(notifier.shouldShowAd, true);

      notifier.resetAfterAd();
      expect(notifier.state, 5);

      // 두 번째 사이클
      notifier.decrementCounter();
      expect(notifier.state, 4);
      expect(notifier.shouldShowAd, false);
    });
  });

  // ============================================================
  // InterstitialAdController
  // ============================================================

  group('InterstitialAdController', () {
    late MockAdService mockAdService;
    late MockLocalStorage mockStorage;

    setUp(() {
      mockAdService = MockAdService();
      mockStorage = MockLocalStorage();
    });

    test('tryShowAd(): canShowAd가 false면 광고 미표시', () async {
      when(() => mockStorage.canShowAd()).thenReturn(false);

      final controller = InterstitialAdController(mockAdService, mockStorage);
      final result = await controller.tryShowAd();

      expect(result, false);
      verifyNever(() => mockAdService.showInterstitialAd());
    });

    test('tryShowAd(): 광고 표시 성공 시 카운트/시간 기록', () async {
      when(() => mockStorage.canShowAd()).thenReturn(true);
      when(() => mockAdService.showInterstitialAd())
          .thenAnswer((_) async => true);
      when(() => mockStorage.incrementAdCount())
          .thenAnswer((_) async => true);
      when(() => mockStorage.setLastAdTime(any()))
          .thenAnswer((_) async => true);

      final controller = InterstitialAdController(mockAdService, mockStorage);
      final result = await controller.tryShowAd();

      expect(result, true);
      verify(() => mockStorage.incrementAdCount()).called(1);
      verify(() => mockStorage.setLastAdTime(any())).called(1);
    });

    test('tryShowAd(): 광고 표시 실패 시 카운트/시간 미기록', () async {
      when(() => mockStorage.canShowAd()).thenReturn(true);
      when(() => mockAdService.showInterstitialAd())
          .thenAnswer((_) async => false);

      final controller = InterstitialAdController(mockAdService, mockStorage);
      final result = await controller.tryShowAd();

      expect(result, false);
      verifyNever(() => mockStorage.incrementAdCount());
      verifyNever(() => mockStorage.setLastAdTime(any()));
    });
  });
}
