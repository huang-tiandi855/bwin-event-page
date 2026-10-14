import 'package:comics_app/common/utils/screen.dart';
import 'package:comics_app/common/widgets/keep_alive_widget.dart';
import 'package:comics_app/pages/bookshelf/reader/widget/directoryDrawer.dart';
import 'package:comics_app/pages/bookshelf/reader/widget/reader_view.dart';
import 'package:comics_app/pages/loading/loading_center_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../widget/reader_bg.dart';
import 'reader_menu.dart';
import 'reader_wrap_logic.dart';
import 'reader_wrap_state.dart';

class ReaderWrapPage extends StatelessWidget {
  const ReaderWrapPage({super.key});

  ReaderWrapLogic get logic => Get.find();

  ReaderWrapState get state => logic.state;

  @override
  Widget build(BuildContext context) {
    Get.put(ReaderWrapLogic());
    return Scaffold(
      key: state.scaffoldKey,
      endDrawer: GetBuilder<ReaderWrapLogic>(
          id: "menu",
          builder: (logic) {
            return drawer(
              state.directory.values.toList(),
              state.currentChapter,
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
              context: context,
            );
          }),
      drawerEdgeDragWidth: 0.0,
      body: Stack(
        children: [
          GetBuilder<ReaderWrapLogic>(
            id: "updateBg",
            builder: (logic) {
              return ReaderBg(bgType: state.bgType);
            },
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              logic.showMenu();
            },
            child: NotificationListener(
              onNotification: state.pageViewScrollUtils.handleNotification,
              child: GetBuilder<ReaderWrapLogic>(
                id: "buildPageView",
                builder: (logic) {
                  // if (state.data.isEmpty) {
                  //   return const LoadingCenterWidget();
                  // }
                  return PageView.builder(
                    controller: state.pageController,
                    itemCount: state.renderList.length,
                    itemBuilder: (context, index) {
                      final e = state.renderList[index];
                      if (e == null) {
                        return const LoadingCenterWidget();
                      }
                      return KeepAliveWidget(
                        ReaderView(
                          page: e.index ?? 0,
                          topSafeHeight: Screen.topSafeHeight,
                          textStyle: state.textStyle,
                          bottomOverlayerColor: state.bottomOverlayerColor,
                          article: e,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          GetBuilder<ReaderWrapLogic>(
            id: "menu",
            builder: (logic) {
              return Obx(() => buildMenu());
            },
          )
        ],
      ),
    );
  }

  Widget buildMenu() {
    if (!state.isMenuVisiable.value) {
      return IgnorePointer(child: Container());
    }
    return ReaderMenu(
      articleIndex: state.currentChapter,
      chapters: state.directory.values.toList(),
      onPreviousArticle: () {},
      onNextArticle: () {},
      onToggleChapter: (int index) => {},
      updateNightDay: logic.updateNightDay,
      bgType: state.bgType,
      menuBg: state.menuBg,
      menuColor: state.menuColor,
      onTap: logic.hideMenu,
    );
  }
}
