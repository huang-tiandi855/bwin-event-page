/// 批量上传图片接口返回的单个文件项
class MultiImageItem {
  String? serverPath;
  String? fileName;

  MultiImageItem({this.serverPath, this.fileName});

  MultiImageItem.fromJson(Map<String, dynamic> json) {
    serverPath = json['serverPath']?.toString();
    fileName = json['fileName']?.toString();
  }

  Map<String, dynamic> toJson() => {
        'serverPath': serverPath,
        'fileName': fileName,
      };
}

/// 批量上传图片后返回的模型
///
/// 服务器真实返回结构：
/// ```json
/// {
///   "code": 0,
///   "msg": "success",
///   "data": [
///     { "serverPath": "posting/xxx.png", "fileName": "2.png" }
///   ]
/// }
/// ```
///
/// 为了保持历史调用方 `model.filePath` 的语义不变，这里把每一项的
/// `serverPath` 抽取到 [filePath] 列表中。
class MultiImageModel {
  /// 服务端返回 code，0 表示成功
  int? code;

  /// 服务端返回的提示语
  String? msg;

  /// 上传成功的文件列表（含 serverPath / fileName）
  List<MultiImageItem>? items;

  /// 兼容历史字段：服务端返回的图片相对路径列表（取自每项 serverPath）
  List<String>? filePath;

  /// 兼容历史字段（早期接口返回的 success 数量）
  int? success;

  MultiImageModel({
    this.code,
    this.msg,
    this.items,
    this.filePath,
    this.success,
  });

  /// [isSercet] 历史保留参数：当响应被加密时由 helper 解密后再 fromJson，
  /// 解密后的 payload 与明文响应字段结构一致，所以这里不做区分。
  MultiImageModel.fromJson(Map<String, dynamic> json, {bool isSercet = false}) {
    code = _toInt(json['code']);
    msg = json['msg']?.toString();

    final dynamic dataField = json['data'];
    if (dataField is List) {
      items = dataField
          .whereType<Map>()
          .map((e) => MultiImageItem.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      filePath = items!
          .map((e) => e.serverPath ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
    } else if (dataField is Map) {
      final Map<String, dynamic> inner = Map<String, dynamic>.from(dataField);
      final fp = inner['filePath'];
      if (fp is List) {
        filePath = fp.map((e) => e.toString()).toList();
      }
      success = _toInt(inner['success']);
    } else if (dataField is String && dataField.isNotEmpty) {
      // 聊天图片上传返回结构: {"code":0,"msg":"success","data":"chat/xxx.png"}
      items = [MultiImageItem(serverPath: dataField)];
      filePath = [dataField];
    }

    if ((filePath == null || filePath!.isEmpty) && json['filePath'] is List) {
      filePath = (json['filePath'] as List).map((e) => e.toString()).toList();
    }
    success ??= _toInt(json['success']);
  }

  /// 是否拿到了有效的上传结果
  bool get isSuccess => code == 0 && (filePath?.isNotEmpty ?? false);

  Map<String, dynamic> toJson() => {
        'code': code,
        'msg': msg,
        'data': items?.map((e) => e.toJson()).toList(),
        'filePath': filePath,
        'success': success,
      };

  static int? _toInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    return int.tryParse(v.toString());
  }
}
