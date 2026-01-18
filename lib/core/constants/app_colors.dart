import 'package:flutter/material.dart';

/// 한코한코 앱 색상 팔레트
/// "Tactile Digital" 디자인 철학 - 실과 바늘의 촉감을 화면에서
class AppColors {
  AppColors._();

  // ============ Light Mode ============

  /// Primary - Wool Coral: 메인 버튼, 강조
  static const Color primary = Color(0xFFFF6B6B);
  static const Color primaryLight = Color(0xFFFF8585);

  /// Secondary - Mint Thread: 보조 강조, 성공
  static const Color secondary = Color(0xFF4ECDC4);

  /// Background - Cream Base: 배경 (눈 편함)
  static const Color background = Color(0xFFFFFBF0);

  /// Surface - Yarn White: 카드, 버튼
  static const Color surface = Color(0xFFFFFFFF);

  /// Text - Charcoal: 주요 텍스트
  static const Color textPrimary = Color(0xFF2D3436);

  /// Text Sub - Warm Gray: 보조 텍스트
  static const Color textSecondary = Color(0xFF636E72);

  /// Success - Soft Green: 완료, 성공
  static const Color success = Color(0xFF6BCB77);

  /// Warning - Sunny Yellow: 알림, 메모
  static const Color warning = Color(0xFFFFD93D);

  /// Error
  static const Color error = Color(0xFFE74C3C);

  /// Border
  static const Color border = Color(0xFFE0E0E0);

  // ============ Dark Mode ============

  /// Primary Dark - Soft Coral
  static const Color primaryDark = Color(0xFFFF8585);

  /// Secondary Dark - Mint Glow
  static const Color secondaryDark = Color(0xFF5EDDD5);

  /// Background Dark - Shadow Yarn
  static const Color backgroundDark = Color(0xFF1A1C23);

  /// Surface Dark - Charcoal
  static const Color surfaceDark = Color(0xFF2A2D3A);

  /// Text Dark - Cream
  static const Color textPrimaryDark = Color(0xFFF5F5F5);

  /// Text Sub Dark
  static const Color textSecondaryDark = Color(0xFFB0B0B0);

  /// Border Dark
  static const Color borderDark = Color(0xFF3A3D4A);

  // ============ Gradients ============

  /// Primary Button Gradient
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Success Gradient
  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF6BCB77), Color(0xFF88D992)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============ Helper Methods ============

  /// 투명도가 적용된 primary 색상
  static Color primaryWithOpacity(double opacity) => primary.withOpacity(opacity);

  /// 투명도가 적용된 warning 색상 (메모 배경용)
  static Color warningBackground = warning.withOpacity(0.2);
}
