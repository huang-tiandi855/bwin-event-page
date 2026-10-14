import 'package:comics_app/common/style/style.dart';
import 'package:comics_app/common/utils/date_util.dart';
import 'package:comics_app/pages/loading/loading_center_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../common/utils/utils.dart';
import '../../../common/widgets/common_ui/common_ui.dart';
import 'package:comics_app/pages/image/network/custom_image_network.dart';
import 'welfare_details_logic.dart';

class WelfareDetailsPage extends StatelessWidget {
  WelfareDetailsPage({Key? key}) : super(key: key);

  final logic = Get.find<WelfareDetailsLogic>();
  final state = Get.find<WelfareDetailsLogic>().state;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WelfareDetailsLogic>(
        id: "detail",
        builder: (logic) {
          return Scaffold(
            appBar: commonAppBar(state.annouList?.title ?? "活动详情"),
            body: state.annouList == null
                ? const LoadingCenterWidget()
                : Container(
                    color: AppColor.bgGrey,
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: AppLocation.appHorizontal),
                            child: GetBuilder<WelfareDetailsLogic>(
                                builder: (logic) {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 12.w),
                                  CustomImage(
                                    height: 140.w,
                                    url: state.annouList?.cover ?? "",
                                    // borderRadius: BorderRadius.circular(6.w),
                                  ),
                                  SizedBox(height: 12.w),
                                  Text(state.annouList?.content ?? "",
                                      style: TextStyle(
                                          color: AppColor.black,
                                          fontSize: 15.sp)),
                                  SizedBox(height: 20.w),
                                  Text(
                                      DataFormats.formatDateYMD(
                                          state.annouList?.time ?? ""),
                                      style: TextStyle(
                                          fontSize: 12.sp,
                                          color: AppColor.warmGrey)),
                                  const SizedBox(height: 80),
                                ],
                              );
                            }),
                          ),
                        ),
                        Align(
                            alignment: Alignment.bottomCenter,
                            child: GestureDetector(
                              onTap: () {
                                AppNavigator.to.jumpAdv(
                                    url: state.annouList?.href ?? '',
                                    id: state.annouList?.id ?? '',
                                    title: state.annouList?.href ?? '',
                                    isStatistics: false, planId: '', slotCode: '');
                              },
                              child: Container(
                                height: 44.w,
                                width: 280.w,
                                margin: const EdgeInsets.only(bottom: 24),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: AppColor.bluishPurple,
                                    borderRadius: BorderRadius.circular(42.w)),
                                child: Text('立即参与',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18.sp)),
                              ),
                            ))
                      ],
                    ),
                  ),
          );
        });
  }
}
