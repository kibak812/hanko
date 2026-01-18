import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// 프로젝트 인라인 편집기
/// - 상단바 롱프레스 시 표시
/// - 프로젝트명, 목표 단수 편집 가능
/// - 자동 저장: 닫을 때 변경사항 저장
class ProjectInlineEditor extends StatefulWidget {
  final String projectName;
  final int currentRow;
  final int? targetRow;
  final double progress;
  final Rect sourceRect;
  final VoidCallback onClose;
  final void Function(String? name, int? targetRow) onSave;

  const ProjectInlineEditor({
    super.key,
    required this.projectName,
    required this.currentRow,
    this.targetRow,
    required this.progress,
    required this.sourceRect,
    required this.onClose,
    required this.onSave,
  });

  @override
  State<ProjectInlineEditor> createState() => _ProjectInlineEditorState();
}

class _ProjectInlineEditorState extends State<ProjectInlineEditor>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  Animation<Offset>? _positionAnimation;

  late TextEditingController _nameController;
  late TextEditingController _targetController;
  bool _animationsInitialized = false;

  late FocusNode _nameFocusNode;
  late FocusNode _targetFocusNode;
  bool _hasFocus = false;

  String _originalName = '';
  String _originalTarget = '';

  @override
  void initState() {
    super.initState();
    _originalName = widget.projectName;
    _originalTarget = widget.targetRow?.toString() ?? '';

    _nameController = TextEditingController(text: widget.projectName);
    _targetController = TextEditingController(text: _originalTarget);

    _nameFocusNode = FocusNode()..addListener(_onFocusChange);
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
      _hasFocus = _nameFocusNode.hasFocus || _targetFocusNode.hasFocus;
    });
  }

  void _initializePositionAnimation(Size screenSize) {
    if (_animationsInitialized) return;
    _animationsInitialized = true;

    const cardWidth = 280.0;
    const cardHeight = 240.0;

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
    _nameController.dispose();
    _targetController.dispose();
    _nameFocusNode.removeListener(_onFocusChange);
    _targetFocusNode.removeListener(_onFocusChange);
    _nameFocusNode.dispose();
    _targetFocusNode.dispose();
    super.dispose();
  }

  void _handleBackgroundTap() {
    if (_hasFocus) {
      FocusScope.of(context).unfocus();
    } else {
      _handleClose();
    }
  }

  void _handleClose() {
    _saveChangesIfNeeded();
    _controller.reverse().then((_) => widget.onClose());
  }

  void _saveChangesIfNeeded() {
    final newName = _nameController.text.trim();
    final newTarget = int.tryParse(_targetController.text.trim());

    final nameChanged = newName.isNotEmpty && newName != _originalName;
    final targetChanged = _targetController.text.trim() != _originalTarget;

    if (nameChanged || targetChanged) {
      widget.onSave(
        nameChanged ? newName : null,
        targetChanged ? newTarget : widget.targetRow,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;

    _initializePositionAnimation(screenSize);

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
    final progressPercent = (widget.progress * 100).round();
    final successColor = isDark ? AppColors.successDark : AppColors.success;

    return Container(
      width: 280,
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
          // 제목
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '프로젝트 편집',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textPrimary,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 프로젝트명 입력
          TextField(
            controller: _nameController,
            focusNode: _nameFocusNode,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: textPrimary,
            ),
            decoration: InputDecoration(
              isDense: true,
              hintText: '프로젝트명',
              hintStyle: TextStyle(color: textSecondary.withAlpha(100)),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.primary,
                  width: 2,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 현재 진행률
          if (widget.targetRow != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: widget.progress,
                minHeight: 6,
                backgroundColor: isDark ? AppColors.borderDark : AppColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(
                  widget.progress >= 1.0 ? successColor : AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.currentRow}단 완료 ($progressPercent%)',
              style: TextStyle(
                fontSize: 14,
                color: textSecondary,
              ),
            ),
            const SizedBox(height: 16),
          ],

          // 목표 단수 입력
          Row(
            children: [
              Text(
                '목표',
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
                    suffixText: '단',
                    suffixStyle: TextStyle(
                      fontSize: 14,
                      color: textSecondary,
                    ),
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
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 힌트 텍스트
          Text(
            '배경을 탭하면 자동 저장됩니다',
            style: TextStyle(
              fontSize: 12,
              color: textSecondary.withAlpha(150),
            ),
          ),
        ],
      ),
    );
  }
}

/// ProjectInlineEditor를 Overlay로 표시
void showProjectInlineEditor({
  required BuildContext context,
  required String projectName,
  required int currentRow,
  int? targetRow,
  required double progress,
  required Rect sourceRect,
  required void Function(String? name, int? targetRow) onSave,
}) {
  late OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) => ProjectInlineEditor(
      projectName: projectName,
      currentRow: currentRow,
      targetRow: targetRow,
      progress: progress,
      sourceRect: sourceRect,
      onClose: () => overlayEntry.remove(),
      onSave: onSave,
    ),
  );

  Overlay.of(context).insert(overlayEntry);
}
