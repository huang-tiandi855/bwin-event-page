import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:comics_app/common/utils/video_download/video_load_record.dart';
import 'package:m3u8_downloader/m3u8_downloader.dart';
import 'package:path_provider/path_provider.dart';
import '../../utils/const.dart';
import '../debug_log.dart';

class DownloadCallBack {
  Function(String)? success;
  Function(String, String)? fail;
  Function(String, String)? progress;

  DownloadCallBack({this.success, this.fail, this.progress});
}

class VideoDownloadManager {
  // 工厂模式
  factory VideoDownloadManager() => _getInstance();

  static VideoDownloadManager get instance => _getInstance();
  static VideoDownloadManager? _instance;
  final ReceivePort _port = ReceivePort();
  static late String basePath; // = "/sdcard/vPlayDownload";
  Map<String, List<DownloadCallBack>?> _callBack = {};

  static bool initialized = false;

  VideoDownloadManager._internal() {
    IsolateNameServer.registerPortWithName(
        _port.sendPort, _isolateM3U8LoaderPortName);
    _port.listen((dynamic data) {
      if (data is Map) {
        debugLog("isolate message:$data");
        String url = data["url"];
        List<DownloadCallBack>? arr = _callBack[url];
        if (data["status"] == 0) {
          // 缓存失败"
          for (DownloadCallBack callback in (arr ?? [])) {
            if (callback.fail != null) {
              callback.fail!(url, data["error"]);
            }
          }
          _callBack.remove(url);
        }
        if (data["status"] == 1) {
          //缓存成功
          for (DownloadCallBack callback in (arr ?? [])) {
            if (callback.success != null) {
              callback.success!(url);
            }
          }
          _callBack.remove(url);
        }
        if (data["status"] == 2) {
          //进度
          for (DownloadCallBack callback in (arr ?? [])) {
            if (callback.progress != null) {
              String progress = data["progress"].toString();
              if (data["progress"] is double) {
                double progressDouble = data["progress"];
                if (progressDouble >= 100) {
                  debugLog("1000000000001");
                }
                progress = progressDouble.toStringAsFixed(2);
              }
              callback.progress!(url, progress);
            }
          }
        }
      }
    });
  }

  Future<bool> m3u8LoaderInit() async {
    if (Platform.isIOS) {
      return false;
    }
    if (initialized) return true;
    final directory = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    basePath = '${directory!.path}/vPlayDownload'; // "/sdcard/vPlayDownload"
    String saveDir = await _findSavePath();
    initialized = await M3u8Downloader.initialize(onSelect: () async {
      return null;
    });
    if (initialized) {
      initialized = await M3u8Downloader.config(
        saveDir: saveDir,
        progressCallback: _progressCallback,
        successCallback: _successCallback,
        errorCallback: _errorCallback,
      );
    }
    return initialized;
  }

  Future<String> _findSavePath() async {
    String saveDir = basePath; //"/sdcard/vPlayDownload";
    Directory root = Directory(saveDir);
    if (!root.existsSync()) {
      await root.create();
    }
    debugLog(saveDir);
    return saveDir;
  }

  static VideoDownloadManager _getInstance() {
    _instance ??= VideoDownloadManager._internal();
    return _instance!;
  }

  emptyCache() async {
    try {
      String saveDir = basePath;
      Directory root = Directory(saveDir);
      if (root.existsSync()) {
        await root.delete(recursive: true);
      }
      VideoLoadRecord.instance.removeAllVideo(CacheMediaType.video);
      if (!root.existsSync()) {
        await root.create();
      }
      removeAllCallBack();
    } catch (e) {
      debugLog(e);
    }
  }

  Future<dynamic> searchInfo({String? url, DownloadCallBack? callBack}) async {
    if (Platform.isIOS) {
      return;
    }
    if (!initialized) {
      bool result = await m3u8LoaderInit();
      if (!result) {
        return "缓存初始化失败";
      }
    }
    dynamic ret = await M3u8Downloader.searchInfo(url ?? "");
    debugLog("======= result:$ret");
    if (ret is Map) {
      Map localInfo = ret;
      if (localInfo["isLoaderRunning"] == "1" && callBack != null) {
        addCallbackItem(url ?? "", callBack);
      }
    }
    return ret;
  }

  Future<bool> delete(String url) async {
    var ret = await M3u8Downloader.delete(url);
    _callBack.remove(url);
    return ret;
  }

  Future<dynamic> pause(String url) async {
    await M3u8Downloader.pause(url);
    _callBack.remove(url);
  }

  // 返回null，开启了任务
  Future<dynamic> download(
      {required String url, DownloadCallBack? callBack}) async {
    try {
      if (!initialized) {
        bool result = await m3u8LoaderInit();
        if (!result) {
          return "缓存加载失败";
        }
      }
      dynamic result = await M3u8Downloader.download(
        url: url,
        name: "m3u8",
      );
      if (result == null || result == "正在执行") {
        if (callBack != null) {
          addCallbackItem(url, callBack);
        }
      }
      return result;
    } catch (e) {
      return e.toString();
    }
  }

  void addCallbackItem(String url, DownloadCallBack callBack) {
    var infoArr = _callBack[url];
    if (infoArr == null) {
      infoArr = [callBack];
      _callBack[url] = infoArr;
    } else {
      infoArr.remove(callBack);
      infoArr.add(callBack);
    }
  }

  void removeAllCallBack() {
    _callBack = {};
  }
}

String _isolateM3U8LoaderPortName = "downloader_send_port";

_progressCallback(dynamic args) {
  final SendPort? send =
      IsolateNameServer.lookupPortByName(_isolateM3U8LoaderPortName);
  if (send != null) {
    args["status"] = 2;
    send.send(args);
  }
}

_successCallback(dynamic args) {
  debugLog("=======load success!!!!!!");
  debugLog(args);
  final SendPort? send =
      IsolateNameServer.lookupPortByName(_isolateM3U8LoaderPortName);
  if (send != null) {
    send.send({
      "status": 1,
      "url": args["url"],
      "filePath": args["filePath"],
      "dir": args["dir"]
    });
  }
}

_errorCallback(dynamic args) {
  final SendPort? send =
      IsolateNameServer.lookupPortByName(_isolateM3U8LoaderPortName);
  if (send != null) {
    send.send({"status": 0, "url": args["url"]});
  }
}
