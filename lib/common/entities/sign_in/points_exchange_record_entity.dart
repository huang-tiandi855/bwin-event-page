/// `activation/points/exchange/record/list` 成功时 `BaseRespBean.data`：兑换记录数组。
///
/// 字段完全对齐服务端真实返回（snake / camel 已统一在网关侧；本层只解析 camel）：
/// ```json
/// {
///   "id": 78,
///   "userId": 1263,
///   "exchangeSource": "POINTS_PRODUCT",   // POINTS_PRODUCT | REDEEM_CODE ...
///   "status": 1,                            // 1 成功；其它取 failReason
///   "rewardType": "VIP_DAY_CARD",
///   "rewardPayload": "{\"amount\":9}",
///   "productId": 7,
///   "productNameSnapshot": "九天随便看",     // ★ 旧 productName 已废弃
///   "costPoints": 12,
///   "stockDelta": -1,
///   "redeemCode": null,                     // 兑换码场景才有
///   "redeemBatchId": null,
///   "idempotencyKey": "...",
///   "failReason": null,
///   "createdAt": 1780043547000,
///   "updatedAt": 1780043547000
/// }
/// ```

int? _perInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

String? _perStr(dynamic v) {
  if (v == null) return null;
  final s = v.toString();
  return s.isEmpty ? null : s;
}

Map<String, dynamic>? _perAsMap(dynamic v) {
  if (v is Map<String, dynamic>) return v;
  if (v is Map) return Map<String, dynamic>.from(v);
  return null;
}

class PointsExchangeRecordModel {
  PointsExchangeRecordModel({
    this.id,
    this.userId,
    this.exchangeSource,
    this.status,
    this.productId,
    this.productNameSnapshot,
    this.productName,
    this.rewardType,
    this.rewardPayload,
    this.costPoints,
    this.stockDelta,
    this.redeemCode,
    this.redeemBatchId,
    this.idempotencyKey,
    this.failReason,
    this.exchangeTime,
    this.createdAt,
    this.updatedAt,
  });

  factory PointsExchangeRecordModel.fromJson(Map<String, dynamic> json) {
    return PointsExchangeRecordModel(
      id: _perInt(json['id']),
      userId: _perInt(json['userId']),
      exchangeSource: _perStr(json['exchangeSource']),
      status: _perInt(json['status']),
      productId: _perInt(json['productId']),
      // 服务端字段名为 `productNameSnapshot`；旧 mock / 旧接口可能还在用
      // `productName / name / rewardName`，全部兜底。
      productNameSnapshot: _perStr(json['productNameSnapshot']),
      productName: _perStr(
          json['productName'] ?? json['name'] ?? json['rewardName']),
      rewardType: _perStr(json['rewardType']),
      rewardPayload: _perStr(json['rewardPayload']),
      costPoints: _perInt(
          json['costPoints'] ?? json['points'] ?? json['consumePoints']),
      stockDelta: _perInt(json['stockDelta']),
      redeemCode: _perStr(json['redeemCode']),
      redeemBatchId: _perInt(json['redeemBatchId']),
      idempotencyKey: _perStr(json['idempotencyKey']),
      failReason: _perStr(json['failReason']),
      // `exchangeTime / exchangeAt` 是旧字段名，新接口已不下发，留作兜底。
      exchangeTime: _perInt(json['exchangeTime'] ?? json['exchangeAt']),
      createdAt: _perInt(json['createdAt']),
      updatedAt: _perInt(json['updatedAt']),
    );
  }

  static List<PointsExchangeRecordModel> listFromData(dynamic data) {
    final dynamic listData = data is Map
        ? (data['list'] ?? data['records'] ?? data['items'] ?? data['data'])
        : data;
    if (listData is! List) return const [];
    final List<PointsExchangeRecordModel> out = [];
    for (final dynamic e in listData) {
      final Map<String, dynamic>? m = _perAsMap(e);
      if (m != null) {
        out.add(PointsExchangeRecordModel.fromJson(m));
      }
    }
    return out;
  }

  final int? id;
  final int? userId;

  /// 兑换来源：`POINTS_PRODUCT`（积分兑换）/ `REDEEM_CODE`（兑换码）等。
  final String? exchangeSource;

  /// 业务状态：`1` 成功；非 1 时通常配合 [failReason] 一起读。
  final int? status;

  final int? productId;

  /// 兑换那一刻的商品名称快照（服务端字段：`productNameSnapshot`）。
  ///
  /// 商品被运营改名 / 下架后，这里仍然保留兑换发生时的原名，UI 渲染优先用它。
  final String? productNameSnapshot;

  /// 兼容旧服务端字段名 `productName / name / rewardName`。
  /// 新接口已切到 [productNameSnapshot]，本字段一般为 `null`。
  final String? productName;

  final String? rewardType;
  final String? rewardPayload;
  final int? costPoints;

  /// 兑换扣库存的增量，例如积分商品扣 1 件时为 `-1`；兑换码场景为 `null`。
  final int? stockDelta;

  /// 兑换码（仅 [exchangeSource] == `REDEEM_CODE` 时下发）。
  final String? redeemCode;
  final int? redeemBatchId;

  /// 业务幂等 key，重试 / 重复回放时服务端去重凭证。
  final String? idempotencyKey;

  /// 失败原因，仅 [status] != 1 时下发。
  final String? failReason;

  /// 毫秒时间戳；旧接口字段，新接口建议读 [updatedAt] / [createdAt]。
  final int? exchangeTime;

  /// 毫秒时间戳。
  final int? createdAt;

  /// 毫秒时间戳。
  final int? updatedAt;

  /// 兑换是否成功（`status == 1`）。
  bool get isSuccess => status == 1;

  /// UI 优先使用快照名，回落到旧 `productName`，再回落到占位符 `-`。
  String get displayName {
    final snap = productNameSnapshot?.trim();
    if (snap != null && snap.isNotEmpty) return snap;
    final legacy = productName?.trim();
    if (legacy != null && legacy.isNotEmpty) return legacy;
    return '-';
  }

  int get displayCostPoints => costPoints ?? 0;

  /// 选用顺序：旧 `exchangeTime` > 服务端权威 `updatedAt` > `createdAt`，
  /// 兼容历史接口同时让新接口拿到「兑换成功的那一刻」。
  int? get displayTimeMillis => exchangeTime ?? updatedAt ?? createdAt;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'userId': userId,
        'exchangeSource': exchangeSource,
        'status': status,
        'productId': productId,
        'productNameSnapshot': productNameSnapshot,
        'productName': productName,
        'rewardType': rewardType,
        'rewardPayload': rewardPayload,
        'costPoints': costPoints,
        'stockDelta': stockDelta,
        'redeemCode': redeemCode,
        'redeemBatchId': redeemBatchId,
        'idempotencyKey': idempotencyKey,
        'failReason': failReason,
        'exchangeTime': exchangeTime,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}
