import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// 보조 액션 버튼 행
/// -1, 리셋, 음성, 더보기
class ActionButtons extends StatelessWidget {
  final VoidCallback onDecrement;
  final VoidCallback? onUndo;
  final VoidCallback onVoice;
  final VoidCallback onMore;
  final bool isListening;

  const ActionButtons({
    super.key,
    required this.onDecrement,
    this.onUndo,
    required this.onVoice,
    required this.onMore,
    this.isListening = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ActionButton(
          icon: Icons.remove,
          onPressed: onDecrement,
          isDark: isDark,
        ),
        const SizedBox(width: 12),
        _ActionButton(
          icon: Icons.undo,
          onPressed: onUndo,
          isDark: isDark,
          enabled: onUndo != null,
        ),
        const SizedBox(width: 12),
        _VoiceButton(
          onPressed: onVoice,
          isListening: isListening,
          isDark: isDark,
        ),
        const SizedBox(width: 12),
        _ActionButton(
          icon: Icons.more_horiz,
          onPressed: onMore,
          isDark: isDark,
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
    final color = enabled
        ? (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)
        : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary)
            .withValues(alpha: 0.3);

    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }
}

class _VoiceButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isListening;
  final bool isDark;

  const _VoiceButton({
    required this.onPressed,
    required this.isListening,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isListening
              ? AppColors.primary
              : (isDark ? AppColors.surfaceDark : Colors.white),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isListening
                ? AppColors.primary
                : (isDark ? AppColors.borderDark : AppColors.border),
          ),
        ),
        child: Icon(
          isListening ? Icons.mic : Icons.mic_none,
          color: isListening
              ? Colors.white
              : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary),
          size: 24,
        ),
      ),
    );
  }
}
