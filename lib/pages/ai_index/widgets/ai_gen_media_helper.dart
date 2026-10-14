import 'dart:io';

import 'package:comics_app/common/utils/files_upload/multi_image_upload_task.dart';
import 'package:comics_app/common/utils/task_manager.dart';
import 'package:comics_app/common/utils/toast_util.dart';
import 'package:comics_app/common/widgets/common_dialog/loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_pickers/image_pickers.dart';

import 'ai_gen_style.dart';

/// 与发布页一致的选图 / 上传流程。
class AiGenMediaHelper {
  AiGenMediaHelper._();

  static Future<String?> pickLocalImage() async {
    try {
      String? path;
      if (GetPlatform.isWeb) {
        final xFile =
            await ImagePicker().pickImage(source: ImageSource.gallery);
        path = xFile?.path;
      } else {
        final mediaList = await ImagePickers.pickerPaths(
          uiConfig: UIConfig(uiThemeColor: const Color.fromRGBO(19, 15, 50, 1)),
          selectCount: 1,
          showCamera: false,
          cropConfig: CropConfig(enableCrop: false),
        );
        if (mediaList.isNotEmpty) {
          path = mediaList.first.path;
        }
      }
      if (path == null || path.isEmpty) return null;

      final file = File(path);
      if (!await file.exists()) {
        showToast(msg: '图片读取失败');
        return null;
      }
      final size = await file.length();
      if (size > AiGenStyle.maxImageBytes) {
        showToast(msg: '图片不能超过 10M');
        return null;
      }
      return path;
    } catch (_) {
      showToast(msg: '选择图片失败');
      return null;
    }
  }

  /// 上传本地图片，成功返回远程地址。
  static Future<String?> uploadLocalImage(
    BuildContext context,
    String localPath,
  ) async {
    await loadingDialog.show(
      context,
      message: '开始上传图片',
      showTip: true,
      isDismissible: true,
    );
    try {
      final multiImageModel = await taskManager.addTaskToQueue(
        MultiImageUploadTask(
          [localPath],
          updateListener: (values, {isSuccess, msg}) {
            loadingDialog.update(values * 100.0, message: '图片上传中...');
          },
        ),
      );
      final url = multiImageModel.filePath?.firstOrNull ?? '';
      await loadingDialog.dismiss();
      if (url.isEmpty) {
        showToast(msg: '上传图片失败');
        return null;
      }
      return url;
    } catch (_) {
      await loadingDialog.dismiss();
      showToast(msg: '上传图片失败');
      return null;
    }
  }
}
