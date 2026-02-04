import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

/// 확장형 카운터 옵션 카드
/// 토글 ON 시 하위 옵션이 펼쳐지는 형태
class ExpandableCounterOption extends StatefulWidget {
  final Widget icon;
  final String title;
  final String subtitle;
  final bool enabled;
  final ValueChanged<bool> onEnabledChanged;
  final List<int> presets;
  final int? selectedValue;
  final ValueChanged<int?> onValueChanged;
  final String valueLabel;
  final String? valueTip;

  const ExpandableCounterOption({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.enabled,
    required this.onEnabledChanged,
    required this.presets,
    required this.selectedValue,
    required this.onValueChanged,
    required this.valueLabel,
    this.valueTip,
  });

  @override
  State<ExpandableCounterOption> createState() =>
      _ExpandableCounterOptionState();
}

class _ExpandableCounterOptionState extends State<ExpandableCounterOption>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  final TextEditingController _customValueController = TextEditingController();
  bool _showCustomInput = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    if (widget.enabled) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(ExpandableCounterOption oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled != oldWidget.enabled) {
      if (widget.enabled) {
        _controller.forward();
      } else {
        _controller.reverse();
        _showCustomInput = false;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _customValueController.dispose();
    super.dispose();
  }

  void _onPresetTap(int value) {
    if (widget.selectedValue == value) {
      // 이미 선택된 값을 다시 탭하면 해제
      widget.onValueChanged(null);
    } else {
      widget.onValueChanged(value);
    }
    setState(() {
      _showCustomInput = false;
    });
  }

  void _onCustomInputTap() {
    setState(() {
      _showCustomInput = true;
      _customValueController.text = widget.selectedValue?.toString() ?? '';
    });
  }

  void _onCustomValueSubmit() {
    final value = int.tryParse(_customValueController.text);
    if (value != null && value > 0) {
      widget.onValueChanged(value);
    }
    setState(() {
      _showCustomInput = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.enabled
              ? AppColors.primary.withValues(alpha: 0.5)
              : (isDark ? AppColors.borderDark : AppColors.border),
          width: widget.enabled ? 1.5 : 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 헤더 (아이콘 + 제목 + 토글)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                widget.icon,
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.subtitle,
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
                Switch(
                  value: widget.enabled,
                  onChanged: widget.onEnabledChanged,
                  activeThumbColor: AppColors.primary,
                ),
              ],
            ),
          ),

          // 확장 영역
          SizeTransition(
            sizeFactor: _expandAnimation,
            child: Column(
              children: [
                Divider(
                  height: 1,
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.valueLabel,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 프리셋 버튼 + 직접 입력
                      if (_showCustomInput)
                        _buildCustomInput(isDark)
                      else
                        _buildPresetButtons(isDark),

                      // 팁 텍스트
                      if (widget.valueTip != null) ...[
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(
                              Icons.lightbulb_outline,
                              size: 14,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                      .withValues(alpha: 0.7)
                                  : AppColors.textSecondary
                                      .withValues(alpha: 0.7),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                widget.valueTip!,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                          .withValues(alpha: 0.7)
                                      : AppColors.textSecondary
                                          .withValues(alpha: 0.7),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPresetButtons(bool isDark) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ...widget.presets.map((value) => _buildPresetChip(value, isDark)),
        _buildCustomChip(isDark),
      ],
    );
  }

  Widget _buildPresetChip(int value, bool isDark) {
    final isSelected = widget.selectedValue == value;

    return GestureDetector(
      onTap: () => _onPresetTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary
              : (isDark ? AppColors.backgroundDark : AppColors.background),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? AppColors.borderDark : AppColors.border),
          ),
        ),
        child: Text(
          '$value',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomChip(bool isDark) {
    final hasCustomValue = widget.selectedValue != null &&
        !widget.presets.contains(widget.selectedValue);

    return GestureDetector(
      onTap: _onCustomInputTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: hasCustomValue
              ? AppColors.primary
              : (isDark ? AppColors.backgroundDark : AppColors.background),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: hasCustomValue
                ? AppColors.primary
                : (isDark ? AppColors.borderDark : AppColors.border),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.edit,
              size: 14,
              color: hasCustomValue
                  ? Colors.white
                  : (isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary),
            ),
            const SizedBox(width: 4),
            Text(
              hasCustomValue ? '${widget.selectedValue}' : '직접 입력',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: hasCustomValue
                    ? Colors.white
                    : (isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomInput(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _customValueController,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: InputDecoration(
              hintText: '숫자 입력',
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onSubmitted: (_) => _onCustomValueSubmit(),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: _onCustomValueSubmit,
          icon: const Icon(Icons.check),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              _showCustomInput = false;
            });
          },
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }
}
