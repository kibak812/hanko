import 'package:purchases_flutter/purchases_flutter.dart';

/// 프리미엄 서비스
/// RevenueCat을 사용한 인앱결제 관리
class PremiumService {
  static const String _apiKey = 'YOUR_REVENUECAT_API_KEY'; // 실제 배포 시 교체

  // 상품 ID
  static const String proMonthly = 'hanko_pro_monthly';
  static const String proYearly = 'hanko_pro_yearly';

  // Entitlement ID
  static const String proEntitlement = 'pro';

  bool _isInitialized = false;

  /// RevenueCat 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    // TODO: 실제 API 키 설정 시 주석 해제
    // await Purchases.configure(PurchasesConfiguration(_apiKey));
    _isInitialized = true;
  }

  /// 현재 프리미엄 상태 확인
  Future<bool> isPremium() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.all[proEntitlement]?.isActive == true;
    } catch (e) {
      return false;
    }
  }

  /// 사용 가능한 상품 목록 조회
  Future<List<StoreProduct>> getProducts() async {
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      if (current == null) return [];

      return current.availablePackages
          .map((p) => p.storeProduct)
          .toList();
    } catch (e) {
      return [];
    }
  }

  /// 상품 구매
  Future<PurchaseResult> purchase(String productId) async {
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      if (current == null) {
        return PurchaseResult(
          success: false,
          error: '상품을 찾을 수 없습니다',
        );
      }

      final package = current.availablePackages.firstWhere(
        (p) => p.storeProduct.identifier == productId,
        orElse: () => throw Exception('Product not found'),
      );

      final customerInfo = await Purchases.purchasePackage(package);
      final isPremiumNow = customerInfo.entitlements.all[proEntitlement]?.isActive == true;

      return PurchaseResult(
        success: isPremiumNow,
        isPremium: isPremiumNow,
      );
    } catch (e) {
      return PurchaseResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// 구매 복원
  Future<PurchaseResult> restorePurchases() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      final isPremiumNow = customerInfo.entitlements.all[proEntitlement]?.isActive == true;

      return PurchaseResult(
        success: true,
        isPremium: isPremiumNow,
        message: isPremiumNow ? '구매가 복원되었습니다' : '복원할 구매가 없습니다',
      );
    } catch (e) {
      return PurchaseResult(
        success: false,
        error: e.toString(),
      );
    }
  }
}

/// 구매 결과
class PurchaseResult {
  final bool success;
  final bool isPremium;
  final String? error;
  final String? message;

  PurchaseResult({
    required this.success,
    this.isPremium = false,
    this.error,
    this.message,
  });
}

/// 상품 정보 (UI 표시용)
class ProductInfo {
  final String id;
  final String title;
  final String description;
  final String price;
  final String period;
  final bool isRecommended;

  ProductInfo({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.period,
    this.isRecommended = false,
  });

  static List<ProductInfo> getDefaultProducts() {
    return [
      ProductInfo(
        id: PremiumService.proYearly,
        title: '연간 구독',
        description: '하루 ₩27, 커피 한 잔보다 저렴!',
        price: '₩9,900',
        period: '/년',
        isRecommended: true,
      ),
      ProductInfo(
        id: PremiumService.proMonthly,
        title: '월간 구독',
        description: '언제든 취소 가능',
        price: '₩1,500',
        period: '/월',
      ),
    ];
  }
}
