import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../../core/constants/voice_commands.dart';

/// 음성 서비스
/// STT (Speech-to-Text) + TTS (Text-to-Speech) 통합
class VoiceService {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  bool _isInitialized = false;
  bool _isListening = false;

  // 현재 세션의 콜백 저장 (글로벌 핸들러에서 사용)
  Function()? _currentOnDone;
  Function(String)? _currentOnError;

  bool get isInitialized => _isInitialized;
  bool get isListening => _isListening;

  /// 음성 서비스 초기화
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // STT 초기화
      final sttAvailable = await _speechToText.initialize(
        onError: (error) {
          // 에러 발생 시 현재 세션의 onError 콜백 호출
          if (_isListening && _currentOnError != null) {
            _isListening = false;
            _currentOnError!(error.errorMsg);
          }
        },
        onStatus: (status) {
          // 'done' 상태에서 onDone 콜백 호출
          if (status == 'done' && _isListening) {
            _isListening = false;
            _currentOnDone?.call();
          }
        },
      );

      if (!sttAvailable) {
        return false;
      }

      // TTS 초기화
      await _flutterTts.setLanguage('ko-KR');
      await _flutterTts.setSpeechRate(0.5); // 조금 빠르게
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      _isInitialized = true;
      return true;
    } catch (e) {
      return false;
    }
  }

  /// 음성 인식 시작
  Future<void> startListening({
    required Future<void> Function(VoiceCommandType command) onCommand,
    required Function(String text) onPartialResult,
    required Function() onDone,
    required Function(String error) onError,
  }) async {
    if (!_isInitialized) {
      final initialized = await initialize();
      if (!initialized) {
        onError('음성 인식을 사용할 수 없어요');
        return;
      }
    }

    if (_isListening) return;

    try {
      _isListening = true;
      bool commandProcessed = false; // 명령어 중복 처리 방지

      // 콜백 저장 (글로벌 핸들러에서 사용)
      _currentOnDone = onDone;
      _currentOnError = onError;

      await _speechToText.listen(
        onResult: (result) async {
          if (commandProcessed) return; // 이미 처리됨

          final text = result.recognizedWords;
          if (text.isEmpty) return;

          // 부분 결과 콜백
          onPartialResult(text);

          // 명령어 파싱 - 부분 결과에서도 명령어 감지 (iOS 대응)
          final command = VoiceCommands.parseCommand(text);

          if (command != null) {
            commandProcessed = true;

            // 인식 중지 후 명령 처리
            await _speechToText.stop();
            _isListening = false;  // stop 후에 false로 설정 (onStatus 'done' 방지)
            await onCommand(command);
            onDone();  // 명령 처리 후 직접 호출하여 연속 모드 재시작
          }
          // finalResult는 무시 - onStatus 'done'에서 처리
        },
        localeId: 'ko-KR',
        listenOptions: SpeechListenOptions(
          listenMode: ListenMode.dictation, // dictation 모드: 더 오래 듣기
          cancelOnError: false,
          partialResults: true,
        ),
        listenFor: const Duration(seconds: 30),  // 30초간 듣기 (끝나면 연속모드에서 자동 재시작)
      );
    } catch (e) {
      _isListening = false;
      _currentOnDone = null;
      _currentOnError = null;
      onError('음성 인식 오류: $e');
    }
  }

  /// 음성 인식 중지
  Future<void> stopListening() async {
    if (!_isListening) return;

    await _speechToText.stop();
    _isListening = false;
  }

  /// 음성 출력 (TTS)
  Future<void> speak(String text) async {
    if (!_isInitialized) {
      await initialize();
    }

    await _flutterTts.speak(text);
  }

  /// 음성 출력 중지
  Future<void> stopSpeaking() async {
    await _flutterTts.stop();
  }

  /// 카운터 값 음성으로 알려주기
  Future<void> announceCount(int count, String unit) async {
    // iOS에서 자연스러운 발음을 위해 한자어 숫자로 변환
    final koreanNumber = _toKoreanNumber(count);
    // iOS에서 발음이 씹히지 않도록 마침표로 pause 추가
    await speak('$koreanNumber. $unit');
  }

  /// 숫자를 한자어 숫자로 변환 (7 → 칠)
  String _toKoreanNumber(int number) {
    if (number == 0) return '영';
    if (number < 0) return '마이너스 ${_toKoreanNumber(-number)}';

    const units = ['', '십', '백', '천'];
    const bigUnits = ['', '만', '억'];
    const digits = ['', '일', '이', '삼', '사', '오', '육', '칠', '팔', '구'];

    if (number < 10) {
      return digits[number];
    }

    String result = '';
    int unitIndex = 0;

    while (number > 0 && unitIndex < bigUnits.length) {
      int part = number % 10000;
      if (part > 0) {
        String partStr = '';
        int smallUnit = 0;
        while (part > 0) {
          int digit = part % 10;
          if (digit > 0) {
            // 십, 백, 천 앞의 1은 생략 (일십 → 십)
            String digitStr = (digit == 1 && smallUnit > 0) ? '' : digits[digit];
            partStr = '$digitStr${units[smallUnit]}$partStr';
          }
          part ~/= 10;
          smallUnit++;
        }
        result = '$partStr${bigUnits[unitIndex]}$result';
      }
      number ~/= 10000;
      unitIndex++;
    }

    return result;
  }

  /// 현재 상태 음성으로 알려주기
  Future<void> announceStatus(int row, int? stitch) async {
    final rowKorean = _toKoreanNumber(row);
    String message = '현재. $rowKorean. 단';
    if (stitch != null && stitch > 0) {
      final stitchKorean = _toKoreanNumber(stitch);
      message += '. $stitchKorean. 코';
    }
    await speak(message);
  }

  /// 리셋 음성 알림
  Future<void> announceReset(String counterType) async {
    await speak('$counterType 리셋');
  }

  /// 목표 달성 축하
  Future<void> announceMilestone(int row) async {
    final rowKorean = _toKoreanNumber(row);
    await speak('$rowKorean 단 달성! 잘하고 있어요');
  }

  /// 리소스 해제
  void dispose() {
    _speechToText.cancel();
    _flutterTts.stop();
    _isInitialized = false;
    _isListening = false;
  }
}
