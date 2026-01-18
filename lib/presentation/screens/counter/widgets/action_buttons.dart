import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

/// 더보기 메뉴 항목
enum MoreMenuAction {
  edit,
  projects,
  settings,
}

/// 보조 액션 버튼 행
/// 되돌리기, 메모, 음성, 더보기
class ActionButtons extends StatelessWidget {
  final VoidCallback? onUndo;
  final VoidCallback? onMemo;
  final VoidCallback onVoice;
  final void Function(MoreMenuAction action) onMenuAction;
  final bool isListening;

  const ActionButtons({
    super.key,
    this.onUndo,
    this.onMemo,
    required this.onVoice,
    required this.onMenuAction,
    this.isListening = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ActionButton(
          icon: Icons.undo,
          onPressed: onUndo,
          isDark: isDark,
          enabled: onUndo != null,
        ),
        const SizedBox(width: 12),
        _ActionButton(
          icon: Icons.note_alt_outlined,
          onPressed: onMemo,
          isDark: isDark,
          enabled: onMemo != null,
        ),
        const SizedBox(width: 12),
        _VoiceButton(
          onPressed: onVoice,
          isListening: isListening,
          isDark: isDark,
        ),
        const SizedBox(width: 12),
        _MoreButton(
          isDark: isDark,
          onAction: onMenuAction,
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

class _MoreButton extends StatelessWidget {
  final bool isDark;
  final void Function(MoreMenuAction action) onAction;

  const _MoreButton({
    required this.isDark,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final textColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return PopupMenuButton<MoreMenuAction>(
      onSelected: onAction,
      offset: const Offset(0, -160),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: isDark ? AppColors.surfaceDark : Colors.white,
      itemBuilder: (context) => [
        PopupMenuItem<MoreMenuAction>(
          value: MoreMenuAction.edit,
          child: Row(
            children: [
              Icon(Icons.edit, size: 20, color: textColor),
              const SizedBox(width: 12),
              Text(AppStrings.edit),
            ],
          ),
        ),
        PopupMenuItem<MoreMenuAction>(
          value: MoreMenuAction.projects,
          child: Row(
            children: [
              Icon(Icons.list, size: 20, color: textColor),
              const SizedBox(width: 12),
              Text(AppStrings.myProjects),
            ],
          ),
        ),
        PopupMenuItem<MoreMenuAction>(
          value: MoreMenuAction.settings,
          child: Row(
            children: [
              Icon(Icons.settings, size: 20, color: textColor),
              const SizedBox(width: 12),
              Text(AppStrings.settings),
            ],
          ),
        ),
      ],
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
        child: Icon(
          Icons.more_horiz,
          color: textColor,
          size: 24,
        ),
      ),
    );
  }
}
