import 'package:comics_app/common/routers/app_routes.dart';
import 'package:comics_app/common/style/color.dart';
import 'package:comics_app/common/style/location.dart';
import 'package:comics_app/common/widgets/common_ui/common_ui.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../common/widgets/pullRefreshView/pull_refresh_view.dart';
import 'welfare_logic.dart';

class WelfarePage extends StatelessWidget {
  WelfarePage({Key? key}) : super(key: key);

  final logic = Get.put(WelfareLogic());
  final state = Get.find<WelfareLogic>().state;

  @override
  Widget build(BuildContext context) {
    //Get.find<WelfareLogic>();
    //final state = Get.find<WelfareLogic>().state;

    return Scaffold(
      appBar: commonAppBar('福利中心'),
      body: GetBuilder<WelfareLogic>(builder: (logic) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: AppLocation.appHorizontal),
          child: PullRefreshView(
            retryOnTap: () async {
              logic.onRefresh();
            },
            controller: state.pullRefreshController,
            child: _item(state),
            onRefresh: () async {
              logic.onRefresh();
            },
            onLoading: () async {
              logic.onLoad();
            },
          ),
        );
      }),
    );
  }

  //item
  Widget _item(state) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      itemBuilder: (BuildContext context, int index) {
        String cover = state.annouList?[index].cover ?? "";
        return GestureDetector(
          onTap: () => Get.toNamed(AppRoutes.WELFARE_DETAILS,
              arguments: {'annouList': state.annouList[index]}),
          child: Column(
            children: [




              Container(
                  margin: EdgeInsets.only(top: 12.r),
                  alignment: Alignment.centerLeft,
                  child: Text(
                    state.annouList?[index].title ?? "",
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppColor.black,
                        fontSize: 18.sp),
                  )),




              Container(
                margin: EdgeInsets.only(top: 12.w),
                height: 141.w,
                child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(10.w)),
                  child: CustomImage(
                    url: cover,
                    // borderRadius: BorderRadius.circular(6.w),
                  ),
                ),
              ),
            ],
          ),
        );
      },
      itemCount: state.annouList.length,
    );
  }
}
