import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:comics_app/common/apis/bookShelf.dart';
import 'package:comics_app/common/entities/media_list_entity.dart';
import 'package:comics_app/common/entities/module_detail_model/all_media_info_model.dart';
import 'package:comics_app/common/utils/check_buy_permission.dart';
import 'package:comics_app/common/widgets/common_dialog/choose_audio_dialog.dart';
import 'package:comics_app/short_video/page_view/views/short_video_reward_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import 'package:flutter_pickers/pickers.dart';
import 'package:flutter_pickers/style/picker_style.dart';
import 'package:flutter_pickers/time_picker/model/date_mode.dart';
import 'package:comics_app/pages/bookshelf/reader/reader_wrap/reader_wrap_view.dart';
import 'package:flutter_pickers/time_picker/model/pduration.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';

import '../../../common/entities/media_info_entity.dart';
import '../../../common/http/base_resp_bean.dart';
import '../../../common/routers/app_routes.dart';
import '../../../common/store/user.dart';
import '../../../common/style/color.dart';
import '../../../common/utils/const.dart';
import '../../../common/utils/toast_util.dart';
import '../../../common/utils/utils.dart';
import '../../../common/values/address.dart';
import '../../../common/values/enum.dart';
import '../../../common/widgets/bottomSheetIntroduce.dart';
import '../../../common/widgets/common_dialog/speed_dialog.dart';
import 'novel_details_state.dart';
import 'package:path/path.dart' as path;

import 'package:comics_app/common/utils/logger.dart';

class NovelDetailsLogic extends GetxController {
  final NovelDetailsState state = NovelDetailsState();
  AudioPlayer? player;
  PlayerState playerState = PlayerState.STOPPED;
  final String PLAYID = "audioId";
  final String PLAYDURATIONID = "audioPosition";
  Duration? duration;
  Duration? position;
  var currentPosition = 0.obs;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _playerCompleteSubscription;
  StreamSubscription? _playerStateChangeSubscription;
  bool isReset = false;
  @override
  void onInit() {
    super.onInit();
    l.d('NovelDetailsLogic  oninit, ');
    UserStore.to.refreshRights();
    if (!isReset) {
      state.mediaKind = Get.arguments['type'] ?? MediaKind.mediaKindComics;
      // 'novelId' 是 circle/novel 等新调用方传入的 key，'id' 保留兼容老调用方。
      state.id = Get.arguments['novelId'] ?? Get.arguments['id'] ?? "";
      getCartoonHot();
      getMediaInfo();
      state.scrollController.addListener(() {
        if (state.scrollController.offset > 250.w) {
          state.isShowTitle.value = true;
        } else {
          state.isShowTitle.value = false;
        }
      });
    }
  }

  void resetAnother(String? id) {
    SmartDialog.showLoading();
    bool isShow = state.isShowTitle.value;
    if (id != null && id != state.id) {
      state.isShowTitle.value = !isShow;
      isReset = true;
      state.reset();
      state.id = id;
      getCartoonHot();
      getMediaInfo();
      stop();
    }
    SmartDialog.dismiss();
    state.isShowTitle.value = isShow;
  }

  @override
  void onClose() {
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();
    _playerCompleteSubscription?.cancel();
    _playerStateChangeSubscription?.cancel();
    player?.setReleaseMode(ReleaseMode.STOP);
    stop();
    player?.release();
    player?.dispose();
    player = null;
    state.scrollController.dispose();
    super.onClose();
  }

  Future<bool> checkPlayPermission(int index) async {
    bool isOk = await CheckPermissionUtils.checkBuyPermission(
        state.mediaInfoEntity!, index, (model) {
      state.mediaInfoEntity = model;
    });
    return isOk;
  }

  bool isInit = false;

  Future<void> setAudioData(int index, [bool isPlay = true]) async {
    var isOk = await checkPlayPermission(index);
    if (player == null) {
      await _initStreams();
    }
    if (!isOk) return;
    if (state.mediaInfoEntity?.contents.isNotEmpty != true) return;
    String? url = state.mediaInfoEntity?.contents[index].getRealAudioUrl;
    if (url?.isNotEmpty == true) {
      player?.setReleaseMode(ReleaseMode.STOP);
      var audioUrl = getPath(url);
      if (isPlay) {
        player?.play(audioUrl);
      } else {
        await player?.setUrl(audioUrl);
      }
      isInit = true;
    }
  }

