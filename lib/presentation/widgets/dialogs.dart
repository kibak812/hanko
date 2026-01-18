import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// 카운터 제거 확인 다이얼로그
/// 사용자가 '제거'를 선택하면 true, '취소'를 선택하면 false 반환
Future<bool> showRemoveCounterDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('카운터 제거'),
      content: const Text('이 카운터를 제거할까요?\n현재 값은 사라집니다.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('취소'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.error,
          ),
          child: const Text('제거'),
        ),
      ],
    ),
  );
  return result ?? false;
}
