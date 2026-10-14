import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../common/entities/readerChapterModel.dart';
import 'reader_logic.dart';
import 'widget/directoryDrawer.dart';
import 'widget/reader_bg.dart';
import 'widget/reader_menu.dart';
import 'widget/reader_view.dart';

class ReaderPage extends StatelessWidget {
  ReaderPage({Key? key}) : super(key: key);

  final logic = Get.find<ReaderLogic>();
  final state = Get.find<ReaderLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: state.scaffoldKey,
      endDrawer: GetBuilder<ReaderLogic>(
          id: "menu",
          builder: (logic) {
            return drawer(
                state.readerList,
                state.curChapterNum,
                state.mediaInfoEntity.title,
                state.directoryReverseOrder,
                logic.onToggleChapter,
                logic.hideMenu,
                logic.setDirectoryReverseOrder,
                drawerColor: state.drawerColor,
                drawerActiveColor: state.drawerActiveColor,
                drawerBg: state.drawerBg,
                drawerColorSeTitle: state.drawerColorSeTitle,
                drawerLine: state.drawerLine,
                context: context);
          }),
      drawerEdgeDragWidth: 0.0,
      body: AnnotatedRegion(
        value: SystemUiOverlayStyle.dark,
        child: Stack(
          children: [
            GetBuilder<ReaderLogic>(
                id: "updateBg",
                builder: (logic) {
                  return ReaderBg(bgType: state.bgType);
                }),
            GetBuilder<ReaderLogic>(
                id: "buildPageView",
                builder: (logic) {
                  return buildPageView();
                }),
            GetBuilder<ReaderLogic>(
                id: "menu",
                builder: (logic) {
                  return Obx(() => buildMenu());
                })
          ],
        ),
      ),
    );
  }

  Widget buildMenu() {
    if (!state.isMenuVisiable.value) {
      return Container();
    }
    return ReaderMenu(
      articleIndex: state.curChapterNum,
      chapters: state.readerList,
      onPreviousArticle: logic.onPreviousArticle,
      onNextArticle: logic.onNextArticle,
      onToggleChapter: (int index) => {logic.onToggleChapter(index)},
      updateNightDay: logic.updateNightDay,
      bgType: state.bgType,
      menuBg: state.menuBg,
      menuColor: state.menuColor,
      onTap: logic.hideMenu,
    );
  }

  Widget buildPage(BuildContext context, int index) {
    int page =
        index - (state.preArticle != null ? state.preArticle!.pageCount : 0);
    ReaderChapterModel? readerChapterModel;
    if (page >= state.currentArticle!.pageCount) {
      //已经到达下一章
      readerChapterModel = state.nextArticle;
      page = 0;
    } else if (page < 0) {
      //已经到达上一章
      readerChapterModel = state.preArticle;
      page = state.preArticle!.pageCount - 1;
    } else {
      readerChapterModel = state.currentArticle;
    }
    return GestureDetector(
      onTapUp: (TapUpDetails details) {
        logic.onTap(details.globalPosition);
      },
      child: ReaderView(
          page: page,
          topSafeHeight: state.topSafeHeight,
          textStyle: state.textStyle,
          bottomOverlayerColor: state.bottomOverlayerColor,
          article: readerChapterModel),
    );
  }

  Widget buildPageView() {
    if (state.currentArticle == null) {
      return Container();
    }
    int itemCount =
        (state.preArticle != null ? state.preArticle!.pageCount : 0) +
            state.currentArticle!.pageCount +
            (state.nextArticle != null ? state.nextArticle!.pageCount : 0);

    return GestureDetector(
      onHorizontalDragEnd: (DragEndDetails details) {
        logic.checkPlayPermission();
      },
      child: PageView.builder(
          physics: state.isPlay
              ? const BouncingScrollPhysics()
              : const NeverScrollableScrollPhysics(),
          controller: state.pageController,
          itemCount: itemCount,
          itemBuilder: buildPage,
          onPageChanged: logic.onPageChanged),
    );
  }
}
