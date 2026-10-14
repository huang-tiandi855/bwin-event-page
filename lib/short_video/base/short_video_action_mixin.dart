part of short_video_play_logic_impl;

mixin ShortVideoActionMixin<T extends ShortVideoModel>
    on AbsShortVideoAction<T> {
  // 通用的请求处理函数
  Future<void> _handleRequest(
      Future<void> Function() request, bool isRequestFlag) async {
    if (isRequestFlag) return;
    isRequestFlag = true;
    try {
      await request();
    } finally {
      isRequestFlag = false;
    }
  }

  @override
  void onTapComment(T videoInfo) {
    openBottomSheetComment(
      videoInfo.id!,
      commentType: CommentType.video,
      totalCount: videoInfo.commentCount,
      commentSuccessFun: () {
        videoInfo.commentCount += 1;
        update(['comment_${videoInfo.id}']);
      },
    ).then((value) {});
  }

  @override
  void onTapFollow(T videoInfo) async {
    final int? star = videoInfo.authorUid;
    if (star == null || star <= 0) {
      showToast(msg: '用户信息错误');
      return;
    }
    await _handleRequest(
      () async {
        final bool hasFollowed = videoInfo.hasFollowed;
        final resp = hasFollowed
            ? await MediaApi.onCancleFocus(star)
            : await MediaApi.onFocus(star);
        if (resp.isSuccess) {
          videoInfo.hasFollowed = !hasFollowed;
          showToast(msg: hasFollowed ? '取消关注' : '关注成功');
          update(['follow_${videoInfo.id}']);
          return;
        }
        showToast(msg: resp.tip ?? (hasFollowed ? '取消关注失败' : '关注失败'));
      },
      state.isRequestFollow,
    );
  }

  @override
  void onTapLike(T videoInfo) async {
    final id = videoInfo.id;
    if (id == null || id.isEmpty) {
      showToast(msg: '视频信息错误');
      return;
    }
    await _handleRequest(
      () async {
        final hasLiked = videoInfo.hasLiked;
        final isSuccess = await UserApi.likeVideo(id, hasLiked ? 0 : 1);
        if (!isSuccess) return;

        videoInfo.hasLiked = !hasLiked;
        videoInfo.likeCount = hasLiked
            ? (videoInfo.likeCount > 0 ? videoInfo.likeCount - 1 : 0)
            : videoInfo.likeCount + 1;
        update(['like_${videoInfo.id}']);
      },
      state.isRequestLike,
    );
  }

  @override
  void onTapCollect(T videoInfo) async {
    final id = videoInfo.id;
    if (id == null || id.isEmpty) {
      showToast(msg: '视频信息错误');
      return;
    }
    await _handleRequest(
      () async {
        final hasCollected = videoInfo.hasCollected;
        final isSuccess = await UserApi.collectVideo(id, hasCollected ? 0 : 1);
        if (!isSuccess) return;

        videoInfo.hasCollected = !hasCollected;
        videoInfo.collectCount = hasCollected
            ? (videoInfo.collectCount > 0 ? videoInfo.collectCount - 1 : 0)
            : videoInfo.collectCount + 1;
        update(['collect_${videoInfo.id}']);
      },
      state.isRequestCollect,
    );
  }

  @override
  void onTapShare(T videoInfo) {
    ShareVideoView.show(
      Get.overlayContext!,
      videoInfo.cover,
      shareType: ShareType.short,
    );
  }

  @override
  void onTapTag(TagsModel tag) async {
    // 走 [TopicMoreDetailRoute.push]：每次点击话题都拿到独立 logic 实例。
    // 短视频流可能是从 [TopicMoreDetailPage] 进入的，栈上叠多份
    // TopicMoreDetail 时 state 不互相覆盖。
    Future<dynamic> navigateToTopicMoreDetail() {
      return TopicMoreDetailRoute.push(
        topicName: tag.name ?? '',
        keywordType: 1,
        videoType: 1,
      );
    }

    final player = state.videoListController.playerOfIndex(state.currentIndex);
    if (player == null || !player.hasController) {
      await navigateToTopicMoreDetail();
      return;
    }

    final wasPlaying = player.controller.value.isPlaying;
    await player.pause();
    await navigateToTopicMoreDetail();

    if (wasPlaying && player.hasController) {
      await player.play();
    }
  }

  @override
  void onTapReward(T videoInfo) {
    Get.bottomSheet(ShortVideoRewardBottomSheet(
      onConfirm: (p0) {
        Get.back();
        // LoadingAlertWidget.show(
        //   Get.context!,
        //   canCancel: true,
        // );
        SmartDialog.showLoading();
        VidApi.reward(
          id: videoInfo.id!,
          coins: p0,
        ).then((value) {
          if (value.isSuccess) {
            showToast(msg: '打赏成功');
          } else {
            if (value.code == 8000) {
              showNeedChargeCoinDialog();
            } else {
              showToast(msg: value.tip ?? '打赏失败');
            }
          }
        }).catchError((err) {
          showToast(msg: '打赏失败');
        }).whenComplete(() {
          SmartDialog.dismiss();
          // LoadingAlertWidget.cancel(Get.context!);
          // Get.back();
        });
      },
    ));
  }

  @override
  void navigateToPublisher(T videoInfo) {
    state.videoListController
        .playerOfIndex(state.currentIndex)
        ?.controller
        .pause();
    final int? uid = videoInfo.authorUid;
    if (uid == null || uid <= 0) {
      showToast(msg: '用户信息错误');
      return;
    }
    Get.toNamed(
      AppRoutes.USER_CENTER,
      arguments: <String, dynamic>{
        'uid': uid,
        'author': <String, dynamic>{
          'id': uid,
          'avatar': videoInfo.authorAvatar,
          'nickName': videoInfo.authorName,
          'follow': videoInfo.hasFollowed,
          'fansNum': videoInfo.authorFansNum,
          'vnum': videoInfo.authorWorksNum,
          'pnum': videoInfo.authorPostNum,
        },
      },
    )?.then((dynamic result) {
      if (result is! Map) return;
      final m = Map<String, dynamic>.from(result);
      final dynamic raw = m['isFollow'];
      final bool? next = raw is bool
          ? raw
          : (raw is num
              ? raw != 0
              : (raw is String ? (raw == 'true' || raw == '1') : null));
      if (next != null && next != videoInfo.hasFollowed) {
        videoInfo.hasFollowed = next;
        update(['follow_${videoInfo.id}']);
      }
    });
  }

  @override
  void onTapVisible() {
    state.visible = !state.visible;
    update(['visible']);
  }
}
