import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:comics_app/common/http/http_detect_line_dio.dart';
import 'package:comics_app/common/http/gateway_crypto.dart'
    show decryptGatewayCipherWithResponseTime;
import 'package:comics_app/common/store/user.dart';
import 'package:comics_app/common/utils/file_util.dart';
import 'package:comics_app/common/utils/task_state.dart';
import 'package:comics_app/common/utils/files_upload/video_upload_result_model.dart';
import 'package:comics_app/common/values/address.dart';
import 'package:comics_app/pages/circle/publish/publish_logic.dart';
// import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:logger/logger.dart';
import 'package:md5_file_checksum/md5_file_checksum.dart';
import 'package:comics_app/common/http/http_request.dart';
import 'package:comics_app/common/http/code.dart';
///旧协议分片上传helper，本项目使用新协议，使用SingleVideoUploadHelper
/// 视频分片上传工具类
/// 和cacheManager一样，类似的webHelper
/// 网路业务和管理业务分开，各个不同的业务比如音色/vpn/短视频，只需要实现自己的上传Helper就行
mixin VideoUploadHelper on TaskState {
  final String tag = "VideoUploadHelper";
  final maxRetryCount = 3;
  final Dio _dio = createDio();

  final state = Get.find<PublishLogic>().state;

  Future<VideoUploadResultModel?> uploadFile(String localPath) async {
    // if (false) {
    //   (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
    //       (client) {
    //     client.findProxy = (uri) {
    //       return "PROXY 192.168.2.137:8888";
    //     };
    //   };
    // }
    if (!FileUtil.isFileExist(localPath)) {
      onError("uploadFile file:$localPath is not exist");
      return null;
    }

    onUpdate(0.0);
    var file = File(localPath);
    int fileLen = FileUtil.getFileSize(localPath);



    final fileChecksum = await Md5FileChecksum.getFileChecksum(filePath: file.path);
    //String fileId = await FileUtil.getFileMd5String(file);
    String fileId = fileChecksum;
    // 1-n次，第n次可能不足一个分片
    int patchSize = FileUtil.getPatchSize(fileLen);
    int patchCount = FileUtil.getPatchCount(fileLen);
    Logger().i(tag, "分段大小:$patchSize 视频被分成:$patchCount 个片段");
    VideoUploadResultModel? model;
    for (int pos = 0; pos < patchCount; pos++) {
      if (isTaskCanceled()) {
        onUpdate(0.0);
        onError(
            "uploadFile user canceled in send pic:${pos + 1} totalPos:$patchCount");
        return null;
      }
      // 处理最后一个分片的长度
      int shouldReadLen =
          pos < patchCount ? patchSize : min((fileLen) % patchSize, patchSize);
      Uint8List data =
          await FileUtil.getFileBlock(pos * patchSize, shouldReadLen, file);

      model = await _uploadPatchAndRetry(fileId, pos, patchCount, data);
      if (null == model) {
        onError("uploadFile error in send index/total:$pos/$patchCount");
        return null;
      } else {
        onUpdate(FileUtil.formatNum((pos + 1) / patchCount, 1), msg: "正在上传${pos + 1}/$patchCount 个分片");

       // debugPrint( "进度 ------ ${FileUtil.formatNum((pos + 1) / patchCount, 1)}");
      }
    }

    if (null == model) {
      onError("error");
    } else {
      //onUpdate(1.0);
    }
    return model;
  }

  /// 发送分片重试3次
  /// [pos] index 下标 从0开始
  /// [totalPos] length
  Future<VideoUploadResultModel?> _uploadPatchAndRetry(
      String fileId, int pos, int totalPos, Uint8List data) async {
    var retryCount = 0;
    while (retryCount <= maxRetryCount && !isTaskCanceled()) {
      var model = await _uploadPatchOnce(fileId, pos, totalPos, data);
      if (null != model) return model;
      retryCount++;
      Logger().i(tag, "_uploadPatchAndRetry()...retry index/total=$pos/$totalPos retryCount:$retryCount");
      if (retryCount >= maxRetryCount) {
        Logger().i(tag,
            '_uploadPatchAndRetry()..retry count out!!! fileId:$fileId result:$model retryCount:$retryCount');
        return model;
      }
    }
    return null;
  }

  /// 单次上传一个分片数据
  /// [pos] index from 0
  Future<VideoUploadResultModel?> _uploadPatchOnce(
      String fileId, int pos, int totalPos, Uint8List data) async {
    var options = Options(
      method: "POST",
      sendTimeout: 15000,
      receiveTimeout: 15000,
      contentType: 'application/json; charset=utf-8',
      responseType: ResponseType.json,
      headers: {
        'user-agent': await HttpRequest().userAgent(),
        "Authorization": UserStore.to.getToken(),
        'Content-Type': 'application/json'
      },
    );

    var postData = {
      'data': base64.encode(data),
      'pos': pos + 1,
      'totalPos': totalPos,
      'id': fileId,
    };
    VideoUploadResultModel? model;
    try {
      Response resp = await _dio.post(
        Address.uploadUrl!,
        options: options,
        data: postData,
        onSendProgress: (count, total) {
          var percent = (pos) / totalPos + (count / total / totalPos);
          onUpdate(percent,
              msg: "正在上传 index/total=${pos + 1}/$totalPos 个分片");
        },
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

      if (Code.isDocSuccess(dataMap['code'])) {
        dynamic payload = dataMap['data'];

        if (dataMap['hash'] == true) {
          final String decryptData = decryptGatewayCipherWithResponseTime(
            payload.toString(),
            dataMap['time'],
          );
          payload = json.decode(decryptData);
        }

        if (payload is! Map) {
          Logger().e(tag,
              '_uploadPatchOnce()...payload not Map: $payload');
          return null;
        }

        state.videoFileId = payload['id'];
        state.videoRemotePath = payload['videoUri'];

        model = VideoUploadResultModel();
        model.id = payload['id'];
        model.videoUri = payload['videoUri'];
      } else {
        Logger().e(tag,
            '_uploadPatchOnce()...biz failed code:${dataMap['code']} msg:${dataMap['msg']} tip:${dataMap['tip']}');
      }
    } on DioError catch (e) {
      Logger().e(tag,
          '_uploadPatchOnce()...DioError type:${e.type} message:${e.message} resp.status:${e.response?.statusCode} resp.data:${e.response?.data}');
    } catch (e) {
      Logger().e(tag, '_uploadPatchOnce()...error:$e');
    }
    return model;
  }
}
