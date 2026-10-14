import 'dart:async';

import 'package:comics_app/common/apis/acg_api.dart';
import 'package:comics_app/common/entities/media_info_entity.dart';
import 'package:comics_app/common/utils/screen.dart';
import 'package:comics_app/pages/bookshelf/reader/widget/reader_bg.dart';
import 'package:comics_app/pages/bookshelf/reader/widget/reader_config.dart';
import 'package:comics_app/pages/bookshelf/reader/widget/reader_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../common/apis/bookShelf.dart';
import '../../../common/entities/readerChapterModel.dart';
import '../../../common/http/base_resp_bean.dart';
import '../../../common/store/user.dart';
import '../../../common/utils/logger.dart';
import '../../../common/utils/toast_util.dart';
import '../../../common/utils/utils.dart';
import '../../../common/widgets/memberPaying.dart';
import '../novel_details/novel_details_logic.dart';
import 'reader_state.dart';
import 'widget/reader_page_agent.dart';

enum PageJumpType { stay, firstPage, lastPage }

class ReaderLogic extends GetxController {
  final ReaderState state = ReaderState();

  @override
  Future<void> onInit() async {
    // TODO: implement onReady
    super.onInit();
    state.mediaInfoEntity = Get.arguments['data'];
    state.curChapterNum = Get.arguments['index'] ?? 0;
    fillNovel();
  }

  Future<void> fillNovel() async {
    for (var v in state.mediaInfoEntity.contents) {
      if (v.isActive ?? false) {
        await getData(v.id);
      }
    }
    init();
    checkPlayPermission();
  }

  Future<void> getData(String? id) async {
    await ACGApi.getNovalContent(id ?? "")
        .then((value) => ReaderChapterModel.fromJson(MediaInfoContents.fromJson(value.data)))
        .then((value) => state.readerList.add(value));
  }

  @override
  void onClose() async {
    // TODO: implement onClose
    HistoryOperation.getInstance()?.addAllMedia(info: state.mediaInfoEntity, episode: state.curChapterNum);
    const timeout = Duration(milliseconds: 666);
    Timer(timeout, () {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    });
    super.onClose();
  }

  void onTap(Offset position) async {
    double xRate = position.dx / Screen.width;
    if (xRate > 0.33 && xRate < 0.66) {
      state.isMenuVisiable.value = true;
    } else if (xRate >= 0.66) {
      l.d("${state.isPlay}");
      if (!state.isPlay) {
        openMemberPaying(
            id: state.mediaInfoEntity.id??"",
            title: state.readerList[state.curChapterNum].name,
            chatId: state.readerList[state.curChapterNum].id,
            isShowCoupon: false);
      } else {
        nextPage();
      }
    } else {
      if (!state.isPlay) {
        openMemberPaying(
            id: state.mediaInfoEntity.id??"",
            title: state.readerList[state.curChapterNum].name,
            chatId: state.readerList[state.curChapterNum].id,
            isShowCoupon: false);
      } else {
        previousPage();
      }
    }
  }

  //检查是否有播放权限
  Future<bool> checkPlayPermission({int? curChapterNum}) async {
    bool isVip = UserStore.to.isVip();
    int curNum = state.curChapterNum;
    if (curChapterNum != null) {
      curNum = curChapterNum;
    }
    int listenPermission = state.readerList[curNum].listenPermission;

    //已购买全本
    if (state.mediaInfoEntity.mediaStatus?.hasPaid ?? false) {
      state.isPlay = true;
      update(['buildPageView']);
      return true;
    }
    //未购买全本
    switch (listenPermission) {
      //会员
      case 0:
        l.d("$isVip");
        if (isVip) {
          if (!state.isPlay) {
            state.isPlay = true;
            update(['buildPageView']);
          }
          return true;
        }
       await openMemberPaying(
            id: state.readerList[state.curChapterNum].id,
            title: state.readerList[state.curChapterNum].name,
            isShowCoupon: false);
        state.isMenuVisiable.value = true;
        state.isPlay = isVip;
        update(['buildPageView']);
        return false;
      //金币购买
      case 1:
        state.isPlay = true;
        return true;
      //免费
      case 2:
        state.isPlay = true;
        update(['buildPageView']);
        return true;
      default:
        return false;
    }
  }

  void previousPage() {
    if (state.pageIndex == 0 && state.curChapterNum == 1) {
      showToast(msg: "已经到第一页了");
      return;
    }
    state.pageController.previousPage(duration: const Duration(milliseconds: 333), curve: Curves.easeOut);
  }