  _initStreams() async {
    if (player != null) {
      await player?.release();
      await player?.dispose();
    }
    player = AudioPlayer();
    _durationSubscription = player?.onDurationChanged.listen((duration) {
      this.duration = duration;
      update([PLAYDURATIONID]);
      refresh();
    });

    _positionSubscription = player?.onAudioPositionChanged.listen((position) {
      this.position = position;
      update([PLAYDURATIONID]);
      refresh();
    });

    _playerCompleteSubscription = player?.onPlayerCompletion.listen((event) {
      if (state.isAllStop) {
        nextAudio();
      } else if (state.countdownTime == 0) {
        playerState = PlayerState.STOPPED;
        position = Duration.zero;
        update([PLAYID]);
      }
    });

    _playerStateChangeSubscription =
        player?.onPlayerStateChanged.listen((state) {
      playerState = state;
      update([PLAYID]);
    });
  }

  Future<void> seek(int? milliseconds) async {
    if (duration == null) return;
    int currentPosition = position?.inMilliseconds ?? 0;
    currentPosition += milliseconds ?? 3000;
    if (currentPosition <= 0) {
      currentPosition = 0;
    } else if (duration != null && currentPosition > duration!.inMilliseconds) {
      currentPosition = duration!.inMilliseconds;
    }
    await player?.seek(Duration(milliseconds: currentPosition));
    playerState = PlayerState.PLAYING;
  }

  Future<void> nextAudio() async {
    var list = state.mediaInfoEntity?.contents ?? [];
    if (list.length == 1) {
      showToast(msg: "只有一集");
      return;
    }
    if (state.index >= list.length - 1) {
      showToast(msg: "已经最后一集");
      return;
    }
    bool isOk = await checkPlayPermission(state.index + 1);
    if (isOk) {
      state.index += 1;
      setAudioData(state.index);
    }
  }

  Future<void> lastAudio() async {
    var list = state.mediaInfoEntity?.contents ?? [];
    if (list.length == 1) {
      showToast(msg: "只有一集");
      return;
    }
    if (state.index == 0) {
      showToast(msg: "已经是第一集");
      return;
    }
    bool isOk = await checkPlayPermission(state.index - 1);
    if (isOk) {
      state.index -= 1;
      setAudioData(state.index);
    }
  }

  Future<void> play() async {
    if (!isInit) {
      setAudioData(state.index);
      return;
    }
    await player?.resume();
    playerState = PlayerState.PLAYING;
    update([PLAYID]);
  }

  Future<void> pause() async {
    await player?.pause();
    playerState = PlayerState.PAUSED;
    update([PLAYID]);
  }

  Future<void> stop() async {
    await player?.stop();
    playerState = PlayerState.STOPPED;
    update([PLAYID]);
  }

  openChooseSpeed() async {
    await openSpeedDialog(state.rate, setPlaybackRate);
  }

