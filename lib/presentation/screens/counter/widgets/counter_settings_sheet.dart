import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../data/models/counter.dart';

/// 카운터 설정 바텀시트
class CounterSettingsSheet extends StatefulWidget {
  final CounterType type;
  final int currentValue;
  final int? targetValue;
  final int? resetAt;
  final VoidCallback onReset;
  final ValueChanged<int?> onTargetChanged;
  final VoidCallback? onRemove;

  const CounterSettingsSheet({
    super.key,
    required this.type,
    required this.currentValue,
    this.targetValue,
    this.resetAt,
    required this.onReset,
    required this.onTargetChanged,
    this.onRemove,
  });

  @override
  State<CounterSettingsSheet> createState() => _CounterSettingsSheetState();
}

class _CounterSettingsSheetState extends State<CounterSettingsSheet> {
  late int? _selectedValue;
  final TextEditingController _customController = TextEditingController();
  bool _showCustomInput = false;

  bool get isStitch => widget.type == CounterType.stitch;

  String get title => isStitch ? '코 카운터 설정' : '패턴 카운터 설정';

  String get valueLabel => isStitch ? '목표 코 수' : '자동 리셋';

  List<int> get presets => isStitch ? [10, 20, 30] : [4, 6, 8];

  int? get displayTarget => isStitch ? widget.targetValue : widget.resetAt;

  @override
  void initState() {
    super.initState();
    _selectedValue = displayTarget;
  }

  void _onPresetTap(int value) {
    setState(() {
      if (_selectedValue == value) {
        _selectedValue = null;
      } else {
        _selectedValue = value;
      }
      _showCustomInput = false;
    });
  }

  void _onCustomSubmit() {
    final value = int.tryParse(_customController.text);
    if (value != null && value > 0) {
      setState(() {
        _selectedValue = value;
        _showCustomInput = false;
      });
    }
  }

  void _onSave() {
    widget.onTargetChanged(_selectedValue);
    Navigator.pop(context);
  }

  void _onReset() {
    widget.onReset();
    Navigator.pop(context);
  }

