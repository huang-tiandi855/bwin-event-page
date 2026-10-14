import 'package:comics_app/common/utils/system_ui_util.dart';
import 'package:comics_app/common/entities/module_detail_model/content_model.dart';
import 'package:comics_app/common/entities/module_detail_model/content_model_extension.dart';
import 'package:comics_app/common/utils/toast_util.dart';
import 'package:comics_app/common/values/enum.dart';
import 'package:comics_app/common/widgets/memberPaying.dart';
import 'package:comics_app/pages/bookshelf/comic_reading/widget/drawer.dart';
import 'package:comics_app/pages/bookshelf/novel_details/novel_details_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../common/apis/bookShelf.dart';
import '../../../common/entities/module_detail_model/all_media_info_model.dart';
import '../../../common/http/base_resp_bean.dart';
import '../../../common/store/user.dart';
import '../../../common/utils/utils.dart';
import '../../../common/widgets/new_gold_paying.dart';
import '../novel_details/novel_details_logic.dart';
import 'comic_reading_state.dart';

enum UpdateType {
  pre, //上一话
  next, //下一话
  customize //自定义跳转
}

class ComicReadingLogic extends GetxController {
  final ComicReadingState state = ComicReadingState();
  final NovelDetailsState parentState = Get.find<NovelDetailsLogic>().state;
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    state.mediaInfoEntity = Get.arguments['data'];
    if (state.mediaInfoEntity?.contents.isNotEmpty ?? false) {
      state.mediaInfoEntity?.contents =
          state.mediaInfoEntity?.contents.where((element) => (element.isActive ?? false)).toList() ?? [];
    }
    state.index = Get.arguments['index'] ?? 0;
    parentState.hasRead.addIf(!parentState.hasRead.contains(state.index), state.index);
    updateChapters();
  }

  bool isOpenSpeed = false;
  int currentSpeedIndex = -1;
  final updateSpeedId = "updateSpeedId";
  void openAutoSpeed() {
    isOpenSpeed = !isOpenSpeed;
    update([updateSpeedId]);
  }

  void closeStopAutoSpeed() {
    isOpenSpeed = false;
    update([updateSpeedId]);
  }

  void selectSpeed(int index) {
    if (!isAutoPlay || index != currentSpeedIndex) {
      isAutoPlay = true;
      currentSpeedIndex = index;
    } else if (index == currentSpeedIndex) {
      isAutoPlay = false;
      currentSpeedIndex = -1;
    }
    isOpenSpeed = false;
    update([updateSpeedId]);
    _autoPlay();
  }

  @override
  void onClose() {
    HistoryOperation.getInstance()?.addAllMedia(info: state.mediaInfoEntity, episode: state.index);
    restoreDefaultSystemUi();
    // TODO: implement onClose
    super.onClose();
  }

  //更新漫画
  void updateChapters() {
    if (state.mediaInfoEntity?.contents.isNotEmpty ?? false) {
      state.mediaInfoContents = state.mediaInfoEntity?.contents[state.index];
    }
  }

  //更新漫画集数
  void updateIndex(UpdateType type, {int index = 0}) async {
    if (isAutoPlay) {
      isAutoPlay = false;
      _autoPlay();
    }
    //上一话
    if (type == UpdateType.pre) {
      if (state.index <= 0) {
        showToast(msg: "已经是第一话");
        return;
      }
      bool isOk = await checkPlayPermission(UpdateType.pre);
      if (!isOk) return;
      state.index--;
      parentState.hasRead.addIf(!parentState.hasRead.contains(state.index), state.index);
      updateChapters();
      state.scrollController.jumpTo(0);
      update(['list', "menu"]);
      return;
    }
    //下一话
    if (type == UpdateType.next) {
      var curIndex = state.mediaInfoEntity?.contents.length ?? 1;
      if (state.index >= curIndex - 1) {
        showToast(msg: "已经是最后一话");
        return;
      }
      bool isOk = await checkPlayPermission(UpdateType.next);
      if (!isOk) return;
      state.index++;
      parentState.hasRead.addIf(!parentState.hasRead.contains(state.index), state.index);
      updateChapters();
      state.scrollController.jumpTo(0);
      update(['list', "menu"]);

      return;
    }
    //自定义
    if (type == UpdateType.customize) {
      bool isOk = await checkPlayPermission(type, curIndex: index);
      if (!isOk) return;
      if (index > (state.mediaInfoEntity?.contents.length ?? 0) || index < 0) {
        showToast(msg: "章节错误");
        return;
      }
      state.index = index;
      parentState.hasRead.addIf(!parentState.hasRead.contains(state.index), state.index);
      updateChapters();
      update(['list', "menu"]);
      return;
    }
  }

  var lastOffset = 0.0;
  bool isAutoPlay = false;
  void _autoPlay() {
    if (!isAutoPlay) {
      stop();
    } else {
      playAnimal();
    }
  }

  void playAnimal() {
    lastOffset = state.scrollController.offset;
    state.scrollController.removeListener(listener);
    state.scrollController.addListener(listener);
    state.scrollController.animateTo(1.sh + lastOffset,
        duration: Duration(seconds: 10 ~/ (0.5 * (currentSpeedIndex + 1))), curve: Curves.linear);
  }

  void stop() {
    isOpenSpeed = false;
    state.isAutoPlayShow = false;
    isAutoPlay = false;
    state.scrollController.removeListener(listener);
    lastOffset = state.scrollController.offset;
    state.scrollController.animateTo(lastOffset, duration: const Duration(seconds: 50), curve: Curves.linear);
  }

  void listener() {
    printInfo(info: "${state.scrollController.offset}===>${state.scrollController.position.maxScrollExtent}");
    if (state.scrollController.offset >= state.scrollController.position.maxScrollExtent - 50) {
      stop();
      state.isMenuVisiable.value = false;
      update(["menu"]);
    } else {
      lastOffset = state.scrollController.offset;
      state.scrollController.animateTo(1.sh + lastOffset,
          duration: Duration(seconds: 10 ~/ (0.5 * (currentSpeedIndex + 1))), curve: Curves.linear);
    }
  }

  //获取详情
  void getMediaInfo() async {
    try {
      Map<String, dynamic> data = {"mediaID": state.mediaInfoEntity?.id ?? ""};
      BaseRespBean baseRespBean = await BookApi.getMediaInfo(data);
      if (baseRespBean.isSuccess) {
        AllMediaInfoModel mediaInfoEntity = AllMediaInfoModel.fromJson(baseRespBean.data);
        state.mediaInfoEntity = mediaInfoEntity;
        update(["list", "menu"]);
      }
    } finally {}
  }

  //检查是否有播放权限
  Future<bool> checkPlayPermission(UpdateType type, {int? curIndex}) async {
    bool isVip = UserStore.to.isVip();
    int listenPermission = -1;

    ContentModel? mediaInfoContents;
    if (type == UpdateType.next) {
      mediaInfoContents = state.mediaInfoEntity?.contents[state.index + 1];
      listenPermission = mediaInfoContents?.listenPermission ?? -1;
      curIndex = state.index + 1;
    } else if (type == UpdateType.pre) {
      mediaInfoContents = state.mediaInfoEntity?.contents[state.index - 1];
      listenPermission = mediaInfoContents?.listenPermission ?? -1;
      curIndex = state.index - 1;
    } else if (type == UpdateType.customize) {
      mediaInfoContents = state.mediaInfoEntity?.contents[curIndex ?? 0];
      listenPermission = mediaInfoContents?.listenPermission ?? -1;
    }
    if (listenPermission == -1) {
      showToast(msg: "数据有误");
      return false;
    }

    printInfo(info: "$curIndex ===>${mediaInfoContents?.hasPaid}");

    if (mediaInfoContents?.needPermission == 2) {
      return true;
    }

    //未购买全本
    switch (listenPermission) {
      //会员
      case 0:
        if (isVip) {
          return true;
        }
        var isOk = await openMemberPaying(
            id: state.mediaInfoEntity?.id ?? "",
            productType: 28,
            title: mediaInfoContents?.name,
            chatId: mediaInfoContents?.id ?? "");
        if (isOk == PaySuccess.exchangeSuccessFullly) {
          state.mediaInfoEntity?.contents[curIndex ?? 0].mediaStatus?.hasPaid = true;
          update(['list', "menu"]);
          return true;
        }
        return false;
      //金币购买
      case 1:
        //已购买全本
        if (state.mediaInfoEntity?.mediaStatus?.hasPaid ?? false) {
          return true;
        }
        if (mediaInfoContents?.mediaStatus?.hasPaid ?? false) {
          return true;
        }
        var isOk = await openNewGoldBeanPaying(
          isShowCoupon: true,
          productType: 28,
          info: state.mediaInfoEntity!,
          currentIndex: curIndex ?? 0,
        );
        if (isOk == PaySuccess.successfulAllEsp) {
          state.mediaInfoEntity?.mediaStatus?.hasPaid = true;
          update(['list', "menu"]);
          getMediaInfo();
          return true;
        }
        //购买成功
        if (isOk == PaySuccess.successfulPurchase) {
          state.mediaInfoEntity?.contents[curIndex ?? 0].mediaStatus?.hasPaid = true;
          update(['list', "menu"]);
          return true;
        }
        //兑换成功
        if (isOk == PaySuccess.exchangeSuccessFullly) {
          state.mediaInfoEntity?.contents[curIndex ?? 0].mediaStatus?.hasPaid = true;
          update(['list', "menu"]);
          return true;
        }
        return false;
      //免费
      case 2:
        return true;
      default:
        return false;
    }
  }

  void hideMenu() {
    state.isMenuVisiable.value = false;
  }

  void onTap() {
    state.isMenuVisiable.value = true;
    if (isAutoPlay) {
      playAnimal();
    }
  }

  void scaleUpdate(value) {
    var offset = state.scrollController.offset;
    state.scaleValue = value;
    update(["scale"]);
    state.scrollController.jumpTo(offset);
  }

  setDirectoryReverseOrder() {
    state.directoryReverseOrder = !state.directoryReverseOrder;
    update(["menu"]);
  }

  //打开目录
  void openDrawer() {
    openComicMenu(
        hasRead: parentState.hasRead,
        updateIndex: updateIndex,
        hideMenu: hideMenu,
        chaptersNumber: state.index,
        mediaInfoEntity: state.mediaInfoEntity,
        setDirectoryReverseOrder: setDirectoryReverseOrder);
  }

  //收藏-取消收藏
  cartoonCollcet() async {
    try {
      Map<String, dynamic> data = {"kind": 1, "mediaID": state.mediaInfoEntity?.id ?? ""};
      final novelDetailsLogic = Get.find<NovelDetailsLogic>();
      if (state.mediaInfoEntity?.mediaStatus?.hasCollected ?? false) {
        BaseRespBean baseRespBean = await BookApi.cartoonUncollect(data);
        if (baseRespBean.isSuccess) {
          showToast(msg: "取消收藏");
          state.mediaInfoEntity?.mediaStatus?.hasCollected = false;
          update(["menu"]);
          novelDetailsLogic.update(['collcet']);
          return;
        }
        showToast(msg: baseRespBean.tip ?? "收藏失败");
      } else {
        BaseRespBean baseRespBean = await BookApi.cartoonCollcet(data);
        if (baseRespBean.isSuccess) {
          showToast(msg: "收藏成功");
          state.mediaInfoEntity?.mediaStatus?.hasCollected = true;
          update(["menu"]);
          novelDetailsLogic.update(['collcet']);
          return;
        }
        showToast(msg: baseRespBean.tip ?? "收藏失败");
      }
    } catch (e) {
      showToast(msg: "收藏失败");
    }
  }
}
