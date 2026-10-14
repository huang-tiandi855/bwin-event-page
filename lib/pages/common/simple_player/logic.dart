import 'dart:developer';

import 'package:chewie/chewie.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../../common/store/user.dart';
import '../../../common/utils/toast_util.dart';
import '../../../common/values/address.dart';
import 'package:comics_app/pages/video_page/material_controls.dart'
    as video_page;

import 'state.dart';

class SimplePlayerLogic extends GetxController {
  final state = SimplePlayerState();

  @override
  void onReady() {
    super.onReady();
    _initPlayer();
  }

  Future<void> _initPlayer() async {
    if (state.initializing || state.chewie != null) return;
    if (state.videoUrl.isEmpty) {
      showToast(msg: '视频暂不可播放');
      return;
    }
    state.initializing = true;
    update();
    try {
      state.video = VideoPlayerController.networkUrl(Uri.parse(_realVideoUrl()));
      log('realVideoUrl: ${_realVideoUrl()}');
      await state.video?.initialize();

      final chewie = ChewieController(
        videoPlayerController: state.video!,
        aspectRatio: state.aspectRatio,
        autoInitialize: false,
        autoPlay: true,
        looping: false,
        allowPlaybackSpeedChanging: false,
        showOptions: false,
        customControls:
            const video_page.MaterialControls(showBackButton: false),
      );

      state.chewie = chewie;
      state.initializing = false;
      update();
    } catch (e, st) {
      log('inline video init error: $e\n$st');
      // 出错时把临时拿到的 controller 也清掉，避免残留资源。
      await state.video?.dispose();
      state.initializing = false;
      showToast(msg: '视频加载失败');
      update();
    }
  }

  String _realVideoUrl() {
    final String v = state.videoUrl;
    if (v.isEmpty) return '';
    return Address.buildH5VideoUrl(
      v,
      token: UserStore.to.getToken(),
      withCdn: false,
    );
  }

  @override
  void onClose() {
    state.chewie?.dispose();
    state.video?.dispose();
    state.video = null;
    state.chewie = null;
    super.onClose();
  }
}
