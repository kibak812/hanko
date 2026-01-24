import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../domain/services/premium_service.dart';
import '../providers/app_providers.dart';

/// 프리미엄 구매 바텀시트
class PremiumPurchaseSheet extends ConsumerStatefulWidget {
  const PremiumPurchaseSheet({super.key});

  @override
  ConsumerState<PremiumPurchaseSheet> createState() =>
      _PremiumPurchaseSheetState();
}

class _PremiumPurchaseSheetState extends ConsumerState<PremiumPurchaseSheet> {
  String? _selectedProductId;
  bool _isLoading = false;
  String? _errorMessage;

  final List<ProductInfo> _products = ProductInfo.getDefaultProducts();

  @override
  void initState() {
    super.initState();
    // 기본 선택: 연간 구독 (추천)
    _selectedProductId = PremiumService.proYearly;
  }

  Future<void> _onPurchase() async {
    if (_selectedProductId == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final premiumService = PremiumService();
      final result = await premiumService.purchase(_selectedProductId!);

      if (result.success && result.isPremium) {
        // 프리미엄 상태 갱신
        ref.invalidate(premiumStatusProvider);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('프리미엄 구매가 완료되었습니다!')),
          );
        }
      } else if (result.error != null) {
        setState(() {
          _errorMessage = result.error;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _onRestore() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final premiumService = PremiumService();
      final result = await premiumService.restorePurchases();

      if (result.success && result.isPremium) {
        ref.invalidate(premiumStatusProvider);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result.message ?? '구매가 복원되었습니다')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(result.message ?? '복원할 구매가 없습니다')),
          );
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 핸들
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppColors.borderDark : AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 헤더
          Center(
            child: Column(
              children: [
                const Text('✨', style: TextStyle(fontSize: 40)),
                const SizedBox(height: 12),
                Text(
                  '한코한코 프리미엄',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color:
                        isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '뜨개질에 더 집중하세요',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 혜택 목록
          _buildBenefitItem(Icons.folder_open, AppStrings.unlimitedProjects, isDark),
          _buildBenefitItem(Icons.mic, AppStrings.unlimitedVoice, isDark),
          _buildBenefitItem(Icons.block, AppStrings.noAds, isDark),
          _buildBenefitItem(Icons.widgets, AppStrings.widget, isDark),
          const SizedBox(height: 24),

          // 상품 선택
          ..._products.map((product) => _buildProductOption(product, isDark)),
          const SizedBox(height: 16),

          // 에러 메시지
          if (_errorMessage != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.error.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: AppColors.error, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // 구매 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _onPurchase,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: AppColors.primary,
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _getSelectedProductPrice(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 12),

          // 복원 버튼
          Center(
            child: TextButton(
              onPressed: _isLoading ? null : _onRestore,
              child: Text(
                AppStrings.restorePurchase,
                style: TextStyle(
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ),

          // 하단 안내
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '구독은 언제든 취소할 수 있습니다',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.textSecondaryDark.withAlpha(179)
                      : AppColors.textSecondary.withAlpha(179),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color:
                    isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductOption(ProductInfo product, bool isDark) {
    final isSelected = _selectedProductId == product.id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedProductId = product.id;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withAlpha(25)
              : (isDark ? AppColors.backgroundDark : AppColors.background),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.borderDark : AppColors.border),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // 라디오 표시
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),

            // 상품 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        product.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                        ),
                      ),
                      if (product.isRecommended) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            '추천',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // 가격
            Text(
              '${product.price}${product.period}',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSelectedProductPrice() {
    final product = _products.firstWhere(
      (p) => p.id == _selectedProductId,
      orElse: () => _products.first,
    );
    return '${product.price}${product.period}으로 구독하기';
  }
}

/// 프리미엄 구매 바텀시트 표시 헬퍼
void showPremiumPurchaseSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const PremiumPurchaseSheet(),
  );
}
