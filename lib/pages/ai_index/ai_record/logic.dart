import 'package:comics_app/common/apis/ai_api.dart';
import 'package:comics_app/common/entities/ai/ai_models.dart';
import 'package:comics_app/common/routers/app_routes.dart';
import 'package:comics_app/common/store/user.dart';
import 'package:comics_app/common/utils/debug_log.dart';
import 'package:comics_app/common/utils/toast_util.dart';
import 'package:comics_app/common/values/address.dart';
import 'package:comics_app/pages/application/application_logic.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../common/entities/ai/ai_image_media.dart';
import '../../../common/entities/ai/ai_video_media.dart';
import 'state.dart';

List<String> normalizeAiResultUrls(Iterable<String>? urls) {
  return (urls ?? const <String>[])
      .map((url) => url.trim())
      .where((url) => url.isNotEmpty)
      .toList(growable: false);
}

int normalizeAiResultIndex(int index, int length) {
  if (length <= 0 || index < 0) return 0;
  if (index >= length) return length - 1;
  return index;
}

String? selectAiImageDownloadUrl({
  required int resultIndex,
  required Iterable<String>? downloadResultUrls,
  required Iterable<String>? taskResultUrls,
  String? downloadUrl,
}) {
  final responseUrls = normalizeAiResultUrls(downloadResultUrls);
  final taskUrls = normalizeAiResultUrls(taskResultUrls);

  String? urlAt(List<String> urls) {
    if (resultIndex < 0 || resultIndex >= urls.length) return null;
    return urls[resultIndex];
  }

  final indexedUrl = urlAt(responseUrls) ?? urlAt(taskUrls);
  if (indexedUrl != null) return indexedUrl;

  // 单地址字段没有索引语义，只能作为第一张的兼容兜底；切到后续图片时
  // 绝不能退回第一张，否则用户看到第 N 张却下载到第 1 张。
  if (resultIndex == 0) {
    final single = downloadUrl?.trim();
    if (single != null && single.isNotEmpty) return single;
  }
  return null;
}

class AiRecordLogic extends GetxController {
  final AiRecordState state = AiRecordState();

  @override
  void onInit() {
    super.onInit();
    loadWorks(refresh: true);
  }

  @override
  void onClose() {
    state.refreshController.dispose();
    super.onClose();
  }

  Future<void> loadWorks({bool refresh = false}) async {
    if (state.loading) return;
    if (refresh) {
      state.resetList();
      state.refreshController.requesting();
    } else if (!state.hasMore) {
      state.refreshController.requestSuccess(
        isFirstPageNum: false,
        hasMore: false,
        isEmpty: state.records.isEmpty,
      );
      return;
    }

    state.loading = true;
    final page = refresh ? 1 : state.page;
    try {
      final result = await AIApi.taskList(
        page: page,
        toastOnFail: refresh,
      );
      if (refresh) {
        state.records
          ..clear()
          ..addAll(result.list);
      } else {
        state.records.addAll(result.list);
      }
      state.total = result.total;
      state.hasMore =
          state.records.length < result.total && result.list.isNotEmpty;
      state.page = page + 1;
      state.refreshController.requestSuccess(
        isFirstPageNum: refresh || page == 1,
        hasMore: state.hasMore,
        isEmpty: state.records.isEmpty,
      );
      update();
    } catch (_) {
      state.refreshController.requestFail(
        isFirstPageNum: refresh || page == 1,
      );
    } finally {
      state.loading = false;
    }
  }

  void onRefresh() => loadWorks(refresh: true);

  void onLoadMore() => loadWorks(refresh: false);

  void onItemTap(AiTaskVo item, {int initialIndex = 0}) {
    final resultUrls = item.resultUrls ?? const <String>[];
    debugLog(
      '[AI_RESULT_URLS] PREVIEW BEGIN '
      'id=${item.id} taskNo=${item.taskNo} '
      'type=${item.type} status=${item.status} count=${resultUrls.length}',
    );
    for (var index = 0; index < resultUrls.length; index++) {
      final url = resultUrls[index];
      debugLog(
        '[AI_RESULT_URLS] PREVIEW[$index] '
        'length=${url.length} url=$url',
      );
    }
    debugLog('[AI_RESULT_URLS] PREVIEW END taskNo=${item.taskNo}');

    if (item.expired == true) {
      showToast(msg: '作品已过期');
      return;
    }
    if (!item.isSuccess) {
      if (item.isProcessing) {
        showToast(msg: '任务正在后台处理，请稍后下拉刷新');
        return;
      }
      final error = item.errorMsg?.trim() ?? '';
      showToast(msg: error.isNotEmpty ? error : item.displayStatusName);
      return;
    }

    final urls = normalizeAiResultUrls(item.resultUrls);
    if (urls.isEmpty) {
      showToast(msg: '暂无预览地址');
      return;
    }

    if (item.type == 2) {
      final videoUrl = Address.buildH5VideoUrl(
        urls.first,
        withCdn: false,
      );
      Get.toNamed(
        AppRoutes.SIMPLE_PLAYER,
        arguments: {
          'videoUrl': videoUrl,
          'coverUrl': item.displayCover ?? '',
          'prepareHlsAsMp4': true,
        },
      );
      return;
    }

    Get.toNamed(
      AppRoutes.PICTURE_PREVIEW,
      arguments: {
        'seriesCover': urls,
        'index': normalizeAiResultIndex(initialIndex, urls.length),
        'title': item.ruleName ?? item.typeName ?? '我的作品',
      },
    );
  }

