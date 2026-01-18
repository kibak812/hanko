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

  bool get isInitialized => _isInitialized;
  bool get isListening => _isListening;

  /// 음성 서비스 초기화
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      // STT 초기화
      final sttAvailable = await _speechToText.initialize(
        onError: (error) => print('STT Error: $error'),
        onStatus: (status) => print('STT Status: $status'),
      );

      if (!sttAvailable) {
        print('Speech-to-Text is not available on this device');
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
      print('Voice service initialization failed: $e');
      return false;
    }
  }

  /// 음성 인식 시작
  Future<void> startListening({
    required Function(VoiceCommandType command) onCommand,
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

      await _speechToText.listen(
        onResult: (result) {
          final text = result.recognizedWords;

          if (text.isEmpty) return;

          // 부분 결과 콜백
          onPartialResult(text);

          // 명령어 파싱
          if (result.finalResult) {
            final command = VoiceCommands.parseCommand(text);
            if (command != null) {
              onCommand(command);
            }
            _isListening = false;
            onDone();
          }
        },
        localeId: 'ko-KR',
        listenMode: ListenMode.confirmation,
        cancelOnError: true,
        partialResults: true,
      );
    } catch (e) {
      _isListening = false;
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
    await speak('$count$unit');
  }

  /// 현재 상태 음성으로 알려주기
  Future<void> announceStatus(int row, int? stitch) async {
    String message = '현재 $row단';
    if (stitch != null && stitch > 0) {
      message += ' $stitch코';
    }
    message += '입니다';
    await speak(message);
  }

  /// 리셋 음성 알림
  Future<void> announceReset(String counterType) async {
    await speak('$counterType 리셋');
  }

  /// 목표 달성 축하
  Future<void> announceMilestone(int row) async {
    await speak('$row단 달성! 잘하고 있어요');
  }

  /// 리소스 해제
  void dispose() {
    _speechToText.cancel();
    _flutterTts.stop();
    _isInitialized = false;
    _isListening = false;
  }
}
