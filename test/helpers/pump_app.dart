import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hanko_hanko/core/theme/app_theme.dart';
import 'package:hanko_hanko/domain/services/ad_service.dart';
import 'package:hanko_hanko/presentation/providers/app_providers.dart';
import 'package:mocktail/mocktail.dart';
import 'mocks.dart';

class _FakeBannerAd extends Fake implements BannerAd {
  @override
  Future<void> load() async {}

  @override
  Future<void> dispose() async {}
}

/// Widget test용 공통 하네스
/// ProviderScope + MaterialApp + 테마 + 기본 override 포함
Future<void> pumpApp(
  WidgetTester tester,
  Widget widget, {
  List<Override> overrides = const [],
}) async {
  // AdService mock은 항상 포함 (AdBannerWidget 의존성)
  final mockAdService = MockAdService();
  final mockAdController = MockInterstitialAdController();

  // createBannerAd stub (AdBannerWidget.initState에서 호출됨)
  when(() => mockAdService.createBannerAd(
        onLoaded: any(named: 'onLoaded'),
        onFailed: any(named: 'onFailed'),
      )).thenReturn(_FakeBannerAd());

  final defaultOverrides = <Override>[
    adServiceProvider.overrideWithValue(mockAdService),
    interstitialAdControllerProvider.overrideWithValue(mockAdController),
  ];

  await tester.pumpWidget(
    ProviderScope(
      overrides: [...defaultOverrides, ...overrides],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: widget,
      ),
    ),
  );
}