  Future<void> onDownload(
    AiTaskVo item, {
    int resultIndex = 0,
  }) async {
    if (!item.isSuccess || item.expired == true) {
      showToast(msg: '作品暂不可下载');
      return;
    }
    final id = item.id;
    if (id == null) {
      showToast(msg: '作品信息异常');
      return;
    }
    SmartDialog.showLoading();
    try {
      final result = await AIApi.workDownload(id);
      if (result == null) {
        showToast(msg: '下载失败');
        return;
      }
      await Future.wait([
        AIApi.getHome(),
        UserStore.to.refreshUser(),
      ]);
      final downloadUrl = result.downloadUrl?.trim() ?? '';
      final String rawUrl;
      if (item.type == 2) {
        final resultUrls = normalizeAiResultUrls(result.resultUrls);
        rawUrl = downloadUrl.isNotEmpty
            ? downloadUrl
            : (resultUrls.isNotEmpty ? resultUrls.first : '');
      } else {
        rawUrl = selectAiImageDownloadUrl(
              resultIndex: resultIndex,
              downloadResultUrls: result.resultUrls,
              taskResultUrls: item.resultUrls,
              downloadUrl: downloadUrl,
            ) ??
            '';
      }
      if (rawUrl.isEmpty) {
        showToast(msg: item.type == 2 ? '暂无下载地址' : '当前图片暂无下载地址');
        return;
      }

      final bool permissionGranted = await _ensureMediaSavePermission();
      if (!permissionGranted) return;

      if (item.type == 2) {
        final String url = Address.buildH5VideoUrl(
          rawUrl,
          withCdn: false,
        );
        final file = await AiVideoMedia.downloadAsMp4(
          url,
        );
        final dynamic saveResult = await ImageGallerySaver.saveFile(
          file.path,
          name: 'ai-work-$id',
        );
        final bool saved = saveResult is Map && saveResult['isSuccess'] == true;
        showToast(msg: saved ? '视频已保存到相册' : '视频保存失败');
        return;
      }

      final imageBytes = await AiImageMedia.downloadBytes(rawUrl);
      final dynamic saveResult = await ImageGallerySaver.saveImage(
        imageBytes,
        quality: 100,
        name: 'ai-work-$id-${resultIndex + 1}',
      );
      final bool saved = saveResult is Map && saveResult['isSuccess'] == true;
      showToast(msg: saved ? '图片已保存到相册' : '图片保存失败');
    } catch (error, stackTrace) {
      debugLog(
        '[AI_WORK_DOWNLOAD] failed id=$id error=$error\n$stackTrace',
      );
      showToast(msg: _downloadErrorMessage(error, isVideo: item.type == 2));
    } finally {
      SmartDialog.dismiss();
    }
  }

  Future<bool> _ensureMediaSavePermission() async {
    final android = await DeviceInfoPlugin().androidInfo;
    if (android.version.sdkInt >= 29) return true;

    final PermissionStatus status = await Permission.storage.request();
    if (status.isGranted) return true;
    showToast(msg: '请开启存储权限后重试');
    return false;
  }

  String _downloadErrorMessage(Object error, {required bool isVideo}) {
    final String message = error.toString();
    if (!isVideo) {
      if (message.contains('图片地址')) return '图片地址无效';
      if (message.contains('图片为空')) return '图片下载失败，请稍后重试';
      return '下载失败';
    }
    if (message.contains('加密的 M3U8')) {
      return '该视频为加密流，暂时无法下载';
    }
    if (message.contains('BYTERANGE') || message.contains('fMP4')) {
      return '暂不支持该视频格式';
    }
    if (message.contains('M3U8') || message.contains('视频分片')) {
      return '视频解析失败，请稍后重试';
    }
    return '下载失败';
  }

  void backToAiHome() {
    if (!Get.isRegistered<ApplicationLogic>()) {
      Get.offAllNamed(AppRoutes.APPLICATION_PAGE);
      Future<void>.delayed(Duration.zero, () {
        if (Get.isRegistered<ApplicationLogic>()) {
          Get.find<ApplicationLogic>().handleNavBarTap(2);
        }
      });
      return;
    }

    Get.until(
      (route) => route.settings.name == AppRoutes.APPLICATION_PAGE,
    );
    if (Get.isRegistered<ApplicationLogic>()) {
      Get.find<ApplicationLogic>().handleNavBarTap(2);
    }
  }
}
