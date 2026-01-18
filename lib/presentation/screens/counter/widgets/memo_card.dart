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
    // 더 부드러운 베이지/크림 톤 배경
    final backgroundColor = isDark
        ? const Color(0xFF3A3526).withOpacity(0.6)
        : const Color(0xFFFFF8E7);
    final borderColor = isDark
        ? const Color(0xFFD4A84B)
        : const Color(0xFFE8D4A8);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
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
