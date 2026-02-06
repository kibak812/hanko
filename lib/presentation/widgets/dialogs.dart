import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

/// 카운터 제거 확인 다이얼로그
/// 사용자가 '제거'를 선택하면 true, '취소'를 선택하면 false 반환
Future<bool> showRemoveCounterDialog(BuildContext context) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text(AppStrings.removeCounter),
      content: const Text(AppStrings.removeCounterConfirm),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text(AppStrings.cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(
            foregroundColor: AppColors.error,
          ),
          child: const Text(AppStrings.remove),
        ),
      ],
    ),
  );
  return result ?? false;
}
