import 'package:comics_app/common/widgets/general_widget/common_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../common/routers/app_routes.dart';
import '../../../common/store/user.dart';
import '../../../common/widgets/acg_section/acg_media_grid_layout_view.dart';
import '../../../common/widgets/space_widget.dart';
import '../abs_origin_view.dart';
import 'vip_logic.dart';

class VipPage extends AbsOriginListView<VipLogic> {
  String id;

  VipPage({required this.id, Key? key}) : super(key: key);

  @override
  VipLogic createController() {
    return Get.put(VipLogic(id: id), tag: obtainTag());
  }

  @override
  createListBody(VipLogic controller) {
    return Stack(
      children: [
        CustomScrollView(slivers: [
          SliverList(
            delegate:
                SliverChildBuilderDelegate((BuildContext context, int index) {
              var item = controller.state.dataList[index];
              return Column(
                children: [
                  20.verticalSpace,
                  getTitle(item, hPadding: 10.w),
                  MediaGridLayoutView(
                    showType: item.showType,
                    medias: item.allMediaInfo,
                    isOriginModule: true,
                  )
                ],
              );
            }, childCount: controller.state.dataList.length),
          )
        ]),
        if (!UserStore.to.isVip())
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.699999988079071),
            ),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              textSpans([
                textSpan('温馨提示\n\n', Colors.white, 20, FontWeight.w400),
                textSpan('该专题为', Colors.white, 20, FontWeight.w400),
                textSpan('VIP免费', const Color(0xff56faf6), 20, FontWeight.w400),
                textSpan('专享\n', Colors.white, 20, FontWeight.w400),
                textSpan('您还不是会员 无法观看 \n\n', Colors.white, 20, FontWeight.w400),
                textSpan('开通会员 即可解锁免费观看', Colors.white, 14, FontWeight.w400),
              ], maxLines: 7, textAlign: TextAlign.center),
              GestureDetector(
                  onTap: () {
                    // openMemberPaying(
                    //   isShowCoupon: false,
                    //   isBottomSheet:false,
                    //   width: 300.w
                    // );
                    Get.toNamed(AppRoutes.MEMBER_CENTER)?.then((value) {});
                  },
                  child: Container(
                      alignment: Alignment.center,
                      width: 178.w,
                      height: 37.w,
                      margin: EdgeInsets.only(top: 21.w),
                      decoration: ShapeDecoration(
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Text(
                        '开通会员',
                        style: TextStyle(
                          color: Color(0xFFB09FD9),
                          fontSize: 14,
                          fontFamily: 'Dream',
                          fontWeight: FontWeight.w900,
                        ),
                      )))
            ]),
          )
      ],
    );
  }

  @override
  String obtainTag() {
    return 'VipPage';
  }
}
