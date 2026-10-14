import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:comics_app/common/utils/task_state.dart';
import 'package:comics_app/common/utils/text_util.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:comics_app/common/http/http_request.dart';
import 'multi_image_model.dart';
import '../../http/http_detect_line_dio.dart';
import '../../http/gateway_crypto.dart'
    show decryptGatewayCipherWithResponseTime;
import '../../http/logInterceptor.dart';
import '../../store/user.dart';
import '../../values/address.dart';
import '../array_util.dart';

/// 多重图片上传工具类
/// 和cacheManager一样，类似的webHelper
/// 网路业务和管理业务分开，各个不同的业务比如音色/vpn/短视频，只需要实现自己的上传Helper就行
mixin MultiImageUploadHelper on TaskState {
  // factory UploadHelper._() => null;
  bool isChatUpload = false;
  final String tag = "MultiImageUploadHelper";
  final maxRetryCount = 3;
  final Dio _dio = createDio();
  Future<MultiImageModel?> uploadFile(List<String> localPaths, bool isUploadChatImage) async {
    isChatUpload = isUploadChatImage;
    _dio.interceptors.add(HttpLogInterceptor());
    if (ArrayUtil.isEmpty(localPaths)) {
      onError("uploadFile localpath is empty");
      return null;
    }
    if (TextUtil.isEmpty(Address.uploadUrl)) {
      onError('uploadFile uploadUrl is empty');
      return null;
    }
    for (final p in localPaths) {
      if (!await File(p).exists()) {
        onError('uploadFile file not exist: $p');
        return null;
      }
    }

    onUpdate(0.01);
    MultiImageModel? model = await _uploadOnceAndRetry(localPaths);
    if (null == model) {
      onUpdate(0.0);
      onError("error to upload");
    } else {
      onUpdate(1.0);
    }
    return model;
  }

  /// 发送分片重试3次
  Future<MultiImageModel?> _uploadOnceAndRetry(List<String> localPaths) async {
    var retryCount = 0;
    while (retryCount <= maxRetryCount && !isTaskCanceled()) {
      final model = await _uploadOnce(localPaths);
      if (null != model) return model;
      retryCount++;
      if (retryCount >= maxRetryCount) {
        Logger().e(tag,
            '_uploadOnceAndRetry()...all $maxRetryCount attempts failed, count:${localPaths.length}');
        return null;
      }
    }
    return null;
  }

  /// 单次上传一个分片数据
  Future<MultiImageModel?> _uploadOnce(List<String> localPaths) async {
    final List<MultipartFile> formDateList = [];
    for (var index = 0; index < localPaths.length; index++) {
      final src = localPaths[index];
      final extent = getNameSuffix(src);
      final filename =
          '${DateTime.now().toIso8601String()}x${Random().nextInt(1024)}.$extent';
      formDateList.add(await MultipartFile.fromFile(src, filename: filename));
    }

    final mapFormData = FormData.fromMap({'file': formDateList});

    final options = Options(
      method: "POST",
      sendTimeout: 15000,
      receiveTimeout: 15000,
      contentType: "*/*",
      headers: {
        'user-agent': await HttpRequest().userAgent(),
        'Authorization': UserStore.to.getToken(),
      },
    );

    MultiImageModel? model;

    try {
      final Response resp = await _dio.post(
        isChatUpload ? Address.chatUploadUrl! : Address.uploadUrl!,
        options: options,
        data: mapFormData,
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

      if (dataMap['hash'] != true) {
        model = MultiImageModel.fromJson(dataMap, isSercet: false);
      } else {
        final String decryptData = decryptGatewayCipherWithResponseTime(
          dataMap['data'].toString(),
          dataMap['time'],
        );
        final dynamic data = json.decode(decryptData);
        model = MultiImageModel.fromJson(
          data is Map<String, dynamic>
              ? data
              : Map<String, dynamic>.from(data as Map),
          isSercet: true,
        );
      }

      if (!model.isSuccess) {
        Logger().e(tag,
            '_uploadOnce()...biz failed code:${model.code} msg:${model.msg}');
        model = null;
      }
    } on DioError catch (e) {
      Logger().e(tag,
          '_uploadOnce()...DioError type:${e.type} message:${e.message} resp.status:${e.response?.statusCode} resp.data:${e.response?.data}');
    } catch (e) {
      Logger().e(tag, '_uploadOnce()...error:$e');
    }
    return Future.value(model);
  }

  /// 获取文件名带后缀
  /// 获取任何路径url/uri/file/abspath的问题见名称
  static String getName(String absPath) {
    if (TextUtil.isEmpty(absPath)) return absPath;
    absPath = Uri.parse(absPath).path;
    var start = absPath.lastIndexOf(Platform.pathSeparator);
    if (start <= 0 || (start == absPath.length - 1)) {
      return absPath;
    } else {
      return absPath.substring(start + 1);
    }
  }

  /// 获取文件名后缀,fileExtension
  /// 获取任何路径url/uri/file/abspath的问题见名称
  static String getNameSuffix(String absPath) {
    var name = getName(absPath);
    if (TextUtil.isEmpty(name)) return name;
    var ar = name.split('.');
    if (ArrayUtil.isEmpty(ar)) {
      return name;
    } else if (ar.length < 2) {
      return ar[0];
    } else {
      return ar[ar.length - 1];
    }
  }
}
