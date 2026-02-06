import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/counter.dart';
import 'objectbox_database.dart';

/// 데이터 마이그레이션 유틸리티
class MigrationUtils {
  static const String _migrationV2Key = 'migration_v2_completed';

  /// 마이그레이션 v2: 기존 stitch/pattern 카운터를 secondaryCounters로 이동
  /// 앱 시작 시 한 번만 실행됨
  static Future<void> runMigrationIfNeeded(
    SharedPreferences prefs,
    ObjectBoxDatabase db,
  ) async {
    // 이미 마이그레이션 완료 확인
    if (prefs.getBool(_migrationV2Key) ?? false) {
      return;
    }

    try {
      bool allSucceeded = true;

      // 모든 프로젝트에 대해 마이그레이션 수행
      final projects = db.getAllProjects();
      for (final project in projects) {
        try {
          bool needsSave = false;

          // 기존 stitch 카운터 마이그레이션 (횟수 유형)
          final stitchCounter = project.stitchCounter.target;
          if (stitchCounter != null) {
            // secondaryCounters로 복사
            final newCounter = Counter.secondaryGoal(
              label: stitchCounter.label,
              initialValue: stitchCounter.value,
              targetValue: stitchCounter.targetValue,
              orderIndex: project.secondaryCounters.length,
            );
            db.counterBox.put(newCounter);
            project.secondaryCounters.add(newCounter);

            // 기존 stitch 카운터는 유지 (호환성)
            needsSave = true;
          }

          // 기존 pattern 카운터 마이그레이션 (반복 유형)
          final patternCounter = project.patternCounter.target;
          if (patternCounter != null) {
            // secondaryCounters로 복사
            final newCounter = Counter.secondaryRepetition(
              label: patternCounter.label,
              initialValue: patternCounter.value,
              resetAt: patternCounter.resetAt,
              orderIndex: project.secondaryCounters.length,
            );
            db.counterBox.put(newCounter);
            project.secondaryCounters.add(newCounter);

            // 기존 pattern 카운터는 유지 (호환성)
            needsSave = true;
          }

          if (needsSave) {
            db.saveProject(project);
          }
        } catch (e) {
          debugPrint('Migration v2 failed for project ${project.id}: $e');
          allSucceeded = false;
        }
      }

      // 모든 프로젝트 성공 시에만 완료 플래그 설정
      if (allSucceeded) {
        await prefs.setBool(_migrationV2Key, true);
      }
    } catch (e) {
      debugPrint('Migration v2 failed: $e');
    }
  }
}
