import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// 보조 액션 버튼 행
/// 되돌리기, 메모, 타이머, 음성, 설정
class ActionButtons extends StatelessWidget {
  final VoidCallback? onUndo;
  final VoidCallback? onMemo;
  final VoidCallback onTimer;
  final VoidCallback? onTimerLongPress;
  final bool isTimerRunning;
  final VoidCallback onVoice;
  final VoidCallback onSettings;
  final bool isListening;

  const ActionButtons({
    super.key,
    this.onUndo,
    this.onMemo,
    required this.onTimer,
    this.onTimerLongPress,
    this.isTimerRunning = false,
    required this.onVoice,
    required this.onSettings,
    this.isListening = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: _ActionButton(
            icon: Icons.undo,
            onPressed: onUndo,
            enabled: onUndo != null,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: _ActionButton(
            icon: Icons.sticky_note_2_outlined,
            onPressed: onMemo,
            enabled: onMemo != null,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: _ToggleActionButton(
            onPressed: onTimer,
            onLongPress: onTimerLongPress,
            isActive: isTimerRunning,
            activeIcon: Icons.timer,
            inactiveIcon: Icons.timer_outlined,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: _ToggleActionButton(
            onPressed: onVoice,
            isActive: isListening,
            activeIcon: Icons.mic,
            inactiveIcon: Icons.mic_none,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: _SettingsButton(
            onPressed: onSettings,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool enabled;

  const _ActionButton({
    required this.icon,
    required this.onPressed,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = context.textSecondary;
    final color = enabled ? baseColor : baseColor.withValues(alpha: 0.3);

    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 48, maxHeight: 48),
          decoration: BoxDecoration(
            color: context.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: context.border,
            ),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }
}

class _ToggleActionButton extends StatelessWidget {
  final VoidCallback onPressed;
  final VoidCallback? onLongPress;
  final bool isActive;
  final IconData activeIcon;
  final IconData inactiveIcon;

  const _ToggleActionButton({
    required this.onPressed,
    this.onLongPress,
    required this.isActive,
    required this.activeIcon,
    required this.inactiveIcon,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isActive
        ? AppColors.primary
        : context.surface;
    final borderColor = isActive
        ? AppColors.primary
        : context.border;
    final iconColor = isActive
        ? Colors.white
        : context.textSecondary;

    return GestureDetector(
      onTap: onPressed,
      onLongPress: onLongPress,
      child: AspectRatio(
        aspectRatio: 1,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          constraints: const BoxConstraints(maxWidth: 48, maxHeight: 48),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          child: Icon(
            isActive ? activeIcon : inactiveIcon,
            color: iconColor,
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _SettingsButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _SettingsButton({
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = context.textSecondary;

    return GestureDetector(
      onTap: onPressed,
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 48, maxHeight: 48),
          decoration: BoxDecoration(
            color: context.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: context.border,
            ),
          ),
          child: Icon(
            Icons.settings,
            color: textColor,
            size: 22,
          ),
        ),
      ),
    );
  }
}
