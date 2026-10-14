import 'dart:async';

import 'package:comics_app/common/apis/media_api.dart';
import 'package:comics_app/common/apis/user.dart';
import 'package:comics_app/common/entities/module_detail_model/all_media_info_model.dart';
import 'package:comics_app/common/entities/module_detail_model/content_model.dart';
import 'package:comics_app/common/widgets/bottom_sheet_comment.dart';
import 'package:comics_app/common/widgets/comment/comment_view.dart';
import 'package:flutter/material.dart';
// class ShortVideoChangeModel {
//   final List<CartoonMediaInfo> infos;
//   // 0从短剧首页 1从详情页
//   final int entry;
//   ShortVideoChangeModel(this.infos, {required this.entry});

// }

// class ShortVideoChangeUtil {
//   final StreamController<CartoonMediaInfo> _streamController = StreamController();
// }

import 'package:get/get.dart';

class ShortMediaPlayController extends GetxController {
  final pageCtr = PageController();
  final List<AllMediaInfoModel> infos = [];
  int selectIndex = 0;
  // 1 是ACG剧场 2 是从详情进入
  int entry = 2;
  late PageController playerPageController;
  AllMediaInfoModel? currentMedia;
  StreamController<AllMediaInfoModel?> currentMediaInfo = StreamController.broadcast();
  bool visible = false;

  bool isLoading = true;

  @override
  void onInit() {
    super.onInit();
    final arguments = Get.arguments;

    if (arguments != null) {
      entry = arguments['entry'] ?? 2;
      infos.addAll(arguments['info'] ?? []);
      selectIndex = arguments['selectIndex'] ?? 0;
      playerPageController = PageController(initialPage: selectIndex);

      loadInfo();
    }
  }

  @override
  void dispose() {
    pageCtr.dispose();
    playerPageController.dispose();
    currentMediaInfo.close();
    super.dispose();
  }

  Future<void> loadInfo() async {
    if (entry == 1) {
      getPlayerData(0);
      await updateMediaData();
      isLoading = false;
    } else {
      isLoading = false;
    }

    update();
  }

  updateMediaData() async {
    final resp = await MediaApi.getMediaInfo(currentMedia?.id ?? '');
    if (resp.isSuccess) {
      final result = AllMediaInfoModel.fromJson(resp.data);
      final index = infos.indexOf(currentMedia!);
      if (index != -1) {
        infos.remove(currentMedia!);
        infos.insert(index, result);
      }
      update();
    }
  }

  Future<void> collectMedia() async {
    final id = currentMedia?.id ?? '';
    if (id.isEmpty) return;

    final collected = currentMedia?.mediaStatus?.hasCollected ?? false;
    final isSuccess = await UserApi.collectVideo(id, collected ? 0 : 1);
    if (!isSuccess) return;

    currentMedia?.mediaStatus?.hasCollected = !collected;
    update();
  }

  Future<void> likeOrDislikeMedia() async {
    final id = currentMedia?.id ?? '';
    if (id.isEmpty) return;

    final liked = currentMedia?.mediaStatus?.hasLiked ?? false;
    final isSuccess = await UserApi.likeVideo(id, liked ? 0 : 1);
    if (!isSuccess) return;

    currentMedia?.mediaStatus?.hasLiked = !liked;
    final count = currentMedia?.countLike ?? 0;
    currentMedia?.countLike =
        liked ? (count > 0 ? count - 1 : 0) : count + 1;
    update();
  }

  void onTapVisible() {
    visible = !visible;
    update();
  }

  void onTapComment() {
    openBottomSheetComment(
      currentMedia?.id ?? '',
      commentType: CommentType.media,
    ).then((value) {});
  }

  // 获取当前的
  ContentModel? getPlayerData(int index) {
    currentMedia = infos.first;
    final content = (currentMedia?.contents.length ?? 0) > index ? currentMedia?.contents[index] : null;
    currentMediaInfo.add(currentMedia);
    return content;
  }

  // 计算视频的总个数
  int caculateTotalCount() {
    int count = 0;
    if (infos.isEmpty) return count;
    count = infos.first.contents.length;
    return count;
  }

  // 选集
  choseEpisode(AllMediaInfoModel info, int index) {
    playerPageController.jumpToPage(index);
    infos.clear();
    infos.addAll([info]);
    selectIndex = index;
    update();
    playerPageController.jumpToPage(index);
  }
}
