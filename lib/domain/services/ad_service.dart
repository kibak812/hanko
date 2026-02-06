import 'dart:async';
import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// 광고 서비스
/// Google Mobile Ads를 사용한 광고 표시
class AdService {
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  bool _isInitialized = false;
  bool _isDisposed = false;

  // 광고 로드 재시도 관련
  static const int _maxRetryCount = 3;
  int _interstitialRetryCount = 0;
  int _rewardedRetryCount = 0;
  Timer? _interstitialRetryTimer;
  Timer? _rewardedRetryTimer;

  // 광고 ID (--dart-define으로 주입, 기본값은 테스트 ID)
  static const String _androidInterstitialId = String.fromEnvironment(
    'ANDROID_INTERSTITIAL_ID',
    defaultValue: 'ca-app-pub-3940256099942544/1033173712',
  );
  static const String _androidRewardedId = String.fromEnvironment(
    'ANDROID_REWARDED_ID',
    defaultValue: 'ca-app-pub-3940256099942544/5224354917',
  );
  static const String _androidBannerId = String.fromEnvironment(
    'ANDROID_BANNER_ID',
    defaultValue: 'ca-app-pub-3940256099942544/6300978111',
  );
  static const String _iosInterstitialId = String.fromEnvironment(
    'IOS_INTERSTITIAL_ID',
    defaultValue: 'ca-app-pub-3940256099942544/4411468910',
  );
  static const String _iosRewardedId = String.fromEnvironment(
    'IOS_REWARDED_ID',
    defaultValue: 'ca-app-pub-3940256099942544/1712485313',
  );
  static const String _iosBannerId = String.fromEnvironment(
    'IOS_BANNER_ID',
    defaultValue: 'ca-app-pub-3940256099942544/2934735716',
  );

  static String get _interstitialAdUnitId {
    if (Platform.isAndroid) return _androidInterstitialId;
    if (Platform.isIOS) return _iosInterstitialId;
    throw UnsupportedError('Unsupported platform');
  }

  static String get _rewardedAdUnitId {
    if (Platform.isAndroid) return _androidRewardedId;
    if (Platform.isIOS) return _iosRewardedId;
    throw UnsupportedError('Unsupported platform');
  }

  static String get _bannerAdUnitId {
    if (Platform.isAndroid) return _androidBannerId;
    if (Platform.isIOS) return _iosBannerId;
    throw UnsupportedError('Unsupported platform');
  }

  /// 광고 SDK 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    await MobileAds.instance.initialize();
    _isInitialized = true;

    // 전면 광고 미리 로드
    _loadInterstitialAd();
    // 리워드 광고 미리 로드
    _loadRewardedAd();
  }

  /// 전면 광고 로드
  void _loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: _interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          if (_isDisposed) { ad.dispose(); return; }
          _interstitialRetryCount = 0;
          _interstitialRetryTimer?.cancel();
          _interstitialAd = ad;
          _interstitialAd?.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _loadInterstitialAd(); // 다음 광고 미리 로드
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _interstitialRetryCount++;
          // 최대 재시도 횟수 초과 시 중단
          if (_interstitialRetryCount >= _maxRetryCount) {
            return;
          }
          // 로드 실패 시 재시도
          _interstitialRetryTimer?.cancel();
          _interstitialRetryTimer = Timer(const Duration(seconds: 30), _loadInterstitialAd);
        },
      ),
    );
  }

  /// 전면 광고 표시
  Future<bool> showInterstitialAd() async {
    if (_interstitialAd == null) {
      _loadInterstitialAd();
      return false;
    }

    await _interstitialAd!.show();
    _interstitialAd = null;
    return true;
  }

  /// 전면 광고 준비 여부
  bool get isInterstitialAdReady => _interstitialAd != null;

  /// 리워드 광고 로드
  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          if (_isDisposed) { ad.dispose(); return; }
          _rewardedRetryCount = 0;
          _rewardedRetryTimer?.cancel();
          _rewardedAd = ad;
          _rewardedAd?.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _loadRewardedAd(); // 다음 광고 미리 로드
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _loadRewardedAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          _rewardedRetryCount++;
          // 최대 재시도 횟수 초과 시 중단
          if (_rewardedRetryCount >= _maxRetryCount) {
            return;
          }
          _rewardedRetryTimer?.cancel();
          _rewardedRetryTimer = Timer(const Duration(seconds: 30), _loadRewardedAd);
        },
      ),
    );
  }

  /// 리워드 광고 표시
  Future<bool> showRewardedAd({
    required Function(int rewardAmount) onRewarded,
  }) async {
    if (_rewardedAd == null) {
      _loadRewardedAd();
      return false;
    }

    await _rewardedAd!.show(
      onUserEarnedReward: (ad, reward) {
        onRewarded(reward.amount.toInt());
      },
    );
    _rewardedAd = null;
    return true;
  }

  /// 리워드 광고 준비 여부
  bool get isRewardedAdReady => _rewardedAd != null;

  /// 배너 광고 생성
  BannerAd createBannerAd({
    required Function() onLoaded,
    required Function(String error) onFailed,
  }) {
    return BannerAd(
      adUnitId: _bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) => onLoaded(),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          onFailed(error.message);
        },
      ),
    );
  }

  /// 리소스 해제
  void dispose() {
    _isDisposed = true;
    _interstitialRetryTimer?.cancel();
    _rewardedRetryTimer?.cancel();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}
