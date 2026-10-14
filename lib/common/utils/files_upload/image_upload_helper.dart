import 'dart:convert';

import 'package:comics_app/common/http/http_detect_line_dio.dart';
import 'package:comics_app/common/http/http_request.dart';
import 'package:comics_app/common/http/gateway_crypto.dart'
    show decryptGatewayCipherWithResponseTime;
import 'package:comics_app/common/store/store.dart';
import 'package:comics_app/common/utils/file_util.dart';
import 'package:comics_app/common/utils/task_state.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../../values/address.dart';
import 'image_upload_result_model.dart';

/// 图片上传工具类
/// 和cacheManager一样，类似的webHelper
/// 网路业务和管理业务分开，各个不同的业务比如音色/vpn/短视频，只需要实现自己的上传Helper就行
mixin ImageUploadHelper on TaskState {
  // factory UploadHelper._() => null;
  final String tag = "ImageUploadHelper";
  final maxRetryCount = 3;
  final Dio _dio = createDio();
  Future<ImageUploadResultModel?> uploadImage(String localPath) async {
    if (!FileUtil.isFileExist(localPath)) {
      onError("uploadFile file:$localPath is not exist");
      // onDone(null); use this??
      return null;
    }
    // 开始给一个0.01 的假进度
    //onUpdate(0.0);
    ImageUploadResultModel? model = await _uploadPatchAndRetry(localPath);
    if (null == model) {
     // onUpdate(0.0);
      onError("error to upload");
      // onDone(null); or this???
    } else {
     // onUpdate(1.0);
    }
    return model;
  }

  /// 发送分片重试3次
  Future<ImageUploadResultModel?> _uploadPatchAndRetry(String localPath) async {
    var retryCount = 0;
    while (retryCount <= maxRetryCount && !isTaskCanceled()) {
      final model = await _uploadPatchOnce(localPath);
      if (null != model) return model;
      retryCount++;
      if (retryCount >= maxRetryCount) {
        Logger().e(tag,
            '_uploadPatchAndRetry()..fileId:$localPath...result:null retryCount:$retryCount');
        return null;
      }
    }
    return null;
  }

  /// 单次上传一个分片数据
  Future<ImageUploadResultModel?> _uploadPatchOnce(String localPath) async {
    FormData formData = FormData.fromMap({
      "file": await MultipartFile.fromFile(localPath,
          filename: '${DateTime.now().toIso8601String()}.jpg'),
    });
    var options = Options(
      method: "POST",
      sendTimeout: 15000,
      receiveTimeout: 15000,
      contentType: "*/*",
      headers: {
        'user-agent': await HttpRequest().userAgent(),
        "Authorization": UserStore.to.getToken(),
      },
    );

    ImageUploadResultModel? model;
    try {
      final Response resp = await _dio.post(
        Address.uploadUrl!,
        options: options,
        data: formData,
      );

      if (resp.statusCode == null ||
          resp.statusCode! < 200 ||
          resp.statusCode! >= 300) {
        Logger().e(tag,
            '_uploadPatchOnce()...http NOT OK status:${resp.statusCode} body:${resp.data}');
        return null;
      }

      dynamic respData = resp.data;
      if (respData is String) {
        if (respData.isEmpty) {
          Logger().e(tag, '_uploadPatchOnce()...empty response body');
          return null;
        }
        try {
          respData = json.decode(respData);
        } catch (e) {
          Logger()
              .e(tag, '_uploadPatchOnce()...response is not json: $respData');
          return null;
        }
      }
      if (respData is! Map) {
        Logger().e(tag, '_uploadPatchOnce()...unexpected response: $respData');
        return null;
      }
      final Map<String, dynamic> dataMap = Map<String, dynamic>.from(respData);

      dynamic data = dataMap['data'];
      if (dataMap['hash'] == true) {
        final String decryptData = decryptGatewayCipherWithResponseTime(
          data.toString(),
          dataMap['time'],
        );
        data = json.decode(decryptData);
      }

      final String? coverImg = _pickCoverImg(data);
      if (coverImg == null || coverImg.isEmpty) {
        Logger().e(tag,
            '_uploadPatchOnce()...no coverImg in response code:${dataMap['code']} msg:${dataMap['msg']} data:$data');
        return null;
      }
      model = ImageUploadResultModel()..coverImg = coverImg;
    } on DioError catch (e) {
      Logger().e(tag,
          '_uploadPatchOnce()...DioError type:${e.type} message:${e.message} resp.status:${e.response?.statusCode} resp.data:${e.response?.data}');
    } catch (e) {
      Logger().e(tag, '_uploadPatchOnce()...error:$e');
    }
    return model;
  }

  /// 兼容新旧响应结构提取图片远端路径：
  /// - 新接口：`data: [{serverPath, fileName}, ...]` → 取首个 `serverPath`
  /// - 旧接口：`data: {coverImg: "..."}` → 取 `coverImg`
  String? _pickCoverImg(dynamic data) {
    if (data is List && data.isNotEmpty) {
      final first = data.first;
      if (first is Map) {
        final v = first['serverPath'] ?? first['coverImg'] ?? first['filePath'];
        return v?.toString();
      }
    }
    if (data is Map) {
      final v = data['coverImg'] ?? data['serverPath'] ?? data['filePath'];
      return v?.toString();
    }
    return null;
  }
}
