import 'package:flutter/material.dart';

/// 위젯 유틸리티 extension
extension WidgetRectExtension on BuildContext {
  /// 현재 위젯의 화면상 Rect 반환
  Rect getWidgetRect() {
    final renderBox = findRenderObject() as RenderBox?;
    if (renderBox == null) return Rect.zero;
    final position = renderBox.localToGlobal(Offset.zero);
    return Rect.fromLTWH(
      position.dx,
      position.dy,
      renderBox.size.width,
      renderBox.size.height,
    );
  }
}
