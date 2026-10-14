import 'package:comics_app/common/res/r.dart';
import 'package:comics_app/common/store/store.dart';
import 'package:comics_app/common/utils/ads_manage/ads_banner_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../../common/utils/ads_manage/getAdv.dart';
import 'splash_logic.dart';

class SplashPage extends StatelessWidget {
  SplashPage({Key? key}) : super(key: key);

  final logic = Get.find<SplashLogic>();
  final state = Get.find<SplashLogic>().state;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    double t36 = size.width > 520 ? 36.0 : 36.w;
    double w18 = size.width > 520 ? 18.0 : 18.w;

    ///预缓存背景图片
    precacheImage(const AssetImage(R.splash), context);
    return Scaffold(
      body: Container(
        alignment: Alignment.center,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Stack(
            alignment: AlignmentDirectional.center,
            fit: StackFit.loose,
            children: [
              GetBuilder<SplashLogic>(builder: (logic) {
                return state.adsList == null || state.adsList!.isEmpty
                    ? Image.asset(
                        R.splash,
                        fit: BoxFit.fill,
                        width: double.infinity,
                        height: double.infinity,
                        gaplessPlayback: true,
                        excludeFromSemantics: true,
                      )
                    : AdsBannerWidget(
                        adsType: AdsType.openScreen,
                        ads: state.adsList,
                        width: ScreenUtil().screenWidth,
                        height: ScreenUtil().screenHeight,
                      );
              }),
              Positioned(
                  top: t36,
                  right: w18,
                  child: Obx(() => Offstage(
                        offstage: state.countdownTime.value == 6,
                        child: GestureDetector(
                          onTap: () {
                            if (state.countdownTime.value > 0) return;
                            logic.goToApplication();
                          },
                          child: Container(
                              width: 66.w,
                              height: 31.w,
                              constraints: const BoxConstraints(
                                  maxWidth: 90, maxHeight: 40),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(15.5.w))),
                              child: Text(
                                state.countdownTime.value > 0
                                    ? state.countdownTime.value.toString()
                                    : '进入',
                                style: TextStyle(
                                    fontSize: (state.countdownTime.value > 0)
                                        ? 22.sp
                                        : 15.sp,
                                    color: Colors.white),
                              )),
                        ),
                      ))),
              Positioned(
                  bottom: w18,
                  right: w18,
                  child: GetBuilder<ConfigStore>(builder: (logic) {
                    return Offstage(
                      offstage: ConfigStore.to.version == '',
                      child: Text(
                        "v${ConfigStore.to.version}",
                        style: TextStyle(color: Colors.red, fontSize: 12.sp),
                      ),
                    );
                  })),
              _loadingDataWidget(context, state.isDetectLineLoading, '线路检查中',
                  key: const Key('line')),
              _loadingDataWidget(context, state.isGetConfigLoading, '数据配置中',
                  key: const Key('config')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _loadingDataWidget(BuildContext context, RxBool status, String text,
      {Key? key}) {
    final size = MediaQuery.of(context).size;
    double t26 = size.width > 520 ? 26.0 : 26.w;
    double w10 = size.width > 520 ? 12.0 : 10.w;
    double w8 = size.width > 520 ? 8.0 : 8.w;
    return Obx(
        () => Offstage(
              offstage: status.value,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: t26),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      LoadingAnimationWidget.inkDrop(
                        color: Colors.white,
                        size: 26,
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: w8),
                        child: Text(text,
                            style: TextStyle(
                                fontSize: w10, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                ),
              ),
            ),
        key: key);
  }
}