  void _onRemove() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('카운터 제거'),
        content: const Text('이 카운터를 제거할까요?\n현재 값은 사라집니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // 다이얼로그 닫기
              Navigator.pop(context); // 바텀시트 닫기
              widget.onRemove?.call();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('제거'),
          ),
        ],
      ),
    );
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
          const SizedBox(height: 16),

          // 헤더
          Row(
            children: [
              isStitch
                  ? AppIcons.stitchIcon(size: 24, color: AppColors.primary)
                  : AppIcons.patternIcon(size: 24, color: AppColors.primary),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 현재 값 표시
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.backgroundDark : AppColors.background,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '현재: ',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
                Text(
                  '${widget.currentValue}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary,
                  ),
                ),
                if (displayTarget != null) ...[
                  Text(
                    ' / $displayTarget',
                    style: TextStyle(
                      fontSize: 16,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 목표 변경
          Text(
            valueLabel,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),

          if (_showCustomInput)
            _buildCustomInput(isDark)
          else
            _buildPresetButtons(isDark),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // 액션 버튼
          Row(
            children: [
              // 리셋 버튼
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _onReset,
                  icon: const Icon(Icons.refresh),
                  label: const Text('리셋'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // 저장 버튼
              Expanded(
                child: ElevatedButton(
                  onPressed: _onSave,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text('저장'),
                ),
              ),
            ],
          ),

          // 제거 버튼 (옵션)
          if (widget.onRemove != null) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: _onRemove,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                ),
                child: const Text('카운터 제거'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPresetButtons(bool isDark) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        // 없음 버튼
        _buildChip(
          label: '없음',
          isSelected: _selectedValue == null,
          onTap: () {
            setState(() {
              _selectedValue = null;
              _showCustomInput = false;
            });
          },
          isDark: isDark,
        ),
        // 프리셋 버튼들
        ...presets.map((value) => _buildChip(
              label: '$value',
              isSelected: _selectedValue == value,
              onTap: () => _onPresetTap(value),
              isDark: isDark,
            )),
        // 직접 입력
        _buildCustomChip(isDark),
      ],
    );
  }

  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
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
          label,
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
    final hasCustomValue =
        _selectedValue != null && !presets.contains(_selectedValue);

    return GestureDetector(
      onTap: () {
        setState(() {
          _showCustomInput = true;
          _customController.text = _selectedValue?.toString() ?? '';
        });
      },
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
              hasCustomValue ? '$_selectedValue' : '직접 입력',
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
            controller: _customController,
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
            onSubmitted: (_) => _onCustomSubmit(),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: _onCustomSubmit,
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

/// 카운터 설정 바텀시트 표시 헬퍼
void showCounterSettingsSheet({
  required BuildContext context,
  required CounterType type,
  required int currentValue,
  int? targetValue,
  int? resetAt,
  required VoidCallback onReset,
  required ValueChanged<int?> onTargetChanged,
  VoidCallback? onRemove,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => CounterSettingsSheet(
      type: type,
      currentValue: currentValue,
      targetValue: targetValue,
      resetAt: resetAt,
      onReset: onReset,
      onTargetChanged: onTargetChanged,
      onRemove: onRemove,
    ),
  );
}

/// 동적 보조 카운터 설정 바텀시트 표시 헬퍼
void showSecondaryCounterSettingsSheet({
  required BuildContext context,
  required int counterId,
  required String label,
  required SecondaryCounterType type,
  required int currentValue,
  int? targetValue,
  int? resetAt,
  required VoidCallback onReset,
  required void Function(String? label, int? targetValue) onSave,
  VoidCallback? onRemove,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => SecondaryCounterSettingsSheet(
      counterId: counterId,
      label: label,
      type: type,
      currentValue: currentValue,
      targetValue: targetValue,
      resetAt: resetAt,
      onReset: onReset,
      onSave: onSave,
      onRemove: onRemove,
    ),
  );
}

/// 동적 보조 카운터 설정 시트 (심플 버전)
class SecondaryCounterSettingsSheet extends StatefulWidget {
  final int counterId;
  final String label;
  final SecondaryCounterType type;
  final int currentValue;
  final int? targetValue;
  final int? resetAt;
  final VoidCallback onReset;
  final void Function(String? label, int? targetValue) onSave;
  final VoidCallback? onRemove;

  const SecondaryCounterSettingsSheet({
    super.key,
    required this.counterId,
    required this.label,
    required this.type,
    required this.currentValue,
    this.targetValue,
    this.resetAt,
    required this.onReset,
    required this.onSave,
    this.onRemove,
  });

  @override
  State<SecondaryCounterSettingsSheet> createState() =>
      _SecondaryCounterSettingsSheetState();
}

class _SecondaryCounterSettingsSheetState
    extends State<SecondaryCounterSettingsSheet> {
  late TextEditingController _labelController;
  late TextEditingController _targetController;
  bool _isEditingLabel = false;

  bool get isGoalType => widget.type == SecondaryCounterType.goal;
  String get valueLabel => isGoalType ? '목표 (선택)' : '주기 (선택)';
  String get valueHint => isGoalType ? '예: 10' : '예: 4';
  int? get displayTarget => isGoalType ? widget.targetValue : widget.resetAt;

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: widget.label);
    _targetController = TextEditingController(
      text: displayTarget?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _labelController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  void _onSave() {
    final newLabel = _labelController.text.trim();
    final newTarget = int.tryParse(_targetController.text.trim());

    // 변경사항 확인
    final labelChanged = newLabel.isNotEmpty && newLabel != widget.label;
    final targetChanged = newTarget != displayTarget;

    if (labelChanged || targetChanged) {
      widget.onSave(
        labelChanged ? newLabel : null,
        targetChanged ? newTarget : displayTarget,
      );
    }
    Navigator.pop(context);
  }

  void _onReset() {
    widget.onReset();
    Navigator.pop(context);
  }

  void _onRemove() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('카운터 제거'),
        content: const Text('이 카운터를 제거할까요?\n현재 값은 사라집니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              widget.onRemove?.call();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('제거'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Container(
        // 키보드가 올라와도 바텀시트 높이 고정
        height: 420 + (widget.onRemove != null ? 48 : 0),
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
                  // 라벨 (터치하여 편집)
                  GestureDetector(
                    onTap: () {
                      setState(() => _isEditingLabel = true);
                    },
                    child: _isEditingLabel
                        ? TextField(
                            controller: _labelController,
                            autofocus: true,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary,
                            ),
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              suffixIcon: IconButton(
                                icon: const Icon(Icons.check, size: 20),
                                onPressed: () {
                                  setState(() => _isEditingLabel = false);
                                },
                              ),
                            ),
                            onSubmitted: (_) {
                              setState(() => _isEditingLabel = false);
                            },
                          )
                        : Row(
                            children: [
                              Icon(
                                isGoalType ? Icons.flag : Icons.refresh,
                                size: 20,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _labelController.text,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.edit,
                                size: 16,
                                color: textSecondary.withAlpha(128),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isGoalType ? '횟수 카운터' : '반복 카운터',
                    style: TextStyle(
                      fontSize: 12,
                      color: textSecondary,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 현재 값
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.backgroundDark
                          : AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${widget.currentValue}',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                          ),
                        ),
                        if (displayTarget != null)
                          Text(
                            '/ $displayTarget',
                            style: TextStyle(
                              fontSize: 14,
                              color: textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 목표/주기 입력
                  Text(
                    valueLabel,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _targetController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: valueHint,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 액션 버튼
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _onReset,
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('리셋'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _onSave,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: const Text('저장'),
                        ),
                      ),
                    ],
                  ),

                  // 제거 버튼
                  if (widget.onRemove != null) ...[
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: _onRemove,
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.error,
                        ),
                        child: const Text('카운터 제거'),
                      ),
                    ),
                  ],
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
