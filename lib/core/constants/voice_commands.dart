/// 한코한코 음성 명령어 정의
/// 한국어 음성 인식을 위한 명령어 매핑
class VoiceCommands {
  VoiceCommands._();

  /// 단 증가 명령어
  static const List<String> nextRow = [
    '다음',
    '플러스',
    '다음 단',
    '하나',
    '하나 더',
    '증가',
  ];

  /// 단 감소 명령어
  static const List<String> prevRow = [
    '이전',
    '마이너스',
    '이전 단',
    '하나 빼',
    '감소',
    '뒤로',
  ];

  /// 코 증가 명령어
  static const List<String> nextStitch = [
    '코 다음',
    '코 플러스',
    '코 하나',
    '코 증가',
  ];

  /// 코 감소 명령어
  static const List<String> prevStitch = [
    '코 이전',
    '코 마이너스',
    '코 하나 빼',
    '코 감소',
  ];

  /// 현재 상태 확인 명령어
  static const List<String> status = [
    '지금 몇 단',
    '현재',
    '몇 단',
    '상태',
    '지금',
  ];

  /// 코 카운터 리셋 명령어
  static const List<String> resetStitch = [
    '리셋',
    '처음',
    '코 리셋',
    '코 처음',
    '초기화',
  ];

  /// 패턴 반복 리셋 명령어
  static const List<String> resetPattern = [
    '패턴 리셋',
    '반복 리셋',
    '패턴 처음',
  ];

  /// 되돌리기 명령어
  static const List<String> undo = [
    '취소',
    '되돌리기',
    '실수',
    '아 잠깐',
  ];

  /// 음성 명령 타입
  static VoiceCommandType? parseCommand(String input) {
    final normalized = input.toLowerCase().trim();

    // 순서 중요: 더 구체적인 명령어를 먼저 체크
    if (_matchesAny(normalized, nextStitch)) {
      return VoiceCommandType.nextStitch;
    }
    if (_matchesAny(normalized, prevStitch)) {
      return VoiceCommandType.prevStitch;
    }
    if (_matchesAny(normalized, resetStitch)) {
      return VoiceCommandType.resetStitch;
    }
    if (_matchesAny(normalized, resetPattern)) {
      return VoiceCommandType.resetPattern;
    }
    if (_matchesAny(normalized, status)) {
      return VoiceCommandType.status;
    }
    if (_matchesAny(normalized, undo)) {
      return VoiceCommandType.undo;
    }
    if (_matchesAny(normalized, nextRow)) {
      return VoiceCommandType.nextRow;
    }
    if (_matchesAny(normalized, prevRow)) {
      return VoiceCommandType.prevRow;
    }

    return null;
  }

  static bool _matchesAny(String input, List<String> commands) {
    for (final cmd in commands) {
      if (input.contains(cmd)) {
        return true;
      }
    }
    return false;
  }
}

/// 음성 명령 타입
enum VoiceCommandType {
  nextRow,
  prevRow,
  nextStitch,
  prevStitch,
  status,
  resetStitch,
  resetPattern,
  undo,
}
