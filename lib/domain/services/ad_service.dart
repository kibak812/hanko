import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io';

/// 광고 서비스
/// Google Mobile Ads를 사용한 광고 표시
class AdService {
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;
  bool _isInitialized = false;

  // 테스트 광고 ID (실제 배포 시 교체 필요)
  static String get _interstitialAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/1033173712'; // 테스트 ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/4411468910'; // 테스트 ID
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String get _rewardedAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/5224354917'; // 테스트 ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/1712485313'; // 테스트 ID
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String get _bannerAdUnitId {
    if (Platform.isAndroid) {
      return 'ca-app-pub-3940256099942544/6300978111'; // 테스트 ID
    } else if (Platform.isIOS) {
      return 'ca-app-pub-3940256099942544/2934735716'; // 테스트 ID
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
