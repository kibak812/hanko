import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// 로컬 저장소 관리 (설정, 사용량 추적 등)
/// SharedPreferences를 사용하여 간단한 키-값 데이터 저장
class LocalStorage {
  static const String _settingsKey = 'hanko_settings';
  static const String _voiceUsageKey = 'hanko_voice_usage';
  static const String _adCountKey = 'hanko_ad_count';
  static const String _activeProjectKey = 'hanko_active_project';

  final SharedPreferences _prefs;

  LocalStorage(this._prefs);

  // ============ 활성 프로젝트 ============

  /// 활성 프로젝트 ID 저장
  Future<bool> setActiveProjectId(int? projectId) async {
    if (projectId == null) {
      return await _prefs.remove(_activeProjectKey);
    }
    return await _prefs.setInt(_activeProjectKey, projectId);
  }

  /// 활성 프로젝트 ID 로드
  int? getActiveProjectId() {
    return _prefs.getInt(_activeProjectKey);
  }

  // ============ 설정 관련 ============

  /// 설정 로드
  AppSettings loadSettings() {
    final jsonString = _prefs.getString(_settingsKey);
    if (jsonString == null || jsonString.isEmpty) {
      return AppSettings();
    }

    try {
      final map = json.decode(jsonString) as Map<String, dynamic>;
      return AppSettings.fromJson(map);
    } catch (e) {
      return AppSettings();
    }
  }

  /// 설정 저장
  Future<bool> saveSettings(AppSettings settings) async {
    try {
      final jsonString = json.encode(settings.toJson());
      return await _prefs.setString(_settingsKey, jsonString);
    } catch (e) {
      return false;
    }
  }

  // ============ 음성 사용량 관련 ============

  /// 오늘 음성 사용 횟수 조회
  int getTodayVoiceUsage() {
    final data = _prefs.getString(_voiceUsageKey);
    if (data == null) return 0;

    try {
      final Map<String, dynamic> usage = json.decode(data) as Map<String, dynamic>;
      final today = _getTodayKey();
      return usage[today] as int? ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// 음성 사용 횟수 증가
  Future<bool> incrementVoiceUsage() async {
    try {
      final data = _prefs.getString(_voiceUsageKey);
      Map<String, dynamic> usage = {};

      if (data != null) {
        usage = json.decode(data) as Map<String, dynamic>;
      }

      final today = _getTodayKey();
      usage[today] = (usage[today] as int? ?? 0) + 1;

      // 오래된 데이터 정리 (7일 이전)
      _cleanupOldEntries(usage);

      return await _prefs.setString(_voiceUsageKey, json.encode(usage));
    } catch (e) {
      return false;
    }
  }

  /// 보너스 음성 횟수 추가 (광고 시청 후)
  Future<bool> addBonusVoiceUsage(int count) async {
    try {
      final data = _prefs.getString(_voiceUsageKey);
      Map<String, dynamic> usage = {};

      if (data != null) {
        usage = json.decode(data) as Map<String, dynamic>;
      }

      final bonusKey = '${_getTodayKey()}_bonus';
      usage[bonusKey] = (usage[bonusKey] as int? ?? 0) + count;

      return await _prefs.setString(_voiceUsageKey, json.encode(usage));
    } catch (e) {
      return false;
    }
  }

  /// 오늘 보너스 음성 횟수 조회
  int getTodayBonusVoiceUsage() {
    final data = _prefs.getString(_voiceUsageKey);
    if (data == null) return 0;

    try {
      final Map<String, dynamic> usage = json.decode(data) as Map<String, dynamic>;
      final bonusKey = '${_getTodayKey()}_bonus';
      return usage[bonusKey] as int? ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// 남은 음성 사용 가능 횟수
  int getRemainingVoiceCount({required int dailyLimit}) {
    final used = getTodayVoiceUsage();
    final bonus = getTodayBonusVoiceUsage();
    return (dailyLimit + bonus - used).clamp(0, dailyLimit + bonus);
  }

  // ============ 광고 카운트 관련 ============

  /// 오늘 세션 내 광고 수 조회
  int getTodayAdCount() {
    final data = _prefs.getString(_adCountKey);
    if (data == null) return 0;

    try {
      final Map<String, dynamic> counts = json.decode(data) as Map<String, dynamic>;
      final today = _getTodayKey();
      return counts[today] as int? ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// 광고 카운트 증가
  Future<bool> incrementAdCount() async {
    try {
      final data = _prefs.getString(_adCountKey);
      Map<String, dynamic> counts = {};

      if (data != null) {
        counts = json.decode(data) as Map<String, dynamic>;
      }

      final today = _getTodayKey();
      counts[today] = (counts[today] as int? ?? 0) + 1;

      _cleanupOldEntries(counts);

      return await _prefs.setString(_adCountKey, json.encode(counts));
    } catch (e) {
      return false;
    }
  }

  /// 마지막 광고 시간 저장
  Future<bool> setLastAdTime(DateTime time) async {
    return await _prefs.setInt('last_ad_time', time.millisecondsSinceEpoch);
  }

  /// 마지막 광고 시간 조회
  DateTime? getLastAdTime() {
    final timestamp = _prefs.getInt('last_ad_time');
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// 광고 표시 가능 여부 (최소 간격: 3분, 세션 상한: 5회)
  bool canShowAd({int maxAdsPerSession = 5, Duration minInterval = const Duration(minutes: 3)}) {
    if (getTodayAdCount() >= maxAdsPerSession) return false;

    final lastAdTime = getLastAdTime();
    if (lastAdTime == null) return true;

    return DateTime.now().difference(lastAdTime) >= minInterval;
  }

  // ============ 온보딩 관련 ============

  /// 온보딩 완료 여부
  bool isOnboardingCompleted() {
    return _prefs.getBool('onboarding_completed') ?? false;
  }

  /// 온보딩 완료 설정
  Future<bool> setOnboardingCompleted(bool completed) async {
    return await _prefs.setBool('onboarding_completed', completed);
  }

  // ============ 튜토리얼 관련 ============

  /// 튜토리얼 완료 여부
  bool isTutorialCompleted() {
    return _prefs.getBool('tutorial_completed') ?? false;
  }

  /// 튜토리얼 완료 설정
  Future<bool> setTutorialCompleted(bool completed) async {
    return await _prefs.setBool('tutorial_completed', completed);
  }

  // ============ 유틸리티 ============

  String _getTodayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  void _cleanupOldEntries(Map<String, dynamic> map) {
    final keysToRemove = <String>[];
    for (final key in map.keys) {
      if (_isOlderThan7Days(key)) {
        keysToRemove.add(key);
      }
    }
    for (final key in keysToRemove) {
      map.remove(key);
    }
  }

  bool _isOlderThan7Days(String dateKey) {
    try {
      // bonus 키는 건너뜀
      String actualKey = dateKey;
      if (dateKey.contains('_bonus')) {
        actualKey = dateKey.split('_')[0];
      }

      final parts = actualKey.split('-');
      if (parts.length != 3) return true;

      final date = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      return DateTime.now().difference(date).inDays > 7;
    } catch (e) {
      return true;
    }
  }
}

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
