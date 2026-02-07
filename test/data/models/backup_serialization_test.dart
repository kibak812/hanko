import 'package:flutter_test/flutter_test.dart';
import 'package:hanko_hanko/data/models/counter.dart';
import 'package:hanko_hanko/data/models/row_memo.dart';
import 'package:hanko_hanko/data/models/project.dart';
import 'package:hanko_hanko/data/models/backup_serialization.dart';

import '../../helpers/test_helpers.dart';

void main() {
  // ============ Counter 직렬화 ============

  group('CounterBackupJson - toBackupJson', () {
    test('모든 필드를 포함하고 id는 제외', () {
      final counter = createTestCounter(
        id: 42,
        typeIndex: 1,
        label: '코',
        value: 15,
        targetValue: 100,
        resetAt: 10,
        autoResetEnabled: true,
        secondaryTypeIndex: 1,
        orderIndex: 2,
        isLinked: true,
      );

      final json = counter.toBackupJson();

      expect(json.containsKey('id'), isFalse);
      expect(json['typeIndex'], 1);
      expect(json['label'], '코');
      expect(json['value'], 15);
      expect(json['targetValue'], 100);
      expect(json['resetAt'], 10);
      expect(json['autoResetEnabled'], true);
      expect(json['secondaryTypeIndex'], 1);
      expect(json['orderIndex'], 2);
      expect(json['isLinked'], true);
    });

    test('nullable 필드가 null일 때 null로 직렬화', () {
      final counter = createTestCounter(id: 1, label: '단');

      final json = counter.toBackupJson();

      expect(json['targetValue'], isNull);
      expect(json['resetAt'], isNull);
    });
  });

  group('counterFromBackupJson', () {
    test('JSON에서 Counter 복원 - id는 항상 0', () {
      final json = {
        'typeIndex': 2,
        'label': '반복',
        'value': 5,
        'targetValue': 20,
        'resetAt': 10,
        'autoResetEnabled': true,
        'secondaryTypeIndex': 0,
        'orderIndex': 3,
        'isLinked': false,
      };

      final counter = counterFromBackupJson(json);

      expect(counter.id, 0);
      expect(counter.typeIndex, 2);
      expect(counter.label, '반복');
      expect(counter.value, 5);
      expect(counter.targetValue, 20);
      expect(counter.resetAt, 10);
      expect(counter.autoResetEnabled, true);
      expect(counter.secondaryTypeIndex, 0);
      expect(counter.orderIndex, 3);
      expect(counter.isLinked, false);
    });

    test('typeIndex 범위 초과 시 0으로 보정', () {
      final counter = counterFromBackupJson({'typeIndex': 5, 'label': 'x'});
      expect(counter.typeIndex, 0);
    });

    test('typeIndex 음수 시 0으로 보정', () {
      final counter = counterFromBackupJson({'typeIndex': -1, 'label': 'x'});
      expect(counter.typeIndex, 0);
    });

    test('secondaryTypeIndex 범위 초과 시 0으로 보정', () {
      final counter = counterFromBackupJson({
        'label': 'x',
        'secondaryTypeIndex': 3,
      });
      expect(counter.secondaryTypeIndex, 0);
    });

    test('필드 누락 시 기본값 적용', () {
      final counter = counterFromBackupJson({});

      expect(counter.id, 0);
      expect(counter.typeIndex, 0);
      expect(counter.label, '');
      expect(counter.value, 0);
      expect(counter.targetValue, isNull);
      expect(counter.autoResetEnabled, false);
      expect(counter.isLinked, false);
    });

    test('round-trip: toBackupJson → counterFromBackupJson', () {
      final original = createTestCounter(
        id: 99,
        typeIndex: 1,
        label: '코',
        value: 42,
        targetValue: 100,
        resetAt: 5,
        autoResetEnabled: true,
        secondaryTypeIndex: 1,
        orderIndex: 7,
        isLinked: true,
      );

      final restored = counterFromBackupJson(original.toBackupJson());

      expect(restored.id, 0); // ID는 항상 0
      expect(restored.typeIndex, original.typeIndex);
      expect(restored.label, original.label);
      expect(restored.value, original.value);
      expect(restored.targetValue, original.targetValue);
      expect(restored.resetAt, original.resetAt);
      expect(restored.autoResetEnabled, original.autoResetEnabled);
      expect(restored.secondaryTypeIndex, original.secondaryTypeIndex);
      expect(restored.orderIndex, original.orderIndex);
      expect(restored.isLinked, original.isLinked);
    });
  });

  // ============ RowMemo 직렬화 ============

  group('RowMemoBackupJson - toBackupJson', () {
    test('모든 필드를 포함하고 id는 제외', () {
      final memo = createTestMemo(
        id: 10,
        rowNumber: 25,
        content: '코 줄이기',
        notified: true,
      );

      final json = memo.toBackupJson();

      expect(json.containsKey('id'), isFalse);
      expect(json['rowNumber'], 25);
      expect(json['content'], '코 줄이기');
      expect(json['notified'], true);
    });
  });

  group('rowMemoFromBackupJson', () {
    test('JSON에서 RowMemo 복원 - id는 항상 0', () {
      final json = {
        'rowNumber': 30,
        'content': '색상 변경',
        'notified': false,
      };

      final memo = rowMemoFromBackupJson(json);

      expect(memo.id, 0);
      expect(memo.rowNumber, 30);
      expect(memo.content, '색상 변경');
      expect(memo.notified, false);
    });

    test('필드 누락 시 기본값 적용', () {
      final memo = rowMemoFromBackupJson({});

      expect(memo.id, 0);
      expect(memo.rowNumber, 0);
      expect(memo.content, '');
      expect(memo.notified, false);
    });

    test('round-trip: toBackupJson → rowMemoFromBackupJson', () {
      final original = createTestMemo(
        id: 55,
        rowNumber: 12,
        content: '무늬 시작',
        notified: true,
      );

      final restored = rowMemoFromBackupJson(original.toBackupJson());

      expect(restored.id, 0);
      expect(restored.rowNumber, original.rowNumber);
      expect(restored.content, original.content);
      expect(restored.notified, original.notified);
    });
  });

  // ============ Project 직렬화 ============

  group('ProjectBackupJson - toBackupJson', () {
    test('기본 필드를 올바르게 직렬화', () {
      final project = createTestProject(
        id: 5,
        name: '머플러',
        statusIndex: 1,
        createdAt: fixedNow,
        updatedAt: fixedNow,
        totalWorkSeconds: 3600,
      );

      final json = project.toBackupJson();

      expect(json.containsKey('id'), isFalse);
      expect(json['name'], '머플러');
      expect(json['statusIndex'], 1);
      expect(json['createdAt'], fixedNow.millisecondsSinceEpoch);
      expect(json['updatedAt'], fixedNow.millisecondsSinceEpoch);
      expect(json['totalWorkSeconds'], 3600);
      expect(json['counterHistoryJson'], '[]');
    });

    test('null DateTime 필드는 null로 직렬화', () {
      final project = createTestProject();

      final json = project.toBackupJson();

      expect(json['startDate'], isNull);
      expect(json['completedDate'], isNull);
    });

    test('DateTime 필드가 있으면 millisecondsSinceEpoch로 직렬화', () {
      final project = createTestProject(
        startDate: fixedYesterday,
        completedDate: fixedNow,
      );

      final json = project.toBackupJson();

      expect(json['startDate'], fixedYesterday.millisecondsSinceEpoch);
      expect(json['completedDate'], fixedNow.millisecondsSinceEpoch);
    });

    test('rowCounter가 없으면 null로 직렬화', () {
      final project = createTestProject();

      final json = project.toBackupJson();

      expect(json['rowCounter'], isNull);
    });

    test('rowCounter가 있으면 인라인으로 직렬화', () {
      final counter = createTestCounter(id: 1, label: '단', value: 10);
      final project = createTestProject(rowCounter: counter);

      final json = project.toBackupJson();

      expect(json['rowCounter'], isA<Map<String, dynamic>>());
      expect(json['rowCounter']['label'], '단');
      expect(json['rowCounter']['value'], 10);
    });

    test('secondaryCounters 빈 배열', () {
      final project = createTestProject();

      final json = project.toBackupJson();

      expect(json['secondaryCounters'], isEmpty);
    });

    test('memos 빈 배열', () {
      final project = createTestProject();

      final json = project.toBackupJson();

      expect(json['memos'], isEmpty);
    });

    test('timerStartedAt가 있으면 totalWorkSeconds에 세션 시간 합산', () {
      final timerStart = DateTime.now().subtract(const Duration(seconds: 60));
      final project = createTestProject(
        totalWorkSeconds: 100,
        timerStartedAt: timerStart,
      );

      final json = project.toBackupJson();

      // 최소 160초 (100 + 60)이어야 함 (실행 시간 오차 허용)
      expect(json['totalWorkSeconds'], greaterThanOrEqualTo(160));
      // timerStartedAt는 JSON에 포함되지 않음
      expect(json.containsKey('timerStartedAt'), isFalse);
    });
  });

  group('projectFromBackupJson', () {
    test('기본 필드 복원', () {
      final json = {
        'name': '장갑',
        'statusIndex': 2,
        'createdAt': fixedNow.millisecondsSinceEpoch,
        'updatedAt': fixedNow.millisecondsSinceEpoch,
        'totalWorkSeconds': 7200,
      };

      final project = projectFromBackupJson(json);

      expect(project.id, 0);
      expect(project.name, '장갑');
      expect(project.statusIndex, 2);
      expect(project.createdAt, fixedNow);
      expect(project.updatedAt, fixedNow);
      expect(project.totalWorkSeconds, 7200);
    });

    test('timerStartedAt는 항상 null로 복원', () {
      final json = {
        'name': 'test',
        'timerStartedAt': DateTime.now().millisecondsSinceEpoch,
      };

      final project = projectFromBackupJson(json);

      expect(project.timerStartedAt, isNull);
    });

    test('counterHistoryJson은 항상 빈 배열로 초기화', () {
      final json = {
        'name': 'test',
        'counterHistoryJson': '[{"type":"row","prev":0,"new":1}]',
      };

      final project = projectFromBackupJson(json);

      expect(project.counterHistoryJson, '[]');
    });

    test('statusIndex 범위 초과 시 0으로 보정', () {
      final project = projectFromBackupJson({
        'name': 'test',
        'statusIndex': 99,
      });
      expect(project.statusIndex, 0);
    });

    test('statusIndex 음수 시 0으로 보정', () {
      final project = projectFromBackupJson({
        'name': 'test',
        'statusIndex': -1,
      });
      expect(project.statusIndex, 0);
    });

    test('필드 누락 시 기본값 적용', () {
      final project = projectFromBackupJson({});

      expect(project.id, 0);
      expect(project.name, '');
      expect(project.statusIndex, 0);
      expect(project.totalWorkSeconds, 0);
      expect(project.timerStartedAt, isNull);
      expect(project.counterHistoryJson, '[]');
    });

    test('nullable DateTime 필드 복원', () {
      final json = {
        'name': 'test',
        'startDate': fixedLastWeek.millisecondsSinceEpoch,
        'completedDate': fixedNow.millisecondsSinceEpoch,
      };

      final project = projectFromBackupJson(json);

      expect(project.startDate, fixedLastWeek);
      expect(project.completedDate, fixedNow);
    });

    test('nullable DateTime이 null이면 null로 복원', () {
      final json = {
        'name': 'test',
        'startDate': null,
        'completedDate': null,
      };

      final project = projectFromBackupJson(json);

      expect(project.startDate, isNull);
      expect(project.completedDate, isNull);
    });

    test('round-trip: toBackupJson → projectFromBackupJson (기본 필드)', () {
      final original = createTestProject(
        id: 77,
        name: '스웨터',
        statusIndex: 1,
        createdAt: fixedNow,
        updatedAt: fixedNow,
        startDate: fixedLastWeek,
        completedDate: fixedNow,
        totalWorkSeconds: 5000,
      );

      final restored = projectFromBackupJson(original.toBackupJson());

      expect(restored.id, 0);
      expect(restored.name, original.name);
      expect(restored.statusIndex, original.statusIndex);
      expect(restored.createdAt, original.createdAt);
      expect(restored.updatedAt, original.updatedAt);
      expect(restored.startDate, original.startDate);
      expect(restored.completedDate, original.completedDate);
      expect(restored.totalWorkSeconds, original.totalWorkSeconds);
      expect(restored.timerStartedAt, isNull);
      expect(restored.counterHistoryJson, '[]');
    });
  });
}
