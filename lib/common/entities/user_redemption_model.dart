/// 兑换记录列表
///
/// 与接口 `activation/redeemCode/records` 对齐：`result` 直接是数组，
/// `BaseRespBean.data` 透传该数组。为兼容历史 `{ "list": [...] }`
/// 包装形式，[fromJson] 同时支持 [List] 与 [Map]。
class ExchangeRecordListModel {
  List<ExchangeRecordItemModel>? list;

  ExchangeRecordListModel({this.list});

  factory ExchangeRecordListModel.fromJson(dynamic json) {
    final items = <ExchangeRecordItemModel>[];
    if (json is List) {
      for (final v in json) {
        if (v is Map) {
          items.add(
            ExchangeRecordItemModel.fromJson(Map<String, dynamic>.from(v)),
          );
        }
      }
    } else if (json is Map) {
      final src = Map<String, dynamic>.from(json);
      final raw = src['list'] ?? src['data'] ?? src['result'];
      if (raw is List) {
        for (final v in raw) {
          if (v is Map) {
            items.add(
              ExchangeRecordItemModel.fromJson(Map<String, dynamic>.from(v)),
            );
          }
        }
      }
    }
    return ExchangeRecordListModel(list: items);
  }
}

/// 单条兑换记录
class ExchangeRecordItemModel {
  int? costPoints;
  String? createdAt;
  String? exchangeSource;
  String? failReason;
  int? id;
  String? idempotencyKey;
  int? productId;
  String? productNameSnapshot;
  int? redeemBatchId;
  String? redeemCode;
  String? rewardPayload;
  String? rewardType;
  int? status;
  int? stockDelta;
  String? updatedAt;
  int? userId;

  ExchangeRecordItemModel({
    this.costPoints,
    this.createdAt,
    this.exchangeSource,
    this.failReason,
    this.id,
    this.idempotencyKey,
    this.productId,
    this.productNameSnapshot,
    this.redeemBatchId,
    this.redeemCode,
    this.rewardPayload,
    this.rewardType,
    this.status,
    this.stockDelta,
    this.updatedAt,
    this.userId,
  });

  ExchangeRecordItemModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return;
    costPoints = _asInt(json['costPoints']);
    createdAt = json['createdAt']?.toString();
    exchangeSource = json['exchangeSource']?.toString();
    failReason = json['failReason']?.toString();
    id = _asInt(json['id']);
    idempotencyKey = json['idempotencyKey']?.toString();
    productId = _asInt(json['productId']);
    productNameSnapshot = json['productNameSnapshot']?.toString();
    redeemBatchId = _asInt(json['redeemBatchId']);
    redeemCode = json['redeemCode']?.toString();
    rewardPayload = json['rewardPayload']?.toString();
    rewardType = json['rewardType']?.toString();
    status = _asInt(json['status']);
    stockDelta = _asInt(json['stockDelta']);
    updatedAt = json['updatedAt']?.toString();
    userId = _asInt(json['userId']);
  }

  Map<String, dynamic> toJson() => {
        'costPoints': costPoints,
        'createdAt': createdAt,
        'exchangeSource': exchangeSource,
        'failReason': failReason,
        'id': id,
        'idempotencyKey': idempotencyKey,
        'productId': productId,
        'productNameSnapshot': productNameSnapshot,
        'redeemBatchId': redeemBatchId,
        'redeemCode': redeemCode,
        'rewardPayload': rewardPayload,
        'rewardType': rewardType,
        'status': status,
        'stockDelta': stockDelta,
        'updatedAt': updatedAt,
        'userId': userId,
      };

  static int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }
}
