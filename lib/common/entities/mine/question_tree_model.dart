/// 常见问题 · 问答树节点（`chat/question/tree`）
///
/// 后端返回的同一个结构既用于顶层分类节点，也用于其下的子问题节点：
/// - 顶层节点：`answer` 字段表示分类名称，`child` 为该分类下的问答列表；
/// - 子节点：`question`/`answer` 表示具体的问与答，`child` 一般为 `null`。
class QuestionTreeModel {
  QuestionTreeModel({
    this.id,
    this.parentId,
    this.position,
    this.status,
    this.question,
    this.answer,
    List<QuestionTreeModel>? child,
  }) : child = child ?? <QuestionTreeModel>[];

  /// 节点 id
  int? id;

  /// 父节点 id，顶层节点通常为 0
  int? parentId;

  /// 排序位置（升序）
  int? position;

  /// 状态：1 启用、0 禁用（以后端定义为准）
  int? status;

  /// 问题文案
  String? question;

  /// 答案文案（顶层节点用作分类标题）
  String? answer;

  /// 子节点列表，可能为空
  List<QuestionTreeModel> child;

  factory QuestionTreeModel.fromJson(Map<String, dynamic> json) {
    return QuestionTreeModel(
      id: _parseInt(json['id']),
      parentId: _parseInt(json['parentId']),
      position: _parseInt(json['position']),
      status: _parseInt(json['status']),
      question: json['question']?.toString(),
      answer: json['answer']?.toString(),
      child: _parseChildren(json['child']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'parentId': parentId,
        'position': position,
        'status': status,
        'question': question,
        'answer': answer,
        'child': child.map((e) => e.toJson()).toList(),
      };

  /// 将接口 `data` 字段直接转换为模型列表，容错处理非数组/空值。
  static List<QuestionTreeModel> listFromData(dynamic data) {
    if (data is! List) return <QuestionTreeModel>[];
    return data
        .whereType<Map>()
        .map((e) => QuestionTreeModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static List<QuestionTreeModel> _parseChildren(dynamic value) {
    if (value is! List) return <QuestionTreeModel>[];
    return value
        .whereType<Map>()
        .map((e) => QuestionTreeModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value.toString());
  }
}
