import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:comics_app/common/http/gateway_crypto.dart'
    show decryptGatewayCipherWithResponseTime;
import 'package:comics_app/common/http/http_detect_line_dio.dart';
import 'package:comics_app/common/http/http_request.dart';
import 'package:comics_app/common/http/logInterceptor.dart';
import 'package:comics_app/common/store/user.dart';
import 'package:comics_app/common/utils/files_upload/video_upload_result_model.dart';
import 'package:comics_app/common/utils/task_state.dart';
import 'package:comics_app/common/utils/text_util.dart';
import 'package:comics_app/common/values/address.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

/// 单视频整段上传工具类（**不分片**）。
///
/// 与历史的 `VideoUploadHelper`（Base64 分片 + `pos/totalPos`）**并存**：
/// 老协议后端在新网关里不再支持，新业务一律用这个 helper，老的暂时保留兼容旧
/// 调用点，避免一次性大改风险。
///
/// 设计参照 [MultiImageUploadHelper]：mixin 在 [TaskState] 上，由 [BaseTask]
/// 提供 `onUpdate / onError / isTaskCanceled`，业务侧只关心一次 [uploadFile]
/// 调用即可。
///
/// 协议要点：
/// - 端点：[Address.uploadUrl]，与图片上传同源；
/// - 方法：`POST multipart/form-data`，字段名 `file`（与图片 helper 一致）；
/// - 响应：与多图上传同一份契约 —— `data` 是数组，每项 `{ serverPath, fileName }`；
///   单视频取第一项的 `serverPath` 作为 [VideoUploadResultModel.videoUri]，
///   `fileName` 作为 [VideoUploadResultModel.id]（后端没有独立的视频 id 字段）。
///   ```json
///   {
///     "code": 0,
///     "msg": "success",
///     "data": [
///       { "serverPath": "content/.../xxx.mp4", "fileName": "...x252.mp4" }
///     ]
///   }
///   ```
/// - 若 `hash == true` 则 `data` 是密文，走 [decryptGatewayCipherWithResponseTime]
///   解密后按同样的「数组首项」结构取字段。
mixin SingleVideoUploadHelper on TaskState {
  final String tag = 'SingleVideoUploadHelper';
  final int maxRetryCount = 3;
  final Dio _dio = createDio();

  /// 单视频上传入口。
  ///
  /// - [localPath] 本地视频绝对路径；不存在直接 `onError` 并返回 `null`。
  /// - 失败会按 [maxRetryCount] 重试（任务被取消则提前终止）。
  /// - 进度通过 [onUpdate] 上报；起步给一个 `0.01` 的假进度避免 UI 卡在 0。
  Future<VideoUploadResultModel?> uploadFile(String localPath) async {
    _dio.interceptors.add(HttpLogInterceptor());

    if (TextUtil.isEmpty(localPath)) {
      onError('uploadFile localPath is empty');
      return null;
    }
    if (TextUtil.isEmpty(Address.uploadUrl)) {
      onError('uploadFile uploadUrl is empty');
      return null;
    }
    if (!await File(localPath).exists()) {
      onError('uploadFile file not exist: $localPath');
      return null;
    }

    onUpdate(0.01);
    final VideoUploadResultModel? model = await _uploadOnceAndRetry(localPath);
    if (model == null) {
      onUpdate(0.0);
      onError('error to upload video');
    } else {
      onUpdate(1.0);
    }
    return model;
  }

  /// 整段上传重试包装（最多 [maxRetryCount] 次）。
  ///
  /// 任务取消（[isTaskCanceled]）会立即返回，不再继续重试。
  Future<VideoUploadResultModel?> _uploadOnceAndRetry(String localPath) async {
    int retryCount = 0;
    while (retryCount <= maxRetryCount && !isTaskCanceled()) {
      final model = await _uploadOnce(localPath);
      if (model != null) return model;
      retryCount++;
      if (retryCount >= maxRetryCount) {
        Logger().e(tag,
            '_uploadOnceAndRetry()...all $maxRetryCount attempts failed, path:$localPath');
        return null;
      }
    }
    return null;
  }

  /// 单次整段上传。
  ///
  /// 文件名采用「时间戳 + 随机数 + 原始后缀」格式，避免后端命名冲突；后端按
  /// `file` 字段读取，与图片上传 helper 一致。空 / 缺失后缀兜底成 `.mp4`，避免
  /// 后端按扩展名校验时拒收。
  Future<VideoUploadResultModel?> _uploadOnce(String localPath) async {
    final String rawExt = _getNameSuffix(localPath);
    final String ext = rawExt.isEmpty ? 'mp4' : rawExt;
    final String filename =
        '${DateTime.now().toIso8601String()}x${Random().nextInt(1024)}.$ext';

    final FormData formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(localPath, filename: filename),
    });

    final Options options = Options(
      method: 'POST',
      // 视频整段上传比图片慢得多，超时拉长；服务端目前最大支持几百 MB，
      // 5 分钟在常见网络下够用，再大需要按机型 / 网络再调。
      sendTimeout: 5 * 60 * 1000,
      receiveTimeout: 5 * 60 * 1000,
      contentType: '*/*',
      headers: {
        'user-agent': await HttpRequest().userAgent(),
        'Authorization': UserStore.to.getToken(),
      },
    );

    VideoUploadResultModel? model;
    try {
      final Response resp = await _dio.post(
        Address.uploadUrl!,
        options: options,
        data: formData,
        onSendProgress: (count, total) {
          if (total > 0) {
            onUpdate(count / total, msg: '上传中 $count/$total');
          }
        },
      );

      if (resp.statusCode == null ||
          resp.statusCode! < 200 ||
          resp.statusCode! >= 300) {
        Logger().e(tag,
            '_uploadOnce()...http NOT OK status:${resp.statusCode} body:${resp.data}');
        return null;
      }

      // 后端实际响应（与多图上传同一份契约）：
      // `{"code":0,"msg":"success","data":[{"serverPath":"content/.../xxx.mp4",
      //  "fileName":"2026-05-29T15:25:14.126670x252.mp4"}]}`
      dynamic respData = resp.data;
      if (respData is String) {
        if (respData.isEmpty) {
          Logger().e(tag, '_uploadOnce()...empty response body');
          return null;
        }
        try {
          respData = json.decode(respData);
        } catch (e) {
          Logger().e(tag, '_uploadOnce()...response is not json: $respData');
          return null;
        }
      }
      if (respData is! Map) {
        Logger().e(tag, '_uploadOnce()...unexpected response: $respData');
        return null;
      }
      final Map<String, dynamic> dataMap = Map<String, dynamic>.from(respData);

      // 后端业务码：成功是 `0`（int）；偶尔被序列化成字符串 `'0'` 也能匹配。
      if (_asInt(dataMap['code']) != 0) {
        Logger().e(tag,
            '_uploadOnce()...biz failed code:${dataMap['code']} msg:${dataMap['msg']} tip:${dataMap['tip']}');
        return null;
      }

      dynamic payload = dataMap['data'];
      if (dataMap['hash'] == true) {
        final String decryptData = decryptGatewayCipherWithResponseTime(
          payload.toString(),
          dataMap['time'],
        );
        payload = json.decode(decryptData);
      }

      // 单视频上传后端只回 1 个数组元素，但解析按「列表 + 第一项」走，方便日后
      // 后端如果改成单对象（旧 chunked 协议风格）也能直接兼容。
      Map? firstItem;
      if (payload is List && payload.isNotEmpty && payload.first is Map) {
        firstItem = payload.first as Map;
      } else if (payload is Map) {
        firstItem = payload;
      }
      if (firstItem == null) {
        Logger().e(tag,
            '_uploadOnce()...payload not List<Map> or Map: $payload');
        return null;
      }
      final Map<String, dynamic> body = Map<String, dynamic>.from(firstItem);

      // 服务端字段名是 `serverPath`；为了不锁死契约，同时兜底老字段 `videoUri`。
      final String? videoUri =
          body['serverPath']?.toString();
      if (videoUri == null || videoUri.isEmpty) {
        Logger().e(tag, '_uploadOnce()...no serverPath in payload: $body');
        return null;
      }

      // 当前接口没有独立的视频 id，用 `fileName` 顶上以维持 [VideoUploadResultModel]
      // 旧字段语义（`id` 大致代表「这次上传的唯一标识」）。
      model = VideoUploadResultModel()
        ..fileName = body['fileName']?.toString()
        ..videoUri = videoUri;
    } on DioError catch (e) {
      Logger().e(tag,
          '_uploadOnce()...DioError type:${e.type} message:${e.message} resp.status:${e.response?.statusCode} resp.data:${e.response?.data}');
    } catch (e) {
      Logger().e(tag, '_uploadOnce()...error:$e');
    }
    return model;
  }

  /// 取路径末段的扩展名（不含 `.`）；无后缀返回空串。
  ///
  /// 简化版，避免与 [MultiImageUploadHelper] 重复实现 path 解析逻辑。
  static String _getNameSuffix(String absPath) {
    if (TextUtil.isEmpty(absPath)) return '';
    final String path = Uri.parse(absPath).path;
    final int slash = path.lastIndexOf(Platform.pathSeparator);
    final String name = (slash >= 0 && slash < path.length - 1)
        ? path.substring(slash + 1)
        : path;
    final int dot = name.lastIndexOf('.');
    if (dot <= 0 || dot >= name.length - 1) return '';
    return name.substring(dot + 1);
  }

  /// 把动态 `code` 字段统一成 int 比较。后端目前回 `0`（int），但偶尔被序列化
  /// 成字符串 `'0'`，统一一层避免业务码判定出现误判。
  static int? _asInt(dynamic v) {
    if (v == null) return null;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString());
  }
}
