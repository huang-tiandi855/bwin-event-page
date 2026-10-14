import 'package:comics_app/common/style/style.dart';
import 'package:comics_app/pages/bookshelf/comic_reading/widget/buildMenu.dart';
import 'package:comics_app/pages/bookshelf/comic_reading/widget/buildView.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'comic_reading_logic.dart';

import 'package:comics_app/common/utils/logger.dart';

class ComicReadingPage extends StatefulWidget {
  const ComicReadingPage({super.key});

  @override
  State<ComicReadingPage> createState() => _ComicReadingPageState();
}

class _ComicReadingPageState extends State<ComicReadingPage> {
  final logic = Get.find<ComicReadingLogic>();
  final state = Get.find<ComicReadingLogic>().state;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColor.whiteBackground,
        key: state.scaffoldKey,
        body: AnnotatedRegion(
          value: SystemUiOverlayStyle.light,
          child: GetBuilder<ComicReadingLogic>(
              id: 'list',
              builder: (logic) {
                l.d('BuildContext    $logic');
                return Stack(
                  children: [
                    GestureDetector(
                      onTap: () => logic.onTap(),
                      child: GestureDetector(
                        onScaleUpdate: (ScaleUpdateDetails details) {
                          logic.scaleUpdate(details.scale);
                        },
                        child: ComicBuildVIew(
                            state.mediaInfoContents, state.scrollController,
                            key: UniqueKey()),
                      ),
                    ),
                    GetBuilder<ComicReadingLogic>(
                        id: 'menu',
                        builder: (logic) {
                          return Obx(() {
                            return buildMenuMenu();
                          });
                        }),
                  ],
                );
              }),
        ));
  }

  Widget buildMenuMenu() {
    if (!state.isMenuVisiable.value) {
      return Container();
    }
    return ComicBuildMenu(
      title: state.mediaInfoEntity?.title,
      mediaInfoContents: state.mediaInfoContents,
      hasCollected: state.mediaInfoEntity?.hasCollected ?? false,
      onTap: logic.hideMenu,
    );
  }
}
