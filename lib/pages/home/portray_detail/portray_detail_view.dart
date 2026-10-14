import 'package:comics_app/common/widgets/empty_widget.dart';
import 'package:comics_app/common/widgets/loading_widget.dart';
import 'package:comics_app/pages/home/portray_detail/buildPortrayMenu.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'build_portray_view.dart';
import 'portray_detail_logic.dart';

class PortrayDetailPage extends StatelessWidget {
  final logic = Get.find<PortrayDetailLogic>();
  final state = Get.find<PortrayDetailLogic>().state;

  PortrayDetailPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PortrayDetailLogic>(builder: (logic) {
      return Theme(
        data: ThemeData(
          bottomSheetTheme: const BottomSheetThemeData(backgroundColor: Colors.transparent),
        ),
        child: Scaffold(
          //backgroundColor: const Color.fromRGBO(27, 22, 76, 1),
          backgroundColor: Colors.black,
          /*appBar: AppBar(
            backgroundColor: const Color.fromRGBO(27, 22, 76, 1),
            title: Text(
                logic.state.mediaInfo == null ? "" : "${logic.state.mediaInfo!.data!.title}[${logic.state.mediaInfo!.data!.contents![0].urlSet!.length}P]"),
          ),*/

          body: logic.state.mediaInfo == null
              ? const LoadingWidget()
              : logic.state.mediaInfo?.data?.contents.isNotEmpty != true
                  ? const EmptyWidget()
                  : Stack(
                      children: [
                        GestureDetector(
                          onTap: () {
                            logic.onTap();
                          },
                          child: PortrayBuildVIew(
                            logic.state.mediaInfo!.data!.contents[0],
                            state.scrollController,
                            key: UniqueKey(),
                          ),

                          /*child: SingleChildScrollView(
                        controller: state.scrollController,
                        child: Column(
                          children: logic
                              .state.mediaInfo!.data!.contents![0].urlSet!
                              .map((e) {
                            return VisibilityDetector(
                              key: UniqueKey(),
                              onVisibilityChanged: (VisibilityInfo info) {
                                 if(info.visibleFraction == 0){

                                   PaintingBinding.instance.imageCache.clear();

                                   CachedNetworkImage.evictFromCache(getPath(e)).then((value) {
                                     if(value){
                                       debugPrint("evictFromCache------$value");
                                     }
                                   });
                                 }
                              },
                              child: CustomImage(
                                  url: e,
                                  widthAndHeightAdaptive: true,
                                  loadingAndErrorWidget: SizedBox(
                                    height: 400.w,
                                    child: LoadingWidget(),
                                  )),
                            );
                          }).toList(),
                        ),
                      ),*/

                          /*child:  CarouselSlider(
                        options: CarouselOptions(
                            viewportFraction: 1,
                            height: ScreenUtil().screenHeight,
                            scrollDirection: Axis.vertical),
                        items: logic.state.mediaInfo!.data!.contents![0].urlSet!
                            .map((e) {
                          return CustomImage(
                            url: e,
                            fit: BoxFit.contain,
                          );
                        }).toList(),
                      ),*/
                        ),
                        GetBuilder<PortrayDetailLogic>(
                            id: 'menu',
                            builder: (logic) {
                              return Obx(() {
                                return buildMenuMenu();
                              });
                            })
                      ],
                    ),

          /*body: ListView.builder(
          itemCount: logic.state.mediaInfo!.data!.contents![0].urlSet!.length,
          itemBuilder: (BuildContext context, int index) {
            String url = logic.state.mediaInfo!.data!.contents![0].urlSet![index];
            return CustomImage(
                url: url,
                widthAndHeightAdaptive: true,
                loadingAndErrorWidget: SizedBox(
                  height: 400.w,
                  child: LoadingWidget(),
                ));
          },
        ),*/

          /*bottomSheet: Theme(
              data: ThemeData(
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                primaryColor: const Color.fromRGBO(27, 22, 76, 1),
                backgroundColor:  const Color.fromRGBO(27, 22, 76, 1),
                bottomSheetTheme: const BottomSheetThemeData(
                    backgroundColor: Colors.transparent),
              ),
              child: Container(
                height: 60.w,
                color: const Color.fromRGBO(27, 22, 76, 1),
                padding: EdgeInsets.only(left: 24.w, right: 24.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: (){
                        logic.lastPortray();
                      },
                      child: Row(
                        children: [
                          Image.asset(
                            "assets/images/png/portray_left.png",
                            width: 7.w,
                            height: 8.6.w,
                          ),
                          getWidth(12),
                          Text(
                            "上一篇",
                            style: TextStyle(
                                color: const Color.fromRGBO(208, 206, 227, 1),
                                fontSize: 15.w),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: (){
                        logic.nextPortray();
                      },
                      child: Row(
                        children: [
                          Text(
                            "
                            下一篇",
                            style: TextStyle(
                                color: const Color.fromRGBO(208, 206, 227, 1),
                                fontSize: 15.w),
                          ),
                          getWidth(12),
                          Image.asset(
                            "assets/images/png/portray_right.png",
                            width: 7.w,
                            height: 8.6.w,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),*/
        ),
      );
    });
  }

  Widget buildMenuMenu() {
    if (!state.isMenuVisiable.value) {
      return Container();
    }
    return PortrayBuildMenu(
      onTap: logic.hideMenu,
      //mediaInfoContents: logic.state.mediaInfo!.data!.title.toString(),
      mediaInfoContents: state.title.toString(),
    );
  }
}
