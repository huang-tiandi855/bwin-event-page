/// `activation/points/product/list` 成功时 `BaseRespBean.data`：商品 JSON 数组。
/// 由 [SignInApis.getPointsExchangeList] 解析为 `List<PointsExchangeProductModel>`。

int? _pexInt(dynamic v) {
  if (v == null) {
    return null;
  }
  if (v is int) {
    return v;
  }
  if (v is num) {
    return v.toInt();
  }
  return int.tryParse(v.toString());
}

Map<String, dynamic>? _pexAsMap(dynamic v) {
  if (v is Map<String, dynamic>) {
    return v;
  }
  if (v is Map) {
    return Map<String, dynamic>.from(v);
  }
  return null;
}

/// 积分兑换商品（列表单项）。
class PointsExchangeProductModel {
  PointsExchangeProductModel({
    this.id,
    this.productName,
    this.rewardType,
    this.rewardPayload,
    this.costPoints,
    this.stock,
    this.status,
    this.isDeleted,
    this.sortOrder,
    this.imageUrl,
    this.remark,
    this.createdAt,
    this.updatedAt,
  });

  factory PointsExchangeProductModel.fromJson(Map<String, dynamic> json) {
    return PointsExchangeProductModel(
      id: _pexInt(json['id']),
      productName: json['productName']?.toString(),
      rewardType: json['rewardType']?.toString(),
      rewardPayload: json['rewardPayload']?.toString(),
      costPoints: _pexInt(json['costPoints']),
      stock: _pexInt(json['stock']),
      status: _pexInt(json['status']),
      isDeleted: _pexInt(json['isDeleted']),
      sortOrder: _pexInt(json['sortOrder']),
      imageUrl: json['imageUrl']?.toString(),
      remark: json['remark']?.toString(),
      createdAt: _pexInt(json['createdAt']),
      updatedAt: _pexInt(json['updatedAt']),
    );
  }

  /// 解析接口 `data`（一般为 JSON 数组）。
  ///
  /// 顺序与接口 **数组下标一致**，不做客户端排序。此前若按 `sortOrder` 再按 `id` 升序，
  /// 在多条 `sortOrder` 均为 0 时会把 `id:1` 排到最前，与接口返回顺序不一致。
  static List<PointsExchangeProductModel> listFromData(dynamic data) {
    if (data is! List) {
      return const [];
    }
    final List<PointsExchangeProductModel> out = [];
    for (final dynamic e in data) {
      final Map<String, dynamic>? m = _pexAsMap(e);
      if (m == null) {
        continue;
      }
      final PointsExchangeProductModel item =
          PointsExchangeProductModel.fromJson(m);
      if (item.isDeleted == 1) {
        continue;
      }
      if (item.status != null && item.status != 1) {
        continue;
      }
      out.add(item);
    }
    return out;
  }

  final int? id;
  final String? productName;
  final String? rewardType;

  /// JSON 字符串，如 `{"amount":3}`
  final String? rewardPayload;
  final int? costPoints;
  final int? stock;

  /// 上架状态等业务态（示例里 `1` 为有效）
  final int? status;
  final int? isDeleted;
  final int? sortOrder;
  final String? imageUrl;
  final String? remark;

  /// 毫秒时间戳
  final int? createdAt;

  /// 毫秒时间戳
  final int? updatedAt;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'productName': productName,
        'rewardType': rewardType,
        'rewardPayload': rewardPayload,
        'costPoints': costPoints,
        'stock': stock,
        'status': status,
        'isDeleted': isDeleted,
        'sortOrder': sortOrder,
        'imageUrl': imageUrl,
        'remark': remark,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };
}
