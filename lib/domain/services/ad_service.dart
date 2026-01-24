import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';

/// 광고 서비스
/// Google Mobile Ads를 사용한 광고 표시
class AdService {
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  bool _isInitialized = false;

  // 광고 로드 재시도 관련
  static const int _maxRetryCount = 3;
  int _interstitialRetryCount = 0;
  int _rewardedRetryCount = 0;

  // 프로덕션 광고 ID
  static const String _androidInterstitialId = 'ca-app-pub-1068771440265964/4299582826';
  static const String _androidRewardedId = 'ca-app-pub-1068771440265964/8398609933';
  static const String _androidBannerId = 'ca-app-pub-1068771440265964/1599259688';
  static const String _iosInterstitialId = 'ca-app-pub-1068771440265964/8238827831';
  static const String _iosRewardedId = 'ca-app-pub-1068771440265964/7616845458';
  static const String _iosBannerId = 'ca-app-pub-1068771440265964/8394740507';

  // 테스트 광고 ID
  static const String _testAndroidInterstitialId = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testAndroidRewardedId = 'ca-app-pub-3940256099942544/5224354917';
  static const String _testAndroidBannerId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testIosInterstitialId = 'ca-app-pub-3940256099942544/4411468910';
  static const String _testIosRewardedId = 'ca-app-pub-3940256099942544/1712485313';
  static const String _testIosBannerId = 'ca-app-pub-3940256099942544/2934735716';

  static String get _interstitialAdUnitId {
    if (Platform.isAndroid) {
      return kReleaseMode ? _androidInterstitialId : _testAndroidInterstitialId;
    } else if (Platform.isIOS) {
      return kReleaseMode ? _iosInterstitialId : _testIosInterstitialId;
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String get _rewardedAdUnitId {
    if (Platform.isAndroid) {
      return kReleaseMode ? _androidRewardedId : _testAndroidRewardedId;
    } else if (Platform.isIOS) {
      return kReleaseMode ? _iosRewardedId : _testIosRewardedId;
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String get _bannerAdUnitId {
    if (Platform.isAndroid) {
      return kReleaseMode ? _androidBannerId : _testAndroidBannerId;
    } else if (Platform.isIOS) {
      return kReleaseMode ? _iosBannerId : _testIosBannerId;
    }
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
          _interstitialRetryCount = 0; // 성공 시 카운터 리셋
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
          Future.delayed(const Duration(seconds: 30), _loadInterstitialAd);
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
          _rewardedRetryCount = 0; // 성공 시 카운터 리셋
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
          Future.delayed(const Duration(seconds: 30), _loadRewardedAd);
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
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
  }
}
