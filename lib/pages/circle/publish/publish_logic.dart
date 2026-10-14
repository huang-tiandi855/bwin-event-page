import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:comics_app/common/apis/circle_api.dart';
import 'package:comics_app/common/routers/app_routes.dart';
import 'package:comics_app/common/utils/files_upload/multi_image_upload_task.dart';
import 'package:comics_app/common/utils/files_upload/video_upload_task.dart';
import 'package:comics_app/common/utils/task_manager.dart';
import 'package:comics_app/common/widgets/common_dialog/loading_dialog.dart';
import 'package:fbroadcast/fbroadcast.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart' hide MultipartFile, FormData;
import 'package:image_picker/image_picker.dart';
import 'package:image_pickers/image_pickers.dart';
import 'package:video_compress/video_compress.dart';
import '../../../common/utils/array_util.dart';
import '../../../common/utils/text_util.dart';
import '../../../common/utils/toast_util.dart';
import '../../../common/widgets/custom_picture_management.dart';
import 'publish_state.dart';

class PublishLogic extends GetxController {
  final PublishState state = PublishState();

  @override
  void onInit() {
    super.onInit();

    /// 注册接收器
    ///
    /// register
    FBroadcast.instance().register("closeUploadDialog", (value, callback) {
      Get.back();
    });
  }

  ///选择图片 视频
  onSelectPicAndVideo(UploadType uploadType) async {
    if (uploadType != UploadType.UPLOAD_VIDEO) {
      var list = await _pickImg(999999);
      if (ArrayUtil.isEmpty(list) || list.isEmpty) {
        showToast(
          msg: "请至少选择1张图片",
        );
        return;
      }

      if (GetPlatform.isAndroid) {
        for (var element in list) {
          state.picList.add(element);
        }
      } else {
        /*for (var element in list) {
          state.picWebList.add(element);
        }*/
      }
    } else {
      var path = await _pickVideo();

      final thumbnailFile =
          await VideoCompress.getFileThumbnail(path.toString(),
              quality: 100, // default(100)
              position: -1 // default(-1)
              );

      state.videoPath = path.toString();
      state.videoPicList = [thumbnailFile.path];
    }

    update();
  }

  ///选择图片
  Future<List<dynamic>> _pickImg(int needCount) async {
    try {
      List<String?> imagePaths = [];
      List<Uint8List?> imageWebPaths = [];

      if (GetPlatform.isAndroid) {
        List<Media> mediaList = await ImagePickers.pickerPaths(
          uiConfig: UIConfig(uiThemeColor: const Color.fromRGBO(19, 15, 50, 1)),
          selectCount: needCount,
          showCamera: false,
          cropConfig: CropConfig(enableCrop: false),
        );

        for (Media assetEntity in mediaList) {
          imagePaths.add(assetEntity.path);
        }
      } else if (GetPlatform.isWeb) {
        final ImagePicker picker = ImagePicker();
        List<XFile> mediaList = await picker.pickMultiImage(imageQuality: 100);
        for (XFile assetEntity in mediaList) {
          imageWebPaths.add(await assetEntity.readAsBytes());
          state.picWebList.add(await assetEntity.readAsBytes());
        }
      }

      return GetPlatform.isAndroid ? imagePaths : imageWebPaths;
    } catch (e) {
      //l.e("pickImages-e", "$e");
    }
    return [];
  }

  ///选择视频
  Future<String?> _pickVideo() async {
    var pickedFile = await ImagePicker().pickVideo(source: ImageSource.gallery);

    var path = pickedFile?.path;

    // var isCheck = await checkVideoRule(path);

    // if (!isCheck) return null;

    return path;
  }

  ///检测视频规则
  // Future<bool> checkVideoRule(dynamic path) async {
  //   bool isRule = true;
  //   if (TextUtil.isEmpty(path)) {
  //     showToast(msg: "视频地址错误");
  //     return false;
  //   }

  //   FlutterVideoInfo videoInfo = FlutterVideoInfo();
  //   var info = await videoInfo.getVideoInfo(path);
  //   const kbSize = 1024;
  //   const mbSize = 1024 * kbSize;

  //   int sizeM = (info?.filesize ?? 0) ~/ mbSize;
  //   int? duration = (info?.duration ?? 0) ~/ 1000;
  //   int? size = info?.filesize;
  //   int? width = info?.width ?? 0;
  //   int? height = info?.height ?? 0;
  //   String? aspectRatio = (width / height).toStringAsFixed(2);
  //   String? filename = info?.title;
  //   String? mimeType = info?.mimetype;
  //   double aspectRatioDouble = double.parse(aspectRatio);
  //   if (duration < 15) {
  //     showToast(
  //       msg: "视频时长不能小于15秒",
  //     );
  //     isRule = false;
  //   }
  //   if (sizeM > 300) {
  //     showToast(
  //       msg: "视频不能大于300M",
  //     );
  //     isRule = false;
  //   }
  //   state.width = width;
  //   state.height = height;
  //   state.aspectRatio = aspectRatioDouble;
  //   state.playTime = duration;
  //   state.mimeType = mimeType;
  //   state.filename = filename;
  //   state.size = size;

  //   if (!isRule) {
  //     return false;
  //   } else {
  //     return true;
  //   }
  // }

