import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// 메인 카운터 숫자 표시 위젯
/// 96px 거대한 숫자로 3m 거리에서도 읽기 가능
/// 인라인 +/- 버튼으로 조작
class CounterDisplay extends StatelessWidget {
  final int value;
  final String label;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const CounterDisplay({
    super.key,
    required this.value,
    required this.label,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(32),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: AppColors.textPrimary.withAlpha(20),
                  offset: const Offset(0, 4),
                  blurRadius: 24,
                ),
                BoxShadow(
                  color: AppColors.textPrimary.withAlpha(10),
                  offset: const Offset(0, 1),
                  blurRadius: 4,
                ),
              ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 상단 영역 (70%): 숫자 + 라벨
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
            child: Column(
              children: [
                // 숫자 (한 줄로 표시, 자동 축소)
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.5),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                        )),
                        child: FadeTransition(
                          opacity: animation,
                          child: child,
                        ),
                      );
                    },
                    child: Text(
                      '$value',
                      key: ValueKey(value),
                      style: TextStyle(
                        fontSize: 96,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // 구분선
          Divider(
            height: 1,
            thickness: 1,
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),

          // 하단 영역 (30%): -/+ 버튼 좌우 분할
          IntrinsicHeight(
            child: Row(
              children: [
                // - 버튼 (왼쪽 절반)
                Expanded(
                  child: _LargeAreaButton(
                    icon: Icons.remove,
                    onPressed: value > 0 ? onDecrement : null,
                    isDark: isDark,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(32),
                    ),
                  ),
                ),

                // 세로 구분선
                VerticalDivider(
                  width: 1,
                  thickness: 1,
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),

                // + 버튼 (오른쪽 절반)
                Expanded(
                  child: _LargeAreaButton(
                    icon: Icons.add,
                    onPressed: onIncrement,
                    isDark: isDark,
                    borderRadius: const BorderRadius.only(
                      bottomRight: Radius.circular(32),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 메인 카운터 하단 영역 버튼 (넓은 터치 영역)
class _LargeAreaButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final bool isDark;
  final BorderRadius borderRadius;

  const _LargeAreaButton({
    required this.icon,
    required this.onPressed,
    required this.isDark,
    required this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: borderRadius,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 32,
            color: enabled
                ? textSecondary.withAlpha(180)
                : textSecondary.withAlpha(77),
          ),
        ),
      ),
    );
  }
}
