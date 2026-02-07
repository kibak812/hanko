import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hanko_hanko/domain/services/backup_service.dart';
import 'package:hanko_hanko/data/datasources/local_storage.dart';
import 'package:hanko_hanko/data/datasources/objectbox_database.dart';
import 'package:mocktail/mocktail.dart';

class MockObjectBoxDatabase extends Mock implements ObjectBoxDatabase {}

class MockLocalStorage extends Mock implements LocalStorage {}

void main() {
  late MockObjectBoxDatabase mockDb;
  late MockLocalStorage mockLocalStorage;
  late BackupService backupService;

  setUp(() {
    mockDb = MockObjectBoxDatabase();
    mockLocalStorage = MockLocalStorage();
    backupService = BackupService(mockDb, mockLocalStorage);
  });

  // ============ validateBackup ============

  group('BackupService - validateBackup', () {
    test('유효한 백업 JSON에서 메타데이터 반환', () {
      final now = DateTime(2025, 6, 15, 14, 30);
      final json = jsonEncode({
        'version': 1,
        'appVersion': '1.0.2',
        'createdAt': now.millisecondsSinceEpoch,
        'projectCount': 3,
        'data': {
          'projects': [{}, {}, {}],
          'settings': {},
        },
      });

      final result = backupService.validateBackup(json);

      expect(result, isNotNull);
      expect(result!.projectCount, 3);
      expect(result.appVersion, '1.0.2');
      expect(result.createdAt, isNotEmpty);
    });

    test('잘못된 JSON 문자열이면 null 반환', () {
      final result = backupService.validateBackup('not json at all');
      expect(result, isNull);
    });

    test('빈 문자열이면 null 반환', () {
      final result = backupService.validateBackup('');
      expect(result, isNull);
    });

    test('version 필드가 없으면 null 반환', () {
      final json = jsonEncode({
        'data': {
          'projects': [],
        },
      });

      final result = backupService.validateBackup(json);
      expect(result, isNull);
    });

    test('version이 현재 버전보다 높으면 null 반환', () {
      final json = jsonEncode({
        'version': 999,
        'data': {
          'projects': [],
        },
      });

      final result = backupService.validateBackup(json);
      expect(result, isNull);
    });

    test('data 필드가 없으면 null 반환', () {
      final json = jsonEncode({
        'version': 1,
      });

      final result = backupService.validateBackup(json);
      expect(result, isNull);
    });

    test('data.projects 필드가 없으면 null 반환', () {
      final json = jsonEncode({
        'version': 1,
        'data': {
          'settings': {},
        },
      });

      final result = backupService.validateBackup(json);
      expect(result, isNull);
    });

    test('빈 프로젝트 배열은 유효', () {
      final json = jsonEncode({
        'version': 1,
        'projectCount': 0,
        'data': {
          'projects': [],
        },
      });

      final result = backupService.validateBackup(json);

      expect(result, isNotNull);
      expect(result!.projectCount, 0);
    });

    test('projectCount가 없으면 projects 배열 길이 사용', () {
      final json = jsonEncode({
        'version': 1,
        'data': {
          'projects': [{'name': 'a'}, {'name': 'b'}],
        },
      });

      final result = backupService.validateBackup(json);

      expect(result, isNotNull);
      expect(result!.projectCount, 2);
    });

    test('appVersion이 없으면 빈 문자열', () {
      final json = jsonEncode({
        'version': 1,
        'data': {
          'projects': [],
        },
      });

      final result = backupService.validateBackup(json);

      expect(result, isNotNull);
      expect(result!.appVersion, '');
    });

    test('createdAt이 없으면 빈 날짜 문자열', () {
      final json = jsonEncode({
        'version': 1,
        'data': {
          'projects': [],
        },
      });

      final result = backupService.validateBackup(json);

      expect(result, isNotNull);
      expect(result!.createdAt, '');
    });

    test('version 1은 유효', () {
      final json = jsonEncode({
        'version': 1,
        'data': {
          'projects': [],
        },
      });

      final result = backupService.validateBackup(json);
      expect(result, isNotNull);
    });
  });
}
