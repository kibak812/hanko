import 'dart:convert';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:objectbox/objectbox.dart';
import 'package:path_provider/path_provider.dart';

import '../../data/datasources/local_storage.dart';
import '../../data/datasources/objectbox_database.dart';
import '../../data/models/backup_serialization.dart';
import '../../data/models/models.dart';

/// 데이터 백업/복원 서비스
class BackupService {
  static const int currentBackupVersion = 1;

  final ObjectBoxDatabase db;
  final LocalStorage localStorage;

  BackupService(this.db, this.localStorage);

  /// 전체 데이터를 JSON 문자열로 직렬화
  String createBackupJson() {
    final projects = db.getAllProjects();
    final settings = localStorage.loadSettings();

    final backup = {
      'version': currentBackupVersion,
      'appVersion': '1.0.2',
      'createdAt': DateTime.now().millisecondsSinceEpoch,
      'projectCount': projects.length,
      'data': {
        'projects': projects.map((p) => p.toBackupJson()).toList(),
        'settings': settings.toJson(),
      },
    };

    return jsonEncode(backup);
  }

  /// 임시 디렉토리에 백업 JSON 파일 생성
  Future<File> createBackupFile() async {
    final dir = await getTemporaryDirectory();
    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final file = File('${dir.path}/hanko_backup_$timestamp.json');
    final jsonString = createBackupJson();
    return file.writeAsString(jsonString);
  }

  /// 백업 JSON 유효성 검증 및 메타데이터 반환
  ({int projectCount, String createdAt, String appVersion})? validateBackup(
    String jsonString,
  ) {
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;

      // 스키마 버전 확인
      final version = json['version'] as int?;
      if (version == null || version > currentBackupVersion) return null;

      // 필수 필드 확인
      final data = json['data'] as Map<String, dynamic>?;
      if (data == null) return null;

      final projects = data['projects'] as List<dynamic>?;
      if (projects == null) return null;

      // 메타데이터 추출
      final projectCount = json['projectCount'] as int? ?? projects.length;
      final createdAtMs = json['createdAt'] as int?;
      final createdAt = createdAtMs != null
          ? DateFormat('yyyy-MM-dd HH:mm').format(
              DateTime.fromMillisecondsSinceEpoch(createdAtMs),
            )
          : '';
      final appVersion = json['appVersion'] as String? ?? '';

      return (
        projectCount: projectCount,
        createdAt: createdAt,
        appVersion: appVersion,
      );
    } catch (_) {
      return null;
    }
  }

  /// 백업 JSON으로부터 데이터 복원
  void restoreFromJson(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    final data = json['data'] as Map<String, dynamic>;
    final projectsJson = data['projects'] as List<dynamic>;
    final settingsJson = data['settings'] as Map<String, dynamic>?;

    // 트랜잭션 밖에서 엔티티 변환을 먼저 완료
    final parsedProjects = projectsJson.map((pJson) {
      final pMap = pJson as Map<String, dynamic>;
      final project = projectFromBackupJson(pMap);

      // 메인 카운터들
      final rowCounter = _parseCounter(pMap, 'rowCounter');
      final stitchCounter = _parseCounter(pMap, 'stitchCounter');
      final patternCounter = _parseCounter(pMap, 'patternCounter');

      // 보조 카운터들
      final secondaryCounters = (pMap['secondaryCounters'] as List<dynamic>?)
              ?.map((sc) => counterFromBackupJson(sc as Map<String, dynamic>))
              .toList() ??
          [];

      // 메모들
      final memos = (pMap['memos'] as List<dynamic>?)
              ?.map((m) => rowMemoFromBackupJson(m as Map<String, dynamic>))
              .toList() ??
          [];

      return _ParsedProject(
        project: project,
        rowCounter: rowCounter,
        stitchCounter: stitchCounter,
        patternCounter: patternCounter,
        secondaryCounters: secondaryCounters,
        memos: memos,
      );
    }).toList();

    // 트랜잭션 안에서 DB 조작
    db.store.runInTransaction(TxMode.write, () {
      // 기존 데이터 전체 삭제 (자식 먼저)
      db.counterBox.removeAll();
      db.memoBox.removeAll();
      db.projectBox.removeAll();

      // 각 프로젝트 복원
      for (final parsed in parsedProjects) {
        final project = parsed.project;

        // 메인 카운터 복원
        if (parsed.rowCounter != null) {
          db.counterBox.put(parsed.rowCounter!);
          project.rowCounter.target = parsed.rowCounter;
        }
        if (parsed.stitchCounter != null) {
          db.counterBox.put(parsed.stitchCounter!);
          project.stitchCounter.target = parsed.stitchCounter;
        }
        if (parsed.patternCounter != null) {
          db.counterBox.put(parsed.patternCounter!);
          project.patternCounter.target = parsed.patternCounter;
        }

        // 보조 카운터 복원
        for (final sc in parsed.secondaryCounters) {
          db.counterBox.put(sc);
          project.secondaryCounters.add(sc);
        }

        // 메모 복원
        for (final memo in parsed.memos) {
          db.memoBox.put(memo);
          project.memos.add(memo);
        }

        db.projectBox.put(project);
      }
    });

    // DB 트랜잭션 성공 후 SharedPreferences 설정 반영
    if (settingsJson != null) {
      localStorage.saveSettings(AppSettings.fromJson(settingsJson));
    }
    localStorage.setActiveProjectId(null);
  }
}

/// JSON Map에서 카운터를 파싱하는 헬퍼
Counter? _parseCounter(Map<String, dynamic> json, String key) {
  final counterJson = json[key] as Map<String, dynamic>?;
  if (counterJson == null) return null;
  return counterFromBackupJson(counterJson);
}

/// 파싱된 프로젝트 데이터 (트랜잭션 밖에서 변환, 안에서 저장)
class _ParsedProject {
  final Project project;
  final Counter? rowCounter;
  final Counter? stitchCounter;
  final Counter? patternCounter;
  final List<Counter> secondaryCounters;
  final List<RowMemo> memos;

  const _ParsedProject({
    required this.project,
    this.rowCounter,
    this.stitchCounter,
    this.patternCounter,
    required this.secondaryCounters,
    required this.memos,
  });
}
