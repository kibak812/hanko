import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/row_memo.dart';

/// 메모 카드 위젯
/// 현재 단에 해당하는 메모를 표시
class MemoCard extends StatelessWidget {
  final RowMemo memo;

  const MemoCard({
    super.key,
    required this.memo,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    // 배경과 구분되는 메모 카드 배경 (좀 더 진한 톤)
    final backgroundColor = isDark
        ? const Color(0xFF3A3526)
        : const Color(0xFFFFF3D4);
    final borderColor = isDark
        ? const Color(0xFFD4A84B)
        : const Color(0xFFDCC99A);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.3)
                : const Color(0xFFD4C4A8).withValues(alpha: 0.4),
            offset: const Offset(0, 2),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            Icons.push_pin_outlined,
            size: 20,
            color: isDark ? const Color(0xFFD4A84B) : const Color(0xFFB8956E),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              memo.content,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
