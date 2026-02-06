/// 앱 설정 모델
class AppSettings {
  final bool hapticFeedback;
  final bool voiceFeedback;
  final bool keepScreenOn;
  final String themeMode; // 'light', 'dark', 'system'

  AppSettings({
    this.hapticFeedback = true,
    this.voiceFeedback = true,
    this.keepScreenOn = true,
    this.themeMode = 'light',
  });

  AppSettings copyWith({
    bool? hapticFeedback,
    bool? voiceFeedback,
    bool? keepScreenOn,
    String? themeMode,
  }) {
    return AppSettings(
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      voiceFeedback: voiceFeedback ?? this.voiceFeedback,
      keepScreenOn: keepScreenOn ?? this.keepScreenOn,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hapticFeedback': hapticFeedback,
      'voiceFeedback': voiceFeedback,
      'keepScreenOn': keepScreenOn,
      'themeMode': themeMode,
    };
  }

  factory AppSettings.fromJson(Map<String, dynamic> json) {
    return AppSettings(
      hapticFeedback: json['hapticFeedback'] as bool? ?? true,
      voiceFeedback: json['voiceFeedback'] as bool? ?? true,
      keepScreenOn: json['keepScreenOn'] as bool? ?? true,
      themeMode: json['themeMode'] as String? ?? 'light',
    );
  }
}
