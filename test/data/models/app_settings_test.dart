import 'package:flutter_test/flutter_test.dart';
import 'package:hanko_hanko/data/models/app_settings.dart';

void main() {
  group('AppSettings - toJson / fromJson', () {
    test('모든 필드 왕복 변환', () {
      final settings = AppSettings(
        hapticFeedback: false,
        voiceFeedback: false,
        keepScreenOn: false,
        themeMode: 'dark',
      );

      final json = settings.toJson();
      final restored = AppSettings.fromJson(json);

      expect(restored.hapticFeedback, false);
      expect(restored.voiceFeedback, false);
      expect(restored.keepScreenOn, false);
      expect(restored.themeMode, 'dark');
    });

    test('기본값 왕복 변환', () {
      final settings = AppSettings();
      final json = settings.toJson();
      final restored = AppSettings.fromJson(json);

      expect(restored.hapticFeedback, true);
      expect(restored.voiceFeedback, true);
      expect(restored.keepScreenOn, true);
      expect(restored.themeMode, 'light');
    });
  });

  group('AppSettings - fromJson 기본값 처리', () {
    test('빈 Map이면 모든 기본값 사용', () {
      final settings = AppSettings.fromJson({});

      expect(settings.hapticFeedback, true);
      expect(settings.voiceFeedback, true);
      expect(settings.keepScreenOn, true);
      expect(settings.themeMode, 'light');
    });

    test('일부 필드만 있으면 나머지는 기본값', () {
      final settings = AppSettings.fromJson({
        'hapticFeedback': false,
        'themeMode': 'dark',
      });

      expect(settings.hapticFeedback, false);
      expect(settings.voiceFeedback, true); // 기본값
      expect(settings.keepScreenOn, true); // 기본값
      expect(settings.themeMode, 'dark');
    });
  });

  group('AppSettings - copyWith', () {
    test('일부 필드만 변경', () {
      final original = AppSettings();
      final copied = original.copyWith(themeMode: 'dark');

      expect(copied.hapticFeedback, true); // 변경 안 됨
      expect(copied.voiceFeedback, true); // 변경 안 됨
      expect(copied.keepScreenOn, true); // 변경 안 됨
      expect(copied.themeMode, 'dark'); // 변경됨
    });

    test('모든 필드 변경', () {
      final original = AppSettings();
      final copied = original.copyWith(
        hapticFeedback: false,
        voiceFeedback: false,
        keepScreenOn: false,
        themeMode: 'system',
      );

      expect(copied.hapticFeedback, false);
      expect(copied.voiceFeedback, false);
      expect(copied.keepScreenOn, false);
      expect(copied.themeMode, 'system');
    });

    test('아무 필드도 변경하지 않으면 원본과 동일', () {
      final original = AppSettings(
        hapticFeedback: false,
        themeMode: 'dark',
      );
      final copied = original.copyWith();

      expect(copied.hapticFeedback, original.hapticFeedback);
      expect(copied.voiceFeedback, original.voiceFeedback);
      expect(copied.keepScreenOn, original.keepScreenOn);
      expect(copied.themeMode, original.themeMode);
    });
  });
}
