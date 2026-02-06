import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';

/// 날짜 편집 바텀시트
void showDateEditSheet({
  required BuildContext context,
  required DateTime? startDate,
  required DateTime? completedDate,
  required void Function(DateTime?) onStartDateChanged,
  required void Function(DateTime?) onCompletedDateChanged,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _DateEditSheet(
      startDate: startDate,
      completedDate: completedDate,
      onStartDateChanged: onStartDateChanged,
      onCompletedDateChanged: onCompletedDateChanged,
    ),
  );
}

class _DateEditSheet extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? completedDate;
  final void Function(DateTime?) onStartDateChanged;
  final void Function(DateTime?) onCompletedDateChanged;

  const _DateEditSheet({
    required this.startDate,
    required this.completedDate,
    required this.onStartDateChanged,
    required this.onCompletedDateChanged,
  });

  @override
  State<_DateEditSheet> createState() => _DateEditSheetState();
}

class _DateEditSheetState extends State<_DateEditSheet> {
  late DateTime? _startDate;
  late DateTime? _completedDate;

  @override
  void initState() {
    super.initState();
    _startDate = widget.startDate;
    _completedDate = widget.completedDate;
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => _startDate = picked);
      widget.onStartDateChanged(picked);
    }
  }

  Future<void> _pickCompletedDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _completedDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => _completedDate = picked);
      widget.onCompletedDateChanged(picked);
    }
  }

  void _clearStartDate() {
    setState(() => _startDate = null);
    widget.onStartDateChanged(null);
  }

  void _clearCompletedDate() {
    setState(() => _completedDate = null);
    widget.onCompletedDateChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    final backgroundColor = context.surface;
    final textColor = context.textPrimary;
    final secondaryColor = context.textSecondary;
    final borderColor = context.border;

    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    AppStrings.editSchedule,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close, color: secondaryColor),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 시작일
              Text(
                AppStrings.startDateLabel,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: secondaryColor,
                ),
              ),
              const SizedBox(height: 8),
              _DateField(
                date: _startDate,
                placeholder: AppStrings.setDate,
                onTap: _pickStartDate,
                onClear: _startDate != null ? _clearStartDate : null,
                borderColor: borderColor,
                textColor: textColor,
                secondaryColor: secondaryColor,
              ),
              const SizedBox(height: 20),

              // 완료일
              Text(
                AppStrings.completedDateLabel,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: secondaryColor,
                ),
              ),
              const SizedBox(height: 8),
              _DateField(
                date: _completedDate,
                placeholder: AppStrings.setDate,
                onTap: _pickCompletedDate,
                onClear: _completedDate != null ? _clearCompletedDate : null,
                borderColor: borderColor,
                textColor: textColor,
                secondaryColor: secondaryColor,
              ),

              if (_completedDate != null) ...[
                const SizedBox(height: 12),
                Text(
                  AppStrings.completedDateInfo,
                  style: TextStyle(
                    fontSize: 12,
                    color: secondaryColor,
                  ),
                ),
              ],

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final DateTime? date;
  final String placeholder;
  final VoidCallback onTap;
  final VoidCallback? onClear;
  final Color borderColor;
  final Color textColor;
  final Color secondaryColor;

  const _DateField({
    required this.date,
    required this.placeholder,
    required this.onTap,
    this.onClear,
    required this.borderColor,
    required this.textColor,
    required this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                date != null
                    ? DateFormat('yyyy년 M월 d일').format(date!)
                    : placeholder,
                style: TextStyle(
                  fontSize: 16,
                  color: date != null ? textColor : secondaryColor,
                ),
              ),
            ),
            if (onClear != null)
              GestureDetector(
                onTap: onClear,
                child: Icon(Icons.close, size: 20, color: secondaryColor),
              )
            else
              Icon(Icons.calendar_today_outlined, size: 20, color: secondaryColor),
          ],
        ),
      ),
    );
  }
}
