import 'dart:io';

import 'package:comics_app/common/apis/ai_api.dart';
import 'package:comics_app/common/entities/ai/ai_params.dart';
import 'package:comics_app/common/routers/app_routes.dart';
import 'package:comics_app/common/store/user.dart';
import 'package:comics_app/common/utils/files_upload/multi_image_upload_task.dart';
import 'package:comics_app/common/utils/task_manager.dart';
import 'package:comics_app/common/utils/toast_util.dart';
import 'package:comics_app/pages/ai_index/widgets/ai_task_submit_helper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_pickers/image_pickers.dart';

import 'state.dart';
import 'feedback.dart';

class AiAdvancedUndressLogic extends GetxController {
  final AiAdvancedUndressState state = AiAdvancedUndressState();
  int _uploadVersion = 0;

  int get remainCoins =>
      AIApi.cachedHome?.goldBalance ??
      UserStore.to.getUserInfoModel?.walletApp ??
      0;

  String get costText => AiTaskSubmitHelper.costTextOf(state.rule);

  String get balanceText =>
      AiTaskSubmitHelper.balanceTextOf(state.rule, remainCoins);

  @override
  void onInit() {
    super.onInit();
    state.rule = AiTaskSubmitHelper.ruleFromArgs();
    state.costCoins = AiTaskSubmitHelper.costCoinsFromRule(state.rule);
    UserStore.to.refreshUser().then((_) => update()).catchError((_) {});
  }

  void selectMode(int index) {
    if (index < 0 || index >= state.modes.length) return;
    if (state.modeIndex == index) return;
    state.modeIndex = index;
    update(['options', 'submit']);
  }

  void selectBreast(int index) {
    if (index < 0 || index >= state.breastSizes.length) return;
    if (state.breastIndex == index) return;
    state.breastIndex = index;
    update(['options', 'submit']);
  }

  void selectHair(int index) {
    if (index < 0 || index >= state.hairStyles.length) return;
    if (state.hairIndex == index) return;
    state.hairIndex = index;
    update(['options', 'submit']);
  }

  Future<void> pickImage() async {
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
      if (path == null || path.isEmpty) return;

      final file = File(path);
      if (!await file.exists()) {
        showToast(msg: '图片读取失败');
        return;
      }
      final size = await file.length();
      if (size > AiAdvancedUndressState.maxImageBytes) {
        showToast(msg: '图片不能超过 10M');
        return;
      }

      state.localImagePath = path;
      state.remoteImageUrl = null;
      state.uploadStatus = AiImageUploadStatus.uploading;
      state.uploadProgress = 0;
      update(['image', 'submit']);

      final uploadVersion = ++_uploadVersion;
      await _uploadImage(path, uploadVersion);
    } catch (_) {
      showToast(msg: '选择图片失败');
    }
  }

  void clearImage() {
    _uploadVersion++;
    _resetImageState();
    update(['image', 'submit']);
  }

  void _resetImageState() {
    state.localImagePath = null;
    state.remoteImageUrl = null;
    state.uploadStatus = AiImageUploadStatus.idle;
    state.uploadProgress = 0;
  }

  bool _isCurrentUpload(int version, String path) {
    return !isClosed &&
        _uploadVersion == version &&
        state.localImagePath == path;
  }

  Future<void> _uploadImage(String localPath, int uploadVersion) async {
    try {
      final multiImageModel = await taskManager.addTaskToQueue(
        MultiImageUploadTask(
          [localPath],
          updateListener: (values, {isSuccess, msg}) {
            if (!_isCurrentUpload(uploadVersion, localPath)) return;
            state.uploadProgress = values.clamp(0.0, 1.0).toDouble();
            update(['image']);
          },
        ),
      );
      if (!_isCurrentUpload(uploadVersion, localPath)) return;

      final url = multiImageModel.filePath?.firstOrNull ?? '';
      if (url.isEmpty) {
        _resetImageState();
        update(['image', 'submit']);
        showAiUploadFailureToast();
        return;
      }

      state.remoteImageUrl = url;
      state.uploadStatus = AiImageUploadStatus.success;
      state.uploadProgress = 1;
      update(['image', 'submit']);
    } catch (_) {
      if (!_isCurrentUpload(uploadVersion, localPath)) return;
      _resetImageState();
      update(['image', 'submit']);
      showAiUploadFailureToast();
    }
  }

  /// H5：组装完整高级脱衣 Prompt（value key，非展示 label）。
  String _buildPrompt() {
    return AiParams.buildAdvancedUndressPrompt(
      mode: state.modes[state.modeIndex].value,
      breast: state.breastSizes[state.breastIndex].value,
      pubic: state.hairStyles[state.hairIndex].value,
    );
  }

  Future<void> startGenerate(BuildContext context) async {
    if (state.isUploading) {
      showToast(msg: '图片正在上传');
      return;
    }
    if (!state.isUploadSuccess) {
      showToast(msg: '请先上传人物图片');
      return;
    }
    if (state.costCoins > remainCoins) {
      await showAiInsufficientBalanceDialog(
        context: context,
        costCoins: state.costCoins,
        balanceCoins: remainCoins,
        onRecharge: () async {
          await Get.toNamed(AppRoutes.WALLET);
          if (isClosed) return;
          try {
            await Future.wait([
              AIApi.getHome(),
              UserStore.to.refreshUser(),
            ]);
          } catch (_) {
            // 返回页面时仍以当前缓存余额展示，不阻断用户继续操作。
          }
          if (!isClosed) update();
        },
      );
      return;
    }

    final images = AiParams.serializeAiImages([state.remoteImageUrl!]);
    final prompt = _buildPrompt();
    if (context.mounted) {
      await AiTaskSubmitHelper.submitAndOpenProgress(
        context: context,
        billingRule: state.rule,
        onBalanceChanged: update,
        create: () => AIApi.undressCreate(
          images: images,
          prompt: prompt,
          billingRule: state.rule,
        ),
      );
    }
  }
}
