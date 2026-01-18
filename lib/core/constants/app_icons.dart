import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// 앱 커스텀 아이콘 관리
class AppIcons {
  AppIcons._();

  static const String _basePath = 'assets/icons';

  // 아이콘 경로
  static const String stitch = '$_basePath/ic_stitch.svg';
  static const String pattern = '$_basePath/ic_pattern.svg';
  static const String goal = '$_basePath/ic_goal.svg';

  /// SVG 아이콘 위젯 생성 헬퍼
  static Widget svg(
    String assetPath, {
    double size = 24,
    Color? color,
  }) {
    return SvgPicture.asset(
      assetPath,
      width: size,
      height: size,
      colorFilter: color != null
          ? ColorFilter.mode(color, BlendMode.srcIn)
          : null,
    );
  }

  /// 코 카운터 아이콘
  static Widget stitchIcon({double size = 24, Color? color}) {
    return svg(stitch, size: size, color: color);
  }

  /// 패턴 반복 아이콘
  static Widget patternIcon({double size = 24, Color? color}) {
    return svg(pattern, size: size, color: color);
  }

  /// 목표 달성 아이콘
  static Widget goalIcon({double size = 24, Color? color}) {
    return svg(goal, size: size, color: color);
  }
}
