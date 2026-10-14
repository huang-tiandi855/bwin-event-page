import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/widgets/space_widget.dart';
import 'package:comics_app/pages/home/home_logic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../common/entities/feature_info.dart';
import '../../../common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'new_logic.dart';

class NewPage extends StatelessWidget {
  const NewPage({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(NewLogic());
    final state = Get.find<NewLogic>().state;

    final homeLogicState = Get.find<HomeLogic>().state;

    List<Widget> lists = [];

    return GetBuilder<NewLogic>(builder: (logic) {

      if(state.featureEntity != null && homeLogicState.homePageSpecialAds.isNotEmpty){

        for (var element in state.featureEntity!.data!.list!) {
          lists.add(getItem(state.featureEntity!.data!.list!.indexOf(element), context, element));
        }

        for (int i = 0; i < lists.length; i++) {
          if ((i + 1) % 2 == 0) {
            lists.insert(i, getHomePageSpecialListAds(i));
          }
        }
      }

      return Container(
        color: AppColor.bgGrey,
        padding: EdgeInsets.only(left: 12.w, right: 12.w),
        child: PullRefreshView(
          controller: state.pullRefreshNewController,
          onLoading: () {
            state.pageNum = state.pageNum! + 1;
            logic.doInit();
          },
          onRefresh: () {
            state.pageNum = 1;
            lists.clear();
            logic.doInit();
          },
          child: CustomScrollView(
            slivers: [
              getSliverHeight(12),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          return Column(

                            children: [

                              getItem(index, context,state.featureEntity?.data?.list![index]),

                              if (homeLogicState.homePageSpecialAds.isNotEmpty) advView(index)

                            ],

                          );
                    }, childCount: state.featureEntity?.data?.list?.length),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget getItem(int index, BuildContext context, ListElement? listElement,) {
    switch (listElement?.direction!) {
      case 0:
        return getThreeCover(index, listElement,
            isFreeZone: true, banner: state.banner,linkName: "首页-热更-${listElement!.name}");
      case 1:
        return getSixCover(
          index,
          context,
          listElement,
          banner: state.banner,
            linkName: "首页-热更-${listElement!.name}"
        );
      case 2:
        return getVerticalFourCover(
          index,
          context,
          listElement,
          banner: state.banner,
            linkName: "首页-热更-${listElement!.name}"
        );
      case 3:
        return getHorizonalFourCover(
          index,
          context,
          listElement,
          banner: state.banner,
            linkName: "首页-热更-${listElement!.name}"
        );
      case 4:
        return getHorizonalFiveCover(
          context,
          listElement,
          banner: state.banner,
            linkName: "首页-热更-${listElement!.name}"
        );
      case 5:
        return getHorizonalSixCover(
          context,
          listElement,
          banner: state.banner,
            linkName: "首页-热更-${listElement!.name}"
        );

      default:
        return getSixCover(
          index,
          context,
          listElement,
          banner: state.banner,
            linkName: "首页-热更-${listElement!.name}"
        );
    }
  }
}
