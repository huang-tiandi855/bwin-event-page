/// 邀请记录分页响应（POST `/user/invite/info/page` 的 `data` 字段）
///
/// 服务端使用 PageHelper 风格分页，常用的字段为 [list]、[hasNextPage]、[total]、
/// [pageNum]、[pageSize]，其余翻页指标字段以兜底解析方式保留。
class InviteRecordPageModel {
  InviteRecordPageModel({
    List<InviteUserModel>? list,
    this.total = 0,
    this.pageNum = 0,
    this.pageSize = 0,
    this.size = 0,
    this.pages = 0,
    this.startRow = 0,
    this.endRow = 0,
    this.prePage = 0,
    this.nextPage = 0,
    this.firstPage = 0,
    this.lastPage = 0,
    this.navigatePages = 0,
    this.navigateFirstPage = 0,
    this.navigateLastPage = 0,
    List<int>? navigatepageNums,
    this.hasNextPage = false,
    this.hasPreviousPage = false,
    this.isFirstPage = false,
    this.isLastPage = false,
  })  : list = list ?? <InviteUserModel>[],
        navigatepageNums = navigatepageNums ?? <int>[];

  /// 邀请用户列表
  List<InviteUserModel> list;

  int total;
  int pageNum;
  int pageSize;
  int size;
  int pages;
  int startRow;
  int endRow;
  int prePage;
  int nextPage;
  int firstPage;
  int lastPage;
  int navigatePages;
  int navigateFirstPage;
  int navigateLastPage;
  List<int> navigatepageNums;
  bool hasNextPage;
  bool hasPreviousPage;
  bool isFirstPage;
  bool isLastPage;

  factory InviteRecordPageModel.fromJson(Map<String, dynamic> json) {
    return InviteRecordPageModel(
      list: (json['list'] as List?)
              ?.whereType<Map>()
              .map((e) => InviteUserModel.fromJson(Map<String, dynamic>.from(e)))
              .toList() ??
          <InviteUserModel>[],
      total: _parseInt(json['total']) ?? 0,
      pageNum: _parseInt(json['pageNum']) ?? 0,
      pageSize: _parseInt(json['pageSize']) ?? 0,
      size: _parseInt(json['size']) ?? 0,
      pages: _parseInt(json['pages']) ?? 0,
      startRow: _parseInt(json['startRow']) ?? 0,
      endRow: _parseInt(json['endRow']) ?? 0,
      prePage: _parseInt(json['prePage']) ?? 0,
      nextPage: _parseInt(json['nextPage']) ?? 0,
      firstPage: _parseInt(json['firstPage']) ?? 0,
      lastPage: _parseInt(json['lastPage']) ?? 0,
      navigatePages: _parseInt(json['navigatePages']) ?? 0,
      navigateFirstPage: _parseInt(json['navigateFirstPage']) ?? 0,
      navigateLastPage: _parseInt(json['navigateLastPage']) ?? 0,
      navigatepageNums: (json['navigatepageNums'] as List?)
              ?.map(_parseInt)
              .whereType<int>()
              .toList() ??
          <int>[],
      hasNextPage: _parseBool(json['hasNextPage']) ?? false,
      hasPreviousPage: _parseBool(json['hasPreviousPage']) ?? false,
      isFirstPage: _parseBool(json['isFirstPage']) ?? false,
      isLastPage: _parseBool(json['isLastPage']) ?? false,
    );
  }

  /// 接口异常 / 无数据的兜底实例
  factory InviteRecordPageModel.empty() => InviteRecordPageModel();

  Map<String, dynamic> toJson() => <String, dynamic>{
        'list': list.map((e) => e.toJson()).toList(),
        'total': total,
        'pageNum': pageNum,
        'pageSize': pageSize,
        'size': size,
        'pages': pages,
        'startRow': startRow,
        'endRow': endRow,
        'prePage': prePage,
        'nextPage': nextPage,
        'firstPage': firstPage,
        'lastPage': lastPage,
        'navigatePages': navigatePages,
        'navigateFirstPage': navigateFirstPage,
        'navigateLastPage': navigateLastPage,
        'navigatepageNums': navigatepageNums,
        'hasNextPage': hasNextPage,
        'hasPreviousPage': hasPreviousPage,
        'isFirstPage': isFirstPage,
        'isLastPage': isLastPage,
      };
}

/// 邀请记录单条
class InviteUserModel {
  InviteUserModel({
    this.id,
    this.account,
    this.nickName,
    this.phone,
    this.agentLevel,
    this.createDate,
  });

  /// 用户 id
  int? id;

  /// 账号
  String? account;

  /// 昵称
  String? nickName;

  /// 手机号
  String? phone;

  /// 代理等级
  int? agentLevel;

  /// 邀请生效时间（ISO8601 字符串解析）
  DateTime? createDate;

  factory InviteUserModel.fromJson(Map<String, dynamic> json) {
    return InviteUserModel(
      id: _parseInt(json['id']),
      account: json['account']?.toString(),
      nickName: json['nickName']?.toString(),
      phone: json['phone']?.toString(),
      agentLevel: _parseInt(json['agentLevel']),
      createDate: _parseDate(json['createDate']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'account': account,
        'nickName': nickName,
        'phone': phone,
        'agentLevel': agentLevel,
        'createDate': createDate?.toIso8601String(),
      };
}

int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value.toString());
}

bool? _parseBool(dynamic value) {
  if (value == null) return null;
  if (value is bool) return value;
  if (value is num) return value != 0;
  final text = value.toString().toLowerCase();
  if (text == 'true') return true;
  if (text == 'false') return false;
  return null;
}

DateTime? _parseDate(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  final text = value.toString();
  if (text.isEmpty) return null;
  return DateTime.tryParse(text);
}
