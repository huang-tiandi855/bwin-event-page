// ignore_for_file: unused_element

import 'package:comics_app/common/entities/module_detail_model/all_media_info_model.dart';
import 'package:comics_app/common/utils/check_buy_permission.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../common/entities/module_detail_model/content_model.dart';
import '../../common/style/color.dart';
import '../../common/utils/const.dart';
import '../../common/utils/toast_util.dart';
import '../../common/utils/video_download/video_download_manager.dart';
import '../../common/utils/video_download/video_load_record.dart';
import '../../generated/assets.dart';

class VideoLoadButton extends StatefulWidget {
  final AllMediaInfoModel? videoModel;
  final int? pageType; //0长视频  1 短视频
  final Function? callback;
  final int index;

  const VideoLoadButton({
    Key? key,
    this.videoModel,
    this.pageType,
    this.callback,
    this.index = 0,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _VideoLoadButtonState();
  }
}

class _VideoLoadButtonState extends State<VideoLoadButton> {
  DownloadCallBack? _callBack;

  AllMediaInfoModel? get _modelInfo => widget.videoModel;
  ContentModel? get _videoInfo => _modelInfo?.contents[widget.index];
  bool get isCartoon => _modelInfo?.kind == KindConst.CARTTONKIND;

  int get loadStatus {
    // 0 未下载，1下载中，2下载完成
    if (_videoInfo?.localPath?.isNotEmpty == true || _videoInfo?.isLoaderRunning == "2") {
      return 2;
    } else if (_videoInfo?.isLoaderRunning == "1") {
      return 1;
    } else {
      return 0;
    }
  }


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _loadData();
    });
  }

  void _loadData() async {
    _callBack = DownloadCallBack(
      success: (url) {
        if (_videoInfo?.realVideoUrl == url) {
          _videoInfo?.isLoaderRunning = "2";
          _videoInfo?.loadProgress = "100.00";
        }
        showToast(msg: "视频下载完成");
        setState(() {});
      },
      fail: (url, error) {
        if (_videoInfo?.realVideoUrl == url) {
          _videoInfo?.isLoaderRunning = "0";
        }
        showToast(msg: "缓存加载失败");
        setState(() {});
      },
      progress: (url, progress) {
        var urlD = _videoInfo?.realVideoUrl;
        if (urlD == url) {
          _videoInfo?.isLoaderRunning = "1";
          _videoInfo?.loadProgress = progress;
          setState(() {});
        }
      },
    );
    dynamic result = await VideoDownloadManager.instance.searchInfo(
      url: _videoInfo?.realVideoUrl,
      callBack: _callBack,
    );
    if (result is Map) {
      Map fileInfoMap = result;
      String? filePath = fileInfoMap["localPath"];
      if (filePath != null && filePath.isNotEmpty == true) {
        _videoInfo?.localPath = filePath;
      } else if (fileInfoMap["isLoaderRunning"] == "1") {
        _videoInfo?.isLoaderRunning = "1";
        _videoInfo?.loadProgress = fileInfoMap["progress"];
      } else {}
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<bool> _checkPermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
    }
    return status.isGranted;
  }

  void _downEvent() async {
   bool isOk = await CheckPermissionUtils.checkBuyPermission(_modelInfo!, widget.index, (value) {

    });

   if(isOk){
      if (loadStatus == 0) {
        // 下载
        _checkPermission().then((hasGranted) async {
          var result = await VideoDownloadManager.instance.download(
            url: _videoInfo?.realVideoUrl ?? "",
            callBack: _callBack,
          );
          if (result == null) {
            _videoInfo?.mediaStatus?.hasPaid = true;
            CacheMediaType movieType = CacheMediaType.video;
            if (isCartoon) {
              movieType = CacheMediaType.cartoon;
            } else if (widget.pageType == 1) {
              movieType = CacheMediaType.short;
            } else {}
            VideoLoadRecord.instance.saveVideoInfo(movieType, _videoInfo);
          }
          if (result == null) {
            _videoInfo?.isLoaderRunning == "1";
            showToast(msg: "开始下载...");
          } else if (result == "正在执行") {
            showToast(msg: "正在下载中...");
          } else if (result == "已下载完成了") {
            showToast(msg: "已下载完成");
          } else {
            showToast(msg: result.toString());
          }
          setState(() {});
        });
      } else if (loadStatus == 1) {
        showToast(msg: "正在下载中...");
      } else if (loadStatus == 2) {
        showToast(msg: "已下载完成");
      } else {}
      widget.callback?.call();
    }
    return;

  }

  @override
  Widget build(BuildContext context) {
    String statusDesc = "下载";
    if (loadStatus == 1) {
      statusDesc = "下载中";
    }
    if (loadStatus == 2) {
      statusDesc = "已下载";
    }
    return InkWell(
      onTap: _downEvent,
      child: widget.pageType == 0
          ? Container(
              margin: const EdgeInsets.only(right: 8, left: 8),
              child: Container(
                margin: const EdgeInsets.only(top: 2),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SvgPicture.asset(
                      Assets.acgPlayDownloadIcon,
                      width: 20.w,
                      height: 20.w,
                    ),
                    6.horizontalSpace,
                    Text(
                      statusDesc,
                      style: TextStyle(
                          height: 1.4, color: AppColor.black, fontSize: 14.sp),
                    ),
                  ],
                ),
              ),
            )
          : SizedBox(
              width: 30,
              height: 30,
              child: Column(
                children: <Widget>[
                  GestureDetector(
                    onTap: _downEvent,
                    child:  Container(
                      margin: const EdgeInsets.only(top: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SvgPicture.asset(
                            Assets.acgPlayDownloadIcon,
                            width: 20.w,
                            height: 20.w,
                          ),
                          6.horizontalSpace,
                          Text(
                            "下载",
                            style: TextStyle(
                                height: 1.4, color: AppColor.black, fontSize: 14.sp),
                          ),
                        ],
                      ),
                    ),
                  ),
                  //_loadStatusDescWidget()
                ],
              ),
            ),
    );
  }

  Widget _loadStatusDescWidget() {
    if (loadStatus == 0) {
      return Text(
        widget.pageType == 0 ? "下载视频" : "下载",
        style: const TextStyle(
          fontSize: 11,
          color: Colors.white,
        ),
      );
    } else if (loadStatus == 1) {
      return Text(
        "${_videoInfo?.loadProgress ?? "0"}%",
        style: const TextStyle(
          fontSize: 11,
          color: Colors.white,
        ),
      );
    } else {
      return const Text(
        "已下载",
        style: TextStyle(
          fontSize: 11,
          color: Colors.white,
        ),
      );
    }
  }

  @override
  void dispose() {
    VideoDownloadManager.instance.removeAllCallBack();
    super.dispose();
  }
}
