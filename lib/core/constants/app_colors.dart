import 'package:flutter/material.dart';

/// 한코한코 앱 색상 팔레트
/// "Tactile Digital" 디자인 철학 - 실과 바늘의 촉감을 화면에서
class AppColors {
  AppColors._();

  // ============ Light Mode ============

  /// Primary - Wool Coral: 메인 버튼, 강조
  static const Color primary = Color(0xFFFF6B6B);
  static const Color primaryLight = Color(0xFFFF8585);

  /// Secondary - Terracotta Clay: 보조 강조, 따뜻한 흙/점토 톤
  static const Color secondary = Color(0xFFE07A5F);

  /// Background - Warm Cream: 배경 (카드와 명확한 대비)
  static const Color background = Color(0xFFFAF3E0);

  /// Surface - Yarn White: 카드, 버튼
  static const Color surface = Color(0xFFFFFFFF);

  /// Text - Charcoal: 주요 텍스트
  static const Color textPrimary = Color(0xFF2D3436);

  /// Text Sub - Warm Gray: 보조 텍스트
  static const Color textSecondary = Color(0xFF636E72);

  /// Success - Golden Honey: 완료, 성공 (따뜻한 톤)
  static const Color success = Color(0xFFD4A574);

  /// Success Dark - 다크모드용 밝은 변형
  static const Color successDark = Color(0xFFE5B88A);

  /// Warning - Sunny Yellow: 알림, 메모
  static const Color warning = Color(0xFFFFD93D);

  /// Error
  static const Color error = Color(0xFFE74C3C);

  /// Memo Background - Warm Yellow Tint: 메모 카드 배경
  static const Color memoBackground = Color(0xFFFFF3D4);

  /// Memo Border - Muted Gold: 메모 카드 테두리
  static const Color memoBorder = Color(0xFFDCC99A);

  /// Memo Icon - Warm Brown: 메모 핀 아이콘
  static const Color memoIcon = Color(0xFFB8956E);

  /// Memo Shadow - Warm Beige: 메모 카드 그림자
  static const Color memoShadow = Color(0xFFD4C4A8);

  /// Border
  static const Color border = Color(0xFFE0E0E0);

  // ============ Dark Mode ============

  /// Primary Dark - Soft Coral
  static const Color primaryDark = Color(0xFFFF8585);

  /// Secondary Dark - Light Terracotta
  static const Color secondaryDark = Color(0xFFE89B84);

  /// Background Dark - Shadow Yarn
  static const Color backgroundDark = Color(0xFF1A1C23);

  /// Surface Dark - Charcoal
  static const Color surfaceDark = Color(0xFF2A2D3A);

  /// Text Dark - Cream
  static const Color textPrimaryDark = Color(0xFFF5F5F5);

  /// Text Sub Dark
  static const Color textSecondaryDark = Color(0xFFB0B0B0);

  /// Memo Background Dark
  static const Color memoBackgroundDark = Color(0xFF3A3526);

  /// Memo Border Dark - Golden
  static const Color memoBorderDark = Color(0xFFD4A84B);

  /// Memo Icon Dark
  static const Color memoIconDark = Color(0xFFD4A84B);

  /// Border Dark
  static const Color borderDark = Color(0xFF3A3D4A);

  // ============ Gradients ============

  /// Primary Button Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Success Gradient (따뜻한 골든 허니 톤)
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFFD4A574), Color(0xFFE5C5A3)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============ Helper Methods ============

  /// 투명도가 적용된 primary 색상
  static Color primaryWithOpacity(double opacity) => primary.withValues(alpha: opacity);

  /// 투명도가 적용된 warning 색상 (메모 배경용)
  static Color warningBackground = warning.withValues(alpha: 0.2);
}

/// 다크 모드 색상을 쉽게 가져오기 위한 BuildContext extension
extension AppColorsExtension on BuildContext {
  bool get _isDark => Theme.of(this).brightness == Brightness.dark;

  Color get textPrimary =>
      _isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;

  Color get textSecondary =>
      _isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;

  Color get surface => _isDark ? AppColors.surfaceDark : AppColors.surface;

  Color get background =>
      _isDark ? AppColors.backgroundDark : AppColors.background;

  Color get border => _isDark ? AppColors.borderDark : AppColors.border;

  Color get primary => _isDark ? AppColors.primaryDark : AppColors.primary;

  Color get success => _isDark ? AppColors.successDark : AppColors.success;

  Color get memoBackground =>
      _isDark ? AppColors.memoBackgroundDark : AppColors.memoBackground;

  Color get memoBorder =>
      _isDark ? AppColors.memoBorderDark : AppColors.memoBorder;

  Color get memoIcon =>
      _isDark ? AppColors.memoIconDark : AppColors.memoIcon;
}
