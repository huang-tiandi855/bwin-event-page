import 'dart:async';
import 'dart:math';

import 'package:comics_app/common/apis/acg_api.dart';
import 'package:comics_app/common/apis/bookShelf.dart';
import 'package:comics_app/common/entities/media_info_entity.dart';
import 'package:comics_app/common/entities/module_detail_model/all_media_info_model.dart';
import 'package:comics_app/common/entities/module_detail_model/content_model.dart';
import 'package:comics_app/common/entities/module_detail_model/content_model_extension.dart';
import 'package:comics_app/common/entities/readerChapterModel.dart';
import 'package:comics_app/common/http/base_resp_bean.dart';
import 'package:comics_app/common/utils/screen.dart';
import 'package:comics_app/common/utils/toast_util.dart';
import 'package:comics_app/common/values/enum.dart';
import 'package:comics_app/common/widgets/golden_beans_buying.dart';
import 'package:comics_app/common/widgets/memberPaying.dart';
import 'package:comics_app/pages/bookshelf/novel_details/novel_details_logic.dart';
import 'package:comics_app/pages/bookshelf/reader/widget/reader_bg.dart';
import 'package:comics_app/pages/bookshelf/reader/widget/reader_config.dart';
import 'package:comics_app/pages/bookshelf/reader/widget/reader_page_agent.dart';
import 'package:comics_app/pages/bookshelf/reader/widget/reader_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../common/utils/utils.dart';
import 'reader_wrap_state.dart';

import 'package:comics_app/common/utils/logger.dart';

class ReaderWrapLogic extends GetxController {
  final state = ReaderWrapState();

  @override
  void onInit() {
    state.lastChapter = Get.arguments['index'] + 1;
    state.mediaInfoEntity = Get.arguments['data'];
    state.directory = {
      for (var element in state.mediaInfoEntity.contents)
        element.episodeNumber!: ReaderChapterModel(
          id: element.id ?? '',
          index: 0,
          mediaID: element.mediaId ?? '',
          episodeNumber: element.episodeNumber ?? 1,
          listenPermission: element.listenPermission ?? 1,
          price: element.price ?? 0,
          name: element.name ?? '',
          text: '',
          status: state.mediaInfoEntity.status ?? 1,
          isActive: true,
          hasPaid: element.hasPaid,
          pageOffsets: [
            {'start': 0, 'end': 0}
          ],
        )
    };
    // state.page = state.chapterIndex > 1 ? 1 : 0;
    state.page = 0; //state.chapterIndex == 1 ? 0 : 1;
    state.pageController = PageController(initialPage: state.page);
    state.pageController.addListener(onChangListener);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    state.topSafeHeight = Screen.topSafeHeight;
    state.bottomSafeHeight = Screen.bottomSafeHeight;
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();

    loadChapter(state.lastChapter);
  }

  @override
  void onClose() {
    HistoryOperation.getInstance()?.addAllMedia(
        info: state.mediaInfoEntity, episode: state.currentChapter - 1);
    state.pageController.removeListener(onChangListener);
    state.pageController.dispose();
    super.onClose();
  }

  Future<void> onChangListener() async {
    int page = state.pageController.page!.round();
    final prev = page < state.page;
    if (state.page != page) {
      state.page = page;
      if (state.renderList.elementAt(page) == null) {
        printInfo(info: "==ddd==currentChaper===>${state.currentChapter}");
        final chapter = prev
            ? max(state.mediaInfoEntity.contents.first.episodeNumber!,
                state.currentChapter - 1)
            : min(state.mediaInfoEntity.contents.last.episodeNumber!,
                state.currentChapter + 1);
        printInfo(info: "==ddd==currentChaper===>$chapter");
        loadChapter(chapter);
      } else {
        state.lastChapter = state.currentChapter;
        printInfo(info: "====currentChaper===>${state.currentChapter}");
        checkPlayPermission(
          state.mediaInfoEntity.contents[state.currentChapter - 1],
          true,
        );
      }
    }
  }

  onToggleChapter(int index) async {
    final chapter = index + 1;

    if (chapter == state.currentChapter) {
      return;
    }

    Get.back();

    final renderIndex = state.renderList.indexWhere(
      (element) => (element?.episodeNumber == chapter && element?.index == 0),
    );

    if (renderIndex == -1) {
      state.pageController.removeListener(onChangListener);
      state.lastChapter = chapter;
      // 没有加载过
      final page =
          chapter > state.currentChapter ? state.renderList.length - 1 : 0;
      state.pageController.animateToPage(
        page,
        duration: const Duration(microseconds: 300),
        curve: Curves.linear,
      );
      loadChapter(chapter);
    } else {
      state.pageController.animateToPage(
        renderIndex,
        duration: const Duration(microseconds: 300),
        curve: Curves.linear,
      );
    }
    update(["menu"]);
  }

  setDirectoryReverseOrder() {
    state.directoryReverseOrder = !state.directoryReverseOrder;
    update(["menu"]);
  }

  void hideMenu() {
    state.isMenuVisiable.value = false;
    update(["menu"]);
  }

  void showMenu() {
    state.isMenuVisiable.value = true;
    update(["menu"]);
  }