  openClock() {
    Get.bottomSheet(ShortVideoRewardBottomSheet(
      onConfirm: (index) {
        state.countdownTime = index * 60;
        state.endTime = DateTime.now()
            .add(
              Duration(
                seconds: state.countdownTime,
              ),
            )
            .millisecondsSinceEpoch;
        update(["countdown"]);
        startTimer();
        Get.back();
      },
      rightTopWidget: GetBuilder<NovelDetailsLogic>(
        init: this,
        id: "countdown",
        builder: (_) {
          return CountdownTimer(
            endTime: state.endTime,
            widgetBuilder: (context, time) {
              final min = (time?.min ?? 0).toString().padLeft(2, '0');
              final sec = (time?.sec ?? 0).toString().padLeft(2, '0');
              state.countdownTime -= 1;
              return Text(
                '$min:$sec',
                style: TextStyle(
                  color: const Color(0xffB09FD9),
                  fontSize: 12.sp,
                  height: 1.05,
                  fontWeight: FontWeight.w900,
                  fontFamily: 'fonteditor',
                ),
              );
            },
          );
        },
      ),
      bottomWidget: GetBuilder<NovelDetailsLogic>(
        init: this,
        id: "stopAll",
        builder: (_) {
          return Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Checkbox(
                shape: const CircleBorder(),
                value: state.isAllStop,
                onChanged: (bool? value) {
                  state.isAllStop = value ?? false;
                  state.countdownTime = 0;
                  update(["stopAll", "countdown"]);
                },
              ),
              Text(
                "播完整部就停止",
                style: TextStyle(
                    color: Colors.black.withOpacity(0.3), fontSize: 14),
              )
            ],
          );
        },
      ),
      title: "定时关闭",
      openCustom: (context) {
        Get.back();
        Pickers.showDatePicker(
          context,
          mode: DateMode.MS,
          selectDate: PDuration(minute: 0, second: 0),
          onCancel: (isCancel) {},
          onConfirm: (data) {
            state.countdownTime =
                ((data.minute ?? 0) * 60) + (data.second ?? 0);
            state.endTime = DateTime.now()
                .add(
                  Duration(
                    seconds: state.countdownTime,
                  ),
                )
                .millisecondsSinceEpoch;
            update(["countdown"]);
            startTimer();
          },
          pickerStyle: PickerStyle(
            backgroundColor: AppColor.white,
            cancelButton: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                '取消',
                style: TextStyle(
                  color: AppColor.c999999,
                  fontSize: 15.sp,
                ),
              ),
            ),
            commitButton: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Text(
                '完成',
                style: TextStyle(
                  color: AppColor.c333333,
                  fontSize: 15.sp,
                ),
              ),
            ),
            menuHeight: 44.w,
            headDecoration: BoxDecoration(
              color: AppColor.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(8.r),
              ),
            ),
            textSize: 18.sp,
            textColor: AppColor.c333333,
          ),
        );
      },
    ));
  }

  setPlaybackRate(double playbackRate) async {
    state.rate = playbackRate;
    await player?.setPlaybackRate(playbackRate: playbackRate);
  }

  String getPath(url) {
    if (!url.startsWith("http") && !url.startsWith("https")) {
      url = path.join(Address.audioUrl ?? '', url);
    }
    return url;
  }

  //刷新续看上一话
  refreshOldEpisode() {
    const timeout = Duration(milliseconds: 100);
    Timer(timeout, () {
      var episode = HistoryOperation.getInstance()
          ?.queryDataByKindId(state.mediaInfoEntity?.kind ?? 0, state.id);
      if (episode != null) {
        state.index = episode;
      }
      update(['refreshOldEpisode', 'refreshInfo']);
    });
  }

  //打开目录
  void openNovelDirectory(MediaInfoEntity mediaInfoEntity) async {
    openDirectory();
  }

  Future<void> openDirectory() async {
    if (state.mediaInfoEntity == null) return;
    ;
    var index = await openChooseAudioItemDialog(
        info: state.mediaInfoEntity!, currentIndex: state.index);
    printInfo(info: "$index====>realIndex");
    bool isOk = await checkPlayPermission(index);
    if (!isOk) return;
    if (index != null && index is int) {
      clickItem(index);
    }
  }

  Future<void> clickItem(int index) async {
    bool isOk = await checkPlayPermission(index);
    if (!isOk) return;

    state.index = index;
    _jumpKind(index);
    update(["refreshInfo"]);
  }

  Future<void> _jumpKind(int index) async {
    state.index = index;
    switch (state.mediaInfoEntity?.kind) {
      case KindConst.COMMICKIND:
        await Get.toNamed(AppRoutes.COMIC_READER,
            arguments: {"data": state.mediaInfoEntity, "index": state.index});
        refreshOldEpisode();
        getMediaInfo();
        break;
      case KindConst.NOVELKIND:
        await Get.to(() => const ReaderWrapPage(),
            arguments: {"data": state.mediaInfoEntity, "index": state.index});
        refreshOldEpisode();
        getMediaInfo();
        break;
      case KindConst.AUDIOKIND:
        setAudioData(state.index);
        break;
    }
  }

  //打开全文
  void openFullText(MediaInfoEntity mediaInfoEntity) {
    bottomSheetIntroduce(mediaInfoEntity);
  }

  //获取详情
  void getMediaInfo() async {
    try {
      Map<String, dynamic> data = {"mediaID": state.id};
      BaseRespBean baseRespBean = await BookApi.getMediaInfo(data);
      if (baseRespBean.isSuccess) {
        AllMediaInfoModel mediaInfoEntity =
            AllMediaInfoModel.fromJson(baseRespBean.data);
        state.mediaInfoEntity = mediaInfoEntity;
        update(["refreshInfo"]);
        refreshOldEpisode();
        if (mediaInfoEntity.kind == KindConst.AUDIOKIND) {
          HistoryOperation.getInstance()
              ?.addAllMedia(info: state.mediaInfoEntity, episode: 0);
          await _initStreams();
          setAudioData(state.index, false);
        }
      }
    } finally {
      state.isLoading.value = false;
    }
  }

  //获取同类作品
  void getCartoonHot() async {
    try {
      Map<String, dynamic> data = {
        "kind": state.mediaKind.index,
        "page": 1,
        "pageSize": 6,
      };
      BaseRespBean baseRespBean = await BookApi.getCartoonRandom(data);
      if (baseRespBean.isSuccess) {
        MediaListEntity mediaListEntity =
            MediaListEntity.fromJson(baseRespBean.data);
        state.mediaList.addAll(mediaListEntity.mediaList ?? []);
        update(['recommended']);
      }
    } finally {}
  }

  //收藏-取消收藏
  cartoonCollcet() async {
    try {
      Map<String, dynamic> data = {
        "kind": 4,
        "mediaID": state.mediaInfoEntity?.id
      };
      if (state.mediaInfoEntity?.mediaStatus?.hasCollected ?? false) {
        BaseRespBean baseRespBean = await BookApi.cartoonUncollect(data);
        if (baseRespBean.isSuccess) {
          showToast(msg: "取消收藏");
          state.mediaInfoEntity?.mediaStatus?.hasCollected = false;
          update(["collect"]);
          return;
        }
        showToast(msg: baseRespBean.tip ?? "收藏失败");
      } else {
        BaseRespBean baseRespBean = await BookApi.cartoonCollcet(data);
        if (baseRespBean.isSuccess) {
          showToast(msg: "收藏成功");
          state.mediaInfoEntity?.mediaStatus?.hasCollected = true;
          update(["collect"]);
          return;
        }
        showToast(msg: baseRespBean.tip ?? "收藏失败");
      }
    } catch (e) {
      showToast(msg: "收藏失败");
    }
  }

  //收藏-取消收藏
  cartoonLike() async {
    try {
      Map<String, dynamic> data = {
        "kind": state.mediaKind.index,
        "mediaID": state.mediaInfoEntity?.id
      };
      if (state.mediaInfoEntity?.mediaStatus?.hasLiked ?? false) {
        BaseRespBean baseRespBean = await BookApi.cancelCartoonLike(data);
        if (baseRespBean.isSuccess) {
          showToast(msg: "取消点赞");
          state.mediaInfoEntity?.mediaStatus?.hasLiked = false;
          return;
        }
        showToast(msg: baseRespBean.tip ?? "点赞失败");
      } else {
        BaseRespBean baseRespBean = await BookApi.cartoonLike(data);
        if (baseRespBean.isSuccess) {
          showToast(msg: "点赞成功");
          state.mediaInfoEntity?.mediaStatus?.hasLiked = true;
          return;
        }
        showToast(msg: baseRespBean.tip ?? "点赞失败");
      }
    } catch (e) {
      showToast(msg: "点赞失败");
    }
  }

  String get durationText => duration?.toString().split('.').first ?? '';

  ///开启定时器
  startTimer() {
    state.timer?.cancel();
    state.timer = null;
    state.timer = Timer(Duration(seconds: state.countdownTime), () {
      state.countdownTime = 0;
      state.timer?.cancel();
      state.timer = null;
      pause();
    });
  }

}
