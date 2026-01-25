import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../data/models/counter.dart';

/// 보조 카운터 추가 바텀시트
class AddSecondaryCounterSheet extends StatefulWidget {
  final void Function(String label, SecondaryCounterType type, int? value)
      onAdd;
  final bool canAdd;

  const AddSecondaryCounterSheet({
    super.key,
    required this.onAdd,
    this.canAdd = true,
  });

  @override
  State<AddSecondaryCounterSheet> createState() =>
      _AddSecondaryCounterSheetState();
}

class _AddSecondaryCounterSheetState extends State<AddSecondaryCounterSheet> {
  final _labelController = TextEditingController();
  final _targetController = TextEditingController();
  SecondaryCounterType _selectedType = SecondaryCounterType.goal;

  @override
  void dispose() {
    _labelController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  void _onAdd() {
    final label = _labelController.text.trim();
    if (label.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('카운터 이름을 입력해주세요')),
      );
      return;
    }

    final value = int.tryParse(_targetController.text.trim());
    widget.onAdd(label, _selectedType, value);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        height: 540 + (widget.canAdd ? 0 : 60),
        margin: EdgeInsets.only(bottom: bottomInset),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
        children: [
          // 핸들
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

          // 스크롤 가능한 콘텐츠
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

          // 헤더
          Text(
            AppStrings.addSecondaryCounter,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color:
                  isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 24),

          // 카운터 이름
          Text(
            AppStrings.counterLabel,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _labelController,
            enabled: widget.canAdd,
            decoration: const InputDecoration(
              hintText: '예: 코줄임, 배색 A',
            ),
            textCapitalization: TextCapitalization.sentences,
          ),

          const SizedBox(height: 24),

          // 유형 선택
          Text(
            AppStrings.selectCounterType,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _TypeChip(
                  icon: Icons.flag,
                  label: AppStrings.goalType,
                  subtitle: '총 N번',
                  isSelected: _selectedType == SecondaryCounterType.goal,
                  onTap: widget.canAdd
                      ? () {
                          setState(() {
                            _selectedType = SecondaryCounterType.goal;
                          });
                        }
                      : null,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _TypeChip(
                  icon: Icons.refresh,
                  label: AppStrings.repetitionType,
                  subtitle: 'N단마다',
                  isSelected: _selectedType == SecondaryCounterType.repetition,
                  onTap: widget.canAdd
                      ? () {
                          setState(() {
                            _selectedType = SecondaryCounterType.repetition;
                          });
                        }
                      : null,
                  isDark: isDark,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 설정값
          Text(
            _selectedType == SecondaryCounterType.goal
                ? '${AppStrings.goal} (선택)'
                : '${AppStrings.period} (선택)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _targetController,
            enabled: widget.canAdd,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: _selectedType == SecondaryCounterType.goal
                  ? '예: 10 (비워두면 목표 없음)'
                  : '예: 4 (비워두면 자동 리셋 없음)',
            ),
          ),

          const SizedBox(height: 24),

                  // 추가 버튼
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: widget.canAdd ? _onAdd : null,
                      child: const Text('추가'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool isDark;

  const _TypeChip({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : (isDark ? AppColors.backgroundDark : AppColors.background),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.borderDark : AppColors.border),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected
                  ? AppColors.primary
                  : (isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? AppColors.primary
                    : (isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary),
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 보조 카운터 추가 바텀시트 표시 헬퍼
void showAddSecondaryCounterSheet({
  required BuildContext context,
  required void Function(String label, SecondaryCounterType type, int? value)
      onAdd,
  bool canAdd = true,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => AddSecondaryCounterSheet(
      onAdd: onAdd,
      canAdd: canAdd,
    ),
  );
}
