import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:hanko_hanko/core/constants/app_strings.dart';
import 'package:hanko_hanko/data/models/counter.dart';
import 'package:hanko_hanko/data/models/project.dart';
import 'package:hanko_hanko/presentation/providers/app_providers.dart';
import 'package:hanko_hanko/presentation/providers/project_provider.dart';
import 'package:hanko_hanko/presentation/screens/projects/project_list_screen.dart';
import 'package:hanko_hanko/presentation/screens/projects/widgets/project_card.dart';

import '../../../helpers/mocks.dart';
import '../../../helpers/pump_app.dart';
import '../../../helpers/test_helpers.dart';

void main() {
  setUpAll(() {
    registerFallbacks();
  });

  group('ProjectListScreen', () {
    late MockProjectRepository mockRepo;
    late MockLocalStorage mockStorage;

    setUp(() {
      mockRepo = MockProjectRepository();
      mockStorage = MockLocalStorage();
    });

    /// mockRepo/mockStorage를 사용해 ProjectListScreen을 pump하는 헬퍼.
    /// [projects]와 [activeProjectId]로 초기 상태를 지정한다.
    Future<void> pumpScreen(
      WidgetTester tester, {
      List<Project> projects = const [],
      int? activeProjectId,
    }) async {
      when(() => mockRepo.getAllProjects()).thenReturn(projects);
      when(() => mockStorage.getActiveProjectId()).thenReturn(activeProjectId);

      await pumpApp(
        tester,
        const ProjectListScreen(),
        overrides: [
          projectsProvider.overrideWith((ref) {
            return ProjectsNotifier(mockRepo);
          }),
          activeProjectIdProvider.overrideWith((ref) {
            return ActiveProjectIdNotifier(mockStorage);
          }),
        ],
      );
      await tester.pump();
    }

    testWidgets('프로젝트 목록 렌더링 - N개의 ProjectCard 표시', (tester) async {
      final testProjects = [
        createTestProject(id: 1, name: 'Project 1', rowCounter: Counter.row(id: 10)),
        createTestProject(id: 2, name: 'Project 2', rowCounter: Counter.row(id: 11)),
        createTestProject(id: 3, name: 'Project 3', rowCounter: Counter.row(id: 12)),
      ];

      await pumpScreen(tester, projects: testProjects, activeProjectId: 1);

      expect(find.byType(ProjectCard), findsNWidgets(3));
      expect(find.text('Project 1'), findsOneWidget);
      expect(find.text('Project 2'), findsOneWidget);
      expect(find.text('Project 3'), findsOneWidget);
    });

    testWidgets('빈 목록 - empty state UI 표시', (tester) async {
      await pumpScreen(tester);

      expect(find.text(AppStrings.noProjects), findsOneWidget);
      expect(find.byIcon(Icons.texture), findsOneWidget);
      expect(find.byType(ProjectCard), findsNothing);
    });

    testWidgets('AppBar에 내 프로젝트 타이틀 표시', (tester) async {
      await pumpScreen(tester);

      expect(find.text(AppStrings.myProjects), findsOneWidget);
    });

    testWidgets('FAB에 새 프로젝트 버튼 표시', (tester) async {
      await pumpScreen(tester);

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text(AppStrings.newProject), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('initState에서 microtask로 refresh 호출', (tester) async {
      await pumpScreen(tester);

      // 생성자에서 1회 + microtask refresh에서 1회 = 최소 2회 호출
      verify(() => mockRepo.getAllProjects()).called(greaterThanOrEqualTo(2));
    });

    testWidgets('활성 프로젝트 하이라이트 표시', (tester) async {
      final testProjects = [
        createTestProject(id: 1, name: 'Active Project', rowCounter: Counter.row(id: 10)),
        createTestProject(id: 2, name: 'Other Project', rowCounter: Counter.row(id: 11)),
      ];

      await pumpScreen(tester, projects: testProjects, activeProjectId: 1);

      final cardList =
          tester.widgetList<ProjectCard>(find.byType(ProjectCard)).toList();

      expect(cardList[0].isActive, isTrue);
      expect(cardList[1].isActive, isFalse);
    });
  });
}
