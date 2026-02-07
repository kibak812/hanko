import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanko_hanko/core/constants/app_colors.dart';
import 'package:hanko_hanko/core/constants/app_strings.dart';
import 'package:hanko_hanko/data/models/counter.dart';
import 'package:hanko_hanko/data/models/project.dart';
import 'package:hanko_hanko/presentation/screens/projects/widgets/project_card.dart';
import 'package:hanko_hanko/presentation/widgets/progress_indicator_bar.dart';

import '../../../../helpers/pump_app.dart';
import '../../../../helpers/test_helpers.dart';

void main() {
  group('ProjectCard', () {
    late bool tapped;
    late bool edited;
    late bool deleted;

    setUp(() {
      tapped = false;
      edited = false;
      deleted = false;
    });

    Widget buildCard({
      Project? project,
      bool isActive = false,
    }) {
      return ProjectCard(
        project: project ??
            createTestProject(
              id: 1,
              name: 'Test Scarf',
              updatedAt: DateTime.now(),
              rowCounter: Counter.row(id: 10, initialValue: 5, targetRow: 20),
            ),
        isActive: isActive,
        onTap: () => tapped = true,
        onEdit: () => edited = true,
        onDelete: () => deleted = true,
      );
    }

    testWidgets('기본 렌더링 - 프로젝트 이름 표시', (tester) async {
      await pumpApp(tester, buildCard());

      expect(find.text('Test Scarf'), findsOneWidget);
    });

    testWidgets('업데이트 시간 텍스트 표시 - 방금 전', (tester) async {
      final project = createTestProject(
        id: 1,
        name: 'Recent Project',
        updatedAt: DateTime.now(),
        rowCounter: Counter.row(id: 10),
      );
      await pumpApp(tester, buildCard(project: project));

      // DateTime.now()과 거의 동일한 시간이므로 "방금 전" 표시
      expect(find.textContaining('전'), findsWidgets);
    });

    testWidgets('활성 프로젝트 - primary 색상 border 표시', (tester) async {
      await pumpApp(tester, buildCard(isActive: true));

      // isActive=true일 때 Container에 primary 색상 border가 적용됨
      final containers = find.byType(Container);
      bool foundActiveBorder = false;

      for (final element in containers.evaluate()) {
        final widget = element.widget as Container;
        final decoration = widget.decoration;
        if (decoration is BoxDecoration && decoration.border != null) {
          final border = decoration.border as Border;
          if (border.top.color == AppColors.primary && border.top.width == 2) {
            foundActiveBorder = true;
            break;
          }
        }
      }

      expect(foundActiveBorder, isTrue);
    });

    testWidgets('완료된 프로젝트 - check_circle 아이콘 표시', (tester) async {
      final project = createTestProject(
        id: 1,
        name: 'Completed Project',
        statusIndex: ProjectStatus.completed.index,
        rowCounter: Counter.row(id: 10, initialValue: 20, targetRow: 20),
      );
      await pumpApp(tester, buildCard(project: project));

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('targetRow 있을 때 ProgressIndicatorBar 표시', (tester) async {
      final project = createTestProject(
        id: 1,
        name: 'With Target',
        rowCounter: Counter.row(id: 10, initialValue: 5, targetRow: 20),
      );
      await pumpApp(tester, buildCard(project: project));

      expect(find.byType(ProgressIndicatorBar), findsOneWidget);
    });

    testWidgets('targetRow 없을 때 단수 텍스트 표시', (tester) async {
      final project = createTestProject(
        id: 1,
        name: 'No Target',
        rowCounter: Counter.row(id: 10, initialValue: 7),
      );
      await pumpApp(tester, buildCard(project: project));

      expect(find.text('7단'), findsOneWidget);
      expect(find.byType(ProgressIndicatorBar), findsNothing);
    });

    testWidgets('onTap 콜백 호출', (tester) async {
      await pumpApp(tester, buildCard());

      await tester.tap(find.byType(GestureDetector).first);
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('PopupMenu - 편집 콜백 호출', (tester) async {
      await pumpApp(tester, buildCard());

      // more_vert 아이콘 탭
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // 편집 메뉴 아이템 탭
      await tester.tap(find.text(AppStrings.edit));
      await tester.pumpAndSettle();

      expect(edited, isTrue);
    });

    testWidgets('PopupMenu - 삭제 콜백 호출', (tester) async {
      await pumpApp(tester, buildCard());

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.delete));
      await tester.pumpAndSettle();

      expect(deleted, isTrue);
    });

    testWidgets('완료된 프로젝트는 ProgressIndicatorBar에 isCompleted 전달',
        (tester) async {
      final project = createTestProject(
        id: 1,
        name: 'Completed',
        statusIndex: ProjectStatus.completed.index,
        rowCounter: Counter.row(id: 10, initialValue: 20, targetRow: 20),
      );
      await pumpApp(tester, buildCard(project: project));

      final progressBar = tester.widget<ProgressIndicatorBar>(
        find.byType(ProgressIndicatorBar),
      );
      expect(progressBar.isCompleted, isTrue);
    });
  });
}