  //打开目录
  void openDrawer() {
    state.scaffoldKey.currentState?.openEndDrawer();
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
      state.bottomOverlayerColor =
          ThemeKraftPaper.instance.bottomOverlayerColor;

      state.drawerBg = ThemeKraftPaper.instance.drawerBg;
      state.drawerColorSeTitle = ThemeKraftPaper.instance.drawerColorSeTitle;
      state.drawerColor = ThemeKraftPaper.instance.drawerColor;
      state.drawerActiveColor = ThemeKraftPaper.instance.drawerActiveColor;
      state.drawerLine = ThemeKraftPaper.instance.drawerLine;
    }
    update(["menu", "buildPageView", "updateBg"]);
  }

  void cartoonCollcet() async {
    try {
      Map<String, dynamic> data = {
        "kind": 4,
        "mediaID": state.mediaInfoEntity.id
      };
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

  Future<bool> checkPlayPermission(ContentModel media,
      [bool refresh = false]) async {
    int needPermission = media.needPermission;
    if (needPermission == 0 || needPermission == 1) {
      var value = await onTapProductPrice(media);
      if (value == PaySuccess.successfulPurchase ||
          value == PaySuccess.exchangeSuccessFullly ||
          value == PaySuccess.successfulAllEsp) {
        if (value == PaySuccess.exchangeSuccessFullly) {
          media.mediaStatus?.hasPaid = true;
        } else {
          // 清除未付费章节
          for (var i = 0; i < state.mediaInfoEntity.contents.length; i++) {
            final e = state.mediaInfoEntity.contents[i];
            if (e.mediaStatus?.hasPaid == false) {
              state.data.remove(e.episodeNumber);
            }
            e.mediaStatus?.hasPaid = true;
          }
        }
        if (refresh) {
          loadChapter(state.currentChapter, true);
        }
        return true;
      }
      return Future.value(false);
    }
    return Future.value(true);
  }

  //获取详情
  Future<void> getMediaInfo(PaySuccess paySuccess, ContentModel media) async {
    try {
      Map<String, dynamic> data = {"mediaID": state.mediaInfoEntity.id};
      BaseRespBean baseRespBean = await BookApi.getMediaInfo(data);
      if (baseRespBean.isSuccess) {
        AllMediaInfoModel mediaInfoEntity =
            AllMediaInfoModel.fromJson(baseRespBean.data);
        state.mediaInfoEntity = mediaInfoEntity;
        state.data = {};
        update();
      }
    } finally {}
  }

  Future<dynamic> onTapProductPrice(ContentModel media) {
    if (state.isShowDialog) {
      return Future.value(null);
    }

    int needPermission = media.needPermission;
    // final videoInfo = state.info!;
    if (needPermission == 0 || needPermission == 1) {
      if (needPermission == 0) {
        state.isShowDialog = true;
        return openMemberPaying(
          isShowCoupon: true,
          id: state.mediaInfoEntity.id,
          productType: 28,
          chatId: media.id,
        ).then((value) {
          state.isShowDialog = false;
          return value;
        });
      } else {
        state.isShowDialog = true;
        return openGoldenBeansBuying(
          id: state.mediaInfoEntity.id!,
          price: state.mediaInfoEntity.price ?? 0,
          productType: 28,
          isShowCoupon: true,
          chapId: media.id,
        ).then((value) {
          state.isShowDialog = false;
          return value;
        });
      }
    }
    return Future.value(null);
  }

  Future<void> _loadData(int chapter) async {
    final media = state.mediaInfoEntity.contents[chapter - 1];

    final id = media.id;
    await ACGApi.getNovalContent(id!).then((value) {
      return formatArticle(
          ReaderChapterModel.fromJson(MediaInfoContents.fromJson(value.data)));
    }).then((value) {
      state.data[chapter] = List.generate(value.pageCount, (index) {
        return ReaderChapterModel(
          id: value.id,
          index: index,
          mediaID: value.mediaID,
          episodeNumber: value.episodeNumber,
          listenPermission: value.listenPermission,
          price: value.price,
          name: value.name,
          text: value.text,
          status: value.status,
          isActive: value.isActive,
          hasPaid: media.hasPaid,
          pageOffsets: value.pageOffsets,
        );
      });
    });
  }

  Future<void> loadChapter(int chapter, [bool refresh = false]) async {
    if (state.data.containsKey(chapter) && !refresh) {
      return;
    }
    printInfo(info: "====loadChapter===>$chapter");
    final media = state.mediaInfoEntity.contents[chapter - 1];
    final hasPermission = await checkPlayPermission(media);

    Completer<void> completer = Completer<void>();

    if (!hasPermission) {
      state.data[chapter] = [state.directory[chapter]!];
      completer.complete();
    } else {
      _loadData(chapter).then((v) {
        completer.complete();
      });
    }

    completer.future.then((value) {
      var sortedEntries = state.data.entries.toList();

      // key排序
      sortedEntries.sort((entry1, entry2) => entry1.key.compareTo(entry2.key));

      state.data = {
        for (var element in sortedEntries) element.key: element.value
      };
      // 移除监听器
      state.pageController.removeListener(onChangListener);
      update(['buildPageView']);

      final renderIndex = state.renderList.indexWhere(
        (element) => element?.episodeNumber == chapter && element?.index == 0,
      );
      if (chapter < state.lastChapter) {
        l.d('往前加载');
        state.page = renderIndex + (state.data[chapter]?.length ?? 0) - 1;
      } else {
        state.page = renderIndex;
        l.d('往后加载');
      }
      state.pageController.jumpToPage(state.page);
      state.lastChapter = chapter;
      state.pageController.addListener(onChangListener);
      l.d((state.renderList).toString());
    });
  }

  ReaderChapterModel formatArticle(ReaderChapterModel model) {
    var contentHeight = Screen.height -
        state.topSafeHeight -
        ReaderUtils.topOffset -
        state.bottomSafeHeight -
        ReaderUtils.bottomOffset -
        ReaderConfig.instance.fontSize;

    var contentWidth = Screen.width - 15.w - 15.w;
    model.pageOffsets = ReaderPageAgent.getPageOffsets(
      model.text,
      contentHeight,
      contentWidth,
      ReaderConfig.instance.fontSize,
    );
    return model;
  }
}
