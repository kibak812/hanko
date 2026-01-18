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

  VoiceStateNotifier(this._ref) : super(VoiceState.idle);

  String? get lastError => _lastError;

  /// 음성 명령 시작
  Future<void> startVoiceCommand() async {
    final isPremium = _ref.read(premiumStatusProvider);
    final voiceUsage = _ref.read(voiceUsageProvider.notifier);
    final settings = _ref.read(appSettingsProvider);

    // 무료 사용자는 횟수 제한 체크
    if (!isPremium) {
      final remaining = _ref.read(voiceUsageProvider);
      if (remaining <= 0) {
        _lastError = '오늘 음성 사용 횟수를 다 썼어요';
        state = VoiceState.error;
        return;
      }
    }

    final voiceService = _ref.read(voiceServiceProvider);
    final counterNotifier = _ref.read(activeProjectCounterProvider.notifier);
    final counterState = _ref.read(activeProjectCounterProvider);

    state = VoiceState.listening;

    await voiceService.startListening(
      onCommand: (command) async {
        state = VoiceState.processing;

        // 무료 사용자는 횟수 차감
        if (!isPremium) {
          await voiceUsage.useVoice();
        }

        // 명령 실행
        await _executeCommand(command, counterNotifier, counterState);

        // 음성 피드백
        if (settings.voiceFeedback) {
          state = VoiceState.speaking;
          await _speakFeedback(command, counterState);
        }

        state = VoiceState.idle;
      },
      onPartialResult: (text) {
        // 부분 결과는 UI에서 표시 가능
      },
      onDone: () {
        if (state == VoiceState.listening) {
          state = VoiceState.idle;
        }
      },
      onError: (error) {
        _lastError = error;
        state = VoiceState.error;
      },
    );
  }

  /// 음성 인식 중지
  Future<void> stopVoiceCommand() async {
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

  /// 음성 피드백
  Future<void> _speakFeedback(
    VoiceCommandType command,
    ProjectCounterState counterState,
  ) async {
    final voiceService = _ref.read(voiceServiceProvider);
    final newState = _ref.read(activeProjectCounterProvider);

    switch (command) {
      case VoiceCommandType.nextRow:
      case VoiceCommandType.prevRow:
      case VoiceCommandType.undo:
        await voiceService.announceCount(newState.currentRow, '단');
        break;
      case VoiceCommandType.nextStitch:
      case VoiceCommandType.prevStitch:
        await voiceService.announceCount(newState.currentStitch, '코');
        break;
      case VoiceCommandType.resetStitch:
        await voiceService.announceReset('코');
        break;
      case VoiceCommandType.resetPattern:
        await voiceService.announceReset('패턴');
        break;
      case VoiceCommandType.status:
        await voiceService.announceStatus(
          newState.currentRow,
          newState.currentStitch > 0 ? newState.currentStitch : null,
        );
        break;
    }
  }

  void clearError() {
    _lastError = null;
    state = VoiceState.idle;
  }
}
