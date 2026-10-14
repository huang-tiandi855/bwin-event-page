import 'package:comics_app/common/apis/mine_apis.dart';
import 'package:comics_app/common/utils/files_upload/multi_image_upload_task.dart';
import 'package:comics_app/common/utils/task_manager.dart';
import 'package:comics_app/common/utils/toast_util.dart';
import 'package:comics_app/common/widgets/common_dialog/custom_loading_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_pickers/image_pickers.dart';

import '../../../common/routers/app_routes.dart';
import 'state.dart';

class FeedBackLogic extends GetxController {
  final FeedBackState state = FeedBackState();

  bool _feedbackInputDisposed = false;

  /// 仅在页面 `State.dispose` 中调用（勿在 [onClose] 里 dispose，避免路由 pop 时
  /// GetX 提前 `delete` 后过渡动画期间 [TextField] 仍持有已 dispose 的 controller）。
  void disposeFeedbackInput() {
    if (_feedbackInputDisposed) return;
    _feedbackInputDisposed = true;
    state.feedbackController.removeListener(_onFeedbackChanged);
    state.feedbackController.dispose();
  }

  @override
  void onInit() {
    super.onInit();
    state.feedbackController = TextEditingController();
    state.feedbackController.addListener(_onFeedbackChanged);
  }

  void _onFeedbackChanged() {
    update(['input']);
  }

  void selectCategory(int index) {
    state.selectedCategoryIndex = index;
    update(['categories']);
  }

  Future<void> insertImage() async {
    const max = FeedBackState.maxImageCount;
    final remaining = max - state.imagePaths.length;
    if (remaining <= 0) {
      showToast(msg: '最多只能添加$max张图片');
      return;
    }

    final file = await ImagePickers.pickerPaths(
      uiConfig: UIConfig(uiThemeColor: const Color.fromRGBO(19, 15, 50, 1)),
      selectCount: remaining,
      showCamera: false,
      cropConfig: CropConfig(enableCrop: false),
    );
    if (file.isNotEmpty) {
      for (var element in file) {
        if (state.imagePaths.length >= max) break;
        final path = element.path ?? '';
        if (path.isEmpty) continue;
        state.imagePaths.add(path);
      }
      showToast(msg: '已添加图片');
      update(['imagePaths']);
    }
  }

  void removeImage(int index) {
    state.imagePaths.removeAt(index);
    update(['imagePaths']);
  }

  Future<void> submit() async {
    if (state.submitting) return;
    if (state.selectedCategoryIndex < 0) {
      showToast(msg: '请选择遇到的问题类型');
      return;
    }
    final text = state.feedbackController.text.trim();
    if (text.isEmpty) {
      showToast(msg: '请填写问题描述');
      return;
    }

    final context = Get.context;
    if (context == null) return;

    final feedbackType = FeedBackState
        .categories[state.selectedCategoryIndex].feedbackType?.value;

    state.submitting = true;
    final loadingWidget = LoadingWidget(title: '上传中');
    loadingWidget.show(context);

    String? annex;
    if (state.imagePaths.isNotEmpty) {
      try {
        final multiImageModel = await taskManager.addTaskToQueue(
          MultiImageUploadTask(List<String>.from(state.imagePaths)),
        );
        final uploadedPaths = multiImageModel.filePath ?? <String>[];
        if (uploadedPaths.isEmpty) {
          loadingWidget.cancel();
          state.submitting = false;
          showToast(msg: '图片上传失败，请稍后再试');
          return;
        }
        annex = uploadedPaths.join(',');
      } catch (_) {
        loadingWidget.cancel();
        state.submitting = false;
        showToast(msg: '图片上传失败，请稍后再试');
        return;
      }
    }

    try {
      final resp = await MineApis.feedBackSubmit(
        annex: annex,
        content: text,
        feedbackType: feedbackType,
      );
      loadingWidget.cancel();
      state.submitting = false;

      if (resp.isSuccess) {
        showToast(msg: '提交成功，感谢您的反馈');
        Get.back();
      } else {
        showToast(msg: resp.tip ?? '提交失败，请稍后再试');
      }
    } catch (_) {
      loadingWidget.cancel();
      state.submitting = false;
      showToast(msg: '提交失败，请稍后再试');
    }
  }

  void openCustomerService() {
    Get.toNamed(AppRoutes.MINE_COMMON_PROBLEM);
  }
}
