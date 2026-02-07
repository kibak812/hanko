import 'package:flutter_test/flutter_test.dart';
import 'package:hanko_hanko/core/utils/formatters.dart';

void main() {
  group('formatDuration', () {
    test('0 이하 입력 시 빈 문자열 반환', () {
      expect(formatDuration(0), '');
      expect(formatDuration(-1), '');
      expect(formatDuration(-100), '');
    });

    test('초만 있는 경우', () {
      expect(formatDuration(1), '1초');
      expect(formatDuration(30), '30초');
      expect(formatDuration(59), '59초');
    });

    test('분만 있는 경우', () {
      expect(formatDuration(60), '1분');
      expect(formatDuration(120), '2분');
    });

    test('분과 초 조합', () {
      expect(formatDuration(90), '1분 30초');
      expect(formatDuration(61), '1분 1초');
    });

    test('시간만 있는 경우', () {
      expect(formatDuration(3600), '1시간');
      expect(formatDuration(7200), '2시간');
    });

    test('시간, 분, 초 모두 포함', () {
      expect(formatDuration(3661), '1시간 1분 1초');
      expect(formatDuration(9015), '2시간 30분 15초');
    });

    test('시간과 초만 있는 경우 (분 0)', () {
      expect(formatDuration(3601), '1시간 1초');
    });

    test('시간과 분만 있는 경우 (초 0)', () {
      expect(formatDuration(3660), '1시간 1분');
    });
  });

  group('formatDateFull', () {
    test('yyyy/M/d 형식으로 반환', () {
      expect(formatDateFull(DateTime(2025, 6, 15)), '2025/6/15');
      expect(formatDateFull(DateTime(2025, 12, 1)), '2025/12/1');
      expect(formatDateFull(DateTime(2024, 1, 31)), '2024/1/31');
    });
  });

  group('formatDateCompact', () {
    test('올해 날짜는 M/d 형식', () {
      final now = DateTime.now();
      final sameYear = DateTime(now.year, 3, 5);
      expect(formatDateCompact(sameYear), '3/5');
    });

    test('다른 해 날짜는 yy년 M/d 형식', () {
      final now = DateTime.now();
      final differentYear = DateTime(now.year - 1, 12, 25);
      final yy = (now.year - 1) % 100;
      final yyStr = yy.toString().padLeft(2, '0');
      expect(formatDateCompact(differentYear), '$yyStr년 12/25');
    });

    test('먼 과거 날짜', () {
      final old = DateTime(2020, 1, 1);
      expect(formatDateCompact(old), '20년 1/1');
    });
  });
}
