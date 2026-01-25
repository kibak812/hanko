import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/voice_commands.dart';
import '../../domain/services/voice_service.dart';
import 'app_providers.dart';
import 'project_provider.dart';

/// Voice Service Provider
final voiceServiceProvider = Provider<VoiceService>((ref) {
  final service = VoiceService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Voice State
enum VoiceState {
  idle,
  listening,
  processing,
  speaking,
  error,
}

/// Voice State Notifier
final voiceStateProvider =
    StateNotifierProvider<VoiceStateNotifier, VoiceState>((ref) {
  return VoiceStateNotifier(ref);
});

class VoiceStateNotifier extends StateNotifier<VoiceState> {
  final Ref _ref;
  String? _lastError;
  bool _continuousMode = false; // 연속 듣기 모드

  VoiceStateNotifier(this._ref) : super(VoiceState.idle);

  String? get lastError => _lastError;
  bool get isContinuousMode => _continuousMode;

  /// 음성 명령 시작
  Future<void> startVoiceCommand() async {
    _continuousMode = true;
    await _startListeningInternal();
  }

  /// 내부 음성 인식 시작 (연속 듣기용)
  Future<void> _startListeningInternal() async {
    if (!_continuousMode) return;

    final voiceService = _ref.read(voiceServiceProvider);
    final counterNotifier = _ref.read(activeProjectCounterProvider.notifier);
    final counterState = _ref.read(activeProjectCounterProvider);

    state = VoiceState.listening;

    await voiceService.startListening(
      onCommand: (command) async {
        state = VoiceState.processing;

        // 명령 실행
        await _executeCommand(command, counterNotifier, counterState);

        // 음성 사용 카운터 감소 (5회마다 광고 표시용)
        _ref.read(voiceUsageProvider.notifier).decrementCounter();

        // 연속 모드면 다시 듣기 시작
        if (_continuousMode) {
          await Future.delayed(const Duration(milliseconds: 300));
          await _startListeningInternal();
        } else {
          state = VoiceState.idle;
        }
      },
      onPartialResult: (text) {
        // 부분 결과는 UI에서 표시 가능
      },
      onDone: () {
        // 연속 모드면 다시 시작
        if (_continuousMode) {
          // onCommand에서 이미 처리 중이면 (processing/speaking) 건너뜀
          if (state == VoiceState.processing || state == VoiceState.speaking) {
            return;
          }
          // 타임아웃이나 에러로 종료된 경우 다시 시작
          state = VoiceState.listening;
          Future.delayed(const Duration(milliseconds: 300), () {
            _startListeningInternal();
          });
        } else if (state == VoiceState.listening) {
          state = VoiceState.idle;
        }
      },
      onError: (error) {
        _lastError = error;
        // 에러가 발생해도 연속 모드면 다시 시도
        if (_continuousMode) {
          state = VoiceState.listening;
          Future.delayed(const Duration(milliseconds: 500), () {
            _startListeningInternal();
          });
        } else {
          state = VoiceState.error;
        }
      },
    );
  }

  /// 음성 인식 중지
  Future<void> stopVoiceCommand() async {
    _continuousMode = false; // 연속 모드 해제
    final voiceService = _ref.read(voiceServiceProvider);
    await voiceService.stopListening();
    state = VoiceState.idle;
  }

  /// 명령 실행
  Future<void> _executeCommand(
    VoiceCommandType command,
    ActiveProjectCounterNotifier notifier,
    ProjectCounterState counterState,
  ) async {
    switch (command) {
      case VoiceCommandType.nextRow:
        notifier.incrementRow();
        break;
      case VoiceCommandType.prevRow:
        notifier.decrementRow();
        break;
      case VoiceCommandType.nextStitch:
        notifier.incrementStitch();
        break;
      case VoiceCommandType.prevStitch:
        notifier.decrementStitch();
        break;
      case VoiceCommandType.resetStitch:
        notifier.resetStitch();
        break;
      case VoiceCommandType.resetPattern:
        notifier.resetPattern();
        break;
      case VoiceCommandType.undo:
        notifier.undo();
        break;
      case VoiceCommandType.status:
        // 상태만 읽어주기 (카운터 변경 없음)
        break;
    }
  }

  void clearError() {
    _lastError = null;
    state = VoiceState.idle;
  }
}
