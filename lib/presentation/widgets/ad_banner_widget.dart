import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../providers/app_providers.dart';

/// 하단 배너 광고 위젯
/// - 광고 로드 실패 시 빈 공간 유지 (레이아웃 점프 방지)
class AdBannerWidget extends ConsumerStatefulWidget {
  final double bottomPadding;

  const AdBannerWidget({
    super.key,
    this.bottomPadding = 8.0,
  });

  @override
  ConsumerState<AdBannerWidget> createState() => _AdBannerWidgetState();
}

class _AdBannerWidgetState extends ConsumerState<AdBannerWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void _loadBannerAd() {
    final adService = ref.read(adServiceProvider);
    _bannerAd = adService.createBannerAd(
      onLoaded: () {
        if (mounted) {
          setState(() {
            _isAdLoaded = true;
          });
        }
      },
      onFailed: (error) {
        if (mounted) {
          setState(() {
            _isAdLoaded = false;
          });
        }
      },
    );
    _bannerAd?.load();
  }

  @override
  Widget build(BuildContext context) {
    // 디버그 모드에서는 광고 숨김 (스크린샷용)
    if (kDebugMode) return const SizedBox.shrink();

    // 광고 높이 고정 (레이아웃 안정성)
    const adHeight = 50.0;

    if (_bannerAd != null && _isAdLoaded) {
      return Padding(
        padding: EdgeInsets.only(bottom: widget.bottomPadding),
        child: Center(
          child: SizedBox(
            width: _bannerAd!.size.width.toDouble(),
            height: adHeight,
            child: AdWidget(ad: _bannerAd!),
          ),
        ),
      );
    }

    // 광고 로드 중 또는 실패 시 빈 공간 유지
    return SizedBox(height: adHeight + widget.bottomPadding);
  }
}
