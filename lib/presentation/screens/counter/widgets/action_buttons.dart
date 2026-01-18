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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: _ActionButton(
            icon: Icons.undo,
            onPressed: onUndo,
            isDark: isDark,
            enabled: onUndo != null,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: _ActionButton(
            icon: Icons.sticky_note_2_outlined,
            onPressed: onMemo,
            isDark: isDark,
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
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: _ToggleActionButton(
            onPressed: onVoice,
            isActive: isListening,
            activeIcon: Icons.mic,
            inactiveIcon: Icons.mic_none,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: _SettingsButton(
            isDark: isDark,
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
  final bool isDark;
  final bool enabled;

  const _ActionButton({
    required this.icon,
    required this.onPressed,
    required this.isDark,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final baseColor = isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final color = enabled ? baseColor : baseColor.withValues(alpha: 0.3);

    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 48, maxHeight: 48),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.border,
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
  final bool isDark;

  const _ToggleActionButton({
    required this.onPressed,
    this.onLongPress,
    required this.isActive,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final backgroundColor = isActive
        ? AppColors.primary
        : (isDark ? AppColors.surfaceDark : Colors.white);
    final borderColor = isActive
        ? AppColors.primary
        : (isDark ? AppColors.borderDark : AppColors.border);
    final iconColor = isActive
        ? Colors.white
        : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary);

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
  final bool isDark;
  final VoidCallback onPressed;

  const _SettingsButton({
    required this.isDark,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final textColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return GestureDetector(
      onTap: onPressed,
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 48, maxHeight: 48),
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.border,
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
