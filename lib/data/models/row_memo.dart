import 'package:objectbox/objectbox.dart';

/// 단(Row) 메모 엔티티
/// 특정 단에 도달했을 때 표시할 메모
@Entity()
class RowMemo {
  @Id()
  int id;

  int rowNumber; // 메모할 단 번호
  String content; // 메모 내용 ("코 줄이기")
  bool notified; // 알림 표시 여부

  RowMemo({
    this.id = 0,
    required this.rowNumber,
    required this.content,
    this.notified = false,
  });

  RowMemo copyWith({
    int? id,
    int? rowNumber,
    String? content,
    bool? notified,
  }) {
    return RowMemo(
      id: id ?? this.id,
      rowNumber: rowNumber ?? this.rowNumber,
      content: content ?? this.content,
      notified: notified ?? this.notified,
    );
  }

  @override
  String toString() {
    return 'RowMemo(id: $id, rowNumber: $rowNumber, content: $content, notified: $notified)';
  }
}