  ///删除视频或图片数据
  void onDeleteItem(UploadType uploadType, int index) async {
    if (uploadType == UploadType.UPLOAD_VIDEO) {
      //ctx.state.uploadModel = UploadVideoModel();
      // ctx.dispatch(VideoPublishActionCreator.isSelectedCover(false));
      state.videoPicList.clear();
      state.videoPath = "";
    } else {
      if (state.picList.isEmpty) return;
      state.picList.removeAt(index);
    }

    update();
  }

  void clearUI() {
    state.picList.clear();
    state.videoPicList.clear();
    state.videoRemoteCoverPath = "";
    state.videoPath = "";
    state.imageDisplayStyle = null;
    state.textEditingController.clear();
    state.selectedCoin = 0;
    state.textContentEditingController.clear();

    upDate();
  }

  /// 发布帖子。
  ///
  /// 接口字段约定：
  /// - `title`     标题
  /// - `type`      帖子类型，`0` 视频 / `1` 图文 / `2` 图片，由 `state.uploadType` 推导
  /// - `costType`  消费类型，`0` 免费 / `1` VIP / `2` 金币
  /// - `gold`      金币数量；仅当 `costType == 2` 时传
  /// - `detail`    段落资源数组，按 [_buildPublishDetail] 拼装后 `jsonEncode` 为字符串
  /// - `showType`  帖子展示样式（`0` 平铺 / `1` 九宫格）；用户未选时不传
  Future<bool> _publishPost(List<String> uploadImages) async {
    final isCoin = (state.selectedCoin ?? 0) > 0;
    final Map<String, dynamic> data = {
      'title': state.textEditingController.text,
      'type': state.uploadType.index,
      'costType': isCoin ? 2 : 0,
      if (isCoin) 'gold': state.selectedCoin ?? 0,
      'detail': jsonEncode(_buildPublishDetail(uploadImages)),
      'showType': state.imageDisplayStyle?.value ?? 0,
    };

    return await CircleApi.publishPost(data);
  }

  /// 把上传完的图片地址 / 视频地址 + 文案，拼成接口要求的段落结构：
  /// `[{msg, source, type}]`，其中 `type`：`0` 图片 / `1` 视频 / `2` 文本。
  List<Map<String, dynamic>> _buildPublishDetail(List<String> uploadImages) {
    final List<Map<String, dynamic>> details = [];
    final String content = state.textContentEditingController.text;
    if (content.isNotEmpty) {
      details.add({'msg': content, 'source': '', 'type': 2});
    }
    for (final url in uploadImages) {
      details.add({'msg': '', 'source': url, 'type': 0});
    }
    if (state.uploadType == UploadType.UPLOAD_VIDEO &&
        (state.videoRemotePath?.isNotEmpty ?? false)) {
      details.add({
        'msg': '',
        'source': state.videoRemotePath,
        'screen': state.videoRemoteCoverPath,
        'type': 1
      });
    }

    return details;
  }

  /// 发布页底部「发布」：校验标题、话题、素材后走图文上传或视频流程。
  Future<void> submitPublish(BuildContext context) async {
    if (state.textEditingController.text == "") {
      showToast(msg: "请输入标题");
      return;
    }

    if (state.uploadType != UploadType.UPLOAD_VIDEO) {
      if (state.picList.isEmpty) {
        showToast(msg: "请至少选择1张图片");
        return;
      }
    } else {
      if (state.videoPath.isEmpty) {
        showToast(msg: "请选择视频");
        return;
      }
    }

    List<String> paths = [];
    if (state.picList.isNotEmpty) {
      await loadingDialog.show(context,
          message: "开始上传图片", showTip: true, isDismissible: true);
      try {
        final multiImageModel = await taskManager.addTaskToQueue(
            MultiImageUploadTask(state.picList,
                updateListener: (values, {isSuccess, msg}) {
          loadingDialog.update(values * 100.0, message: "图片上传中...");
        }));
        paths = multiImageModel.filePath ?? [];
        await loadingDialog.dismiss();
      } catch (e) {
        await loadingDialog.dismiss();
        showToast(msg: "上传图片失败");
        return;
      }
    }
    if (state.videoPath.isNotEmpty && context.mounted) {
      await loadingDialog.show(context,
          message: "开始上传视频", showTip: true, isDismissible: true);
      try {
        final multiImageModel = await taskManager.addTaskToQueue(
            MultiImageUploadTask(state.videoPicList,
                updateListener: (values, {isSuccess, msg}) {
          loadingDialog.update(values * 100.0, message: "图片上传中...");
        }));
        state.videoRemoteCoverPath = multiImageModel.filePath?.firstOrNull ?? "";
        if (state.videoRemoteCoverPath?.isEmpty ?? true) {
          showToast(msg: "上传封面失败");
          return;
        }
        final model = await taskManager.addTaskToQueue(VideoUploadTask(
            state.videoPath, updateListener: (values, {isSuccess, msg}) {
          loadingDialog.update(values * 100.0, message: "视频上传中...");
        }));
        state.videoRemotePath = model.videoUri;
        await loadingDialog.dismiss();
      } catch (e) {
        await loadingDialog.dismiss();
        showToast(msg: "上传视频失败");
        return;
      }
    }

    bool isSuccess = await _publishPost(paths);
    if (isSuccess == false) {
      showToast(msg: "发布失败");
      return;
    }
    showToast(msg: "发布成功");
    await Future.delayed(const Duration(seconds: 2), () {
      clearUI();
      Get.back();
    });
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

  void jumpMakeCenter() {
    Get.toNamed(AppRoutes.CREATE_CENTER, arguments: {"index": 1});
  }

  void upDate() {
    update();
  }
}