  void nextPage() {
    if (state.pageIndex >= state.currentArticle!.pageCount - 1 && state.curChapterNum == state.chapterTotal) {
      showToast(msg: "已经到最后一页了");
      return;
    }
    state.pageController.nextPage(duration: const Duration(milliseconds: 333), curve: Curves.easeOut);
  }

  void hideMenu() {
    state.isMenuVisiable.value = false;
  }

  //打开目录
  void openDrawer() {
    state.scaffoldKey.currentState?.openEndDrawer();
  }

  void init() async {
    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    // 如果topSafeHeight 是错的，那么就打开延迟（打开延迟屏幕还闪屏一下）
    // await Future.delayed(const Duration(milliseconds: 100), () {});
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    state.topSafeHeight = Screen.topSafeHeight;
    state.bottomSafeHeight = Screen.bottomSafeHeight;
    resetContent(state.curChapterNum, PageJumpType.stay);
  }

  //初始化小说数据
  void resetContent(int curChapterNum, PageJumpType jumpType) {
    int length = state.chapterTotal = state.readerList.length;
    if (curChapterNum > length) return;
    state.currentArticle = formatArticle(curChapterNum);

    if (curChapterNum > 1) {
      state.preArticle = formatArticle(curChapterNum - 1);
    } else {
      state.preArticle = null;
    }

    if (curChapterNum < length) {
      state.nextArticle = formatArticle(curChapterNum + 1);
    } else {
      state.nextArticle = null;
    }

    if (jumpType == PageJumpType.firstPage) {
      state.pageIndex = 0;
    }
    if (jumpType == PageJumpType.lastPage) {
      state.pageIndex = state.currentArticle!.pageCount - 1;
    }
    if (jumpType != PageJumpType.stay) {
      state.pageController.jumpToPage((state.preArticle != null ? state.preArticle!.pageCount : 0) + state.pageIndex);
    }
    if (state.curChapterNum > 1) {
      state.pageController = PageController(keepPage: false, initialPage: ((state.preArticle?.pageCount ?? 0)));
    } else {
      state.pageController = PageController(keepPage: false);
    }
    state.pageController.addListener(onScroll);
    update(['buildPageView']);
  }

  // 格式化文章
  ReaderChapterModel formatArticle(int curChapterNum) {
    if (curChapterNum < 1) {
      curChapterNum = 1;
    }
    ReaderChapterModel readerChapterModel = state.readerList[curChapterNum];
    var contentHeight = Screen.height -
        state.topSafeHeight -
        ReaderUtils.topOffset -
        state.bottomSafeHeight -
        ReaderUtils.bottomOffset -
        ReaderConfig.instance.fontSize;
    if (kIsWeb) {
      contentHeight = contentHeight - 120.h;
    }
    var contentWidth = Screen.width - 15.w - 15.w;
    readerChapterModel.pageOffsets = ReaderPageAgent.getPageOffsets(
        readerChapterModel.text, contentHeight, contentWidth, ReaderConfig.instance.fontSize);
    return readerChapterModel;
  }

  void onScroll() {
    double page = state.pageController.page ?? 0;
    int nextArtilePage = state.currentArticle!.pageCount + (state.preArticle != null ? state.preArticle!.pageCount : 0);
    if (page >= nextArtilePage) {
      l.d('到达下个章节');
      state.curChapterNum++;
      state.preArticle = state.currentArticle;
      state.currentArticle = state.nextArticle;
      state.nextArticle = null;
      state.pageIndex = 0;
      state.pageController.jumpToPage(state.preArticle!.pageCount);
      getNextArticle();
      update(['buildPageView']);
    }

    if (state.preArticle != null && page <= state.preArticle!.pageCount - 1) {
      l.d('到达上一章');
      state.curChapterNum--;
      state.nextArticle = state.currentArticle;
      state.currentArticle = state.preArticle;
      state.preArticle = null;
      state.pageIndex = state.currentArticle!.pageCount - 1;
      state.pageController.jumpToPage(state.currentArticle!.pageCount - 1);
      getPreviousArticle();
      update(['buildPageView']);
    }
  }

  void getNextArticle() {
    if (state.nextArticle != null || state.curChapterNum >= state.chapterTotal) {
      return;
    }
    state.nextArticle = formatArticle(state.curChapterNum + 1);
  }

