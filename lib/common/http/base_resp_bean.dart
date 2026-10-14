import 'code.dart';

/// 基础网络请求结构
/// 本来是业务层包装的一层东西，但是这个项目好像没用，用状态码代替了业务码
class BaseRespBean<T> {
  /// 纯数字或可解析为 int 时的数值码（成功时为 `0`，因 `0000` 经 [int.tryParse] 得到 0；含字母的码如 FAT10001 可能为 null）
  int? code;

  /// 文档及网关原始业务码字符串（权威语义以文档为准，成功为 [Code.SUCCESS_DOC]）
  String? bizCode;

  T? data;

  /// 部分接口业务主数据落在 `result` 字段（如 `/ads/fetch/batch` 同时携带
  /// `data`（元数据 List）与 `result`（主数据 Map），`_flattenNestedDataEnvelope`
  /// 按 `data ?? result` 选 `data` 后会丢失 `result`）。这里同步保留一份，
  /// 业务侧可显式读取 `resp.result` 拿到原始 `inner['result']`。
  T? result;

  /// 后台提示
  String? tip;
  String? action;

  /// 是否加密
  bool? hash;

  /// 一般是 code 不为成功时的后端错误信息
  String? msg;

  /// 服务器时间，一切vip时间计算以服务器时间为准
  String? time;

  /// 分页接口根级总数（如章节列表 `total`）。
  int? total;

  /// 文档：**code = 0000** 为业务成功
  bool get isSuccess => bizCode == Code.SUCCESS_DOC;

  BaseRespBean(this.code,
      {this.data,
      this.msg,
      this.tip,
      this.hash = true,
      this.time,
      this.bizCode,
      this.total}) {
    // ignore: prefer_null_aware_operators
    bizCode ??= code == null ? null : code.toString();
  }

  BaseRespBean.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> src = _flattenNestedDataEnvelope(json);

    bizCode = _normalizeBizCode(src['code']);

    if (bizCode == Code.SUCCESS_DOC) {
      code = int.tryParse(bizCode!);
    } else if (bizCode != null && bizCode!.isNotEmpty) {
      code = int.tryParse(bizCode!);
    } else {
      code = null;
    }

    if (src.containsKey('data') && src['data'] != null) {
      data = src['data'] as T?;
    } else {
      data = src['result'] as T?;
    }
    result = src['result'] as T?;
    tip = src['tip']?.toString();
    action = src['action']?.toString();
    msg = src['msg']?.toString();
    time = _normalizeTimeField(src['time']);
    hash = _parseOptionalBool(src['hash']);
    total = _parseOptionalInt(src['total']);
    if (src['message'] != null && (msg == null || msg!.isEmpty)) {
      msg = src['message']?.toString();
    }
  }

  /// 新网关/业务包装：`{ "data": { "code","message","result","data",... }, "time" }`（根级无 `code`）。
  /// 与历史平铺 `{ "code","data"|"result","time",... }` 兼容。
  static Map<String, dynamic> _flattenNestedDataEnvelope(
    Map<String, dynamic> json,
  ) {
    final dynamic rootCode = json['code'];
    final dynamic rootData = json['data'];
    if (rootCode != null) {
      return json;
    }
    if (rootData is! Map) {
      return json;
    }
    final Map<String, dynamic> inner = Map<String, dynamic>.from(rootData);
    if (!inner.containsKey('code')) {
      return json;
    }
    final dynamic payload = inner['data'] ?? inner['result'];
    return <String, dynamic>{
      'code': inner['code'],
      'message': inner['message'],
      'msg': inner['msg'],
      'tip': inner['tip'] ?? json['tip'],
      'data': payload,
      'result': inner['result'],
      'time': json['time'] ?? inner['time'],
      'hash': json['hash'] ?? inner['hash'],
      'action': inner['action'] ?? json['action'],
    };
  }

  /// 供 [HttpRequest.setServerTime] 与网关选钥：`time` 可为 ISO 字符串或毫秒时间戳（num）。
  static String? _normalizeTimeField(dynamic raw) {
    if (raw == null) {
      return null;
    }
    if (raw is int) {
      return raw.toString();
    }
    if (raw is num) {
      return raw.round().toString();
    }
    final String s = raw.toString().trim();
    return s.isEmpty ? null : s;
  }

  static int? _parseOptionalInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }

  static bool? _parseOptionalBool(dynamic v) {
    if (v == null) {
      return null;
    }
    if (v is bool) {
      return v;
    }
    if (v is num) {
      return v != 0;
    }
    if (v is String) {
      final String s = v.trim().toLowerCase();
      if (s == 'true' || s == '1' || s == 'yes') {
        return true;
      }
      if (s == 'false' || s == '0' || s == 'no' || s.isEmpty) {
        return false;
      }
    }
    return null;
  }

  static String? _normalizeBizCode(dynamic raw) {
    if (raw == null) {
      return null;
    }
    final String s = raw.toString().trim();
    return s.isEmpty ? null : s;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    data['bizCode'] = bizCode;
    data['data'] = this.data;
    data['tip'] = tip;
    data['action'] = action;
    data['msg'] = msg;
    data['time'] = time;
    data['hash'] = hash;
    return data;
  }
}
