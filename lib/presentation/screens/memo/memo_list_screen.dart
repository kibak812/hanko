import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../data/models/row_memo.dart';
import '../../providers/app_providers.dart';
import '../../providers/project_provider.dart';
import '../../widgets/ad_banner_widget.dart';

/// 메모 목록 화면
class MemoListScreen extends ConsumerStatefulWidget {
  final int projectId;

  const MemoListScreen({super.key, required this.projectId});

  @override
  ConsumerState<MemoListScreen> createState() => _MemoListScreenState();
}

class _MemoListScreenState extends ConsumerState<MemoListScreen> {
  @override
  Widget build(BuildContext context) {
    final project = ref.watch(activeProjectProvider);

    if (project == null) {
      return Scaffold(
        appBar: AppBar(title: const Text(AppStrings.memos)),
        body: const Center(child: Text('프로젝트를 찾을 수 없어요')),
      );
    }

    // 메모를 단 번호순으로 정렬
    final memos = project.memos.toList()
      ..sort((a, b) => a.rowNumber.compareTo(b.rowNumber));

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.memos),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showMemoDialog(context, null),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: memos.isEmpty
                ? _buildEmptyState(context)
                : _buildMemoList(context, memos),
          ),
          // 배너 광고 (하단)
          const AdBannerWidget(),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.note_alt_outlined,
              size: 64,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              AppStrings.noMemos,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _showMemoDialog(context, null),
              icon: const Icon(Icons.add),
              label: const Text(AppStrings.addMemo),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemoList(BuildContext context, List<RowMemo> memos) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: memos.length,
      itemBuilder: (context, index) {
        final memo = memos[index];
        return Dismissible(
          key: Key('memo_${memo.id}'),
          direction: DismissDirection.endToStart,
          confirmDismiss: (direction) => _confirmDelete(context, memo),
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 16),
            color: Colors.red,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Text(
                '${memo.rowNumber}',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(memo.content),
            subtitle: Text('${memo.rowNumber}${AppStrings.row}'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _showMemoDialog(context, memo),
          ),
        );
      },
    );
  }

  Future<bool> _confirmDelete(BuildContext context, RowMemo memo) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.delete),
        content: const Text(AppStrings.deleteMemoConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text(AppStrings.delete),
          ),
        ],
      ),
    );

    if (result == true) {
      ref.read(activeProjectCounterProvider.notifier).removeMemo(memo.id);
    }

    return false; // Don't dismiss automatically, we handle it manually
  }

  void _showMemoDialog(BuildContext context, RowMemo? memo) {
    final isEditing = memo != null;
    final rowController = TextEditingController(
      text: memo?.rowNumber.toString() ??
          (ref.read(activeProjectCounterProvider).currentRow + 1).toString(),
    );
    final contentController = TextEditingController(text: memo?.content ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? AppStrings.editMemo : AppStrings.addMemo),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: rowController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: AppStrings.rowNumber,
                  hintText: '예: 50',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  labelText: AppStrings.memoHint,
                  hintText: '예: 코 줄이기 2코',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          if (isEditing)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ref
                    .read(activeProjectCounterProvider.notifier)
                    .removeMemo(memo.id);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text(AppStrings.delete),
            ),
          ElevatedButton(
            onPressed: () async {
              final row = int.tryParse(rowController.text);
              final content = contentController.text.trim();

              if (row != null && content.isNotEmpty) {
                if (isEditing) {
                  ref
                      .read(activeProjectCounterProvider.notifier)
                      .updateMemo(memo.id, row, content);
                } else {
                  ref
                      .read(activeProjectCounterProvider.notifier)
                      .addMemo(row, content);
                }
                Navigator.pop(context);
                // 메모 저장 후 전면 광고 표시
                await ref.read(interstitialAdControllerProvider)?.tryShowAd();
              }
            },
            child: const Text(AppStrings.save),
          ),
        ],
      ),
    );
  }
}
