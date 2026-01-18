import 'package:flutter/material.dart';

/// 넓은 터치 영역을 가진 아이콘 버튼
/// 카운터 하단의 +/- 버튼에 사용
class LargeAreaButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color color;
  final BorderRadius borderRadius;
  final double iconSize;
  final double verticalPadding;

  const LargeAreaButton({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.color,
    required this.borderRadius,
    this.iconSize = 20,
    this.verticalPadding = 12,
  });

  /// 메인 카운터용 (큰 버튼)
  const LargeAreaButton.large({
    super.key,
    required this.icon,
    required this.onPressed,
    required this.color,
    required this.borderRadius,
  })  : iconSize = 32,
        verticalPadding = 20;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: borderRadius,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: verticalPadding),
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: iconSize,
            color: enabled ? color.withAlpha(180) : color.withAlpha(77),
          ),
        ),
      ),
    );
  }
}
