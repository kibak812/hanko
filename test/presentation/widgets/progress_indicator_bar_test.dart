import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanko_hanko/core/constants/app_colors.dart';
import 'package:hanko_hanko/presentation/widgets/progress_indicator_bar.dart';

import '../../helpers/pump_app.dart';

void main() {
  group('ProgressIndicatorBar', () {
    testWidgets('기본 렌더링 - LinearProgressIndicator, 단수 텍스트, 퍼센트 뱃지 표시',
        (tester) async {
      await pumpApp(
        tester,
        ProgressIndicatorBar(
          progress: 0.5,
          currentRow: 5,
          targetRow: 10,
        ),
      );

      expect(find.byType(LinearProgressIndicator), findsOneWidget);
      expect(find.text('5/10단'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
    });

    testWidgets('isCompleted=true 일 때 success 색상 적용', (tester) async {
      await pumpApp(
        tester,
        ProgressIndicatorBar(
          progress: 0.8,
          currentRow: 8,
          targetRow: 10,
          isCompleted: true,
        ),
      );

      final indicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      final animation = indicator.valueColor as AlwaysStoppedAnimation<Color>;
      // light theme에서 success 색상 = AppColors.success
      expect(animation.value, equals(AppColors.success));
    });

    testWidgets('progress >= 1.0 일 때 success 색상 적용', (tester) async {
      await pumpApp(
        tester,
        ProgressIndicatorBar(
          progress: 1.0,
          currentRow: 10,
          targetRow: 10,
        ),
      );

      final indicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      final animation = indicator.valueColor as AlwaysStoppedAnimation<Color>;
      expect(animation.value, equals(AppColors.success));
    });

    testWidgets('진행 중 상태에서 primary 색상 적용', (tester) async {
      await pumpApp(
        tester,
        ProgressIndicatorBar(
          progress: 0.3,
          currentRow: 3,
          targetRow: 10,
        ),
      );

      final indicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      final animation = indicator.valueColor as AlwaysStoppedAnimation<Color>;
      // light theme에서 primary 색상 = AppColors.primary
      expect(animation.value, equals(AppColors.primary));
    });

    testWidgets('진행률 0% 표시', (tester) async {
      await pumpApp(
        tester,
        ProgressIndicatorBar(
          progress: 0.0,
          currentRow: 0,
          targetRow: 10,
        ),
      );

      expect(find.text('0/10단'), findsOneWidget);
      expect(find.text('0%'), findsOneWidget);
    });

    testWidgets('진행률 100% 표시', (tester) async {
      await pumpApp(
        tester,
        ProgressIndicatorBar(
          progress: 1.0,
          currentRow: 10,
          targetRow: 10,
        ),
      );

      expect(find.text('10/10단'), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
    });

    testWidgets('커스텀 backgroundColor 적용', (tester) async {
      const customBg = Colors.blue;
      await pumpApp(
        tester,
        ProgressIndicatorBar(
          progress: 0.5,
          currentRow: 5,
          targetRow: 10,
          backgroundColor: customBg,
        ),
      );

      final indicator = tester.widget<LinearProgressIndicator>(
        find.byType(LinearProgressIndicator),
      );
      expect(indicator.backgroundColor, equals(customBg));
    });
  });
}
