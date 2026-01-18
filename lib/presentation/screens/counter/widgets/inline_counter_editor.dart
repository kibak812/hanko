import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/counter.dart';
import '../../../widgets/dialogs.dart';

/// 인라인 카운터 편집기
/// - 원본 카운터 위치에서 확대되어 중앙으로 이동
/// - 하나의 통합된 카드 UI
/// - 자동 저장: 닫을 때 변경사항 저장
class InlineCounterEditor extends StatefulWidget {
  final String label;
  final SecondaryCounterType type;
  final int currentValue;
  final int? targetValue;
  final int? resetAt;
  final Rect sourceRect;
  final VoidCallback onClose;
  final VoidCallback onReset;
  final void Function(String? label, int? targetValue, SecondaryCounterType? newType) onSave;
  final VoidCallback? onRemove;

  const InlineCounterEditor({
    super.key,
    required this.label,
    required this.type,
    required this.currentValue,
    this.targetValue,
    this.resetAt,
    required this.sourceRect,
    required this.onClose,
    required this.onReset,
    required this.onSave,
    this.onRemove,
  });

  @override
  State<InlineCounterEditor> createState() => _InlineCounterEditorState();
}

class _InlineCounterEditorState extends State<InlineCounterEditor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  Animation<Offset>? _positionAnimation;

  late TextEditingController _labelController;
  late TextEditingController _targetController;
  late SecondaryCounterType _currentType;
  bool _animationsInitialized = false;

  // 포커스 상태 추적 (키보드 닫기용)
  late FocusNode _labelFocusNode;
  late FocusNode _targetFocusNode;
  bool _hasFocus = false;

  String _originalLabel = '';
  String _originalTarget = '';
  SecondaryCounterType? _originalType;

  bool get isGoalType => _currentType == SecondaryCounterType.goal;
  int? get displayTarget => widget.type == SecondaryCounterType.goal
      ? widget.targetValue
      : widget.resetAt;

  @override
  void initState() {
    super.initState();
    _currentType = widget.type;
    _originalType = widget.type;
    _originalLabel = widget.label;
    _originalTarget = displayTarget?.toString() ?? '';

    _labelController = TextEditingController(text: widget.label);
    _targetController = TextEditingController(text: _originalTarget);

    _labelFocusNode = FocusNode()..addListener(_onFocusChange);
    _targetFocusNode = FocusNode()..addListener(_onFocusChange);

    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      reverseDuration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  void _onFocusChange() {
    setState(() {
      _hasFocus = _labelFocusNode.hasFocus || _targetFocusNode.hasFocus;
    });
  }

  void _initializePositionAnimation(Size screenSize) {
    if (_animationsInitialized) return;
    _animationsInitialized = true;

    const cardWidth = 240.0;
    const cardHeight = 280.0;

    final targetX = (screenSize.width - cardWidth) / 2;
    final targetY = (screenSize.height - cardHeight) / 2;

    _positionAnimation = Tween<Offset>(
      begin: Offset(widget.sourceRect.center.dx - cardWidth / 2,
          widget.sourceRect.center.dy - cardHeight / 2),
      end: Offset(targetX, targetY),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _labelController.dispose();
    _targetController.dispose();
    _labelFocusNode.removeListener(_onFocusChange);
    _targetFocusNode.removeListener(_onFocusChange);
    _labelFocusNode.dispose();
    _targetFocusNode.dispose();
    super.dispose();
  }

  /// 배경 탭 핸들러: 키보드 열려있으면 키보드만 닫고, 아니면 편집기 닫기
  void _handleBackgroundTap() {
    if (_hasFocus) {
      // 키보드가 열려있으면 포커스 해제 (키보드만 닫기)
      FocusScope.of(context).unfocus();
    } else {
      // 키보드가 없으면 편집기 닫기
      _handleClose();
    }
  }

  void _handleClose() {
    _saveChangesIfNeeded();
    _controller.reverse().then((_) => widget.onClose());
  }

  void _saveChangesIfNeeded() {
    final newLabel = _labelController.text.trim();
    final newTarget = int.tryParse(_targetController.text.trim());

    final labelChanged = newLabel.isNotEmpty && newLabel != _originalLabel;
    final targetChanged = _targetController.text.trim() != _originalTarget;
    final typeChanged = _currentType != _originalType;

    if (labelChanged || targetChanged || typeChanged) {
      widget.onSave(
        labelChanged ? newLabel : null,
        targetChanged ? newTarget : displayTarget,
        typeChanged ? _currentType : null,
      );
    }
  }

  void _handleReset() {
    widget.onReset();
    _controller.reverse().then((_) => widget.onClose());
  }

  Future<void> _handleRemove() async {
    final confirmed = await showRemoveCounterDialog(context);
    if (confirmed && mounted) {
      _controller.reverse().then((_) {
        widget.onClose();
        widget.onRemove?.call();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;

    _initializePositionAnimation(screenSize);

    // 키보드 높이 감지
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final hasKeyboard = keyboardHeight > 0;

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          // 배경
          GestureDetector(
            onTap: _handleBackgroundTap,
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) => Container(
                color: Colors.black.withValues(alpha: 0.5 * _fadeAnimation.value),
              ),
            ),
          ),

          // 편집 카드
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              final position = _positionAnimation?.value ??
                  Offset(widget.sourceRect.left, widget.sourceRect.top);

              // 키보드가 열렸을 때 카드 위치 조정
              final adjustedTop = hasKeyboard
                  ? (position.dy - keyboardHeight / 2).clamp(40.0, position.dy)
                  : position.dy;

              return AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                left: position.dx,
                top: adjustedTop,
                child: Opacity(
                  opacity: _fadeAnimation.value.clamp(0.0, 1.0),
                  child: Transform.scale(
                    scale: 0.8 + (0.2 * _controller.value),
                    child: GestureDetector(
                      onTap: () {},
                      child: _buildEditCard(isDark),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEditCard(bool isDark) {
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimary;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final hasTarget = displayTarget != null;
    final isCompleted = widget.type == SecondaryCounterType.goal &&
        widget.targetValue != null &&
        widget.currentValue >= widget.targetValue!;
    final progress = hasTarget
        ? (widget.currentValue / displayTarget!).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      width: 240,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 타입 선택 (세그먼트)
          _buildTypeSegment(isDark),

          const SizedBox(height: 16),

          // 라벨 입력
          TextField(
            controller: _labelController,
            focusNode: _labelFocusNode,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
            decoration: InputDecoration(
              isDense: true,
              hintText: '라벨',
              hintStyle: TextStyle(color: textSecondary.withAlpha(100)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 현재 값 (큰 숫자)
          Text(
            '${widget.currentValue}',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w700,
              color: isCompleted ? AppColors.success : textPrimary,
            ),
          ),

          // 프로그레스 바 (목표 있을 때)
          if (hasTarget) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: isDark ? AppColors.borderDark : AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isCompleted ? AppColors.success : AppColors.primary,
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // 목표/주기 입력
          Row(
            children: [
              Text(
                isGoalType ? '목표' : '주기',
                style: TextStyle(
                  fontSize: 14,
                  color: textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _targetController,
                  focusNode: _targetFocusNode,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: textPrimary,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: '없음',
                    hintStyle: TextStyle(color: textSecondary.withAlpha(100)),
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: isDark ? AppColors.borderDark : AppColors.border,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: isDark ? AppColors.borderDark : AppColors.border,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 액션 버튼들
          Row(
            children: [
              Expanded(
                child: _buildActionButton(
                  label: '리셋',
                  icon: Icons.refresh,
                  onTap: _handleReset,
                  isDark: isDark,
                ),
              ),
              if (widget.onRemove != null) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: _buildActionButton(
                    label: '제거',
                    icon: Icons.delete_outline,
                    onTap: _handleRemove,
                    isDark: isDark,
                    isDestructive: true,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSegment(bool isDark) {
    final unselectedColor =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondary;
    final bgColor = isDark
        ? AppColors.borderDark.withAlpha(100)
        : AppColors.border.withAlpha(100);

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _currentType = SecondaryCounterType.goal),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isGoalType
                      ? (isDark ? AppColors.surfaceDark : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: isGoalType
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                          )
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.flag,
                      size: 16,
                      color: isGoalType ? AppColors.primary : unselectedColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '목표',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isGoalType ? FontWeight.w600 : FontWeight.w500,
                        color: isGoalType ? AppColors.primary : unselectedColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () =>
                  setState(() => _currentType = SecondaryCounterType.repetition),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: !isGoalType
                      ? (isDark ? AppColors.surfaceDark : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: !isGoalType
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                          )
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.refresh,
                      size: 16,
                      color: !isGoalType ? AppColors.primary : unselectedColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '반복',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            !isGoalType ? FontWeight.w600 : FontWeight.w500,
                        color: !isGoalType ? AppColors.primary : unselectedColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
    bool isDestructive = false,
  }) {
    final color = isDestructive
        ? AppColors.error
        : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isDestructive
              ? AppColors.error.withAlpha(20)
              : (isDark
                  ? AppColors.borderDark.withAlpha(100)
                  : AppColors.border.withAlpha(100)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// InlineCounterEditor를 Overlay로 표시
void showInlineCounterEditor({
  required BuildContext context,
  required String label,
  required SecondaryCounterType type,
  required int currentValue,
  int? targetValue,
  int? resetAt,
  required Rect sourceRect,
  required VoidCallback onReset,
  required void Function(String? label, int? targetValue, SecondaryCounterType? newType) onSave,
  VoidCallback? onRemove,
}) {
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => InlineCounterEditor(
      label: label,
      type: type,
      currentValue: currentValue,
      targetValue: targetValue,
      resetAt: resetAt,
      sourceRect: sourceRect,
      onClose: () => overlayEntry.remove(),
      onReset: onReset,
      onSave: onSave,
      onRemove: onRemove,
    ),
  );

  Overlay.of(context).insert(overlayEntry);
}