  void getPreviousArticle() {
    if (state.preArticle != null || (state.curChapterNum <= 1)) {
      return;
    }
    state.preArticle = formatArticle(state.curChapterNum - 1);
    state.pageController.jumpToPage(state.preArticle!.pageCount + state.pageIndex);
  }

  void onPageChanged(int index) {
    int page = index - (state.preArticle != null ? state.preArticle!.pageCount : 0);
    if (page < state.currentArticle!.pageCount && page >= 0) {
      state.pageIndex = page;
    }
    checkPlayPermission();
  }

  onPreviousArticle() {
    if (state.curChapterNum <= 1) return;
    state.curChapterNum--;
    resetContent(state.curChapterNum, PageJumpType.firstPage);
    update(["menu"]);
  }

  onNextArticle() {
    if (state.curChapterNum >= state.chapterTotal) return;
    state.curChapterNum++;
    resetContent(state.curChapterNum, PageJumpType.firstPage);
    update(["menu"]);
  }

  onToggleChapter(int index) async {
    bool isOk = await checkPlayPermission(curChapterNum: index);
    if (!isOk) {
      Get.back();
      showToast(msg: "当前章节没有购买");
      return;
    }
    resetContent(index + 1, PageJumpType.firstPage);
    state.curChapterNum = index + 1;
    update(["menu"]);
  }

  setDirectoryReverseOrder() {
    state.directoryReverseOrder = !state.directoryReverseOrder;
    update(["menu"]);
  }

  updateNightDay() {
    if (state.bgType == BgType.greenBg) {
      state.bgType = ThemeDarkNight.instance.bgType;
      state.textStyle = ThemeDarkNight.instance.textStyle;
      state.bottomOverlayerColor = ThemeDarkNight.instance.bottomOverlayerColor;
      state.menuColor = ThemeDarkNight.instance.menuColor;
      state.menuBg = ThemeDarkNight.instance.menuBg;

      state.drawerBg = ThemeDarkNight.instance.drawerBg;
      state.drawerColorSeTitle = ThemeDarkNight.instance.drawerColorSeTitle;
      state.drawerColor = ThemeDarkNight.instance.drawerColor;
      state.drawerActiveColor = ThemeDarkNight.instance.drawerActiveColor;
      state.drawerLine = ThemeDarkNight.instance.drawerLine;
    } else {
      state.bgType = ThemeKraftPaper.instance.bgType;
      state.textStyle = ThemeKraftPaper.instance.textStyle;
      state.menuColor = ThemeKraftPaper.instance.menuColor;
      state.menuBg = ThemeKraftPaper.instance.menuBg;
      state.bottomOverlayerColor = ThemeKraftPaper.instance.bottomOverlayerColor;

      state.drawerBg = ThemeKraftPaper.instance.drawerBg;
      state.drawerColorSeTitle = ThemeKraftPaper.instance.drawerColorSeTitle;
      state.drawerColor = ThemeKraftPaper.instance.drawerColor;
      state.drawerActiveColor = ThemeKraftPaper.instance.drawerActiveColor;
      state.drawerLine = ThemeKraftPaper.instance.drawerLine;
    }
    update(["menu", "buildPageView", "updateBg"]);
  }

  //收藏-取消收藏
  cartoonCollcet() async {
    try {
      Map<String, dynamic> data = {"kind": 4, "mediaID": state.mediaInfoEntity.id};
      final novelDetailsLogic = Get.find<NovelDetailsLogic>();
      if (state.mediaInfoEntity.hasCollected) {
        BaseRespBean baseRespBean = await BookApi.cartoonUncollect(data);
        if (baseRespBean.isSuccess) {
          showToast(msg: "取消收藏");
          state.mediaInfoEntity.mediaStatus?.hasCollected = false;
          update(["menu"]);
          novelDetailsLogic.update(['collcet']);
          return;
        }
        showToast(msg: baseRespBean.tip ?? "收藏失败");
      } else {
        BaseRespBean baseRespBean = await BookApi.cartoonCollcet(data);
        if (baseRespBean.isSuccess) {
          showToast(msg: "收藏成功");
          state.mediaInfoEntity.mediaStatus?.hasCollected = true;
          novelDetailsLogic.update(['collcet']);
          update(["menu"]);
          return;
        }
        showToast(msg: baseRespBean.tip ?? "收藏失败");
      }
    } catch (e) {
      showToast(msg: "收藏失败");
    }
  }
}
