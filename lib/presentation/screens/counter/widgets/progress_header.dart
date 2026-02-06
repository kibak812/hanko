import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../widgets/progress_indicator_bar.dart';
import '../../../widgets/widget_extensions.dart';

/// 상단 진행률 헤더
/// 프로젝트명 + 진행률 바
/// - 탭: 프로젝트 목록으로 이동
/// - 롱프레스: 인라인 편집기 표시
class ProgressHeader extends StatelessWidget {
  final String projectName;
  final int currentRow;
  final int? targetRow;
  final double progress;
  final VoidCallback? onTap;
  final void Function(Rect sourceRect)? onLongPress;

  const ProgressHeader({
    super.key,
    required this.projectName,
    required this.currentRow,
    this.targetRow,
    required this.progress,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress != null
          ? () => onLongPress!(context.getWidgetRect())
          : null,
      child: Container(
        padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      projectName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: context.textPrimary,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    Icons.menu,
                    color: context.textSecondary,
                  ),
                ],
              ),
            ),
            if (targetRow != null) ...[
              const SizedBox(height: 8),
              ProgressIndicatorBar(
                progress: progress,
                currentRow: currentRow,
                targetRow: targetRow!,
                backgroundColor: context.border,
                textColor: context.textSecondary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
